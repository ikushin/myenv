;; 基本設定
(setq inhibit-startup-message t)
(global-font-lock-mode t)
(menu-bar-mode -1)
(setq inhibit-default-init t)
(setq scroll-step 1)
(setq dabbrev-case-fold-search nil)
(add-to-list 'load-path "~/.lisp")
(add-to-list 'load-path "~/lisp/apel")
(add-to-list 'load-path "~/lisp/emu")
(add-to-list 'load-path "~/lisp/emacs-w3m")
(setq kill-whole-line t)
;(setq-default indicate-empty-lines t)
;(global-set-key "\C-x\C-b" 'buffer-menu)
(show-paren-mode t)
(column-number-mode 1)  ;keta hyouji

(global-set-key (kbd "C-x C-b") 'bs-show)
; possible values for the configuration are:
;    ("all"                . bs-config--all)
;    ("files"              . bs-config--only-files)
;    ("files-and-scratch"  . bs-config--files-and-scratch)
;    ("all-intern-last"    . bs-config--all-intern-last)
(setq bs-default-configuration "all")

(global-hl-line-mode 0)
(line-number-mode 1)
(column-number-mode 1)
(savehist-mode 1)

;; diff オプション
(setq diff-switches "-ubtw")

;; dired ls option
(setq dired-listing-switches "-ltrh --group-directories-first --time-style=long-iso")
;(setq dired-listing-switches "-lh --group-directories-first --time-style=long-iso")

;; スペースで yes を入力する
(fset 'yes-or-no-p 'y-or-n-p)

;; リージョンに色を付ける
(setq transient-mark-mode t)
(set-face-foreground 'region "black")
(set-face-background 'region "white")

;; スクロール設定
(defun scroll-up-one () "Scroll up 1 line." (interactive)
  (scroll-up (prefix-numeric-value current-prefix-arg)))
(defun scroll-down-one () "Scroll down 1 line." (interactive)
  (scroll-down (prefix-numeric-value current-prefix-arg)))
(define-key global-map "\C-\M-z" 'scroll-up-one)
(define-key global-map "\C-\M-v" 'scroll-down-one)

(defun line-to-top-of-window () "Move the line point is on to top of window." (interactive)
  (recenter 5))
(define-key global-map "\M-p" 'line-to-top-of-window)
;(define-key global-map "\M-n" 'line-to-top-of-window)

;; Key バインド
;(keyboard-translate ?\C-\\ ?\C-h)
(keyboard-translate ?\C-h ?\C-?)
(keyboard-translate ?\C-t ?\M-/)
(define-key mode-specific-map "c" 'compile)
(define-key global-map "\C-x\C-u" 'undo)
(define-key global-map "\C-x\C-o" 'other-window)
(define-key global-map "\C-w" 'kill-ring-save)
(define-key global-map "\M-w" 'kill-region)
(define-key global-map "\C-s" 'isearch-forward-regexp)
(define-key global-map "\C-r" 'isearch-backward-regexp)
(define-key global-map "\M-s\M-s" 'isearch-forward)
(define-key global-map "\M-s\M-r" 'isearch-backward)
(define-key global-map "\M-h" 'backward-kill-word)
(global-set-key "\C-\M-b" 'scroll-other-window-down)
(global-set-key "\M-g" 'goto-line)

(define-key global-map [f1] 'woman)
(define-key global-map [f3] 'previous-error)
(define-key global-map [f4] 'next-error)
;(define-key global-map [(shift f4)] 'previous-error)
;(define-key global-map [f7] 'compile)
(define-key global-map "\M-oP" 'woman)
(define-key global-map "\M-oR" 'previous-error)
(define-key global-map "\M-oS" 'next-error)
(define-key global-map [f14] 'previous-error)
(define-key global-map [f7] 'compile)
(define-key global-map [f8] 'YaCompile)



;; electric-buffer-list(SPC demo eraberu)
(global-set-key "\C-x\C-e" 'electric-buffer-list)

;; When a folder is opened, the new buffer is not made
(defvar my-dired-before-buffer nil)
(defadvice dired-advertised-find-file
  (before kill-dired-buffer activate)
  (setq my-dired-before-buffer (current-buffer)))

(defadvice dired-advertised-find-file
  (after kill-dired-buffer-after activate)
  (if (eq major-mode 'dired-mode)
      (kill-buffer my-dired-before-buffer)))

(defadvice dired-up-directory
  (before kill-up-dired-buffer activate)
  (setq my-dired-before-buffer (current-buffer)))

(defadvice dired-up-directory
  (after kill-up-dired-buffer-after activate)
  (if (eq major-mode 'dired-mode)
      (kill-buffer my-dired-before-buffer)))

;; ミニバッファでの補完を TAB だけで行う
(require 'minibuffer-complete-cycle)
(and (load "minibuffer-complete-cycle") (setq minibuffer-complete-cycle t))

;; minibuffer isearch
;(require 'minibuf-isearch)

;; scratch buffer
(defun my-make-scratch (&optional arg)
  (interactive)
  (progn
    ;;
    (set-buffer (get-buffer-create "*scratch*"))
    (funcall initial-major-mode)
    (erase-buffer)
    (when (and initial-scratch-message (not inhibit-startup-message))
      (insert initial-scratch-message))
    (or arg (progn (setq arg 0)
                   (switch-to-buffer "*scratch*")))
    (cond ((= arg 0) (message "*scratch* is cleared up."))
          ((= arg 1) (message "another *scratch* is created")))))

(defun my-buffer-name-list ()
  (mapcar (function buffer-name) (buffer-list)))

(add-hook 'kill-buffer-query-functions
          ;;
          (function (lambda ()
                      (if (string= "*scratch*" (buffer-name))
                          (progn (my-make-scratch 0) nil)
                        t))))

(add-hook 'after-save-hook
          ;;
          (function (lambda ()
                      (unless (member "*scratch*" (my-buffer-name-list))
                        (my-make-scratch 1)))))

;; occur-at-point
(defun oc()
  (interactive)
  (if (thing-at-point 'word)
      (occur (thing-at-point 'word))
    (call-interactively 'occur)))

(setq list-matching-lines-face 'color-occur-face)
;(setq list-matching-lines-face "light steel blue")

;(require 'color-moccur)


;; YaTeX like compile
; ex, //!gcc -Wall -o test test.c
 (add-hook 'c-mode-common-hook
  '(lambda ()
      (define-key c-mode-map "\C-c\C-c" 'YaCompile)
      (setq current-comment-prefix "//")))

(defvar current-comment-prefix "#" "*Default prefix string")
(make-variable-buffer-local 'current-comment-prefix)
(defun YaCompile ()
  (interactive)
  (require 'compile)
  (let ( (cmd compile-command))
    (save-excursion
      (goto-char (point-min))
      (if (re-search-forward
           (concat "^" (regexp-quote current-comment-prefix) "!\\(.*\\)$")
           nil t)
          (setq cmd (buffer-substring
                     (match-beginning 1) (match-end 1)))))
    (setq compile-command
          (read-from-minibuffer "Compile command: "
                                cmd nil nil
                                '(compile-history . 1))))
  (compile compile-command))



;; インデント設定と tab->SPC 変換
(add-hook 'c-mode-common-hook
            '(lambda ()
             (progn
               (c-toggle-hungry-state 1)
               (setq c-basic-offset 4 indent-tabs-mode nil))))


(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;; バックアップファイルを作らない
(setq make-backup-files nil)
(setq auto-save-default nil)

;; 自動インデント無効
(electric-indent-mode -1)

;; 行末の空白をハイライト
;(setq-default show-trailing-whitespace t)

;; タブをハイライトする
;(add-hook 'font-lock-mode-hook
;          (lambda ()
;            (font-lock-add-keywords
;             nil
;             '(("\t" 0 'trailing-whitespace prepend)))))
;

;; コンパイルする前に全バッファ保存する
(setq compilation-ask-about-save nil)

;; キルリングの内容を視覚化する
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; オートインデントでスペースを使う
(setq-default indent-tabs-mode nil)

;; 現在の関数名を表示する
(which-function-mode 1)

;;通常のウィンドウ用の設定
(setq-default truncate-lines t)
;;ウィンドウを左右に分割したとき用の設定
(setq-default truncate-partial-width-windows t)

;; redo+ の設定
(require 'redo+)
(global-set-key (kbd "C-M-_") 'redo)
(setq undo-no-redo t) ; 過去のundoがredoされないようにする
(setq undo-limit 600000)
(setq undo-strong-limit 900000)

;; 行末の空白を削除する
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; M-% for query-replace-regexp
(define-key global-map "\M-%" 'query-replace-regexp)

;; disable emacs here document completion
(add-hook 'sh-mode-hook
          (lambda ()
            (sh-electric-here-document-mode -1)))

;; F2で画面入替えする
(defun swap-screen()
  "Swap two screen,leaving cursor at current window."
  (interactive)
  (let ((thiswin (selected-window))
        (nextbuf (window-buffer (next-window))))
    (set-window-buffer (next-window) (window-buffer))
    (set-window-buffer thiswin nextbuf)))
(defun swap-screen-with-cursor()
  "Swap two screen,with cursor in same buffer."
  (interactive)
  (let ((thiswin (selected-window))
        (thisbuf (window-buffer)))
    (other-window 1)
    (set-window-buffer thiswin (window-buffer))
    (set-window-buffer (selected-window) thisbuf)))
(global-set-key [S-f2] 'swap-screen)
(global-set-key [f2] 'swap-screen-with-cursor)

;; カーソル位置を戻すpoint-undoパッケージ
(require 'point-undo)
(define-key global-map [f7] 'point-undo)
(define-key global-map [f17] 'point-redo)

;; 設定ファイルの色付けをする
(require 'generic-x)

;; 最初から *Occur* を選択させる
(defun occur-and-select (regexp &optional nlines)
  (interactive (occur-read-primary-args))
  (occur regexp nlines)
  (select-window (get-buffer-window "*Occur*"))
  (forward-line 1))
(global-set-key (kbd "M-s M-o") 'occur-and-select)

;; 最近のファイル500個を保存する
(setq recentf-max-saved-items 500)
;; 最近使ったファイルに加えないファイルを正規表現で指定する
(setq recentf-exclude
      '("/TAGS$" "/var/tmp/"))
(require 'recentf-ext)

;; バッファの同一ファイル名を区別する
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; コンパイルに成功したら *compilation* バッファを閉じる
; 指定したバッファに警告の文字列があるか
; (defun my-compilation-warning-bufferp (buf)
;   (save-current-buffer
;     (set-buffer buf)
;     (save-excursion
;         (goto-char (point-min))
;           (if (or (search-forward "warning:" nil t)
;                     (search-forward "警告:" nil t)) t nil))))
; ;;; バッファに"abnormally"や警告メッセージがなければウィンドウを閉じる
; (defun my-close-compilation-buffer-if-succeeded (buf str)
;   (cond ((string-match "abnormally" str)
;           (message "Error!"))
;         ((if (my-compilation-warning-bufferp buf)
;               (message "Warning!")))
;         (t
;           (delete-window (get-buffer-window buf))
;            (message "Succeeded"))))
; ;;; compile終了時の実行関数に追加する
; (if compilation-finish-functions
;   (append compilation-finish-functions
;             '(my-close-compilation-buffer-if-succeeded))
;   (setq compilation-finish-functions
;         '(my-close-compilation-buffer-if-succeeded)))

;; サーチをループしない
(setq isearch-wrap-function '(lambda nil))

;; コンパイル時に出力を追って表示する
(setq compilation-scroll-output t)

;; 縦分割を強制する
;(setq split-height-threshold nil)
;(setq split-width-threshold 0)

;; shell mode でzshを使用する
(setq shell-file-name "zsh")
(setenv "SHELL" shell-file-name)
(setq explicit-shell-file-name shell-file-name)

;; MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line

