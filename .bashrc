# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions

#
# grep
alias grep='/bin/grep --color -a -P'
alias egrep='/bin/grep -E --color -a'
alias xgrep='grep -P'
alias fgrep='/bin/fgrep --color'
alias igrep='g -i'

alias g='xgrep'
alias go='g -o'
alias gh='g -h'
alias goh='g -oh'
alias gho='goh'

# ipgrep
alias ipgrep='xgrep "(\d+\.){3}\d+"'
alias ipgrep2='xgrep "(\d+\.){4}\d+" **/*~*.db(.) GV "127.0.0.1|0.0.0.0|\.hint|\.zone" Key "(\d+\.){3}\d+|^.*?:"'

# perl
alias perl_ple='perl -ple'
alias perl_iple='perl -i -ple'
alias perl_plei='perl -i -ple'
alias perl_inle='perl -i -nle'

# LANG
alias lang_C='LANG=C LANGUAGE=C LC_ALL=C'
alias lang_EUC='LANG=ja_JP.eucJP'
alias lang_UTF='LANG=ja_JP.UTF-8'
alias lang_SJIS='LANG=ja_JP.UTF-8 LC_ALL=ja_JP.sjis'

# vi
which vim  >/dev/null 2>&1  && alias vi=`which vim`
alias fvi='vi $(mktemp --tmpdir=./ vi.XXXXXXXXXX)'
alias vv='fvi'
alias vif='vi -c startinsert f'
alias vii='vi -c startinsert'
alias view='vi -R'
alias viz='vi ~/.zshrc'
alias .viz='source ~/.zshrc'
alias vie='vi ~/.emacs'

# date
alias date_heisei='printf "%d: H.%d\n" $(/bin/date +%Y) $(($(/bin/date +%Y)-1988))'
alias date_now='/bin/date +%F_%T'
alias date_full='/bin/date +%F_%T_%N'
alias date_today='/bin/date +%Y%m%d'
alias date_yesterday='/bin/date --date "1 day ago" +%Y%m%d'
alias date_MMDDhhmmYY='/bin/date +%m%d%H%M%y'

# cp, mv
alias cp='/bin/cp -ia'
alias cpf='/bin/cp -f'
alias mv='/bin/mv -i'
alias mvf='/bin/mv -f'
alias rm='/bin/rm -i'
alias rmf='/bin/rm -rf'

# ls, stat
alias ls='ls --color=auto --group-directories-first'
alias sl='ls'
alias ll='ls -lh --time-style=long-iso'
alias llx='ls -lh --time-style=long-iso -X'
alias lll='ll -tr'
alias llll='lll -i --time-style=full-iso'
alias l4='llll'
alias la='ll -A'
alias lld='ll -d'
alias stat_my='stat -c "%A %a %U:%G %u:%g %N"'
alias lsstat='stat_my'
alias stat_my2='stat -c "%A %a %u %g %N"'

# df
alias df='df -PTh'
alias df.='df .'
alias dfx='df -x tmpfs -x devtmpfs'
alias dfxx='dfx GV "/boot"'

# emacs
alias emacs='LANG=ja_JP.UTF8 emacs -nw'
alias tejun='emacs -l ~/.emacs_tejun'
alias femacs='emacs $(mktemp --tmpdir=./ emacs.XXXXXXXXXX)'
alias em='emacs'
alias ema='emacs a'
alias emb='emacs b'
alias fe='femacs'
alias ff='femacs'
alias ee='femacs'

# alias
#alias sar='sar -q'
#alias sed='sed --regexp-extended --follow-symlinks'
alias Du='du -sh * .* 2>/dev/null | sort -h'
alias cata='cat -A'
alias cscope='cscope -b'
alias ct='cut -c -$(($COLUMNS-10))'
alias diff='diff -tbwrN --unified=1'
alias fmt='fmt -s -w $(($COLUMNS))'
alias jq='jq -r'
#alias less='LANG=ja_JP.UTF8 less -iR -j3'
alias m='md5sum'
alias md5sum='md5sum --text'
alias nkf='nkf -f80-0'
alias scp='scp -r'
alias ssh='ssh -C -o "StrictHostKeyChecking no"'
alias time='/usr/bin/time -p'
alias type='type -a'
alias wget='wget -c'
alias which='which -a'
alias zsh='exec zsh'
alias tailf='tail -F'

# misc
alias .='source'
alias ..='cd ..'
alias dc='cd'
alias h='history 0 | tail -n 100 | perl -pe "s/^\d+\*? +//"'
alias weeklyreport='em ~/sandbox/WeeklyReport'
alias clock='clear; xcal; echo; while :; do printf "%s\r" "$(date +%T)"; sleep 1 ; done'
alias c='clock'
alias pyser='ipa; python -m CGIHTTPServer'
alias curl_my='curl --location --silent --show-error --max-time 3'
alias path='readlink -f'
alias delete_mailq='mailq Go "^\w+"|postsuper -d -'

# a b c ファイル用
alias via='vi -c startinsert a'
alias vib='vi -c startinsert b'
alias vic='vi -c startinsert c'

alias viaa='vi -c startinsert aa'
alias vibb='vi -c startinsert bb'
alias vicc='vi -c startinsert cc'

alias mva='mvf aa a'
alias mvb='mvf bb b'
alias mvc='mvf cc c'

alias asu='cat a SU'
alias asc='cat a SC'
alias sua='su_file a'
alias sca='cat a SC'

alias bsu='cat b SU'
alias bsc='cat b SC'
alias sub='su_file b'
alias scb='cat b SC'

alias csu='cat c SU'
alias csc='cat c SC'
alias suc='cat c SU'
alias scc='cat c SC'

# pgrep
alias pgrep="pgrep -af"

