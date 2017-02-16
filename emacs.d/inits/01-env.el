
;; 対応する括弧をハイライトする
(show-paren-mode t)
(set-face-background 'show-paren-match-face "blue")
;;;; 遅延時間
(setq show-paren-delay 0)
;;;; 括弧の中をすべて強調表示
(setq show-paren-style 'expression)
;;;; 括弧だけを強調表示
;(setq show-paren-style 'parenthesis)
;;;; 対応する括弧が画面内にあるかどうかで強調を変える
;(setq show-paren-style 'mixed)

;; C-x C-b の表示モードの指定
(global-set-key (kbd "C-x C-b") 'bs-show)
; possible values for the configuration are:
;    ("all"                . bs-config--all)
;    ("files"              . bs-config--only-files)
;    ("files-and-scratch"  . bs-config--files-and-scratch)
;    ("all-intern-last"    . bs-config--all-intern-last)
(setq bs-default-configuration "all")

;; 単語単位で補完する (e.g. p_h -> public_htmlm, _.-)
(partial-completion-mode 1)
