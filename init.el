;; Bref: Emacs init dot file.
;; Author: lynxbyorion.
;; based on https://github.com/lunaryorn/.emacs.d

;; add ~/.emacs.d/lisp to load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Please don't load outdated byte code
(setq load-prefer-newer t)

(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq show-paren-style 'expression)
(show-paren-mode 2)

(set-face-attribute 'default nil
		    :family "Hack"
		    :height 120
		    )

(setq make-backup-files nil)
(setq auto-save-list-file-name nil)
(setq auto-save-default nil)

(ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-enerywhere t)

;; my name and email adress
(setq user-full-name "Gennady Sazonov")
(setq user-mail-adress "lynxbyorion@gmail.com")

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

;;; Colour theme
(use-package solarized
  :ensure solarized-theme
  :config
  ;; Disable variable pitch fonts in Solarized theme
  (progn
    (load-theme 'solarized-light 'no-confirm)))

;;; Turn page breaks into lines
(use-package page-break-lines
  :ensure t
  :init (global-page-break-lines-mode)
  :diminish page-break-lines-mode)

;;; Highlight cursor position in buffer
(use-package beacon
 :ensure t
 :init (beacon-mode 1)
 :diminish beacon-mode)

;;; Search init file for bugs
(use-package bug-hunter
  :ensure t)

;;; The mode line
(line-number-mode)
(column-number-mode)

;;;  Fancy battery info for mode line
(use-package fancy-battery
  :ensure t
  :defer t
  :init (fancy-battery-mode))

;;; Save buffers when focus is lost
(use-package focus-autosave-mode
  :ensure t
  :init (focus-autosave-mode)
  :diminish focus-autosave-mode)

;;; Better buffer list
(use-package ibuffer
  :bind (([remap list-buffers] . ibuffer))
  ;; Show VC Status in ibuffer
  :config
  (setq ibuffer-formats
        '((mark modified read-only vc-status-mini " "
                (name 18 18 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " "
                (vc-status 16 16 :left)
                " "
                filename-and-process)
          (mark modified read-only " "
                (name 18 18 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " " filename-and-process)
          (mark " " (name 16 -1) " " filename))))

;;; Group buffers by VC project and status
(use-package ibuffer-vc
  :ensure t
  :defer t
  :init (add-hook 'ibuffer-hook
                  (lambda ()
                    (ibuffer-vc-set-filter-groups-by-vc-root)
                    (unless (eq ibuffer-sorting-mode 'alphabetic)
                      (ibuffer-do-sort-by-alphabetic)))))

;;; Group buffers by Projectile project
(use-package ibuffer-projectile
  :ensure t
  :disabled t
  :defer t
  :init (add-hook 'ibuffer-hook #'ibuffer-projectile-set-filter-groups))

;;; Save buffers, windows and frames
(use-package desktop
  :disabled t
  :init (desktop-save-mode)
  :config
  ;; Save desktops a minute after Emacs was idle.
  (setq desktop-auto-save-timeout 60)
  ;; Don't save Magit and Git related buffers
  (dolist (mode '(magit-mode magit-log-mode))
    (add-to-list 'desktop-modes-not-to-save mode))
  (add-to-list 'desktop-files-not-to-save (rx bos "COMMIT_EDITMSG")))

;;; Distraction-free editing
(use-package writeroom-mode
  :ensure t
  :bind (("C-c t r" . writeroom-mode)))

;;; The server of `emacsclient'
(use-package server
  :ensure nil
  :config
  (unless (server-running-p)
    (server-start))
  :diminish (server-buffer-clients . " ⓒ"))

;;; Edit directories
(use-package dired
  :defer t
  :config
  (setq dired-auto-revert-buffer t    ; Revert on re-visiting
        ;; Better dired flags: `-l' is mandatory, `-a' shows all files, `-h'
        ;; uses human-readable sizes, and `-F' appends file-type classifiers
        ;; to file names (for better highlighting)
        dired-listing-switches "-alhF"
        dired-ls-F-marks-symlinks t   ; -F marks links with @
        ;; Inhibit prompts for simple recursive operations
        dired-recursive-copies 'always
        ;; Auto-copy to other Dired split window
        dired-dwim-target t)

  (when (or (memq system-type '(gnu gnu/linux))
            (string= (file-name-nondirectory insert-directory-program) "gls"))
    ;; If we are on a GNU system or have GNU ls, add some more `ls' switches:
    ;; `--group-directories-first' lists directories before files, and `-v'
    ;; sorts numbers in file names naturally, i.e. "image1" goes before
    ;; "image02"
    (setq dired-listing-switches
          (concat dired-listing-switches " --group-directories-first -v"))))

;;; Save recently visited files
(use-package recentf
  :init (recentf-mode)
  :config
  (setq recentf-max-saved-items 200
        recentf-max-menu-items 15
        ;; Cleanup recent files only when Emacs is idle, but not when the mode
        ;; is enabled, because that unnecessarily slows down Emacs. My Emacs
        ;; idles often enough to have the recent files list clean up regularly
        recentf-auto-cleanup 300
        recentf-exclude (list "/\\.git/.*\\'" ; Git contents
                              "/elpa/.*\\'" ; Package files
                              "/itsalltext/" ; It's all text temp files
                              ;; And all other kinds of boring files
                              #'ignoramus-boring-p)))

;;; Save carriage place in file
(use-package saveplace
  :init (save-place-mode 1))

(setq view-read-only t)

;;; Auto-revert buffers of changed files
(use-package autorevert
  :init (global-auto-revert-mode)
  :config
  (setq auto-revert-verbose nil         ; Shut up, please!
        ;; Revert Dired buffers, too
        global-auto-revert-non-file-buffers t)

  (when (eq system-type 'darwin)
    ;; File notifications aren't supported on OS X
    (setq auto-revert-use-notify nil))
  :diminish (auto-revert-mode . " Ⓐ"))

(use-package image-file                 ; Visit images as images
  :init (auto-image-file-mode))

(use-package launch                     ; Open files in external programs
  :ensure t
  :defer t)

;;; Navigation and scrolling
(setq scroll-conservatively 1000        ; Never recenter the screen while scrolling
      scroll-error-top-bottom t         ; Move to beg/end of buffer before
                                        ; signalling an error
      ;; These settings make trackpad scrolling on OS X much more predictable
      ;; and smooth
      mouse-wheel-progressive-speed nil
      mouse-wheel-scroll-amount '(1))

(use-package linum
  :config
  (progn
    (setq linum-format "%3d ")
    (global-linum-mode 1)
    )
  )

(use-package hl-line                    ; Highlight the current line
  :init (global-hl-line-mode 1))

(use-package rainbow-delimiters         ; Highlight delimiters by depth
  :ensure t
  :defer t
  :init
  (dolist (hook '(text-mode-hook prog-mode-hook))
    (add-hook hook #'rainbow-delimiters-mode)))

(use-package highlight-numbers          ; Fontify number literals
  :ensure t
  :defer t
  :init (add-hook 'prog-mode-hook #'highlight-numbers-mode))

(use-package rainbow-mode               ; Fontify color values in code
  :ensure t
  :bind (("C-c t r" . rainbow-mode))
  :config (add-hook 'css-mode-hook #'rainbow-mode))

(use-package auto-complete
  :ensure t
  :config
  (ac-config-default)
  )

(use-package projectile
  :ensure projectile
  :config (projectile-global-mode t)
  )

;;; Highlight hunks in fringe
(use-package diff-hl
  :ensure t
  :defer t
  :init
  ;; Highlight changes to the current file in the fringe
  (global-diff-hl-mode)
  ;; Highlight changed files in the fringe of Dired
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)

  ;; Fall back to the display margin, if the fringe is unavailable
  (unless (display-graphic-p)
    (diff-hl-margin-mode))

  ;; Refresh diff-hl after Magit operations
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(use-package magit
  :ensure magit
  :bind ("C-x g" . magit-status)
  )

 (use-package ediff
    :defer t
    :init
    (progn
      ;; first we set some sane defaults
      (setq-default
       ediff-window-setup-function 'ediff-setup-windows-plain
       ;; emacs is evil and decrees that vertical shall henceforth be horizontal
       ediff-split-window-function 'split-window-horizontally
       ediff-merge-split-window-function 'split-window-horizontally)
      ;; restore window layout when done
      (add-hook 'ediff-quit-hook #'winner-undo)))


(use-package tex
  :ensure auctex
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  ;; (setq TeX-PDF-mode nil)
  (setq-default TeX-master nil)
  (add-hook 'LaTeX-mode-hook 'visual-line-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t)
  (setq TeX-PDF-mode t)

  ;; Use Skim as viewer, enable source <-> PDF sync
  ;; make latexmk available via C-c C-c
  ;; Note: SyncTeX is setup via ~/.latexmkrc (see below)
  (add-hook 'LaTeX-mode-hook (lambda ()
                               (push
                                '("latexmk" "latexmk -pdf %s" TeX-run-TeX nil t
                                  :help "Run latexmk on file")
                                TeX-command-list)))
  (add-hook 'TeX-mode-hook '(lambda () (setq TeX-command-default "latexmk")))

  ;; use Skim as default pdf viewer
  ;; Skim's displayline is used for forward search (from .tex to .pdf)
  ;; option -b highlights the current line; option -g opens Skim in the background  
  (setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
  (setq TeX-view-program-list
        '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -r %n %o %b")))
  )

;;; Spelling and syntax checking
(use-package ispell                     ; Spell checking
  :defer t
  :config
  (setq ispell-program-name (if (eq system-type 'darwin)
                                (executable-find "aspell")
                              (executable-find "hunspell"))
        ispell-dictionary "ru"     ; Default dictionnary
        ispell-silently-savep t       ; Don't ask when saving the private dict
        ;; Increase the height of the choices window to take our header line
        ;; into account.
        ispell-choices-win-default-height 5)

  (unless ispell-program-name
    (warn "No spell checker available.  Install Hunspell or ASpell for OS X.")))

(use-package flyspell                   ; On-the-fly spell checking
  :bind (("C-c t s" . flyspell-mode)
         ("C-c l b" . flyspell-buffer))
  :init (progn (dolist (hook '(text-mode-hook message-mode-hook))
                 (add-hook hook 'turn-on-flyspell))
               (add-hook 'prog-mode-hook 'flyspell-prog-mode))
  :config
  (progn
    (setq flyspell-use-meta-tab nil
          ;; Make Flyspell less chatty
          flyspell-issue-welcome-flag nil
          flyspell-issue-message-flag nil)

    ;; Free C-M-i for completion
    (define-key flyspell-mode-map "\M-\t" nil)
    ;; Undefine mouse buttons which get in the way
    (define-key flyspell-mouse-map [down-mouse-2] nil)
    (define-key flyspell-mouse-map [mouse-2] nil))
  :diminish (flyspell-mode . " ⓢ"))


;;; Basic editing

;; Disable tabs, but given them proper width
(setq-default indent-tabs-mode nil
              tab-width 8)
;; Make Tab complete if the line is indented
(setq tab-always-indent 'complete)

;; Indicate empty lines at the end of a buffer in the fringe, but require a
;; final new line
(setq indicate-empty-lines t
      require-final-newline t)

(setq kill-ring-max 200                 ; More killed items
      kill-do-not-save-duplicates t     ; No duplicates in kill ring
      ;; Save the contents of the clipboard to kill ring before killing
      save-interprogram-paste-before-kill t)

;; Configure a reasonable fill column, indicate it in the buffer and enable
;; automatic filling
(setq-default fill-column 80)
(add-hook 'text-mode-hook #'auto-fill-mode)
(diminish 'auto-fill-function " Ⓕ")

(bind-key "C-c x i" #'indent-region)

;; ;;; Buffer, Windows and Frames
;; (setq frame-resize-pixelwise t          ; Resize by pixels
;;       frame-title-format
;;       '(:eval (if (buffer-file-name)
;;                   (abbreviate-file-name (buffer-file-name)) "%b"))
;;       ;; Size new windows proportionally wrt other windows
;;       window-combination-resize t)

;; (setq-default line-spacing 0.2)         ; A bit more spacing between lines

;; (defun lunaryorn-display-buffer-fullframe (buffer alist)
;;   "Display BUFFER in fullscreen.
;; ALIST is a `display-buffer' ALIST.
;; Return the new window for BUFFER."
;;   (let ((window (display-buffer-pop-up-window buffer alist)))
;;     (when window
;;       (delete-other-windows window))
;;     window))

;; ;; Configure `display-buffer' behaviour for some special buffers.
;; (setq display-buffer-alist
;;       `(
;;         ;; Magit status window in fullscreen
;;         (,(rx "*magit: ")
;;          (lunaryorn-display-buffer-fullframe)
;;          (reusable-frames . nil))
;;         ;; Give Helm Help a non-side window because Helm as very peculiar ideas
;;         ;; about how to display its help
;;         (,(rx bos "*Helm Help" (* nonl) "*" eos)
;;          (display-buffer-use-some-window
;;           display-buffer-pop-up-window))
;;         ;; Nail Helm to the side window
;;         (,(rx bos "*" (* nonl) "helm" (* nonl) "*" eos)
;;          (display-buffer-in-side-window)
;;          (side . bottom)
;;          (window-height . 0.4)
;;          (window-width . 0.6))
;;         ;; Put REPLs and error lists into the bottom side window
;;         (,(rx bos
;;               (or "*Help"                 ; Help buffers
;;                   "*Warnings*"            ; Emacs warnings
;;                   "*compilation"          ; Compilation buffers
;;                   "*Flycheck errors*"     ; Flycheck error list
;;                   "*shell"                ; Shell window
;;                   "*sbt"                  ; SBT REPL and compilation buffer
;;                   "*ensime-update*"       ; Server update from Ensime
;;                   "*SQL"                  ; SQL REPL
;;                   "*Cargo"                ; Cargo process buffers
;;                   (and (1+ nonl) " output*") ; AUCTeX command output
;;                   ))
;;          (display-buffer-reuse-window
;;           display-buffer-in-side-window)
;;          (side            . bottom)
;;          (reusable-frames . visible)
;;          (window-height   . 0.33))
;;         ;; Let `display-buffer' reuse visible frames for all buffers.  This must
;;         ;; be the last entry in `display-buffer-alist', because it overrides any
;;         ;; later entry with more specific actions.
;;         ("." nil (reusable-frames . visible))))

;; (use-package frame                      ; Frames
;;   :bind (("C-c w F" . toggle-frame-fullscreen))
;;   :init (progn
;;           ;; Kill `suspend-frame'
;;           (global-set-key (kbd "C-z") nil)
;;           (global-set-key (kbd "C-x C-z") nil))
;;   :config (add-to-list 'initial-frame-alist '(fullscreen . fullboth)))

;; don't open files from the workspace in a new frame
(setq ns-pop-up-frames nil)

;; use old-style fullscreen
(setq ns-use-native-fullscreen nil)

;; move deleted files to ~/.Trash
(setq trash-directory "~/.Trash")

;; ;; OS X support
;; (use-package ns-win                     ; OS X window support
;;   :defer t
;;   :if (eq system-type 'darwin)
;;   :config
;;   (setq ns-pop-up-frames nil
;;         pop-up-windows nil
;;                                         ; Don't pop up new frames from the
;;                                         ; workspace
;;         mac-option-modifier 'meta       ; Option is simply the natural Meta
;;         mac-command-modifier 'meta      ; But command is a lot easier to hit
;;         mac-right-command-modifier 'left
;;         mac-right-option-modifier 'none ; Keep right option for accented input
;;         ;; Just in case we ever need these keys
;;         mac-function-modifier 'hyper))

;; (setq magit-restore-window-configuration t) ; that's the default actually
;; (setq magit-status-buffer-switch-function
;;       (lambda (buffer) ; there might already be an Emacs function which does this
;;         (pop-to-buffer buffer)
;;         (delete-other-windows)))

;; (setq pop-up-windows nil)

;;; save custom settings (unversioned) locally
(setq custom-file (expand-file-name
                   "init-local.el"
                   (expand-file-name "lisp" user-emacs-directory)))

(require 'init-behavior)

(use-package fill-column-indicator
  :ensure fill-column-indicator
  :config
  (add-hook 'prog-mode-hook 'fci-mode)
  (add-hook 'LaTeX-mode-hook 'fci-mode))
