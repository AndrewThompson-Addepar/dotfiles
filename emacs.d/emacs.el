;;; -*- lexical-binding: t -*-

(require 'local-setup "~/.emacs.d/local.el")

(setq *is-a-mac* (eq system-type 'darwin)
      *is-linux* (eq system-type 'gnu/linux)
      *is-windows* (eq system-type 'windows-nt))

(setq straight-repository-branch "develop")

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-cache-autoloads t
      straight-use-package-by-default t)

;; Install use-package
(straight-use-package 'use-package)

;; Configure use-package to use straight.el by default
(use-package straight
  :custom
  (straight-use-package-by-default t))

(use-package compat
  :straight (:host github :repo "emacs-compat/compat"))

(use-package diminish) ;; for :diminish
(use-package bind-key) ;; for :bind

(straight-use-package 'org)

(use-package use-package-ensure-system-package)

(use-package gcmh
  :hook (after-init . gcmh-mode))

(setq read-process-output-max (* 1024 1024)) ;; 1mb

(use-package emacs
  :straight nil
  :init
  ;; answer with y/n instead of typing out yes/no
  (defalias 'yes-or-no-p 'y-or-n-p)
  :config
  (setq indent-tabs-mode nil
        tab-width 4
        show-trailing-whitespace t)
  (setq-default fill-column 100)
  (setq fill-column 100)
  :custom
  ;; load new source files instead of stale elisp bytecode
  (load-prefer-newer t)
  ;; allow emacs to be any size, removes black bars
  (frame-resize-pixelwise t))

(use-package autorevert
  :straight nil
  :custom
  (global-revert-check-vc-info t)
  :config
  (global-auto-revert-mode +1))

(use-package mule
  :straight nil
  :config
  (prefer-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (set-language-environment 'utf-8)
  (set-terminal-coding-system 'utf-8-unix)
  (setq locale-coding-system 'utf-8-unix)
  (set-selection-coding-system 'utf-8-unix))

(use-package files
  :straight nil
  :config
  (setq
   backup-by-copying t
   backup-directory-alist '((".*" . "~/.emacs.d/backups/"))
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t
   vc-make-backup-files t
   recentf-max-menu-items 25
   recentf-max-saved-items 500))

(use-package simple
  :straight nil
  :custom
  ;; killing and yanking uses the system clipboard
  (save-interprogram-paste-before-kill t)
  :config
  ;; display column info in the modeline
  (column-number-mode +1))

(use-package so-long
  :straight nil
  :config
  (global-so-long-mode +1))

(use-package saveplace
  :straight nil
  :config
  (save-place-mode +1))

(use-package no-littering
  :init
  (setq no-littering-etc-directory
        (expand-file-name "etc/" user-emacs-directory))
  (setq no-littering-var-directory
        (expand-file-name "var/" user-emacs-directory)))

(use-package paren
  :straight nil
  :custom
  (show-paren-delay 0)
  :config
  (show-paren-mode +1))

(use-package general
  :straight t
  :custom
  (general-override-states '(insert emacs hybrid normal visual motion operator replace))
  :config
  (general-define-key
   "C-w" 'backward-kill-word
   "C-c C-k" 'kill-region
   "C-x C-k" 'kill-region
   "C-x C-b" 'ibuffer
   "M-s" 'highlight-symbol-at-point
   "M-c" 'hi-lock-mode
   "M-z" 'pop-global-mark
   )

  (general-override-mode)
  (general-create-definer my-leader-def
    :prefix "C-c")
  (my-leader-def
    "a" 'org-agenda
    "c" 'comment-dwim
    "RET" 'make-frame-command
    ;; bookmarks
    "b" '(:ignore t :wk "bookmarks")
    "bs" 'bookmark-set
    "bg" 'bookmark-jump
    "bl" 'bookmark-bmenu-list
    ;; quit / restart
    "q" '(:ignore t :wk "quit / restart")
    "qq" 'save-buffers-kill-terminal
    "qQ" 'save-buffers-kill-emacs
    "qr" 'restart-emacs))

(use-package which-key
  :straight t
  :custom
  (which-key-idle-delay 0)
  :config
  (which-key-mode +1)
  ;(which-key-setup-minibuffer)
  (which-key-setup-side-window-bottom)
  )

(use-package hydra
  :straight t
  :defer t)

;; This allows us to use :hydra within use-package
(use-package use-package-hydra
  :ensure t)

(my-leader-def "z" '(hydra-zoom/body :wk "zoom"))
(defhydra hydra-zoom (:column 2)
    ("n" text-scale-increase "Zoom in")
    ("t" text-scale-decrease "Zoom out")
    ("r" (text-scale-set 0) "Reset zoom")
    ("0" (text-scale-set 0) :bind nil :exit t))

(general-define-key "C-n" 'hydra-move/body)
(defhydra hydra-move
  (:body-pre (next-line))
  "navigation"
  ("n" next-line)
  ("p" previous-line)
  ("f" forward-char)
  ("b" backward-char)
  ("a" beginning-of-line)
  ("e" move-end-of-line)
  ("v" scroll-up-command)
  ;; Converting M-v to V here by analogy.
  ("V" scroll-down-command)
  ("l" recenter-top-bottom)
  ("<" beginning-of-buffer)
  (">" end-of-buffer))

(my-leader-def "R" '(hydra-rectangle/body :wk "rectangle"))
(defhydra hydra-rectangle (:body-pre (rectangle-mark-mode 1)
                                     :color pink
                                     :hint nil
                                     :post (deactivate-mark))
       "
    ^_i_^       _w_ copy      _O_pen       _N_umber-lines
  _n_   _o_     _y_ank        _t_ype       _E_xchange-point
    ^_e_^       _d_ kill      _c_lear      _r_eset-region-mark
  ^^^^          _u_ndo        _g_ quit     ^ ^
  "
       ("i" rectangle-previous-line)
       ("e" rectangle-next-line)
       ("n" rectangle-backward-char)
       ("o" rectangle-forward-char)
       ("d" kill-rectangle)                    ;; C-x r k
       ("y" yank-rectangle)                    ;; C-x r y
       ("w" copy-rectangle-as-kill)            ;; C-x r M-w
       ("O" open-rectangle)                    ;; C-x r o
       ("t" string-rectangle)                  ;; C-x r t
       ("c" clear-rectangle)                   ;; C-x r c
       ("E" rectangle-exchange-point-and-mark) ;; C-x C-x
       ("N" rectangle-number-lines)            ;; C-x r N
       ("r" (if (region-active-p)
                (deactivate-mark)
              (rectangle-mark-mode 1)))
       ("u" undo nil)
       ("g" nil))

(my-leader-def "s" '(hydra-straight-helper/body :wk "pkgs"))
(defhydra hydra-straight-helper (:hint nil :color green)
       "
      _c_heck all       |_f_etch all     |_m_erge all      |_n_ormalize all   |p_u_sh all
      _C_heck package   |_F_etch package |_M_erge package  |_N_ormlize package|p_U_sh package
      ----------------^^+--------------^^+---------------^^+----------------^^+------------||_q_uit||
      _r_ebuild all     |_p_ull all      |_v_ersions freeze|_w_atcher start   |_g_et recipe
      _R_ebuild package |_P_ull package  |_V_ersions thaw  |_W_atcher quit    |prun_e_ build"
       ("c" straight-check-all)
       ("C" straight-check-package)
       ("r" straight-rebuild-all)
       ("R" straight-rebuild-package)
       ("f" straight-fetch-all)
       ("F" straight-fetch-package)
       ("p" straight-pull-all)
       ("P" straight-pull-package)
       ("m" straight-merge-all)
       ("M" straight-merge-package)
       ("n" straight-normalize-all)
       ("N" straight-normalize-package)
       ("u" straight-push-all)
       ("U" straight-push-package)
       ("v" straight-freeze-versions)
       ("V" straight-thaw-versions)
       ("w" straight-watcher-start)
       ("W" straight-watcher-quit)
       ("g" straight-get-recipe)
       ("e" straight-prune-build)
       ("q" nil))

(defun my/insert-unicode (unicode-name)
  "Same as C-x 8 enter UNICODE-NAME."
  (insert-char (gethash unicode-name (ucs-names))))

(my-leader-def "u" '(hydra-unicode/body :wk "unicode"))
(defhydra hydra-unicode (:hint nil)
  "
        Unicode  _e_ €  _g_ £
                 _f_ ♀  _r_ ♂
                 _o_ °  _m_ µ  _z_ ë  _Z_ Ë
                 _n_ ←  _e_ ↓  _i_ ↑  _o_ →
        "
  ("e" (my/insert-unicode "EURO SIGN"))
  ("g" (my/insert-unicode "POUND SIGN"))

  ("r" (my/insert-unicode "MALE SIGN"))
  ("f" (my/insert-unicode "FEMALE SIGN"))

  ("o" (my/insert-unicode "DEGREE SIGN"))
  ("m" (my/insert-unicode "MICRO SIGN"))

  ("z" (my/insert-unicode "LATIN SMALL LETTER E DIAERESIS"))
  ("Z" (my/insert-unicode "LATIN CAPITAL LETTER E DIAERESIS"))

  ("n" (my/insert-unicode "LEFTWARDS ARROW"))
  ("e" (my/insert-unicode "DOWNWARDS ARROW"))
  ("i" (my/insert-unicode "UPWARDS ARROW"))
  ("o" (my/insert-unicode "RIGHTWARDS ARROW")))

(use-package keyfreq
  :straight t
  :config
  (keyfreq-autosave-mode 1))

(use-package helm
  :straight t
  :diminish
  :init (helm-mode t)
  :config
  (setq helm-buffer-max-length 40)
  :bind (("M-x"     . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b"   . helm-mini)     ;; See buffers & recent files; more useful.
         ("C-x r b" . helm-filtered-bookmarks)
         ("C-x C-r" . helm-recentf)  ;; Search for recently edited files
         ("C-c i"   . helm-imenu)
         ("C-h a"   . helm-apropos)
         ;; Look at what was cut recently & paste it in.
         ("M-y" . helm-show-kill-ring)

         :map helm-map
         ;; We can list ‘actions’ on the currently selected item by C-z.
         ("C-z" . helm-select-action)
         ;; Let's keep tab-completetion anyhow.
         ("TAB"   . helm-execute-persistent-action)
          ("<tab>" . helm-execute-persistent-action)))

(setq helm-mini-default-sources '(helm-source-buffers-list
                                  helm-source-recentf
                                  helm-source-bookmarks
                                  helm-source-bookmark-set
                                  helm-source-buffer-not-found))
;; this stops helm pinging websites when it interprets texts as a url
(setq ffap-machine-p-known 'reject)
(use-package helm-descbinds
  :straight t
  :config (helm-descbinds-mode))

(use-package helm-make
  :straight t)

(use-package helm-swoop
  :straight t
  :config (setq helm-swoop-pre-input-function
                (lambda () ""))
  :general
  ("C-s"   'helm-swoop)
  ("C-M-s" 'helm-multi-swoop-all)
  ("C-S-s" 'helm-swoop-back-to-last-point)
  :custom (helm-swoop-split-with-multiple-windows nil "Do not split window inside the current window."))

(use-package anzu
  :straight t
  :config
  (global-anzu-mode)
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp))

(use-package undo-tree
  :straight t
  :ensure t
  :diminish
  :after hydra
  :general ("C-x /" 'hydra-undo-tree/body)
  :config
    (global-undo-tree-mode 1)
    (setq undo-tree-visualizer-timestamps t
          undo-tree-visualizer-diff t
          undo-tree-show-minibuffer-help t
          undo-tree-minibuffer-help-dynamic t
          undo-tree-show-help-in-visualize-buffer t)
  :hydra (hydra-undo-tree (:hint nil)
"
_p_: undo  _n_: redo _s_: save _l_: load   "
    ("p"   undo-tree-undo)
    ("n"   undo-tree-redo)
    ("s"   undo-tree-save-history)
    ("l"   undo-tree-load-history)
    ("u"   undo-tree-visualize "visualize" :color blue)
    ("q"   nil "quit" :color blue)))
; This helps undo-tree keep loading: https://github.com/syl20bnr/spacemacs/issues/14064
(with-eval-after-load 'undo-tree (defun undo-tree-overridden-undo-bindings-p () nil))

(use-package avy
  :straight t
  :config (setq avy-background t)
  :general ("C-'" 'avy-goto-char-timer))

(use-package multiple-cursors
  :straight t
  :defer t
  :general
  (my-leader-def
    "v" '(hydra-multiple-cursors/body :wk "mv-mode")) ;;oryx
  :hydra
  (hydra-multiple-cursors (:hint nil)
    "
 Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Next     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search      [_q_] Quit
 [_|_] Align with input CHAR       [Click] Cursor at point"
    ("l" mc/edit-lines)
    ("a" mc/mark-all-like-this :exit t)
    ("n" mc/mark-next-like-this)
    ("N" mc/skip-to-next-like-this)
    ("M-n" mc/unmark-next-like-this)
    ("p" mc/mark-previous-like-this)
    ("P" mc/skip-to-previous-like-this)
    ("M-p" mc/unmark-previous-like-this)
    ("|" mc/vertical-align)
    ("s" mc/mark-all-in-region-regexp :exit t)
    ("0" mc/insert-numbers :exit t)
    ("A" mc/insert-letters :exit t)
    ("<mouse-1>" mc/add-cursor-on-click)
    ;; Help with click recognition in this hydra
    ("<down-mouse-1>" ignore)
    ("<drag-mouse-1>" ignore)
    ("q" nil)))

(use-package iedit
  :straight t)

(use-package dashboard
  :straight t
  :config
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (registers . 5)))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-init-info (concat "Welcome "     user-full-name
                                    "! Emacs "      emacs-version
                                    "; System "     (system-name)
                                    "; Time "       (emacs-init-time))))

;; Emacs Start-up Profiler
(use-package esup
  :straight t
  :commands (esup))

;; Some basic config
(use-package emacs
  :straight nil
  :when *is-a-mac*
  :config
  (setq mac-command-modifier 'meta) ;; Mac atl/option to Control
  (setq mac-option-modifier 'control) ; Mac command to Meta
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (set-fontset-font t 'symbol (font-spec :family "Apple Symbols") nil 'prepend)
  (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") nil 'prepend))

(use-package cus-edit
  :straight nil
  :custom
  (custom-file (expand-file-name "custom.el" user-emacs-directory))
  :config
  (if (file-exists-p custom-file)
      (load-file custom-file)))

(use-package frame
  :straight nil
  :config
  (blink-cursor-mode -1)
  (setq initial-scratch-message ""
        inhibit-startup-message t
        visible-bell nil
        ring-bell-function 'ignore
        initial-frame-alist
        '((menu-bar-lines . 0)
          (tool-bar-lines . 0)))
  (scroll-bar-mode 0)
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (global-hl-line-mode 1))

(use-package dracula-theme
  :straight t
  :config
  (load-theme 'dracula))

(add-to-list 'default-frame-alist '(font . "Fira Code-14"))

(use-package all-the-icons
  :straight t
  :defer t)

(use-package doom-modeline
  :straight t
  :demand t
  :preface
  (defun my-doom-modeline-setup ()
    (column-number-mode +1)
    (doom-modeline-mode +1))
  :init (my-doom-modeline-setup)
  :config
  (setq doom-modeline-height 1)
  (set-face-attribute 'mode-line nil :height 150)
  (set-face-attribute 'mode-line-inactive nil :height 150)
  :custom
  (doom-modeline-vcs-max-length 50)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project))

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (setq show-paren-delay  0)
  (setq show-paren-style 'mixed))

(use-package beacon
  :straight t
  :diminish
  :config
  (setq beacon-color "#666600")
  (beacon-mode 1))

(use-package back-button
  :straight (back-button :host github :repo "rolandwalker/back-button")
  :general
  (my-leader-def
    "k" '(hydra-back-button/body :wk "back-button"))
  :config
  (back-button-mode 1)
  :hydra
  (hydra-back-button (:color red :hint nil)
      "
  Local         Global
--------------------------------
  _t_ forward   _e_ forward
  _s_ backward  _n_ backward
  "
    ("e" back-button-global-forward)
    ("n" back-button-global-backward)
    ("t" back-button-local-forward)
    ("s" back-button-local-backward)))

(use-package ace-window
  :straight t
  :general
  ("M-o" 'ace-window)
  :config
  (setq aw-keys '(?a ?r ?s ?t ?n ?e ?i ?o)))

(use-package switch-window
  :straight t
  :general
  ("C-x o" 'switch-window)
  :config
  (setq switch-window-shortcut-style 'qwerty))

(use-package eyebrowse
:ensure t
:init
(eyebrowse-mode t))

(use-package winner
  :commands winner-mode
  :init (winner-mode t))

(defun hydra-move-splitter-left (delta)
  "Move window splitter left."
  (interactive "p")
  (let ((windmove-wrap-around nil))
    (if (windmove-find-other-window 'right)
        (shrink-window-horizontally delta)
      (enlarge-window-horizontally delta))))

(defun hydra-move-splitter-right (delta)
  "Move window splitter right."
  (interactive "p")
  (let ((windmove-wrap-around nil))
    (if (windmove-find-other-window 'right)
        (enlarge-window-horizontally delta)
      (shrink-window-horizontally delta))))

(defun hydra-move-splitter-up (delta)
  "Move window splitter up."
  (interactive "p")
  (let ((windmove-wrap-around nil))
    (if (windmove-find-other-window 'up)
        (enlarge-window delta)
      (shrink-window delta))))

(defun hydra-move-splitter-down (delta)
  "Move window splitter down."
  (interactive "p")
  (let ((windmove-wrap-around nil))
    (if (windmove-find-other-window 'up)
        (shrink-window delta)
      (enlarge-window delta))))

(defhydra hydra-window-delux ()
       "
    ^Movement^        ^Split^          ^Switch^	        ^Resize^    ^Eyebrowse^
    -----------------------------------------------------------------------------
    _n_ ←             _v_ertical       _b_uffer	        _q_ X←       _c_lose config
    _e_ ↓             _h_orizontal     _f_ind files         _w_ X↓       _r_ename config
    _i_ ↑             _z_ undo         _a_ce 1	        _f_ X↑       _1_ setup 1
    _o_ →             _Z_ reset        _s_wap	        _p_ X→       _2_ setup 2
    _F_ollow	      _D_lt Other      _S_ave	        _m_aximize   _3_ setup 3
    _SPC_ cancel      _O_nly this      _d_elete	        _=_ balance  _4_ setup 4
    "
       ("n" windmove-left )
       ("e" windmove-down )
       ("i" windmove-up )
       ("o" windmove-right )

       ("q" hydra-move-splitter-left)
       ("w" hydra-move-splitter-down)
       ("f" hydra-move-splitter-up)
       ("p" hydra-move-splitter-right)
       ("b" helm-mini)
       ;("f" helm-find-files)
       ("F" follow-mode)
       ("a" (lambda ()
              (interactive)
              (ace-window 1)
              (add-hook 'ace-window-end-once-hook
                        'hydra-window/body))
           )
       ("v" (lambda ()
              (interactive)
              (split-window-right)
              (windmove-right))
           )
       ("h" (lambda ()
              (interactive)
              (split-window-below)
              (windmove-down))
           )
       ("s" (lambda ()
              (interactive)
              (ace-window 4)
              (add-hook 'ace-window-end-once-hook
                        'hydra-window/body)))
       ("S" save-buffer)
       ("d" delete-window)
       ("D" (lambda ()
              (interactive)
              (ace-window 16)
              (add-hook 'ace-window-end-once-hook
                        'hydra-window/body))
           )
       ("O" delete-other-windows)
       ("m" ace-maximize-window)
       ("z" (progn
              (winner-undo)
              (setq this-command 'winner-undo))
       )
       ("Z" winner-redo)
       ("=" balance-windows)

       ("c" eyebrowse-close-window-config)
       ("r" eyebrowse-rename-window-config)

       ("0" eyebrowse-switch-to-window-config-0)
       ("1" eyebrowse-switch-to-window-config-1)
       ("2" eyebrowse-switch-to-window-config-2)
       ("3" eyebrowse-switch-to-window-config-3)
       ("4" eyebrowse-switch-to-window-config-4)
       ("5" eyebrowse-switch-to-window-config-5)
       ("6" eyebrowse-switch-to-window-config-6)
       ("7" eyebrowse-switch-to-window-config-7)
       ("8" eyebrowse-switch-to-window-config-8)
       ("9" eyebrowse-switch-to-window-config-9)
       ("SPC" nil)
       )
(my-leader-def
  "w" '(hydra-window-delux/body :wk "Window Management"))

(setq ibuffer-saved-filter-groups
      '(("home"
         ("system-config" (or (filename . "dotfiles")
                              (filename . "emacs-config")))
         ("Org" (or (mode . org-mode)
                    (filename . "OrgMode")))
         ("code" (or (filename . "code")
                     (filename . ".py")
                     (filename . ".go")
                     (filename . ".java")))
         ("Web Dev" (or (mode . html-mode)
                        (mode . css-mode)))
         ("Directories" (mode . dired-mode))
         ("Help" (or (name . "\*Help\*")
                     (name . "\*Apropos\*")
                     (name . "\*info\*")))
         ("Builtin" (or (name . "\*Messages\*")
                        (name . "\*Completions\*")
                        (name . "\*Backtrace\*")
                        (name . "\*Compile-Log\*")
                        (name . "\*Calendar\*")
                        (name . "\*Calculator\*")
                        (name . "'*Scratch\*"))))))
(add-hook 'ibuffer-mode-hook
          '(lambda ()
             (ibuffer-auto-mode 1)
             (ibuffer-switch-to-saved-filter-groups "home")))
; hide empty filter groups
(setq ibuffer-show-empty-filter-groups nil)

(defhydra hydra-ibuffer-main (:color pink :hint nil)
  "
  ^Mark^         ^Actions^         ^View^          ^Select^              ^Navigation^
  _m_: mark      _D_: delete       _g_: refresh    _q_: quit             _i_:   ↑    _n_
  _u_: unmark    _s_: save marked  _S_: sort       _TAB_: toggle         _RET_: visit
  _*_: specific  _a_: all actions  _/_: filter     _o_: other window     _e_:   ↓    _o_
  _t_: toggle    _._: toggle hydra _H_: help       C-o other win no-select
  "
  ("m" ibuffer-mark-forward)
  ("u" ibuffer-unmark-forward)
  ("*" hydra-ibuffer-mark/body :color blue)
  ("t" ibuffer-toggle-marks)

  ("D" ibuffer-do-delete)
  ("s" ibuffer-do-save)
  ("a" hydra-ibuffer-action/body :color blue)

  ("g" ibuffer-update)
  ("S" hydra-ibuffer-sort/body :color blue)
  ("/" hydra-ibuffer-filter/body :color blue)
  ("H" describe-mode :color blue)

  ("n" ibuffer-backward-filter-group)
  ("i" ibuffer-backward-line)
  ("o" ibuffer-forward-filter-group)
  ("e" ibuffer-forward-line)
  ("RET" ibuffer-visit-buffer :color blue)

  ("TAB" ibuffer-toggle-filter-group)

  ("O" ibuffer-visit-buffer-other-window :color blue)
  ("q" quit-window :color blue)
  ("." nil :color blue))

(defhydra hydra-ibuffer-mark (:color teal :columns 5
                                     :after-exit (hydra-ibuffer-main/body))
  "Mark"
  ("*" ibuffer-unmark-all "unmark all")
  ("M" ibuffer-mark-by-mode "mode")
  ("m" ibuffer-mark-modified-buffers "modified")
  ("u" ibuffer-mark-unsaved-buffers "unsaved")
  ("s" ibuffer-mark-special-buffers "special")
  ("r" ibuffer-mark-read-only-buffers "read-only")
  ("/" ibuffer-mark-dired-buffers "dired")
  ("e" ibuffer-mark-dissociated-buffers "dissociated")
  ("h" ibuffer-mark-help-buffers "help")
  ("z" ibuffer-mark-compressed-file-buffers "compressed")
  ("b" hydra-ibuffer-main/body "back" :color blue))

(defhydra hydra-ibuffer-action (:color teal :columns 4
                                       :after-exit
                                       (if (eq major-mode 'ibuffer-mode)
                                           (hydra-ibuffer-main/body)))
  "Action"
  ("A" ibuffer-do-view "view")
  ("E" ibuffer-do-eval "eval")
  ("F" ibuffer-do-shell-command-file "shell-command-file")
  ("I" ibuffer-do-query-replace-regexp "query-replace-regexp")
  ("H" ibuffer-do-view-other-frame "view-other-frame")
  ("N" ibuffer-do-shell-command-pipe-replace "shell-cmd-pipe-replace")
  ("M" ibuffer-do-toggle-modified "toggle-modified")
  ("O" ibuffer-do-occur "occur")
  ("P" ibuffer-do-print "print")
  ("Q" ibuffer-do-query-replace "query-replace")
  ("R" ibuffer-do-rename-uniquely "rename-uniquely")
  ("T" ibuffer-do-toggle-read-only "toggle-read-only")
  ("U" ibuffer-do-replace-regexp "replace-regexp")
  ("V" ibuffer-do-revert "revert")
  ("W" ibuffer-do-view-and-eval "view-and-eval")
  ("X" ibuffer-do-shell-command-pipe "shell-command-pipe")
  ("b" nil "back"))

(defhydra hydra-ibuffer-sort (:color amaranth :columns 3)
  "Sort"
  ("i" ibuffer-invert-sorting "invert")
  ("a" ibuffer-do-sort-by-alphabetic "alphabetic")
  ("v" ibuffer-do-sort-by-recency "recently used")
  ("s" ibuffer-do-sort-by-size "size")
  ("f" ibuffer-do-sort-by-filename/process "filename")
  ("m" ibuffer-do-sort-by-major-mode "mode")
  ("b" hydra-ibuffer-main/body "back" :color blue))

(defhydra hydra-ibuffer-filter (:color amaranth :columns 4)
  "Filter"
  ("m" ibuffer-filter-by-used-mode "mode")
  ("M" ibuffer-filter-by-derived-mode "derived mode")
  ("n" ibuffer-filter-by-name "name")
  ("c" ibuffer-filter-by-content "content")
  ("e" ibuffer-filter-by-predicate "predicate")
  ("f" ibuffer-filter-by-filename "filename")
  (">" ibuffer-filter-by-size-gt "size")
  ("<" ibuffer-filter-by-size-lt "size")
  ("/" ibuffer-filter-disable "disable")
  ("b" hydra-ibuffer-main/body "back" :color blue))

(general-define-key
 :keymaps 'ibuffer-mode-map
 "." 'hydra-ibuffer-main/body)

(use-package dired
  :straight nil
  :defer t
  :hook (dired-mode . dired-hide-details-mode)
  :general
  (my-leader-def
    "d" 'dired)
  (dired-mode-map "." 'hydra-dired/body)
  :hydra
  (hydra-dired (:hint nil :color pink)
  "
_+_ mkdir          _v_iew           _m_ark             _(_ details        _i_nsert-subdir    wdired
_C_opy             _O_ view other   _U_nmark all       _)_ omit-mode      _$_ hide-subdir    C-x C-q : edit
_D_elete           _o_pen other     _u_nmark           _l_ redisplay      _w_ kill-subdir    C-c C-c : commit
_R_ename           _M_ chmod        _t_oggle           _g_ revert buf     _e_ ediff          C-c ESC : abort
_Y_ rel symlink    _G_ chgrp        _E_xtension mark   _s_ort             _=_ pdiff
_S_ymlink          ^ ^              _F_ind marked      _._ toggle hydra   \\ flyspell
_r_sync            ^ ^              ^ ^                ^ ^                _?_ summary
_z_ compress-file  _A_ find regexp
_Z_ compress       _Q_ repl regexp

T - tag prefix
"
    ("\\" dired-do-ispell)
    ("(" dired-hide-details-mode)
    (")" dired-omit-mode)
    ("+" dired-create-directory)
    ("=" diredp-ediff)         ;; smart diff
    ("?" dired-summary)
    ("$" diredp-hide-subdir-nomove)
    ("A" dired-do-find-regexp)
    ("C" dired-do-copy)        ;; Copy all marked files
    ("D" dired-do-delete)
    ("E" dired-mark-extension)
    ("e" dired-ediff-files)
    ("F" dired-do-find-marked-files)
    ("G" dired-do-chgrp)
    ("g" revert-buffer)        ;; read all directories again (refresh)
    ("i" dired-maybe-insert-subdir)
    ("l" dired-do-redisplay)   ;; relist the marked or singel directory
    ("M" dired-do-chmod)
    ("m" dired-mark)
    ("O" dired-display-file)
    ("o" dired-find-file-other-window)
    ("Q" dired-do-find-regexp-and-replace)
    ("R" dired-do-rename)
    ("r" dired-do-rsynch)
    ("S" dired-do-symlink)
    ("s" dired-sort-toggle-or-edit)
    ("t" dired-toggle-marks)
    ("U" dired-unmark-all-marks)
    ("u" dired-unmark)
    ("v" dired-view-file)      ;; q to exit, s to search, = gets line #
    ("w" dired-kill-subdir)
    ("Y" dired-do-relsymlink)
    ("z" diredp-compress-this-file)
    ("Z" dired-do-compress)
    ("q" nil)
    ("." nil :color blue)))

;; Colourful columns.
(use-package diredfl
  :straight t
  :after dired
  :config
  (diredfl-global-mode +1))

(use-package dired-git-info
    :straight t
    :general ('dired-mode-map
              "C-(" 'dired-git-info-mode))

(use-package projectile
  :straight t
  :general
  (my-leader-def
    "H" '(hydra-projectile/body :wk "projectile-mode")) ;;oryx
  (projectile-mode-map "C-c h" 'projectile-command-map)
  :config
  (projectile-mode +1)
  :hydra
  (hydra-projectile (:color teal
                            :hint nil)
  "
     PROJECTILE: %(projectile-project-root)

     Find File            Search/Tags          Buffers                Cache
------------------------------------------------------------------------------------------
_s-f_: file            _a_: ag                _i_: Ibuffer           _c_: cache clear
 _ff_: file dwim       _g_: update gtags      _b_: switch to buffer  _x_: remove known project
 _fd_: file curr dir   _o_: multi-occur     _s-k_: Kill all buffers  _X_: cleanup non-existing
  _r_: recent file                                               ^^^^_z_: cache current
  _d_: dir

"
    ("a"   helm-rg)
    ("b"   projectile-switch-to-buffer)
    ("c"   projectile-invalidate-cache)
    ("d"   projectile-find-dir)
    ("s-f" projectile-find-file)
    ("ff"  projectile-find-file-dwim)
    ("fd"  projectile-find-file-in-directory)
    ("g"   ggtags-update-tags)
    ("s-g" ggtags-update-tags)
    ("i"   projectile-ibuffer)
    ("K"   projectile-kill-buffers)
    ("s-k" projectile-kill-buffers)
    ("m"   projectile-multi-occur)
    ("o"   projectile-multi-occur)
    ("s-p" projectile-switch-project "switch project")
    ("p"   projectile-switch-project)
    ("s"   projectile-switch-project)
    ("r"   projectile-recentf)
    ("x"   projectile-remove-known-project)
    ("X"   projectile-cleanup-known-projects)
    ("z"   projectile-cache-current-file)
    ("`"   hydra-projectile-other-window/body "other window")
    ("q"   nil "cancel" :color blue)))

(use-package ibuffer-vc
  :straight t
  :config
  (add-hook 'ibuffer-hook #'ibuffer-vc-set-filter-groups-by-vc-root))

(use-package ibuffer-projectile
  :straight t)

(use-package helm-projectile
  :straight t
  :after projectile
  :config
  (helm-projectile-on))

(use-package helm-rg
  :straight t
  :ensure t
  :config
  (setq helm-rg-default-directory 'git-root))

(use-package helm-ag
  :straight t
  :ensure t
  :config
  (setq ag-arguments (list "--smart-case" "--column")))

(use-package treemacs
  :straight t
  :defer t
  :general ([f8] 'treemacs))

(use-package treemacs-projectile
  :straight t
  :after (projectile treemacs))

(use-package treemacs-magit
  :straight t
  :after (treemacs))

(defun my-org-prettify-hook ()
  (turn-on-visual-line-mode))


(defun my-org-prettify-settings ()
  (setq org-startup-indented nil
        org-src-fontify-natively nil
        org-hide-emphasis-markers t
        org-fontify-whole-heading-line t
        org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t
        line-spacing 0.2))

(use-package htmlize
  :straight t
  :defer t)

(defun my-org-todo-setup ()
  (setq org-use-fast-todo-selection t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "CURRENT(c)" "|" "DONE(d)")
          (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(a@/!)")
                (type "MEETING")))
    (setq org-log-done 'time)
    (setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("MEETING" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold)))))

(defun my-org-structure-templates ()
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("sh" . "src sh")))

(defhydra hydra-org-template (:color blue :hint nil)
  "
 _c_enter  _q_uote     _e_macs-lisp    _L_aTeX:
 _l_atex   _E_xample   _p_erl          _i_ndex:
 _a_scii   _v_erse     _P_erl tangled  _I_NCLUDE:
 _s_rc     _n_ote      plant_u_ml      _H_TML:
 _h_tml    ^ ^         ^ ^             _A_SCII:
"
  ("s" (hot-expand "<s"))
  ("E" (hot-expand "<e"))
  ("q" (hot-expand "<q"))
  ("v" (hot-expand "<v"))
  ("n" (hot-expand "<not"))
  ("c" (hot-expand "<c"))
  ("l" (hot-expand "<l"))
  ("h" (hot-expand "<h"))
  ("a" (hot-expand "<a"))
  ("L" (hot-expand "<L"))
  ("i" (hot-expand "<i"))
  ("e" (hot-expand "<s" "emacs-lisp"))
  ("p" (hot-expand "<s" "perl"))
  ("u" (hot-expand "<s" "plantuml :file CHANGE.png"))
  ("P" (hot-expand "<s" "perl" ":results output :exports both :shebang \"#!/usr/bin/env perl\"\n"))
  ("I" (hot-expand "<I"))
  ("H" (hot-expand "<H"))
  ("A" (hot-expand "<A"))
  ("<" self-insert-command "ins")
  ("o" nil "quit"))

(require 'org-tempo) ; Required from org 9 onwards for old template expansion
;; Reset the org-template expnsion system, this is need after upgrading to org 9 for some reason
(setq org-structure-template-alist (eval (car (get 'org-structure-template-alist 'standard-value))))
(defun hot-expand (str &optional mod header)
  "Expand org template.

STR is a structure template string recognised by org like <s. MOD is a
string with additional parameters to add the begin line of the
structure element. HEADER string includes more parameters that are
prepended to the element after the #+HEADER: tag."
  (let (text)
    (when (region-active-p)
      (setq text (buffer-substring (region-beginning) (region-end)))
      (delete-region (region-beginning) (region-end))
      (deactivate-mark))
    (when header (insert "#+HEADER: " header) (forward-line))
    (insert str)
    (org-tempo-complete-tag)
    (when mod (insert mod) (forward-line))
    (when text (insert text))))

(general-define-key
 :keymaps 'org-mode-map
 ;; disable this agenda key since I use it for avy
 "C-'" nil
 "<" '(lambda () (interactive)
        (if (or (region-active-p) (looking-back "^"))
            (hydra-org-template/body)
          (self-insert-command 1))))

(eval-after-load "org"
  '(cl-pushnew
    '("not" . "note")
    org-structure-template-alist))

(use-package org-capture
  :straight nil
  :general
  (my-leader-def
    "C" 'org-capture)
  :config
  (setq org-capture-templates
        '(
          ("c" "Note on current task" plain (clock) "\n\n%T from: %a\n%i\n%?")
          ("s" "Standup" entry (file+olp+datetree (concat my/org-dir "todo.org") "Standup") "* Planned\n- %?\n %i\n %a")
          ("r" "To-Read" item (file+headline (lamdba () (concat my/org-dir "personal.org")) "To Read") "")
          ("t" "Tasks")
          ("tw" "Work Task" entry (file+headline (lambda () (concat my/org-dir "work/swrx.org")) "Tasks") "** TODO %?\n %i")
          ("tp" "Pesonal Task" entry (file+headline (lambda () (concat my/org-dir "personal.org")) "Tasks") "* TODO %?\n %i\n %a")
          ("th" "Household Task" entry (file+headline (lambda () (concat my/org-dir "household.org")) "Tasks") "* TODO %?\n %i\n %a")
                ("i" "Interruption")
                ("ii" "interruption" entry (file+olp+datetree (lambda () (concat my/org-dir "tracker.org"))) "* IN-PROGRESS %?  :interruption:work:\n%U\n- ref :: %a\n"
                 :prepend t :tree-type week :clock-in t :clock-keep t)
                ("ic" "chat"         entry (file+olp+datetree (lambda () (concat my/org-dir "tracker.org"))) "* CHAT %?         :work:chat:\n%U\n- ref :: %a\n"
                 :prepend t :tree-type week :clock-in t :clock-keep t)
                ("ie" "email"        entry (file+olp+datetree (lambda () (concat my/org-dir "tracker.org"))) "* EMAIL %?        :work:email:\n%U\n- ref :: %a\n"
                 :prepend t :tree-type week :clock-in t :clock-keep t)
                ("im" "meeting"      entry (file+olp+datetree (lambda () (concat my/org-dir "tracker.org")))  "* MEETING %?      :work:meeting:\n%U\n- ref :: %a\n"
                 :prepend t :tree-type week :clock-in t :clock-keep t)
                ("ir" "review"       entry (file+olp+datetree (lambda () (concat my/org-dir "tracker.org")))  "* REVIEW %?       :work:review:\n%U\n- ref :: %a\n"
                 :prepend t :tree-type week :clock-in t :clock-keep t)
                ))

  (defun org-hugo-new-subtree-post-capture-template ()
    "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
    (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
           (fname (org-hugo-slug title)))
      (mapconcat #'identity
                 `(
                   ,(concat "* TODO " title)
                   ":PROPERTIES:"
                   ,(concat ":EXPORT_FILE_NAME: " fname)
                   ":END:"
                   "%?\n")          ;Place the cursor here finally
                 "\n")))

  (add-to-list 'org-capture-templates
               '("b"
                 "Blog Post"
                 entry
                 ;; It is assumed that below file is present in `org-directory'
                 ;; and that it has a "Blog Ideas" heading. It can even be a
                 ;; symlink pointing to the actual location of all-posts.org!
                 (file+olp "blog-posts.org" "Ideas")
                 (function org-hugo-new-subtree-post-capture-template))))
(add-hook 'org-mode-hook (lambda ()
   "Beautify Org Checkbox Symbol"
   (push '("[ ]" . "☐") prettify-symbols-alist)
   (push '("[X]" . "☑" ) prettify-symbols-alist)
   (push '("[-]" . "❍" ) prettify-symbols-alist)
   (prettify-symbols-mode)))

(add-hook 'org-mode-hook 'turn-on-auto-fill)

(use-package org
  :straight nil
  :gfhook
  #'my-org-prettify-hook
  ('org-src-mode-hook #'my-disable-flycheck-for-elisp)
  :preface
  (defun my-disable-flycheck-for-elisp ()
    (setq flycheck-disabled-checkers '(emacs-lisp-checkdoc)))
  :general
  ("C-c l" 'org-store-link)
  (org-mode-map "C-'" nil)

  :config
  (setq org-agenda-files my/org-agenda-files
	org-directory my/org-dir
	org-tags-column 75
	org-log-into-drawer t ;; hide the log state change history a bit better
	org-deadline-warning-days 7
	org-agenda-skip-scheduled-if-deadline-is-shown t
	org-habit-show-habits-only-for-today nil
	org-habit-graph-column 65
	org-duration-format 'h:mm ;; show hours at max, not days
	org-agenda-compact-blocks t
	org-cycle-separator-lines 0
	;; hide empty agenda sections
	org-agenda-clockreport-parameter-plist '(:stepskip0 t :link t :maxlevel 2 :fileskip0 t)
	;; default show today
	org-agenda-span 'day
	org-agenda-start-day "-0d"
	org-agenda-start-on-weekday 1
	org-agenda-custom-commands
	'(("d" "Done tasks" tags "/DONE|CANCELED")
          ("g" "Plan Today"
           ((agenda "" ((org-agenda-span 'day)))
            (org-agenda-skip-function '(org-agenda-skip-deadline-if-not-today))
            (org-agenda-entry-types '(:deadline))
            (org-agenda-overriding-header "Today's Deadlines "))))
	)
  (my-org-prettify-settings)
  (my-org-todo-setup)
  (my-org-structure-templates))


(use-package org-super-agenda
  :straight t
  :after org-agenda
  :custom (org-super-agenda-groups
           '( ;; Each group has an implicit boolean OR operator between its selectors.
             (:name "Overdue" :deadline past :order 0)
             (:name "Evening Habits" :and (:habit t :tag "evening") :order 8)
             (:name "Habits" :habit t :order 6)
             (:name "Today" ;; Optionally specify section name
                    :time-grid t  ;; Items that appear on the time grid (scheduled/deadline with time)
                    :order 3)     ;; capture the today first but show it in order 3
             (:name "Low Priority" :priority "C" :tag "maybe" :order 7)
             (:name "Due Today" :deadline today :order 1)
             (:name "Important"
                    :and (:priority "A" :not (:todo ("DONE" "CANCELED")))
                    :order 2)
             (:name "Due Soon" :deadline future :order 4)
             (:name "Todo" :not (:habit t) :order 5)
             (:name "Waiting" :todo ("WAITING" "HOLD") :order 9)))
  :config
  (setq org-super-agenda-header-map nil
	org-super-agenda-mode t))


(defhydra hydra-org-agenda (:pre (setq which-key-inhibit t)
                                 :post (setq which-key-inhibit nil)
                                 :hint none)
  "
Org agenda (_q_uit)

^Clock^      ^Visit entry^              ^Date^             ^Other^
^-----^----  ^-----------^------------  ^----^-----------  ^-----^---------
_ci_ in      _SPC_ in other window      _ds_ schedule      _gr_ reload
_co_ out     _TAB_ & go to location     _dd_ set deadline  _._  go to today
_cq_ cancel  _RET_ & del other windows  _dt_ timestamp     _gd_ go to date
_cj_ jump    _o_   link                 _+_  do later      ^^
^^           ^^                         _-_  do earlier    ^^
^^           ^^                         ^^                 ^^
^View^          ^Filter^                 ^Headline^         ^Toggle mode^
^----^--------  ^------^---------------  ^--------^-------  ^-----------^----
_vd_ day        _ft_ by tag              _ht_ set status    _tf_ follow
_vw_ week       _fr_ refine by tag       _hk_ kill          _tl_ log
_vt_ fortnight  _fc_ by category         _hr_ refile        _ta_ archive trees
_vm_ month      _fh_ by top headline     _hA_ archive       _tA_ archive files
_vy_ year       _fx_ by regexp           _h:_ set tags      _tr_ clock report
_vn_ next span  _fd_ delete all filters  _hp_ set priority  _td_ diaries
_vp_ prev span  ^^                       ^^                 ^^
_vr_ reset      ^^                       ^^                 ^^
^^              ^^                       ^^                 ^^
"
  ;; Entry
  ("hA" org-agenda-archive-default)
  ("hk" org-agenda-kill)
  ("hp" org-agenda-priority)
  ("hr" org-agenda-refile)
  ("h:" org-agenda-set-tags)
  ("ht" org-agenda-todo)
  ;; Visit entry
  ("o"   link-hint-open-link :exit t)
  ("<tab>" org-agenda-goto :exit t)
  ("TAB" org-agenda-goto :exit t)
  ("SPC" org-agenda-show-and-scroll-up)
  ("RET" org-agenda-switch-to :exit t)
  ;; Date
  ("dt" org-agenda-date-prompt)
  ("dd" org-agenda-deadline)
  ("+" org-agenda-do-date-later)
  ("-" org-agenda-do-date-earlier)
  ("ds" org-agenda-schedule)
  ;; View
  ("vd" org-agenda-day-view)
  ("vw" org-agenda-week-view)
  ("vt" org-agenda-fortnight-view)
  ("vm" org-agenda-month-view)
  ("vy" org-agenda-year-view)
  ("vn" org-agenda-later)
  ("vp" org-agenda-earlier)
  ("vr" org-agenda-reset-view)
  ;; Toggle mode
  ("ta" org-agenda-archives-mode)
  ("tA" (org-agenda-archives-mode 'files))
  ("tr" org-agenda-clockreport-mode)
  ("tf" org-agenda-follow-mode)
  ("tl" org-agenda-log-mode)
  ("td" org-agenda-toggle-diary)
  ;; Filter
  ("fc" org-agenda-filter-by-category)
  ("fx" org-agenda-filter-by-regexp)
  ("ft" org-agenda-filter-by-tag)
  ("fr" org-agenda-filter-by-tag-refine)
  ("fh" org-agenda-filter-by-top-headline)
  ("fd" org-agenda-filter-remove-all)
  ;; Clock
  ("cq" org-agenda-clock-cancel)
  ("cj" org-agenda-clock-goto :exit t)
  ("ci" org-agenda-clock-in :exit t)
  ("co" org-agenda-clock-out)
  ;; Other
  ("q" nil :exit t)
  ("gd" org-agenda-goto-date)
  ("." org-agenda-goto-today)
  ("gr" org-agenda-redo))
;; TODO: This doesn't seem to load automatically
(general-define-key
  :keymaps 'org-agenda-mode-map
  "." 'hydra-org-agenda/body)

(use-package org-pomodoro
  :straight t)

(use-package org-journal
  :straight t
  :defer t
  :config
  (setq org-journal-dir (concat my/org-dir "journal"))
  (setq org-journal-date-format "%A %d %B %Y")
  (setq org-journal-time-format "%H:%M")
  (setq org-journal-enable-agenda-integration t)
  (setq org-journal-file-format "%Y%m%d.org")
  :general ("C-x C-j" 'org-journal-new-entry))

(use-package org-babel
  :no-require
  :straight nil
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)
     (plantuml . t))))

(use-package olivetti
  :straight t
  :defer t
  :custom
  (olivetti-body-width 90))

(use-package writegood-mode
  :straight t
  :defer t)

(defun my/writing-modes ()
  (interactive)
  (flyspell-mode +1)
  (olivetti-mode +1)
  (writegood-mode +1))

(setenv "LANG" "en_GB")
(use-package flyspell
  :straight t
  :diminish
  :general
  (my-leader-def
    "n" 'hydra-spelling/body) ;;oryx: just 'c' would be better here
  :hook ((prog-mode . flyspell-prog-mode)
       ((org-mode text-mode) . flyspell-mode))
  :config
  (setq ispell-dictionary "english"
        ispell-silently-savep t
        ispell-personal-dictionary "~/.emacs.d/.aspell.en.pws")
  :hydra (hydra-spelling (:color blue)
    "
^
^Spelling^          ^Errors^            ^Checker^
^────────^──────────^──────^────────────^───────^───────
_q_ quit            _<_ previous        _c_ correction
^^                  _>_ next            _d_ dictionary
^^                  _f_ check           _m_ mode
^^                  ^^                  ^^
"
    ("q" nil)
    ("<" flyspell-correct-previous :color pink)
    (">" flyspell-correct-next :color pink)
    ("c" ispell)
    ("d" ispell-change-dictionary)
    ("f" flyspell-buffer)
    ("m" flyspell-mode)))

(use-package flyspell-correct
  :straight t
  :after flyspell)

(use-package flyspell-correct-helm
  :straight t
  :after flyspell)

(use-package expand-region
  :straight t
  :general
  ("C->" 'er/expand-region)
  ("C-<" 'er/contract-region))

(use-package display-line-numbers
  :straight nil
  :ghook
  ('prog-mode-hook #'display-line-numbers-mode))

(use-package flycheck
  :straight t
  :general
  (my-leader-def
    "f" '(hydra-flycheck-mode/body :wk "flycheck-mode"))
  :config
  (global-flycheck-mode +1)
  (setq-default flycheck-disabled-checkers '(json-python-json))
  :hydra
  (hydra-flycheck-mode
    (:hint nil
     :color green
     :pre (flycheck-list-errors)
     :post (quit-windows-on "*Flycheck errors*"))
    "
Find Errors        Describe Errors
-----------------------------------
_f_irst error      _s_how error
_n_ext error       _e_xplain error
_p_rev error       ^ ^
_l_ist errors      ^ ^
"
    ("f" flycheck-first-error)
    ("n" flycheck-next-error)
    ("p" flycheck-previous-error)
    ("l" flycheck-list-errors)
    ("s" flycheck-display-error-at-point)
    ("e" flycheck-explain-error-at-point)))

(use-package yasnippet
  :straight t
 :custom
 (yas-snippet-dirs
  '("~/.emacs.d/snippets"))
 :config
 (yas-global-mode +1))

(use-package yasnippet-snippets
  :straight t
  :after yasnippet)

(use-package company
  :straight t
  :diminish
  :ensure t
  :config
  (global-company-mode 1)
  (setq ;; Only 1 letters required for completion to activate.
   company-minimum-prefix-length 1
   ;; Search other buffers for compleition candidates
   company-dabbrev-other-buffers t
   company-dabbrev-code-other-buffers t
   ;; Show candidates according to importance, then case, then in-buffer frequency
   company-transformers ;'(company-sort-by-backend-importance
                        ;  company-sort-prefer-same-case-prefix
                          '(company-sort-by-occurrence)
   ;; Flushright any annotations for a compleition;
   ;; e.g., the description of what a snippet template word expands into.
   company-tooltip-align-annotations t
   ;; Allow (lengthy) numbers to be eligible for completion.
   company-complete-number nil
   ;; M-⟪num⟫ to select an option according to its number.
   company-show-numbers t
   ;; Show 10 items in a tooltip; scrollbar otherwise or C-s ^_^
   company-tooltip-limit 10
   ;; Edge of the completion list cycles around.
   company-selection-wrap-around t
   ;; Do not downcase completions by default.
   company-dabbrev-downcase nil
   ;; Even if I write something with the ‘wrong’ case,
   ;; provide the ‘correct’ casing.
   company-dabbrev-ignore-case nil
   ;; Immediately activate completion.
   company-idle-delay 0
   ;;company-backends (mapcar #'company-mode/backend-with-yas company-backends)
   ;;company-backends '((:separate company-capf company-yasnippet))
   ;; don't try to complete numbers
   company-dabbrev-char-regexp "[A-z:-]"
   )

  ;; Added from https://emacs.stackexchange.com/questions/10431/get-company-to-show-suggestions-for-yasnippet-names
  (defvar company-mode/enable-yas t
    "Enable yasnippet for all backends.")
  (defun company-mode/backend-with-yas (backend)
    (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
	backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))
  (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
  
  ;; Use C-/ to manually start company mode at point. C-/ is used by undo-tree.
  ;; Override all minor modes that use C-/; bind-key* is discussed below.
  (bind-key* "C-/" #'company-manual-begin)

  ;; Bindings when the company list is active.
  :general
  ;; TODO add cancel binding
  (company-active-map
   "C-d" 'company-show-doc-buffer ;; In new temp buffer
   "<tab>" 'company-complete-selection
   ;; Keep this as the global binding
   "C-w" 'backward-kill-word
   ;; Use C-n,p for navigation in addition to M-n,p
   ;;"C-n" '(lambda () (interactive) (company-complete-common-or-cycle 1))
   ;;"C-p" '(lambda () (interactive) (company-complete-common-or-cycle -1))
   ))

;; Nice icons for company-mode
(use-package company-box
  :diminish company-box-mode
  :hook (company-mode . company-box-mode)
  :init
  (setq company-box-icons-alist 'company-box-icons-all-the-icons)
  :config
  (setq company-box-icons-alist 'company-box-icons-all-the-icons
        company-box-backends-colors nil

        ;; These are the Doom Emacs defaults. Taken from: https://github.com/TheBB/dotemacs/blob/master/init.el#L527-L570
        company-box-icons-all-the-icons
        `((Unknown       . ,(all-the-icons-material "find_in_page"             :face 'all-the-icons-purple))
          (Text          . ,(all-the-icons-material "text_fields"              :face 'all-the-icons-green))
          (Method        . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
          (Function      . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
          (Constructor   . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
          (Field         . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
          (Variable      . ,(all-the-icons-material "adjust"                   :face 'all-the-icons-blue))
          (Class         . ,(all-the-icons-material "class"                    :face 'all-the-icons-red))
          (Interface     . ,(all-the-icons-material "settings_input_component" :face 'all-the-icons-red))
          (Module        . ,(all-the-icons-material "view_module"              :face 'all-the-icons-red))
          (Property      . ,(all-the-icons-material "settings"                 :face 'all-the-icons-red))
          (Unit          . ,(all-the-icons-material "straighten"               :face 'all-the-icons-red))
          (Value         . ,(all-the-icons-material "filter_1"                 :face 'all-the-icons-red))
          (Enum          . ,(all-the-icons-material "plus_one"                 :face 'all-the-icons-red))
          (Keyword       . ,(all-the-icons-material "filter_center_focus"      :face 'all-the-icons-red))
          (Snippet       . ,(all-the-icons-material "short_text"               :face 'all-the-icons-red))
          (Color         . ,(all-the-icons-material "color_lens"               :face 'all-the-icons-red))
          (File          . ,(all-the-icons-material "insert_drive_file"        :face 'all-the-icons-red))
          (Reference     . ,(all-the-icons-material "collections_bookmark"     :face 'all-the-icons-red))
          (Folder        . ,(all-the-icons-material "folder"                   :face 'all-the-icons-red))
          (EnumMember    . ,(all-the-icons-material "people"                   :face 'all-the-icons-red))
          (Constant      . ,(all-the-icons-material "pause_circle_filled"      :face 'all-the-icons-red))
          (Struct        . ,(all-the-icons-material "streetview"               :face 'all-the-icons-red))
          (Event         . ,(all-the-icons-material "event"                    :face 'all-the-icons-red))
          (Operator      . ,(all-the-icons-material "control_point"            :face 'all-the-icons-red))
          (TypeParameter . ,(all-the-icons-material "class"                    :face 'all-the-icons-red))
          (Template      . ,(all-the-icons-material "short_text"               :face 'all-the-icons-green))))
  )

(use-package smartscan
  :straight t
  :hook ((prog-mode . smartscan-mode))
  :general
  ("M-n" 'smartscan-symbol-go-forward)
  ("M-p" 'smartscan-symbol-go-backward)
  ("M-'" 'my/symbol-replace))

(defun my/symbol-replace (replacement)
  "Replace all standalone symbols in the buffer matching the one at point."
  (interactive  (list (read-from-minibuffer "Replacement for thing at point: " nil)))
  (save-excursion
    (let ((symbol (or (thing-at-point 'symbol) (error "No symbol at point!"))))
      (beginning-of-buffer)
      ;; (query-replace-regexp symbol replacement)
      (replace-regexp (format "\\b%s\\b" (regexp-quote symbol)) replacement))))

(use-package lsp-mode
  :straight t
  :hook (lsp-mode . lsp-enable-which-key-integration)
  (go-mode . lsp-deferred)
  :commands lsp
  :custom
  (lsp-completion-provider :none)
  :general
  (my-leader-def
    "L" '(hydra-lsp/body :wk "lsp-mode"))
  :config
  (setq lsp-file-watch-threshold 500)
  (defhydra hydra-lsp (:exit t :hint nil)
    "
 Buffer^^               Server^^                   Symbol
-------------------------------------------------------------------------------------
 [_f_] format           [_M-r_] restart            [_d_] declaration  [_i_] implementation  [_o_] documentation
 [_m_] imenu            [_S_]   shutdown           [_D_] definition   [_t_] type            [_r_] rename
 [_x_] execute action   [_M-s_] describe session   [_R_] references   [_s_] signature       [_a_] actions"
    ("d" lsp-find-declaration)
    ("D" lsp-ui-peek-find-definitions)
    ("R" lsp-ui-peek-find-references)
    ("i" lsp-ui-peek-find-implementation)
    ("t" lsp-find-type-definition)
    ("s" lsp-signature-help)
    ("o" lsp-describe-thing-at-point)
    ("r" lsp-rename)
    ("a" helm-lsp-code-actions)

    ("f" lsp-format-buffer)
    ("m" lsp-ui-imenu)
    ("x" lsp-execute-code-action)

    ("M-s" lsp-describe-session)
    ("M-r" lsp-restart-workspace)
    ("S" lsp-shutdown-workspace)))

(custom-set-faces
 '(lsp-face-highlight-read ((t (:background "gray"))))
 '(lsp-face-highlight-textual ((t (:background "gray"))))
 '(lsp-face-highlight-write ((t (:background "SteelBlue1"))))
 '(lsp-ui-doc-background ((t (:background "black")))))

(use-package lsp-ui
  :straight t
  :ensure t
  :commands lsp-ui-mode
  :config (setq lsp-ui-doc-enable t
                lsp-ui-peek-enable t
                lsp-ui-sideline-enable t
                lsp-ui-imenu-enable t
                lsp-ui-flycheck-enable t))

(use-package helm-lsp
  :straight t
  :commands (helm-lsp-workspace-symbol))

(use-package lsp-treemacs
  :straight t
  :commands lsp-treemacs-errors-list)
(use-package dap-mode
  :straight t)

(use-package editorconfig
  :straight t
  :delight
  :config
  (editorconfig-mode +1))

(use-package origami
  :straight t
  :hook (prog-mode . origami-mode)
  :general
  (my-leader-def "e" '(hydra-folding/body :wk "code folding"))
  :hydra
  (hydra-folding (:color red)
   "
  _o_pen node    _n_ext fold       _t_oggle node     _s_how current only
  _c_lose node   _p_revious fold   toggle _f_orward
  ^ ^            ^ ^               toggle _a_ll
  "
    ("o" origami-open-node)
    ("c" origami-close-node)
    ("n" origami-next-fold)
    ("p" origami-previous-fold)
    ("t" origami-toggle-node)
    ("f" origami-forward-toggle-node)
    ("a" origami-toggle-all-nodes)
    ("s" origami-show-only-node)))

(use-package magit
  :straight t
  :defer t
  :general
  ("C-x g" 'magit-status)
  (my-leader-def
    "g" '(:ignore t :wk "git")
    "gs" 'magit-status
    "gc" 'magit-checkout
    "gC" 'magit-commit
    "gb" 'magit-blame
    "gS" 'magit-stage-file
    "gU" 'magit-unstage-file
    "gg" 'hydra-my-git-menu/body
    "gy" 'my/magit-yank-branch-name)
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  (defun my/magit-yank-branch-name ()
    "Show the current branch in the echo-area and add it to the `kill-ring'."
    (interactive)
    (let ((branch (magit-get-current-branch)))
      (if branch
          (progn (kill-new branch)
                 (message "%s" branch))
        (user-error "There is not current branch")))))

(use-package git-timemachine
  :straight t
  :defer t)

(use-package git-messenger
  :straight t
  :defer t)

(use-package git-gutter-fringe
  :straight t
  :config
  (global-git-gutter-mode +1)
  (setq-default fringes-outside-margins t))

(use-package git-link
  :straight t
  :general
  (my-leader-def
    "gl" '(:ignore t :wk "git link")
    "gll" 'git-link
    "glc" 'git-link-commit
    "glh" 'git-link-homepage))

(use-package browse-at-remote
  :straight t
  :general
  (my-leader-def
    "glg" 'browse-at-remote))

(defhydra hydra-my-git-menu (global-map "<f7>"
                                        :color blue)
  "
^Navigate^        ^Action^               ^Info^
^^^^^^^^^^^^---------------------------------------------------
_j_: next hunk    _s_: stage hunk        _d_: diff
_k_: prev hunk    _S_: stage file        _c_: show commit
^ ^               _U_: unstage file      _g_: magit status
^ ^               ^ ^                    _t_: git timemachine
^ ^               ^ ^                    ^ ^
"
  ("j" git-gutter:next-hunk)
  ("k" git-gutter:previous-hunk)
  ("s" git-gutter:stage-hunk)
  ("S" magit-stage-file)
  ("U" magit-unstage-file)
  ("c" git-messenger:popup-show)
  ("g" magit-status :exit t)
  ("d" magit-diff-buffer-file)
  ("t" git-timemachine :exit t)
  ("q" quit-window "quit-window")
  ("<ESC>" git-gutter:update-all-windows "quit" :exit t))

(defhydra hydra-my-git-timemachine-menu (:color blue)
  ("s" git-timemachine "start")
  ("j" git-timemachine-show-next-revision "next revision")
  ("k" git-timemachine-show-previous-revision "prev revision")
  ("c" git-timemachine-show-current-revision "curr revision")
  ("<ESC>" git-timemachine-show-current-revision "quit" :exit t))

(setq exec-path (append exec-path '("/Users/andrew.thompson/go/bin/")))
(setq exec-path (append exec-path '("/opt/homebrew/bin/")))

;; I can't quite get this to work for some reason
;; (use-package exec-path-from-shell
;;   :straight nil
;;   :ensure t
;;   :config
;;   (exec-path-from-shell-initialize))

;; (when (eq system-type 'darwin)
;;   (mac-auto-operator-composition-mode))

(when (eq system-type 'darwin)
  (setq python-shell-interpreter "/usr/local/bin/python3"))

(when (eq system-type 'darwin)
  (setq visible-bell nil
        ring-bell-function 'flash-mode-line)
  (defun flash-mode-line ()
    (invert-face 'mode-line)
    (run-with-timer 0.1 nil #'invert-face 'mode-line)))

(when (eq system-type 'darwin)
  (setq magit-git-executable "/usr/bin/git"))

(use-package restart-emacs
  :straight t
  :defer t)

(use-package restclient
  :straight t
  :defer  t)

(use-package company-restclient
  :straight t
  :defer t)

(use-package ob-restclient
  :straight t
  :defer t)

(use-package lsp-java
  :straight t
  :config (add-hook 'java-mode-hook 'lsp))

(use-package go-mode
  :straight t
  :custom
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
  :config
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  :general
  (my-leader-def
    "p" '(hydra-go-mode/body :wk "go-mode")) ;;oryx - this could be better?
  :hydra
  (hydra-go-mode (:hint nil :color green)

    "
Imports             Describe             GoTo
--------------------------------------------------------
_ig_ import go      _d_escribe           _ga_ arguments
_ia_ import add     _j_ump to definition _gd_ docstring
_ir_ import remove  ^ ^                  _gf_ function
^ ^                 ^ ^                  _gn_ function name
^ ^                 ^ ^                  _gr_ return values
"
    ("ig" go-goto-imports)
    ("ia" go-import-add)
    ("ir" go-remove-unused-imports)
    ("d" godef-describe)
    ("j" godef-jump)
    ("ga" go-goto-arguments)
    ("gd" go-goto-docstring)
    ("gf" go-goto-function)
    ("gn" go-goto-function-name)
    ("gr" go-goto-return-values)))
(setq lsp-go-env '((GOFLAGS . "-tags=integration")))

(use-package dockerfile-mode
  :straight t
  :defer t)

(use-package docker
  :straight t
  :defer t)

(use-package kubernetes
  :straight t
  :commands (kubernetes-overview))

(use-package js2-mode
  :straight t
  :mode "\\.js$"
  :hook (js2-mode . lsp)
  :interpreter "node"
  :ensure-system-package ((typescript-language-server . "npm i -g typescript-language-server")
                          (eslint_d . "npm i -g eslint_d"))
  :custom
  ;; set the indent level to 2
  (js2-basic-offset 2)
  (js-chain-indent t)
  (js-indent-level 2)
  ;; use eslint_d instead of eslint for faster linting
  (flycheck-javascript-eslint-executable "eslint_d"))

(use-package json-mode
  :straight t
  :mode "\\.json\\'")

(use-package skewer-mode
  :straight t
  :defer t
  :ghook ('js2-mode-hook)
  :general
  (my-local-leader-def 'js2-mode-map
    "eb" 'skewer-eval-defun
    "el" 'skewer-eval-last-expression))

(which-key-add-major-mode-key-based-replacements 'clojure-mode "C-c e" "eval")
(which-key-add-major-mode-key-based-replacements 'emacs-lisp-mode "C-c e" "eval")
(which-key-add-major-mode-key-based-replacements 'hy-mode "C-c e" "eval")
(which-key-add-major-mode-key-based-replacements 'lisp-interaction-mode "C-c e" "eval")
(which-key-add-major-mode-key-based-replacements 'scheme-mode "C-c e" "eval")

(defconst my-lisp-mode-hooks
  '(lisp-mode-hook
    sly-mrepl-mode-hook
    emacs-lisp-mode-hook
    scheme-mode-hook
    geiser-repl-mode-hook
    hy-mode-hook
    inferior-hy-mode-hook
    clojure-mode-hook
    cider-repl-mode-hook))

(defun my-lisp-setup ()
  (electric-pair-mode -1))

;; (use-package paredit
;;   :straight nil
;;   :defer t
;;   :ghook my-lisp-mode-hooks
;;   :gfhook #'my-lisp-setup)

(my-leader-def
  :keymaps 'emacs-lisp-mode-map
  "eb" 'eval-buffer
  "el" 'eval-last-sexp
  "ed" 'eval-defun
  "er" 'eval-region)

(my-leader-def
  :keymaps 'lisp-interaction-mode-map
  "eb" 'eval-buffer
  "el" 'eval-last-sexp
  "ed" 'eval-defun
  "er" 'eval-region)

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)


(use-package sly
  :straight t
  :defer t
  :hook (sly-mrepl-mode . rainbow-delimiters-mode)
  :general
  (my-local-leader-def
    :keymaps 'lisp-mode-map
    "eb" 'sly-eval-buffer
    "el" 'sly-eval-last-expression
    "ed" 'sly-eval-defun
    "er" 'sly-eval-region)
  :config
  (setq inferior-lisp-program "/usr/bin/sbcl"))

(use-package sly-quicklisp
  :straight t
  :after sly)

(use-package sly-asdf
  :straight t
  :after sly)

(use-package hy-mode
  :straight t
  :mode "\\.hy\\'"
  :general
  (my-local-leader-def 'hy-mode-map
    "er" 'hy-shell-eval-region
    "eb" 'hy-shell-eval-buffer
    "el" 'hy-shell-eval-last-sexp
    "ed" 'hy-shell-eval-current-form))

(use-package geiser
  :straight t
  :defer t
  :general
  (my-local-leader-def
    :keymaps 'scheme-mode-map
    "r" 'run-geiser
    "er" 'geiser-eval-region
    "eR" 'geiser-eval-region-and-go
    "eb" 'geiser-eval-buffer
    "eB" 'geiser-eval-buffer-and-go
    "ed" 'geiser-eval-definition
    "eD" 'geiser-eval-definition-and-go
    "el" 'geiser-eval-eval-sexp)
  :custom
  (geiser-active-implementations '(guile mit racket)))

(use-package python
  :straight t
  :mode "\\.py\\'"
  :ghook
  ('python-mode-hook #'lsp)
  :general
  (my-local-leader-def 'python-mode-map
    "er" 'python-shell-send-region
    "eb" 'python-shell-send-buffer
    "ef" 'python-shell-send-file
    "es" 'python-shell-send-string))

(use-package pipenv
  :straight t
  :hook ((python-mode . pipenv-mode)
         (hy-mode . pipenv-mode))
  :init
  (setq pipenv-projectile-after-switch-function #'pipenv-projectile-after-switch-extended))

(use-package web-mode
  :straight t
  :defer t
  :preface
  (defun my-web-mode-hook ()
    ;; set the html indent to 2
    (setq web-mode-markup-indent-offset 2)
    ;; highlight matching elements in html
    (setq web-mode-enable-current-element-highlight 1))
  :hook (web-mode . my-web-mode-hook)
  :init
  (add-hook 'web-mode-before-auto-complete-hooks
            '(lambda ()
               (let ((web-mode-cur-language
                      (web-mode-language-at-pos))))))
  (add-to-list `auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list `auto-mode-alist '("\\.css\\'" . web-mode)))

(use-package yaml-mode
  :straight t
  :defer t)

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package terraform-mode
  :straight t
  :ensure t)

(use-package sqlformat
  :ensure t
  :straight t
  :init
  ;(add-hook 'sql-mode-hook 'sqlformat-on-save-mode)
  :config
  (setq sqlformat-command 'pgformatter))

(defmacro my/with-advice (adlist &rest body)
  "Execute BODY with temporary advice in ADLIST.

Each element of ADLIST should be a list of the form
  (SYMBOL WHERE FUNCTION [PROPS])
suitable for passing to `advice-add'.  The BODY is wrapped in an
`unwind-protect' form, so the advice will be removed even in the
event of an error or nonlocal exit."
  (declare (debug ((&rest (&rest form)) body))
           (indent 1))
  `(progn
     ,@(mapcar (lambda (adform)
                 (cons 'advice-add adform))
               adlist)
     (unwind-protect (progn ,@body)
       ,@(mapcar (lambda (adform)
                   `(advice-remove ,(car adform) ,(nth 2 adform)))
                 adlist))))

(defun my/call-logging-hooks (command &optional verbose)
  "Call COMMAND, reporting every hook run in the process.
Interactively, prompt for a command to execute.

Return a list of the hooks run, in the order they were run.
Interactively, or with optional argument VERBOSE, also print a
message listing the hooks."
  (interactive "CCommand to log hooks: \np")
  (let* ((log     nil)
         (logger (lambda (&rest hooks) 
                   (setq log (append log hooks nil)))))
    (my/with-advice
        ((#'run-hooks :before logger))
      (call-interactively command))
    (when verbose
      (message
       (if log "Hooks run during execution of %s:"
         "No hooks run during execution of %s.")
       command)
      (dolist (hook log)
        (message "> %s" hook)))
    log))

(defun my/today ()
  "Create Org file from skeleton with current time as name."
  (interactive)
  (find-file (format-time-string (concat my/org-dir "journal/%Y-%m-%d.org"))))
;  (insert "Skeleton contents"))

(use-package gradle-mode
  :straight t
  :ensure t)
