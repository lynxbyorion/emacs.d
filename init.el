;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq show-paren-style 'expression)
(show-paren-mode 2)

(set-face-attribute 'default nil
		    :family "PragmataPro")

(setq make-backup-files nil)
(setq auto-save-list-file-name nil)
(setq auto-save-default nil)

(ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-enerywhere t)

;; my name and email adress
(setq user-full-name "Gennady Sazonov")
(setq user-mail-adress "lynxbyorion@gmail.com")

(package-initialize)


(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize)
  )

(use-package linum
  :config
  (progn
    (setq linum-format "%3d ")
    (global-linum-mode 1)
    )
  )

(use-package auto-complete
  :ensure t
  :config
  (ac-config-default)
  )

(use-package projectile
  :ensure projectile
  :config (projectile-global-mode t)
  )

(use-package magit
  :ensure magit
  )

(use-package git-gutter+
  :ensure t
  :config
  (progn
    (global-git-gutter+-mode)
    ;; (git-gutter+:linum-setup)
    )
  )

(use-package tex
  :ensure auctex
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-PDF-mode t)
  (setq-default TeX-master nil)
  :ensure latex-preview-pane
  :config
  '(latex-preview-pane-multifile-mode (quote auctex))
  )
