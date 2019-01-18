;; 日本語環境設定
(prefer-coding-system 'utf-8)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)

;; ミニバッファの履歴を自動的に保存
(savehist-mode 1)

;; スタート時のスプラッシュ非表示
(setq inhibit-startup-message t)

;; 色表示を有効にする
(global-font-lock-mode t)

;; バックアップファイルを作らない
(setq make-backup-files nil)
(setq auto-save-default nil)

;; メニューバーを非表示にする
(menu-bar-mode 0)

;; 1行ずつスクロールする
(setq scroll-step 1)

;; 行の先頭で Ctrl-k を押すとその行ごと削除する
(setq kill-whole-line t)

; タブでなく4つのスペースを使う
(setq-default tab-width 4 indent-tabs-mode nil)

;; 自動インデント無効
(electric-indent-mode -1)

;; モードラインに行列番号表示
(column-number-mode t)
(line-number-mode t)

;; スペースで yes を入力する
(fset 'yes-or-no-p 'y-or-n-p)

;; リージョンに色を付ける
(setq transient-mark-mode t)
(set-face-foreground 'region "black")
(set-face-background 'region "green")

;; ミニバッファでの補完を TAB だけで行う
(setq minibuffer-complete-cycle t)

;; コンパイルする前に全バッファ保存する
(setq compilation-ask-about-save nil)

;; キルリングの内容を視覚化する
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; 行末の空白を削除する
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; /etc/hosts とかの設定ファイルを色付けをする
(require 'generic-x)

;; ;; 最近のファイル50個を保存する
;; (setq recentf-max-saved-items 50)
;; ;;;; 履歴加えないファイルを正規表現で指定する
;; (setq recentf-exclude
;;       '("/TAGS$" "/var/tmp/"))
;; (require 'recentf-ext)

;; バッファの同一ファイル名を区別する
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; サーチをループしない
(setq isearch-wrap-function '(lambda nil))

;; コンパイル時に出力を追って表示する
(setq compilation-scroll-output t)
