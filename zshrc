
# autoload
# -z を付けないと KSH_AUTOLOAD の設定の影響を受けるそうなので、 基本的には -z を明示的に付けるのがおすすめのようです。
autoload -Uz colors && colors
autoload -Uz promptinit && promptinit
autoload -Uz add-zsh-hook

# 補完
autoload -U compinit && compinit
zstyle ':completion:*:default' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' '+m:{a-zA-Z}={A-Za-z} l:|=* r:|=*' # 補完強化
zstyle ':completion:*:cd:*' tag-order local-directories path-directories # cwd にない場合cdpathを検索する
zstyle ':completion:*' group-name ''                  # 補完候補をグループ分けする

# コマンドライン編集できるようにする
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^J' edit-command-line

# cdr を有効にする
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*' recent-dirs-insert both # always, fallback, both
zstyle ':chpwd:*' recent-dirs-max 20
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "${XDG_CACHE_HOME:-$HOME/.cache}/shell/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true

# Ctrl-x,Ctrl-l で最後のコマンドの出力を得る
zmodload -i zsh/parameter
insert-last-command-output() {
LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

# setopt
#setopt hist_ignore_dups
#setopt hist_ignoreall_dups    # 連続したコマンドは削除する -> Ctrl+O と相性が悪い
#setopt ignore_eof             # ignore logout in crtr-d
#setopt interactive_comments
#setopt null_glob
setopt always_last_prompt
setopt auto_cd
setopt auto_menu
setopt auto_name_dirs
setopt auto_param_keys
setopt auto_pushd
setopt auto_remove_slash
setopt auto_resume
setopt brace_ccl
setopt cdable_vars
setopt chase_links
setopt extended_glob
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_nodups
setopt magic_equal_subst
setopt no_beep
setopt nonomatch
setopt notify
setopt numeric_globsort
setopt prompt_subst
setopt pushd_ignore_dups
setopt pushd_minus
setopt rm_star_silent
setopt sun_keyboard_hack
setopt transient_rprompt
unset MAILCHECK             # no MailChecks
unsetopt case_glob
unsetopt correctall
unsetopt flow_control   # ignore ctrl-s
unsetopt list_types
unsetopt prompt_cr

# key binds
bindkey -e
bindkey '^O'   accept-line-and-down-history
bindkey "^[H"  backward-kill-word
bindkey "^[h"  backward-kill-word

# 単語区切り文字指定
WORDCHARS='*?[]~&;!#$%^{}<>|'
export WORDCHARS

# 補完強化
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _list
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
zstyle ':completion:*:manuals' separate-sections true

# 補完に関するオプション
# http://voidy21.hatenablog.jp/entry/20090902/1251918174
#setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
#setopt mark_dirs             # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
#setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
#setopt auto_param_keys       # カッコの対応などを自動的に補完
#setopt interactive_comments  # コマンドラインでも # 以降をコメントと見なす
#setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
#
setopt complete_in_word      # 語の途中でもカーソル位置で補完
#setopt always_last_prompt    # カーソル位置は保持したままファイル名一覧を順次その場で表示
#
#setopt print_eight_bit       # 日本語ファイル名等8ビットを通す
#setopt extended_glob         # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)

# history
setopt share_history
setopt extended_history
HISTFILE=$HOME/.zhistory
HISTSIZE=100000
SAVEHIST=100000
DIRSTACKSIZE=200

# prompt
RPROMPT='[%d]'

# environment variable
LC_ALL="ja_JP.UTF8"
LANG="C"
export EDITOR=vim
export PAGER=less
export LESSCHARSET=utf-8

# path
path=( $HOME/*bin(N-/) /usr{/local,}/bin(N-/) /opt/*/*bin(N-/) /opt/*/*/*bin(N-/) \
    /usr/local/*bin(N-/) /usr/*bin(N-/) /*bin(N-/) /usr/ucb(N-/) )

# cdpath
cdpath=( .. $HOME )

# manpath
manpath=( /usr/local/share/man(N-/) /usr/local/man(N-/) /usr/share/man/ja(N-/) /usr/share/man(N-/) )
export MANPATH

# delete a repeating element automatically
typeset -U path cdpath fpath manpath

# 補完候補を色付けする
eval $(dircolors ~/.dir_colors --bourne-shell)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# color echo
nc='\033[0m'
red='\033[0;31m'
green='\033[0;32m'

######
# rc #
######
TERM=linux

# 名前付きdir
hash -d mm=~/.myenv
hash -d ss=~/.ssh

# mkdir
mkdir -p $HOME/.cache/shell
mkdir -p $HOME/.{trash,sandbox}

for i in .zshrc.{func,alias,git,cygwin} .zprompt .localrc
do
    test -e ~/$i && source $_
done

# for emacs
if [[ $EMACS ]] ;then
  unsetopt zle
  unsetopt transient_rprompt
  alias ls='/bin/ls -F -w 100 --group-directories-first'
  alias emacs='ls'
  alias git='git --no-pager'
  PROMPT='[(zsh)%~]%(#.#.$) '
  source=true
fi
