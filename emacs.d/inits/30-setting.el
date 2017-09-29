;; 画面端で折り返さない
;;;; 通常
(setq-default truncate-lines t)
;;;; 縦分割時
(setq-default truncate-partial-width-windows t)

;; shellスクリプトでヒアドキュメントの補完を無効にする
(add-hook 'sh-mode-hook
          (lambda ()
            (sh-electric-here-document-mode -1)))

;; shell mode でzshを使用する
(setq shell-file-name "zsh")
(setenv "SHELL" shell-file-name)
(setq explicit-shell-file-name shell-file-name)

;; dired
;;;; dired を diredx に切り替える
(add-hook 'dired-load-hook (lambda () (load "dired-x")))

;;;; C-sした時にファイル名だけにマッチするようにする
(setq dired-isearch-filenames t)

;;;; e を押すとリネームできる
(require 'wdired)
(define-key dired-mode-map "e" 'wdired-change-to-wdired-mode)

;;;; diredで出てくる書き込み権限等を非表示
(define-key dired-mode-map (kbd "(") 'dired-hide-details-mode)
(define-key dired-mode-map (kbd ")") 'dired-hide-details-mode)

;;;; ls オプション
;(setq dired-listing-switches "-ltrh --group-directories-first --time-style=long-iso")
(setq dired-listing-switches "-lh --group-directories-first --time-style=long-iso")


;; 先頭が#!から始まる場合，実行権限をつけて保存する
;(add-hook 'after-save-hook
;          'executable-make-buffer-file-executable-if-script-p)

;; redo+
(require 'redo+)
(global-set-key (kbd "C-M-_") 'redo)
(setq undo-no-redo t) ; 過去のundoがredoされないようにする
(setq undo-limit 600000)
(setq undo-strong-limit 900000)

;; elscreen
(require 'elscreen)
(elscreen-start)

;; コンパイルに成功したら *compilation* バッファを閉じる
; 指定したバッファに警告の文字列があるか
; (defun my-compilation-warning-bufferp (buf)
;   (save-current-buffer
;     (set-buffer buf)
;     (save-excursion
;         (goto-char (point-min))
;           (if (or (search-forward "warning:" nil t)
;                     (search-forward "警告:" nil t)) t nil))))
; ; バッファに"abnormally"や警告メッセージがなければウィンドウを閉じる
; (defun my-close-compilation-buffer-if-succeeded (buf str)
;   (cond ((string-match "abnormally" str)
;           (message "Error!"))
;         ((if (my-compilation-warning-bufferp buf)
;               (message "Warning!")))
;         (t
;           (delete-window (get-buffer-window buf))
;            (message "Succeeded"))))
; ; compile終了時の実行関数に追加する
; (if compilation-finish-functions
;   (append compilation-finish-functions
;             '(my-close-compilation-buffer-if-succeeded))
;   (setq compilation-finish-functions
;         '(my-close-compilation-buffer-if-succeeded)))
