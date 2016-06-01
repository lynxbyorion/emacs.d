
(defun lx-is-previous()
  (when (not (boundp 'lx-x))
    (setq lx-x 2)))

(defun lx-switch-previous-window()
  (interactive)
  (lx-is-previous)
  (if (eq lx-x 1)
      (progn
        (other-window -1)
        (setq lx-x 2))
    (progn
      (other-window 1)
      (setq lx-x 1))))

(global-set-key (kbd "C-x p") (lambda () (interactive) (lx-switch-previous-window)))

(provide 'init-behavior)
