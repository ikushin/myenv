
;; 効果不明
;(keyboard-translate ?\C-h ?\C-?)
;(keyboard-translate ?\C-t ?\M-/)
;(define-key mode-specific-map "c" 'compile)
;(define-key global-map "\C-x\C-u" 'undo)
;(define-key global-map "\M-oP" 'woman)
;(define-key global-map "\M-oR" 'previous-error)
;(define-key global-map "\M-oS" 'next-error)
;(global-set-key (kbd "C-x C-b") 'bs-show)


;; 鉄板
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\M-g" 'goto-line)
;
(define-key global-map "\C-x\C-o" 'other-window)
(define-key global-map "\M-w" 'kill-region)
(define-key global-map "\C-s" 'isearch-forward-regexp)
(define-key global-map "\C-r" 'isearch-backward-regexp)
(define-key global-map (kbd "C-c C-l") 'toggle-truncate-lines)
(define-key global-map (kbd "C-t") 'smart-tab)
(define-key global-map "\M-h" 'backward-kill-word)
(define-key global-map "\C-\M-z" 'scroll-up-line)
(define-key global-map "\C-\M-v" 'scroll-down-line)
(define-key global-map "\C-w" 'kill-ring-save)
;
(bind-key "M-o p" 'woman)                   ;; F1
(bind-key "M-o q" 'swap-screen-with-cursor) ;; F2
(define-key global-map [f3] 'previous-error)
(define-key global-map [f4] 'next-error)
(bind-key "M-o r" 'previous-error)
(bind-key "M-o s" 'next-error)
;(define-key global-map [f7] 'compile)
(define-key global-map [f8] 'YaCompile)

;; バッファ切替
;; (global-set-key [(f9)]   'bs-cycle-previous)
;; (global-set-key [(f7)]  'bs-cycle-next)
;;;; *scratch*バッファを表示候補に入れる
(setq bs-cycle-configuration-name "files-and-scratch")

;; 使うかどうか判定中
;(require 'point-undo)
;(define-key global-map (kbd "M-[") 'point-undo)
;(define-key global-map (kbd "M-]") 'point-redo)

(global-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)
(define-key global-map "\M-s\M-s" 'isearch-forward)
(define-key global-map "\M-s\M-r" 'isearch-backward)
(global-set-key "\C-\M-b" 'scroll-other-window-down)
(define-key global-map [f14] 'previous-error)
(define-key global-map "\C-x\C-l" 'toggle-truncate-lines)
;(global-set-key "\M-n" 'scroll-up-line)
;(global-set-key "\M-p" 'scroll-down-line)

;; 不要っぽかったら削除すること。
; (add-hook 'c-mode-common-hook
;             '(lambda ()
;              (progn
;                (c-toggle-hungry-state 1)
;                (setq c-basic-offset 4 indent-tabs-mode nil))))

;; Occur 時、Occur バッファを選択する
(defun occur-and-select (regexp &optional nlines)
  (interactive (occur-read-primary-args))
  (occur regexp nlines)
  (select-window (get-buffer-window "*Occur*"))
  (forward-line 1))
(global-set-key (kbd "M-s M-o") 'occur-and-select)

;; query-replace で正規表現を使用する
(define-key global-map "\M-%" 'query-replace-regexp)

;; F2で画面入替える
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
;; (global-set-key [S-f7] 'swap-screen)
;; (global-set-key [f7] 'swap-screen-with-cursor)


;; YaTeX like compile
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

;; 画面縦分割と移動をM-t一つで行う(C-x 3 C-x o --> C-t)
; (defun other-window-or-split ()
;   (interactive)
;   (when (one-window-p)
;     (split-window-horizontally))
;   (other-window 1))
; (global-set-key (kbd "C-t") 'other-window-or-split)

;; 1行コピーをおこなう
;; (defun copy-line (&optional arg)
;;   (interactive "p")
;;   (copy-region-as-kill
;;    (line-beginning-position)
;;    (line-beginning-position (1+ (or arg 1))))
;;   (message "Line copied"))
;; (global-set-key global-map (kbd "C-t C-t") 'copy-line)

;; 単語ごとの削除をコピーなしに変更
;; M-hに前の単語を削除を割り当て
(defun delete-word (arg)
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun backward-delete-word (arg)
  (interactive "p")
  (delete-word (- arg)))

;(bind-key "M-d" 'delete-word)
;(bind-key "M-h" 'backward-delete-word)
(define-key global-map "\M-h" 'backward-delete-word)

;; ファイル名をバッファ上で変更
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))
;; (bind-key "C-c C-n" 'rename-file-and-buffer)
