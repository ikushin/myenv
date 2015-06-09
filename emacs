;; basic options
(setq inhibit-startup-message t)
(global-font-lock-mode t)
(menu-bar-mode -1)
(setq inhibit-default-init t)
(setq scroll-step 1)
(setq dabbrev-case-fold-search nil)
(add-to-list 'load-path "~/lisp")
(add-to-list 'load-path "~/lisp/apel")
(add-to-list 'load-path "~/lisp/emu")
(add-to-list 'load-path "~/lisp/emacs-w3m")
(setq kill-whole-line t)
;(setq-default indicate-empty-lines t)
(global-set-key "\C-x\C-b" 'buffer-menu)
(show-paren-mode t)
(column-number-mode 1)  ;keta hyouji

;; new
(global-hl-line-mode 0)
(line-number-mode 1)
(column-number-mode 1)
(savehist-mode 1)

(setq diff-switches "-ubtw")



;; dired ls option
(setq dired-listing-switches "-ltrh --group-directories-first --time-style=long-iso")
;(setq dired-listing-switches "-lh --group-directories-first --time-style=long-iso")

;; yes -> SPC
(fset 'yes-or-no-p 'y-or-n-p)

;; region color
(setq transient-mark-mode t)
(set-face-foreground 'region "black")
(set-face-background 'region "white")

;; scroll
(defun scroll-up-one () "Scroll up 1 line." (interactive)
  (scroll-up (prefix-numeric-value current-prefix-arg)))
(defun scroll-down-one () "Scroll down 1 line." (interactive)
  (scroll-down (prefix-numeric-value current-prefix-arg)))
(define-key global-map "\C-\M-z" 'scroll-up-one)
(define-key global-map "\C-\M-v" 'scroll-down-one)

(defun line-to-top-of-window () "Move the line point is on to top of window." (interactive)
  (recenter 5))
(define-key global-map "\M-p" 'line-to-top-of-window)
;;(define-key global-map "\M-n" 'line-to-top-of-window)

;; key bindes
;;(keyboard-translate ?\C-\\ ?\C-h)
(keyboard-translate ?\C-h ?\C-?)
(keyboard-translate ?\C-t ?\M-/)
(define-key mode-specific-map "c" 'compile)
(define-key global-map "\C-x\C-u" 'undo)
(define-key global-map "\C-x\C-o" 'other-window)
(define-key global-map "\C-w" 'kill-ring-save)
(define-key global-map "\M-w" 'kill-region)
(define-key global-map "\C-s" 'isearch-forward-regexp)
(define-key global-map "\C-r" 'isearch-backward-regexp)
(define-key global-map "\M-h" 'backward-kill-word)
(global-set-key "\C-\M-b" 'scroll-other-window-down)
(global-set-key "\M-g" 'goto-line)

(define-key global-map [f1] 'woman)
;(define-key global-map [f3] 'previous-error)
;(define-key global-map [f4] 'next-error)
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

;; minibuffer TAB TAB
;(require 'minibuffer-complete-cycle)

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
(defun occurat()
  (interactive)
  (if (thing-at-point 'word)
      (occur (thing-at-point 'word))
    (call-interactively 'occur)))

(setq list-matching-lines-face 'color-occur-face)
                                        ;(setq list-matching-lines-face "light steel blue")

;;
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



;; indent=8, tab -> space
(add-hook 'c-mode-common-hook
            '(lambda ()
             (progn
               (c-toggle-hungry-state 1)
               (setq c-basic-offset 8 indent-tabs-mode nil))))


(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;;; *.~ とかのバックアップファイルを作らない
(setq make-backup-files nil)
;;; .#* とかのバックアップファイルを作らない
(setq auto-save-default nil)

;;; 自動インデント無効
(electric-indent-mode -1)

;;; 行末の空白をハイライト
(setq-default show-trailing-whitespace t)

;;; タブをハイライト
;(add-hook 'font-lock-mode-hook
;          (lambda ()
;            (font-lock-add-keywords
;             nil
;             '(("\t" 0 'trailing-whitespace prepend)))))
;

;; コンパイルする前に全バッファ保存する
(setq compilation-ask-about-save nil)
