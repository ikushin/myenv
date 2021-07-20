#!/usr/bin/perl

#   (c) 2017 Ikeda Tomoyuki

use strict;
use warnings;
use utf8;

$| = 1;

my $buffer = OrderedHash->new();

while(<>)
{
    chomp();

    #    0     1    2     3      4      5     6
    my ($mmm, $dd, $hms, $host, $proc, $qid, $msg) = split(/\s+/, $_, 7);

    # or, adjust according to maillog format
    #    0     1    2     3      4      5     6       7
    #my ($mmm, $dd, $hms, $host, $proc, $qid, $level, $msg) = split(/\s+/, $_, 8);

    if($qid !~ /:$/) { next; }  # not like queue-id

    # ID: 'hostname|queue-id'
    my $id = sprintf('%s|%s', $host, $qid); 

    # to=
    if($msg =~ /^to=/)
    {
        my $dt = sprintf("%s %2d %s", $mmm, $dd, $hms); # day, time
        my $log = join(" ", $dt, $host, $proc, $qid, $buffer->get($id));
        $log .= $msg;

        # printf(STDOUT "%s\n", $log);
        print_digest($log);
        next;
    }

    # client=; SMTP session starts
    if($msg =~ /^client=/)
    {
        $buffer->set($msg . ", ", $id);
        next;
    }

    # from=
    if($msg =~ /^from=/)
    {
        if($buffer->get($id) =~ /, from=</) # already set 'from=', must be re-run
        {
            next;
        }
    }

    # other; message-id=, etc...
    $buffer->append($msg . ", ", $id);
}

#======================================================================

sub print_digest
{
    my ($line) = @_;

    # my @fields = split(/\s+/, $line, 7);
    my ($mmm, $dd, $hms, $host, $proc, $qid, $logmsg) = split(/\s+/, $line, 7);

    my ($msgid, $from, $to, $status) = ("", "", "", "");
    $logmsg = ' ' . $logmsg . ' ';  # add a sentinel at first and last

    if($logmsg =~ /\s+(message-id=\S+),\s/)
    {
        $msgid = $1;
    }
    if($logmsg =~ /\s+(from=\S+),\s/)
    {
        $from = $1;
    }
    if($logmsg =~ /\s+(to=\S+),\s/)
    {
        $to = $1;
    }
    if($logmsg =~ /\s+(status=\S+)\s/)
    {
        $status = $1;
    }

    my $dth = sprintf("%s %2d %s %s", $mmm, $dd, $hms, $host);
    printf(STDOUT "%s\n", join("\t", $dth, $qid, $from, $to, $status));
}

#======================================================================

#
# OrderedHash.pm
#
#   (c) 2017 Ikeda Tomoyuki
#
package OrderedHash;

use strict;
use warnings;
use utf8;

use constant DEBUG => 0;


#-----------------------------------------------------------------------
# new() ... create a new OrderedHash instance
#
#   arg:
#       $size   : Buffer Size
#
#   returns: OBJECT (blessed hash reference)
#
# Data Structure:
#
# + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
# ' ring: ARRAY, size = n                                         '
# '                                                               '
# '   +--------------------------------------------------+        '
# '   v                                                  |        '
# ' +------+     +----+     +----+      +-------+     +--------+  '
# ' |  k0  | --> | k1 | --> | k2 | ---> | (...) | --> | k(n-1) |  '
# ' +------+     +----+     +----+      +-------+     +--------+  '
# '   |            |          |                                   '
# + - | - - - - - -|- - - - - | - - - - - - - - - - - - - - - - - +
#     |            |          |
#     |            |          |
# + - | - - - - - -|- - - - - | - - - - - -+
# '   v            v          v    buffer: '
# ' +------+     +----+     +----+    HASH '
# ' |  k0  |     | k1 |     | k2 |         '
# ' +------+     +----+     +----+         '
# '   |            |          |            '
# '   |            |          |            '
# '   v            v          v            '
# ' +------+     +----+     +----+         '
# ' |  v0  |     | v1 |     | v2 |         '
# ' +------+     +----+     +----+         '
# '                                        '
# + - - - - - - - - - - - - - - - - - - - -+
#
sub new
{
    my ($class, $size) = @_;

    if(! defined($size) || $size =~ /[^0-9]/ || $size <= 0)
    {
        $size = 10000;  # default
    }

    my $self = {

        # a hash 'buffer'; KEY-VALUE pair
        # store values with each key (specified, or automatically assigned).
        'buffer'    => {},

        # an array of KEYs in a hash 'buffer'
        # ring[i] = key, i: 0..(size-1)
        'ring'  => [],  

        # size of 'buffer' = (max index for an array 'ring') + 1
        'size'  => $size,

        # write cursor, index for an array 'ring' to write next
        'write_next'    => 0,

    };
    bless $self, $class;

    return $self;
}

#-----------------------------------------------------------------------
# set() ... set a value into OrderedHash
#
#   see append()
#
#   arg:
#       $value  : a value to set, or overwrite OLDEST key-value pair.
#                 Existing value for the key is CLEARed.
#       $key    : a key for value, automatically generated if omitted
#
#   returns:
#       $key    : String
#
sub set
{
    my ($self, $value, $key) = @_;

    if(defined($key) && $self->_isExistKey($key))
    {
        $self->delete($key);
    }

    return $self->append($value, $key);
}

#-----------------------------------------------------------------------
# append() ... append a specified value to existing key-value pair
#
#   set KEY into $self->{ring}->[write_next]
#   set KEY-VALUE pair into $self->{buffer}->{KEY} = VALUE
#
#   arg:
#       $value  : a value to append to existing value for the key,
#                 or overwrite OLDEST key-value pair.
#                 Existing value for the key is NOT cleared and appended.
#       $key    : a key for value, automatically generated if omitted.
#
#   returns:
#       $key    : String
#
#
sub append
{
    my ($self, $value, $key) = @_;

    if(! $self->_isExistKey($key))
    {
        # BRANDNEW KEY! -> into next area in 'ring'
        my $cur = $self->{write_next};

        # if the OLDEST key exists in next area ->delete the oldest data
        if($self->{ring}->[$cur])   
        {
            # delete the corresponding key-value in the 'buffer'.
            $self->delete($self->{ring}->[$cur]);
        }

        # set the key into 'ring', or overwrite the oldest key
        $self->{ring}->[$cur] = $key;
        $self->{buffer}->{$key} = '';

        # write cursor steps ahead.
        $self->{write_next} = ($self->{write_next} + 1) % $self->{size};
    }

    $self->{buffer}->{$key} .= $value;

    return $key;
}


#-----------------------------------------------------------------------
# get() ... get a value at read cursor, or for a specified key
#
#   arg:
#       $key    : a key for the value
#
#   returns
#       $value  : String, maybe null string ''
#
sub get
{
    my ($self, $key) = @_;

    if(! defined($key))
    {
        return '';
    }

    my $value = $self->{buffer}->{$key};
    if(! defined($value))
    {
        $value = '';
    }
    return $value;
}

#-----------------------------------------------------------------------
# delete() ... delete a key-value pair
#
#   arg:
#       $key    : a key for the value to delete
#
#   returns:
#       boolean : 1 ->success, 0 ->FAIL
#
sub delete
{
    my ($self, $key) = @_;

    if(!defined($key)){
        return 0;   # false
    }
    delete($self->{buffer}->{$key});
    return 1;
}

#-----------------------------------------------------------------------
# _isExistKey() ... check wheather a specified key is exists or not.
#
#   arg:
#       $key    : a key for the value to search
#
#   returns:
#       boolean : EXIST -> true / NOT exist -> false
#
sub _isExistKey
{
    my ($self, $key) = @_;

    if(!defined($key)){
        return 0;   # false
    }
    return exists($self->{buffer}->{$key});
}

1;
