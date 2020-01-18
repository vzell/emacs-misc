;; (defvar vz-menu
;;   (list "vz"
;;         ["@"   vz-keyboard-at       t]
;;         ["|"   vz-keyboard-pipe     t]
;;         ["{"   vz-keyboard-gka      t]
;;         ["}"   vz-keyboard-gkz      t]
;;         ["["   vz-keyboard-eka      t]
;;         ["]"   vz-keyboard-ekz      t]
;;         ["~"   vz-keyboard-schlange t]
;;         ["\\"  vz-keyboard-bs       t]
;;         "-----"
;;         ["Toggle Coding System"   toggle-buffer-file-coding-system t]
;;         ["Load Mule UCS"          vz-load-mule-ucs                 t]
;;         ["Imenu"                  imenu                            t]
;;         ["Occur..."               occur                            t]
;;         ["Align"                  align
;;          :active (region-exists-p)]
;;         "-----"
;;         ["Just one space"          just-one-space t]
;;         ["Fixup whitespace"        fixup-whitespace t]
;;         ["Delete indentation"      delete-indentation t]
;;         ["Delete horizontal space" delete-horizontal-space t]
;;         ["Delete blank lines"      delete-blank-lines t]
;;         "-----"
;;         ["List load path shadows" list-load-path-shadows t]
;;         (list "Dictionary"
;;               ["Search word..."   dictionary-search      t]
;;               ["Match words..."   dictionary-match-words t]
;;               )
;;         (list "Web"
;;               ["Watson..."           watson t]
;;               ["Show RFC..."       rfc-util t]
;;               )
;;         (list "Misc"
;;               ["Command History"  repeat-complex-command t]
;;               )
;;         (list "Cygwin"
;;               ["WTF"  cygwin-wtf t]
;;               )
;;         (list "Help"
;;               ["Whatis"  whatis t]
;;               )
;;         )
;;   "Menu for vz.")

(defvar menuitem1
  ["Set mark!" (set-mark-command nil)]) ; Boring alias for C-SPC

(defvar menuitem2
  ["Show fireworks!" (lambda () (interactive) (message-box "Fun!"))]) ; Making function interactive

;;Menu with submenus.
(defvar menuitem-whitespace
  '("Whitespace" ; Note that list must be quoted, otherwise it would be treated as function.
    ["Just one space"          just-one-space]
    ["Fixup whitespace"        fixup-whitespace]
    ["Delete indentation"      delete-indentation]
    ["Delete horizontal space" delete-horizontal-space]
    ["Delete trailing space"   delete-trailing-whitespace]
    ["Delete blank lines"      delete-blank-lines]
    ("SubSubmenu"
     ["This will do wonders" (lambda () (interactive) (beep)) [:help "Welcome to the banana"]]
     ["And this will do nothing" (lambda () (interactive))])
    ("SubSubmenu2"
     ["Boring alias" (replace-string " " " banana ")])
    ))

;;Menu with submenus.
(defvar menuitem-lines
  '("Lines" ; Note that list must be quoted, otherwise it would be treated as function.
    ["List Matching Lines"            	   list-matching-lines]
    ["Delete Matching Lines"          	   delete-matching-lines]
    ["Delete Non-Matching Lines"      	   delete-non-matching-lines]
    ["Delete Duplicate Lines"         	   delete-duplicate-lines]
    ["Sort Lines"                     	   sort-lines]
    ["Sort Numeric Fields"            	   sort-numeric-fields]
    ["Reverse Region"                 	   reverse-region]
    ["Highlight Lines Matching Regexp"     highlight-lines-matching-regexp]
    ))

(easy-menu-define test-menu nil "Menu used as an example."
  `("Test menu"
    ,menuitem1
    ,menuitem2
    ,menuitem3
    ,menuitem-lines
    ["Items can also be defined here" (lambda () (interactive) (message-box "It's simple!"))]
    )
  )

(define-key global-map [menu-bar mymenu] (cons "VZ" test-menu))

;;; Insert menu after options menu, in global menu bar.
;; (define-key-after (lookup-key global-map [menu-bar])
;;   [mymenu] ; shortcut for our menu
;;   (cons "Test menu" test-menu) 'options) ; Our menu's name in cons.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (defvar my-menu-bar-menu (make-sparse-keymap "Mine"))
;; (define-key global-map [menu-bar my-menu] (cons "Mine" my-menu-bar-menu))

;; (define-key my-menu-bar-menu [my-cmd1]
;;   '(menu-item "My Command 1" my-cmd1 :help "Do what my-cmd1 does"))
;; (define-key my-menu-bar-menu [my-cmd2]
;;   '(menu-item "My Command 2" my-cmd2 :help "Do what my-cmd2 does"))

(provide 'vz-custom-menu)
