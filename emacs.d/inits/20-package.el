;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; (add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
;; (package-initialize)

;; (require 'cl)

;; (defvar installing-package-list
;;   '(
;;     ;; ここに使っているパッケージを書く。
;;     minibuffer-complete-cycle
;;     redo+
;;     point-undo
;;     browse-kill-ring
;;     recentf-ext
;;     yaml-mode
;;     bind-key
;;     smart-tab
;;     auto-shell-command
;;     elscreen
;;     ))

;; (let ((not-installed (loop for x in installing-package-list
;;                             when (not (package-installed-p x))
;;                             collect x)))
;;   (when not-installed
;;     (package-refresh-contents)
;;     (dolist (pkg not-installed)
;;         (package-install pkg))))
