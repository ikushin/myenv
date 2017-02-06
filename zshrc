#
# basic options
#
autoload -U compinit
compinit -u
#autoload -U colors
#colors
#setopt hist_ignoreall_dups
setopt hist_save_nodups

autoload -U edit-command-line
zle -N edit-command-line

autoload -U promptinit
promptinit

autoload -Uz colors
colors

autoload -Uz add-zsh-hook

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
#zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

unsetopt case_glob
setopt auto_resume
setopt nonomatch
setopt auto_pushd
setopt auto_cd
unsetopt correctall
setopt cdable_vars
setopt hist_no_store
#setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt numeric_globsort
setopt pushd_ignore_dups
setopt notify
setopt auto_name_dirs
setopt auto_remove_slash
#setopt null_glob
setopt hist_ignore_space
unsetopt list_types
setopt no_beep
setopt prompt_subst
setopt rm_star_silent
setopt sun_keyboard_hack
setopt transient_rprompt
setopt brace_ccl
#setopt interactive_comments
setopt chase_links
setopt pushd_minus
#setopt ignore_eof      # ignore logout in crtr-d
unsetopt flow_control   # ignore ctrl-s
unsetopt prompt_cr

# cdr, add-zsh-hook を有効にする
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# cdr の設定
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-pushd true

# key binds
bindkey -e
bindkey '^O'   accept-line-and-down-history
bindkey '^J' edit-command-line
bindkey "^[H"  backward-kill-word
bindkey "^[h"  backward-kill-word
#bindkey "^[^H" run-help
bindkey -s "^[g"  '| egrep -v "\^[[:space:]]*(#|$)" '
bindkey -s "^[f"  "| fgrep -v ?"
bindkey -s "^[q"  "ps -eo uname,lstart,pid,rss,vsz,args | egrep"
bindkey "^I" menu-complete   # 展開する前に補完候補を出させる(Ctrl-iで補完するようにする)

# 単語区切り文字指定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars ':"/*?[]~&;!#$%^{}<>| '\' #"
zstyle ':zle:*' word-style unspecified

#ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 補完関数の表示を強化する
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT

# マッチ種別を別々に表示
zstyle ':completion:*' group-name ''

# 補完に関するオプション
# http://voidy21.hatenablog.jp/entry/20090902/1251918174
setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs             # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
setopt auto_param_keys       # カッコの対応などを自動的に補完
setopt interactive_comments  # コマンドラインでも # 以降をコメントと見なす
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる

setopt complete_in_word      # 語の途中でもカーソル位置で補完
setopt always_last_prompt    # カーソル位置は保持したままファイル名一覧を順次その場で表示

setopt print_eight_bit       # 日本語ファイル名等8ビットを通す
setopt extended_glob         # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)

# not end of word
#WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
#WORDCHARS='*?[]~=&;!#$%^{}<>'
WORDCHARS='*?[]~&;!#$%^{}<>|'
export WORDCHARS

# history
setopt share_history
setopt extended_history
HISTFILE=$HOME/.zhistory
HISTSIZE=100000                 # メモリに保存される履歴の件数
SAVEHIST=100000                 # 履歴ファイルに保存される履歴の件数
DIRSTACKSIZE=200

# prompts
#PROMPT='[%n@%{$bg[blue]%}%m%{$reset_color%}]%(#.#.$) '
RPROMPT='[%d]'


# environment variable
LC_ALL="ja_JP.UTF8"
LANG="C"
cdpath=( .. $HOME )
export EDITOR=vim
export PAGER=less
export LESSCHARSET=utf-8
#export CFLAGS='-g -Wall -Wuninitialized -O'

# convenient variable
host=${HOST%%.*}
today=$( /bin/date +%Y%m%d )
yesterday=`date --date "1 day ago" +%Y%m%d` 2>/dev/null

# man
manpath=( /usr/local/share/man(N-/) /usr/local/man(N-/) /usr/share/man/ja(N-/) /usr/share/man(N-/) )
export MANPATH

# color echo
nc='\033[0m'
red='\033[0;31m'
green='\033[0;32m'

# PATH
path=( $HOME/*bin(N-/) /usr{/local,}/bin(N-/) /opt/*/*bin(N-/) /opt/*/*/*bin(N-/) \
    /usr/local/*bin(N-/) /usr/*bin(N-/) /*bin(N-/) /usr/ucb(N-/) )

# delete a repeating element automatically
typeset -U path cdpath fpath manpath

######
# rc #
######
TERM=linux

hash -d mm=~/.myenv
hash -d ss=~/.ssh

mkdir -p $HOME/.{trash,sandbox}
which dircolors  >/dev/null 2>&1  && eval `dircolors --bourne-shell`

for i in .zshrc.func .zshrc.alias .zshrc.git .zshrc.cygwin .zprompt .localrc
do
    test -e ~/$i && source $_
done

# for emacs
if [[ $EMACS = t ]] ;then
  unsetopt zle
  unsetopt transient_rprompt
  alias ls='/bin/ls -F -w 100 --group-directories-first'
  alias emacs='ls'
  alias git='git --no-pager'
  PROMPT='[(zsh)%~]%(#.#.$) '
  source=true
fi
