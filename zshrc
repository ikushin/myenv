#
# basic options
#
autoload -U compinit
compinit -u
autoload -U colors
colors
setopt hist_ignoreall_dups
setopt hist_save_nodups
setopt share_history

autoload -U edit-command-line
zle -N edit-command-line

autoload -U promptinit
promptinit

autoload -Uz colors
colors

autoload -Uz add-zsh-hook

zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

unsetopt case_glob
setopt auto_resume
setopt nonomatch
setopt magic_equal_subst
setopt auto_pushd
setopt auto_cd
setopt correct
setopt cdable_vars
setopt hist_no_store
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt numeric_globsort
setopt pushd_ignore_dups
setopt notify
setopt always_last_prompt
setopt auto_menu
setopt auto_name_dirs
setopt auto_param_keys
setopt auto_remove_slash
setopt extended_glob
setopt hist_ignore_space
setopt list_types
setopt no_beep
setopt prompt_subst
setopt rm_star_silent
setopt sun_keyboard_hack
setopt transient_rprompt
setopt brace_ccl
#setopt ignore_eof      # ignore logout in crtr-d
unsetopt flow_control   # ignore ctrl-s
unsetopt prompt_cr

# key binds
bindkey -e
bindkey '^O'   edit-command-line
bindkey "^[H"  backward-kill-word
bindkey "^[h"  backward-kill-word
bindkey "^[^H" run-help

bindkey -s "^[g"  '| egrep -v "\^[[:space:]]*(#|$)" '
bindkey -s "^[f"  "| fgrep -v ?"

# git key binds
bindkey -s "^[s"  "git status -s "
bindkey -s "^[l"  "git log -p --ignore-space-change --ignore-all-space --ignore-blank-lines --ignore-space-at-eol --break-rewrites -t "
bindkey -s "^[b"  "git branch "
bindkey -s "^[f"  "git diff --ignore-space-change --ignore-all-space --ignore-blank-lines --ignore-space-at-eol "
bindkey -s "^[c"  'git pull && git commit -a -m "Update"; git push origin master '
bindkey -s "^[v"  "git checkout "
bindkey -s "^[p"  "git push origin master "
bindkey -s "^[z"  "scp .zshrc .zprompt .emacs .screenrc "

# not end of word
#WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
#WORDCHARS='*?[]~=&;!#$%^{}<>'
WORDCHARS='*?[]~&;!#$%^{}<>|'
export WORDCHARS

# history
setopt extended_history
HISTFILE=$HOME/.zhistory
HISTSIZE=100000
SAVEHIST=100000
DIRSTACKSIZE=200

# prompts
#PROMPT='[%n@%{$bg[blue]%}%m%{$reset_color%}]%(#.#.$) '
RPROMPT='[%~]'


# environment variable
LC_ALL=C
LANG=C
cdpath=( $HOME .. )
export EDITOR=vi
export PAGER=less
export LESSCHARSET=utf-8
#export CFLAGS='-g -Wall -Wuninitialized -O'

# convenient variable
host=${HOST%%.*}
today=$( /bin/date +%Y%m%d )
yesterday=`date --date "1 day ago" +%Y%m%d` 2>/dev/null

# man
manpath=( /usr/share/man/ja(N-/) /usr/share/man(N-/) /usr/local/man(N-/) )
export MANPATH

function col {
  awk -v col=$1 '{print $col}'
}

function subnet2cidr ()
{
    # Assumes there's no "255." after a non-255 byte in the mask
    local x=${1##*255.}
    set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
    x=${1%%$3*}
    echo $(( $2 + (${#x}/4) ))
}

function cidr2subnet ()
{
    # Number of args to shift, 255..255, first non-255 byte, zeroes
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

function org() {
  cp -a $1{,.org}
}

function pass() {
    cat $1 >/dev/clipboard 2>&1
}

function bak() {
  cp $1{,.bak}
}

function day_bak() {
  cp $1{,.$today}
}

function commit() {
  svn commit -m"kim"
  sleep 1
  svn update
}


pmver () {
  perl -M${1} -le "print \$$1::VERSION"
}

pmver2 () {
  echo "perl -M${1} -e 'print \$$1::VERSION . \"\\\n\"'"
  perl -M${1} -le "print \$$1::VERSION"
}

path () {
  for i ; do
      case "$i" in
          /* )
              echo $i ;;
          .|.. )
              ( cd $i; echo `pwd` ) ;;
          * )
              echo `pwd`/$i ;;
      esac
  done
}

__path () {
  case "$i" in
      /* )
          echo $i ;;
      .|.. )
          ( cd $i; echo `pwd` ) ;;
      * )
          echo `pwd`/$i ;;
  esac
}

function pcflow() {
    cflow --tree --print-level --depth=$1 --main=zzz *.c \
        | sed -e 's/\({   0} +-\([^ ]*\).*\)/\n\n\2\n\1/'
}

function pdf() {
	sudo du -d 1 | perl -nle 'my %a;($a{u},$a{d})=split(/\s/);push(@a,\%a);END{map{printf "%.2f %16d %s\n",$_->{u}/$a[-1]->{u},$_->{u},$_->{d}}@a}'
}

function sa()
{
    (
        d=$(mktemp -d) && cd "$d" || exit 1
        zsh
        s=$?
        if [[ $s == 0 ]]; then
            rm -rf "$d"
        else
            echo "Directory '$d' still exists." >&2
        fi
        exit $s
    )
}


# PATH
path=( $HOME/*bin(N-/) /usr{/local,}/bin(N-/) /opt/*/*bin(N-/) /opt/*/*/*bin(N-/) \
    /usr/local/*bin(N-/) /usr/*bin(N-/) /*bin(N-/) /usr/ucb(N-/) )

# aliases
which vim  >/dev/null 2>&1  && alias vi=`which vim`
alias fvi='vi $(mktemp --tmpdir=./ vi.XXXXXXXXXX)'
alias vv='fvi'

alias .='source'
alias ..='cd ..'
alias h='history 0 | /bin/sed -r "s/^ [ 0-9][ 0-9]*/ /"'

alias cp='cp -ir'
alias mv='/bin/mv -i'
alias rm='rm -i'
alias mvf='/bin/mv -f'
alias rmf='rm -rf'
alias ls='/bin/ls --color=auto --group-directories-first'
alias ll='ls -lh --time-style=long-iso'
alias lll='ll -tr'
alias llll='lll --time-style=full-iso'
alias la='ll -A'
alias lld='ll -d'
alias ip='/sbin/ip -4 -oneline'
alias ipa='/sbin/ip -4 -oneline addr | grep -vw lo | /bin/sed "s@/@ /@"'
alias locate='locate -r'
alias df='df -PTh'
alias df.='df .'
alias dfx='df -x tmpfs -x devtmpfs'
alias view='vi -R'
alias grep='egrep --color=auto'
alias igrep='grep -i'
alias fgrep='fgrep --color=auto'
alias rgrep='grep -v "^#|^$"'
alias scp='scp -r'
alias mrcsdiff='rcsdiff -utw'
alias mci='ci -u -m"kim"'
alias mrlog='rlog -L -R RCS/*'
alias cscope='cscope -b'
alias ssh='ssh -C -o "StrictHostKeyChecking no"'
alias wget='wget -c'
alias zsh='exec zsh'
alias viz='vi ~/.zshrc'
alias .viz='source ~/.zshrc'
alias watch='watch -d'
alias pstree='pstree -p'
alias emacs='LANG=ja_JP.UTF8 emacs -nw -f shell'
alias femacs='emacs $(mktemp --tmpdir=./ emacs.XXXXXXXXXX)'
alias em='emacs'
alias fe='femacs'
alias ff='femacs'
alias svndiff='svn diff --diff-cmd /usr/bin/diff -x "-Nurb"'
alias dstat-full='$HOME/bin/dstat/dstat -clmdrn --bits --nocolor'
alias dstat-mem='$HOME/bin/dstat/dstat  -clm    --bits --nocolor'
alias dstat-cpu='$HOME/bin/dstat/dstat  -clr    --bits --nocolor'
alias dstat-net='$HOME/bin/dstat/dstat  -clnd   --bits --nocolor'
alias dstat-disk='$HOME/bin/dstat/dstat -cldr   --bits --nocolor'
alias dstat='$HOME/bin/dstat/dstat --nocolor --load --cpu --disk --net --tcp --page --sys --proc --mem --swap --bits'
alias sed='sed --regexp-extended --follow-symlinks'
#alias sar='sar -q'
alias tcpdump='tcpdump -nnn'
alias nkf='nkf -f80-0'
alias netstat='/bin/netstat  --numeric --tcp --listen --program'
alias unetstat='/bin/netstat --numeric --udp --listen --program'
alias fmt='fmt -s -w $(($COLUMNS))'
alias ct='cut -c -$(($COLUMNS-10))'
alias less='LANG=ja_JP.UTF8 less -iFe'
#alias git='git --no-pager'
alias gitd='git diff -b -w -B'
alias sl='ls'
alias time='/usr/bin/time -p'
alias jq='jq -r'
alias crm_mon='crm_mon -rAf'
alias which='which -a'
alias fdate='date "+%Y-%m-%d-%H:%M:%S"'
alias free='free -m'
alias pkill='pkill -f'
alias weeklyreport='em ~/sandbox/WeeklyReport'

# diff
if type git >/dev/null 2>&1; then
    alias diff='git diff --ignore-space-change --ignore-all-space --ignore-blank-lines --ignore-space-at-eol --no-index'
else
    alias diff='diff -tbwrN --unified=1'
fi

# pgrep
\pgrep -af init |& grep -q init
  [[ $? != 0 ]] && alias pgrep='pgrep -lf' || alias pgrep='pgrep -af'

# end-alias

# LANG
alias eng='LANG=C LANGUAGE=C LC_ALL=C'
alias euc='LANG=ja_JP.eucJP'
alias utf='LANG=ja_JP.UTF-8'
alias jap='LANG=C LANGUAGE=C LC_ALL=ja_JP.UTF8'
alias sjis='LANG=ja_JP.UTF-8 LC_ALL=ja_JP.sjis'
alias fuck='eval $(thefuck $(fc -ln -1))'

# RPM
alias rpmqa='rpm -qa --queryformat="%-30{NAME} %-30{VERSION} %-30{RELEASE}\n"'
alias rpmql='rpm -ql'
alias rpmqf='rpm -qf'
alias rpmqi='rpm -qi'
alias rpmqlp='rpm -qlp'
alias rpmqip='rpm -qip'

# galiases
alias -g L='|&less -SL'
alias -g M='|&more'
alias -g H='|&head'
alias -g TEE='|&tee'
alias -g T='|&tail'
alias -g WC='|&wc -l'
alias -g G='|&grep -a'
alias -g GI='G -i'
alias -g GV='G -v'
alias -g GVV="G -v '^(#|$)'"
alias -g GO='G -o'
alias -g FG='|& fgrep -a'
alias -g FGV='FG -v'
alias -g S='GVV |&sort'
alias -g SC='S |uniq -c |sort -n'
alias -g SU='S |uniq'
alias -g CT='|&ct'
alias -g J='2>/dev/null |jq .'
alias -g CL='| column -t'

alias -g e2s='|& lv -Ieuc -Osjis | cat'
alias -g e2j='|& lv -Ieuc -Osjis | cat'
alias -g e2u='|& lv -Ieuc -Ou8   | cat'

alias -g u2s='|& lv -Iu8  -Osjis | cat'
alias -g u2j='|& lv -Iu8  -Osjis | cat'

alias -g j2u='|& lv -Is   -Ou8   | cat'
alias -g s2u='|& lv -Is   -Ou8   | cat'


alias -s 'gz'='tar zxvf'

hash -d mm=~/.myenv
hash -d ss=~/.ssh

# for every OS
case $OSTYPE in
  linux-gnu)
      TERM=linux
      alias man='LC_ALL=ja_JP.UTF-8 man'
      alias su="/bin/su -m"
      alias msu="/bin/su -m -s `which zsh`"
      alias sum='md5sum'

      which dpkg >/dev/null 2>&1
      if [ $? -eq 0 ]; then
          # Debian
          alias rpmqa='dpkg -l'
          alias rpmql='dpkg -L'
          alias rpmqf='dpkg -S'
          alias rpmqi='dpkg -s'
          alias rpmqlp='dpkg -c'
          alias rpmqip='dpkg -I'
          alias free='free -h'
          alias netstat='/bin/netstat  --numeric --tcp -4 --listen --program'
      fi

      ;;
  solaris*)
      TERM=vt100
      [ -x /usr/local/bin/less ] && alias man='LANG=ja man'
      alias su="/bin/su"
      alias msu="/bin/su root -c `which zsh`"
      alias sum='/usr/bin/sum'
      alias ping='ping -s'
      alias df='df -h -F ufs'
      alias rpmqa='pkginfo'
      alias rpmql='pkgchk -vn'
      alias rpmqf='pkgchk -lp'
      alias rpmqi='pkginfo -l'
      alias rpmqlp='pkgchk -vd'
      alias rpmqip='pkginfo -l -d'
      ;;
  cygwin)
      LC_ALL=ja_JP.UTF8
      TERM=linux  # yes, not cygwin!
      path=( $path $(cygpath -W) $(cygpath -S){,/wbem} )
      alias rpmqa='cygcheck -c -d'
      alias rpmql='cygcheck -l'
      alias rpmqf='cygcheck -f'
      alias rpmqi='cygcheck -p'
      alias sum='md5sum'
      alias ls='ls --color=auto --show-control-chars --group-directories-first'
      alias exp='explorer . &'
      alias open='/usr/bin/cygstart'
      alias ifconfig='/cygdrive/c/WINDOWS/system32/ipconfig j2u'
      alias sudo=''
      #alias ping='ping -t'
      #alias ping='/cygdrive/c/Windows/System32/ping -t'
      alias -g CLIP='>/dev/clipboard 2>&1'
      alias -g SCLIP='s2u >/dev/clipboard 2>&1'
      alias -g CLIPS='s2u >/dev/clipboard 2>&1'
      #export LC_ALL=ja_JP.sjis
      #export LANG=ja_JP.sjis
      export OUTPUT_CHARSET=ja_JP.sjis
      export SHELL=/bin/bash
      cdpath=( $cdpath /cygdrive/d/system/My\ Documents )
      path=( $path )
      bindkey -s "^[c"  'git commit -a -m "Update"; git push origin master '
      alias vagrant='/cygdrive/c/HashiCorp/Vagrant/bin/vagrant'
      alias sed='sed --regexp-extended'
      ;;
  minix)
      alias -g L='|&less'
      alias ls='ls --color=auto --show-control-chars'
      bindkey "^Q" history-incremental-search-backward
      manpath=( /usr/gnu/man /usr/local/man /usr/local/share/man /usr/man /usr/src/man )
      ;;
  *)
      echo "unknown OS"
      ;;
esac

# for CentOS5
grep -q 'release 5' /etc/redhat-release 2>/dev/null
if [[ $? = 0 ]]
then
    alias ls='/bin/ls --color=auto'
    alias sed='sed --regexp-extended'
fi

# delete a repeating element automatically
typeset -U path cdpath fpath manpath

# rc
mkdir -p $HOME/{,sandbox}/Trash
which dircolors  >/dev/null 2>&1  && eval `dircolors`
[[ -e $HOME/.zprompt ]] && source $HOME/.zprompt
[[ -e $HOME/.localrc ]] && source $HOME/.localrc
source="source"

# for emacs
if [[ $EMACS = t ]] ;then
  unsetopt zle
  unsetopt transient_rprompt
  alias ls='/bin/ls -F -w 100 --group-directories-first'
  alias grep='egrep'
  alias emacs='ls'
  alias git='git --no-pager'
  PROMPT='[(zsh)%~]%(#.#.$) '
  source=true
fi

# for cygwin
if [[ $OSTYPE == "cygwin" ]]; then
    # mv系
    rm -f ~/sandbox/emacs.*(L0,m+7) ~/\#*
    #mv -f *~Makefile~localrc~user* ~/Trash 2>/dev/null
    #mv -f *~Makefile~localrc(L0,a+7.)~user* ~/Trash 2>/dev/null
    mv -f instances.*(L0,a+1.) ~/Trash 2>/dev/null
    #find ~/sandbox -type f -atime +7 | xargs mv -t ~/sandbox/trash
    [[ -e ~/bin/puttylog_archive.sh ]] && bash ~/bin/puttylog_archive.sh
    [ `pwd` = "/usr/bin" ] && cd $HOME
fi

#proxy=
#export {HTTP{,S}_PROXY,http{,s}_proxy}=$proxy

[[ -e ~/.localrc ]] && $source ~/.localrc
