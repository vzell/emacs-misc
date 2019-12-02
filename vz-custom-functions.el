;;; vz-org

(require "rect")

(defun vz-org-trim (s)
  "Remove whitespace at beginning and end of string."
  (if (string-match "\\`[ \t\n\r]+" s) (setq s (replace-match "" t t s)))
  (if (string-match "[ \t\n\r]+\\'" s) (setq s (replace-match "" t t s)))
  s)

(defun vz-org-mark-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))

(defun vz-org-backward-codeblock ()
  "Move to beginning of next codeblock after an empty line"
  (interactive "_")
  ;; TODO: skip also comments for different programming languages
  (while (and (looking-at "^$")
              (not (bobp)))
    (backward-char 1))
  (if (re-search-backward "^\n" (point-min) t)
      nil
    (goto-char (point-min))
    ))

(defun vz-org-forward-codeblock ()
  "Move to end of next codeblock"
  (interactive "_")
  (vz-skip-whitespace)
  (re-search-forward "^$" (point-max) t)
  )

(defun vz-org-mark-codeblock ()
  "Put mark at the beginning of this codeblock, point at end.
The codeblock marked is the one that contains point or is before point."
  (interactive)
  (push-mark (point))
  (vz-org-backward-codeblock)
  (if (not (bobp))
      (forward-char 1))
  (push-mark (point) nil t)
  (vz-org-forward-codeblock)
  )

(defun vz-org-backward-codeblock-after-begin-marker ()
  "Move to beginning of next codeblock after an empty line"
  (interactive "_")
  ;; TODO: skip also comments for different programming languages
  (while (and (looking-at "^$")
              (not (bobp)))
    (backward-char 1))
  (if (re-search-backward "^\n" (point-min) t)
      nil
    (goto-char (point-min)))
  (save-excursion
    (forward-line)
    (if (looking-at "^#+begin_src")
	(forward-line 2))
    ))

(defun vz-org-forward-codeblock-before-end-marker ()
  "Move to end of next codeblock"
  (interactive "_")
  (vz-skip-whitespace)
  (re-search-forward "^$" (point-max) t)
  (forward-line -1)
  )

(defun vz-org-mark-codeblock-between-markers ()
  "Put mark at the beginning of this codeblock, point at end.
The codeblock marked is the one that contains point or is before point."
  (interactive)
  (push-mark (point))
  (vz-org-backward-codeblock-after-begin-marker)
;  (if (not (bobp))
;      (forward-char 1))
  (push-mark (point) nil t)
  (vz-org-forward-codeblock-before-end-marker)
  )

(defun vz-org-mark-codeblock-between-beg-end-src ()
  "Put mark at the beginning of this codeblock, point at end.
The codeblock marked is the one that contains point or is before point."
  (interactive)
  (let ((pmin (progn
		;; (while (and (looking-at "^$")
		;; 	    (not (bobp)))
		;;   (backward-char 1))
		(move-end-of-line nil)
		(if (re-search-backward "^#\\+begin_src" (point-min) t)
		    nil
		  (goto-char (point-min)))
		(forward-line)
		(point)
		))
	(pmax (progn
		(re-search-forward "^$" (point-max) t)
		(forward-line -1)
		(point)
		))
	)
    (progn
      (set-mark pmin)
      (goto-char pmax))))

(defun vz-org-mark-cb (prefix-arg)
  ""
  (interactive "P") 
  (if prefix-arg
      (vz-org-mark-codeblock)
    (vz-org-mark-codeblock-between-beg-end-src)))

(defun vz-org-send-region-to-other-window (beg end)
  "Send the current region to the process running in the other window for execution or edit with Tramp."
  (interactive "r")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (save-excursion
      (goto-char beg)
      (if (looking-at "^/\\(ssh\\|sudo:\\):")
	  (find-file (vz-org-trim cmd))
	(progn
	  (or (setq process (get-buffer-process "*shell*")) ; look for process 
	      (setq process (get-buffer-process (shell))) ; or create process 
	      (error "Unable to create SHELL session."))
	  (set-buffer this-buffer)
	  (switch-to-buffer-other-window (process-buffer process))
	  (goto-char (point-max))
	  (recenter 0)
	  (insert (format "\n                                    Output from buffer '%s':\n"
			  (buffer-name this-buffer)))
;;	  (insert "Command begin\n" (vz-org-trim cmd) "\nCommand end\n")
	  (set-marker (process-mark process) (point))
	  (comint-send-string process (vz-org-trim cmd))
	  (comint-send-string process "\n")
	  (switch-to-buffer-other-window this-buffer)
	  )))))

(defun vz-org-send-region-to-other-window-2 (beg end)
  "Send the current region to the process running in the other window for execution or edit with Tramp. *shell-2*"
  (interactive "r")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (save-excursion
      (goto-char beg)
      (if (looking-at "^/\\(ssh\\|sudo:\\):")
	  (find-file (vz-org-trim cmd))
	(progn
	  (or (setq process (get-buffer-process "*shell-2*")) ; look for process
	      (setq process (get-buffer-process (shell "*shell-2*"))) ; or create process
	      (error "Unable to create SHELL session."))
	  (set-buffer this-buffer)
	  (switch-to-buffer-other-window (process-buffer process))
	  (goto-char (point-max))
	  (recenter 0)
	  (insert (format "\n                                    Output from buffer '%s':\n"
			  (buffer-name this-buffer)))
;;	  (insert "Command begin\n" (vz-org-trim cmd) "\nCommand end\n")
	  (set-marker (process-mark process) (point))
	  (comint-send-string process (vz-org-trim cmd))
	  (comint-send-string process "\n")
	  (switch-to-buffer-other-window this-buffer)
	  )))))

(defun vz-org-send-region-to-other-window-3 (beg end)
  "Send the current region to the process running in the other window for execution or edit with Tramp. *shell-3*"
  (interactive "r")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (save-excursion
      (goto-char beg)
      (if (looking-at "^/\\(ssh\\|sudo:\\):")
	  (find-file (vz-org-trim cmd))
	(progn
	  (or (setq process (get-buffer-process "*shell-3*")) ; look for process
	      (setq process (get-buffer-process (shell "*shell-3*"))) ; or create process
	      (error "Unable to create SHELL session."))
	  (set-buffer this-buffer)
	  (switch-to-buffer-other-window (process-buffer process))
	  (goto-char (point-max))
	  (recenter 0)
	  (insert (format "\n                                    Output from buffer '%s':\n"
			  (buffer-name this-buffer)))
;;	  (insert "Command begin\n" (vz-org-trim cmd) "\nCommand end\n")
	  (set-marker (process-mark process) (point))
	  (comint-send-string process (vz-org-trim cmd))
	  (comint-send-string process "\n")
	  (switch-to-buffer-other-window this-buffer)
	  )))))

(defun vz-org-send-region-to-other-window-4 (beg end)
  "Send the current region to the process running in the other window for execution or edit with Tramp. *shell-4*"
  (interactive "r")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (save-excursion
      (goto-char beg)
      (if (looking-at "^/\\(ssh\\|sudo:\\):")
	  (find-file (vz-org-trim cmd))
	(progn
	  (or (setq process (get-buffer-process "*shell-4*")) ; look for process
	      (setq process (get-buffer-process (shell "*shell-4*"))) ; or create process
	      (error "Unable to create SHELL session."))
	  (set-buffer this-buffer)
	  (switch-to-buffer-other-window (process-buffer process))
	  (goto-char (point-max))
	  (recenter 0)
	  (insert (format "\n                                    Output from buffer '%s':\n"
			  (buffer-name this-buffer)))
;;	  (insert "Command begin\n" (vz-org-trim cmd) "\nCommand end\n")
	  (set-marker (process-mark process) (point))
	  (comint-send-string process (vz-org-trim cmd))
	  (comint-send-string process "\n")
	  (switch-to-buffer-other-window this-buffer)
	  )))))

(defun vz-org-send-region-to-other-window-5 (beg end)
  "Send the current region to the process running in the other window for execution or edit with Tramp. *shell-5*"
  (interactive "r")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (save-excursion
      (goto-char beg)
      (if (looking-at "^/\\(ssh\\|sudo:\\):")
	  (find-file (vz-org-trim cmd))
	(progn
	  (or (setq process (get-buffer-process "*shell-5*")) ; look for process
	      (setq process (get-buffer-process (shell "*shell-5*"))) ; or create process
	      (error "Unable to create SHELL session."))
	  (set-buffer this-buffer)
	  (switch-to-buffer-other-window (process-buffer process))
	  (goto-char (point-max))
	  (recenter 0)
	  (insert (format "\n                                    Output from buffer '%s':\n"
			  (buffer-name this-buffer)))
;;	  (insert "Command begin\n" (vz-org-trim cmd) "\nCommand end\n")
	  (set-marker (process-mark process) (point))
	  (comint-send-string process (vz-org-trim cmd))
	  (comint-send-string process "\n")
	  (switch-to-buffer-other-window this-buffer)
	  )))))

(defun vz-org-send-region-to-other-window-6 (beg end)
  "Send the current region to the process running in the other window for execution or edit with Tramp. *shell-6*"
  (interactive "r")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (save-excursion
      (goto-char beg)
      (if (looking-at "^/\\(ssh\\|sudo:\\):")
	  (find-file (vz-org-trim cmd))
	(progn
	  (or (setq process (get-buffer-process "*shell-6*")) ; look for process
	      (setq process (get-buffer-process (shell "*shell-6*"))) ; or create process
	      (error "Unable to create SHELL session."))
	  (set-buffer this-buffer)
	  (switch-to-buffer-other-window (process-buffer process))
	  (goto-char (point-max))
	  (recenter 0)
	  (insert (format "\n                                    Output from buffer '%s':\n"
			  (buffer-name this-buffer)))
;;	  (insert "Command begin\n" (vz-org-trim cmd) "\nCommand end\n")
	  (set-marker (process-mark process) (point))
	  (comint-send-string process (vz-org-trim cmd))
	  (comint-send-string process "\n")
	  (switch-to-buffer-other-window this-buffer)
	  )))))

(defun vz-org-send-region-to-other-window2 (buf beg end)
  "Send the current region to the process which get's prompted."
  (interactive "b\nr")
  (let ((cmd (buffer-substring beg end))
        (this-buffer (current-buffer))
        (process)
        )
    (or (setq process (get-buffer-process buf)) ; look for process 
        (setq process (get-buffer-process (shell))) ; or create process 
        (error "Unable to create SHELL session."))
    (set-buffer this-buffer)
    (switch-to-buffer-other-window (process-buffer process))
    (goto-char (point-max))
    (recenter 0)
    (insert (format "\nOutput from buffer '%s':\n"
                    (buffer-name this-buffer)))
    (set-marker (process-mark process) (point))
    (comint-send-string process "\n")
    (comint-send-string process (vz-org-trim cmd))
    (comint-send-string process "\n")
    (switch-to-buffer-other-window this-buffer)
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; vz misc.

(defun vz-skip-whitespace ()
  "Search forward for the first character that isn't a SPACE, TAB or NEWLINE."
  (interactive)
  (while (looking-at "[ \t\n]")
    (forward-char 1)))

(defun vz-kill-line-1 (arg entire-line)
  (kill-region (if entire-line
		   (save-excursion
		     (beginning-of-line)
		     (point))
		 (point))
	       ;; Don't shift point before doing the delete; that way,
	       ;; undo will record the right position of point.
;; FSF
;	       ;; It is better to move point to the other end of the kill
;	       ;; before killing.  That way, in a read-only buffer, point
;	       ;; moves across the text that is copied to the kill ring.
;	       ;; The choice has no effect on undo now that undo records
;	       ;; the value of point from before the command was run.
;              (progn
	       (save-excursion
		 (if arg
		     (forward-line (prefix-numeric-value arg))
		   (if (eobp)
		       (signal 'end-of-buffer nil))
		   (if (or (looking-at "[ \t]*$")
			   (or entire-line
			       (and kill-whole-line (bolp))))
		       (forward-line 1)
		     (end-of-line)))
		 (point))))

(defun vz-kill-entire-line (&optional arg)
  "Kill the entire line.
With prefix argument, kill that many lines from point.  Negative
arguments kill lines backward.

When calling from a program, nil means \"no arg\",
a number counts as a prefix arg."
  (interactive "*P")
  (vz-kill-line-1 arg t))

(defun vz-screenshot ()
  "Take a screenshot into a unique-named file in the current buffer file directory
and insert a link to this file."
  (interactive)
  (setq filename
        (concat
         (make-temp-name
          (file-name-directory (buffer-file-name))
          )
         ".jpg"
         )
        )
  (call-process "import" nil nil nil filename)
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images)
  )

(defun vz-template-gtg ()
  "Insert GTG"
  (interactive)
  (insert "Builds fine from source, packaging and setup.hint look good.

GTG
  Volker")
  (let ((subject "Subject: ")
        (secure "<#secure"))
    (re-search-backward secure nil t)
    (vz-kill-entire-line)
    (re-search-backward subject)
    (re-search-forward subject)
    (insert "[GTG] ")
    )
  )

(defun vz-change-backslash-to-slash (beg end)
  "Change in region every occurence of / to \\."
  (interactive "r")
  (let ((string (replace-regexp-in-string "\\\\" "/" (buffer-substring beg end))))
    (delete-region beg end)
    (insert string)
    ))

(defun vz-change-slash-to-backslash (beg end)
  "Change in region every occurence of \\ to /."
  (interactive "r")
  (let ((string (replace-regexp-in-string "/" "\\\\" (buffer-substring beg end))))
    (delete-region beg end)
    (insert string)
    ))

;;
(defun vz-add-string-to-end-of-lines-in-region (str b e)
  "Prompt for string, add it to end of lines in the region"
  (interactive "sWhat string shall we append? \nr")
  (goto-char e)
  (forward-line -1)
  (while (> (point) b)
    (end-of-line)
    (insert str)
    (forward-line -1)))

(defun vz-kill-lines-until-non-hash ()
  "Kill all lines starting with # from current line.
This is useful to clean Oracle lab documentation"
  (interactive)
  (save-excursion
    (let (
	  (beg (point))
	  end)
      (while (looking-at "^# ")
	(kill-line)
	(forward-line)
	)
       (setq end (point))
       (delete-region beg end))
    )
  (search-forward-regexp "^# ")
  (beginning-of-line)
  (open-line 1)
  )

(global-set-key [(f12)] 'vz-kill-lines-until-non-hash)

;;; Clean up course pdf contents for use in org-mode

(defun vz-delete-matching-lines ()
  "Delete Copyright etc."
  (interactive)
  (beginning-of-buffer)
  (delete-matching-lines "^For Instructor Use Only")
  (beginning-of-buffer)
  (delete-matching-lines "^This document should not be distributed.")
  (beginning-of-buffer)
  (delete-matching-lines "^Oracle Internal & Oracle Academy Use Only")
  (beginning-of-buffer)
  (delete-matching-lines "^Copyright © [0-9]+, Oracle and/or its affiliates. All rights reserved.")
  (beginning-of-buffer)
  (delete-matching-lines "^Chapter [0-9]+ - Page [0-9]+")
  (beginning-of-buffer)
  (delete-matching-lines "^Practices for Lesson [0-9]+: Overview")
  (beginning-of-buffer)
  (delete-matching-lines "^[0-9]+ Practices for Lesson [0-9]+:")
  (beginning-of-buffer)
  (delete-matching-lines "^Practices for Lesson [0-9]+: .*[0-9]+")
  (beginning-of-buffer)
  )

(defun vz-delete-matching-lines-new ()
  "Delete Copyright etc."
  (interactive)
  (beginning-of-buffer)
  (delete-matching-lines "Copyright 2017,")
  (beginning-of-buffer)
  )

;;;; Prepend "# " to whole buffer


;; The next two commands should be with the complete buffer as a region
(defun vz-replace-hash-with-org1 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "\\(#\\)\\( Practices for Lesson \\)" "***\\2" nil beg end)
  )

(defun vz-replace-hash-with-org2 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "\\(#\\)\\( Practice [0-9]+-[0-9]+: \\)" "****\\2" nil beg end)
  )

(defun vz-replace-hash-with-org-new (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "\\(#\\)\\( Practice [0-9][0-9]\\)" "****\\2" nil beg end)
  )

;; in org collapsed mode Kill all line which start with "*** Practices for Lesson <number>:...

;; org-show-all

(defun vz-delete-all-overview ()
  ""
  (interactive)
  (beginning-of-buffer)
  (while (re-search-forward "^#\\( Practices?\\)? Overview$" nil t)
	(progn
	  (beginning-of-line)
	  (kill-line))
	))

(defun vz-delete-all-but-first-org-subheader ()
  ""
  (interactive)
  (let (
	(practice 1)
	(last-practice 12)
	(count 0)
	)
    (beginning-of-buffer)
    (while (< practice (+ last-practice 1))
      (while (re-search-forward (concat "*** Practices for Lesson " (number-to-string practice) ":") nil t)
;      (while (re-search-forward (concat "*** Practices for Lesson " (number-to-string practice)) nil t)
	(progn
	  (setq count (+ count 1))
	  (if (> count 1)
	      (progn
		(beginning-of-line)
		(kill-line 1))
	    )
	  )
	)
      (setq practice (+ practice 1))
      (setq count 0)
      )
    )
  )

;; Expose statements

(defun vz-replace-hash-with-blank-new (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "^# $ " "" nil beg end)
  )

(defun vz-replace-hash-with-blank1 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "^# $ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank2 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "^# \\(SQL\\|RMAN\\|ASMCMD\\|adrci\\)> ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank3 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[[a-z]+@[a-z]+.*\\][#$]? " "" nil beg end)
  )

(defun vz-replace-hash-with-blank4 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# bash-3\\.2$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank5 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[root@<your lab machine> ~\\]# ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank6 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[root@ovsvr01 ~\\]# ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank7 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[root@<your lab machine> # ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank8 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# OVM> ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank9 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[root@ovmmgr01 ~\\]# ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank10 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[root@.*\\]# ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank11 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[vncuser@.*\\] ?$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank12 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[oracle@.*\\]$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank13 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# DGMGRL> ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank14 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# GDSCTL> ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank15 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[grid@.*\\]$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank16 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[.*@.*\\]$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank17 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\(DB\\|DB10G\\|DB12UPG\\|EM\\|EM10G\\|EM12\\|EM13\\) \\[.*@.*\\]$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank18 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# root@.*\\]# ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank19 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "^# # ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank20 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[.*\\]\\($\\|#\\) ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank21 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "^# \\[.*\\]$ ?" "" nil beg end)
  )

(defun vz-replace-hash-with-blank22 (beg end)
  ""
  (interactive "r")
  (query-replace-regexp "^# (.*) \\(SQL\\|RMAN\\|ASMCMD\\|adrci\\|DGMGRL\\)> ?" "" nil beg end)
  )

;; (defun vz-replace-hash-with-blank9 (beg end)
;;   ""
;;   (interactive "r")
;;   (query-replace-regexp  "^# \\[root@<your lab machine> ~\\]# " "" nil beg end)
;;   )

;; (defun vz-replace-hash-with-blank10 (beg end)
;;   ""
;;   (interactive "r")
;;   (query-replace-regexp  "^# \\[root@<your lab machine> ~\\]# " "" nil beg end)
;;   )



(defun vz-replace-emdash-with-dash (beg end)
  ""
  (interactive "r")
  (query-replace-regexp  "\\(–\\|−\\)" "-" nil beg end)
  )

(defun vz-delete-empty-prompts ()
  "Delete empty prompts"
  (interactive)
  (beginning-of-buffer)
  (delete-matching-lines "^# \\[[a-z]+@[a-z]+.*\\] ?[ #$]?$")
  )

(defun vz-delete-empty-prompts-2 ()
  "Delete empty prompts"
  (interactive)
  (beginning-of-buffer)
  (delete-matching-lines "^# \\[[a-z]+@[a-z]+.*\\] ?[ #$]?$")
  )

(defun vz-insert-newline-before-subtask ()
  ""
  (interactive)
  (beginning-of-buffer)
  (while (re-search-forward "^# [1-9][0-9]?\\. " nil t)
    (save-excursion
      (beginning-of-line)
      (newline)
      )))

(defun vz-skip-org-comments ()
  "Skip org comment lines"
  (interactive)
  (beginning-of-line)
  (while (and (looking-at "^\\(# \\|$\\)")
	      (not (eobp)))
    (forward-line)
    ))

(defun vz-surround-command-blocks-with-blank-lines ()
  "Surround command blocks with blank lines"
  (interactive)
  (while (not (eobp))
    (vz-skip-org-comments)
    (newline)
    (while (and (not (looking-at "^# "))
		(not (eobp)))
      (forward-line)
      )
    (newline)
    )
  )

(defun vz-write-output-to-orgfile ()
  "Insert current shell output into org buffer."
  (interactive)
  (let ((cb (current-buffer))
	)
      (set-buffer "*shell*")
      (save-excursion
	(let ((re (progn (forward-line -1)
			 (end-of-line)
			 (point)))
	      (rb (progn (re-search-backward "Output from buffer ")
			 (forward-line 1)
			 (point)))
	      )
	  (copy-region-as-kill rb re)))
      (set-buffer (get-buffer-create "*yank-temp*"))
      (yank)
      (apply-on-rectangle
       (lambda (beg end)
	 (insert"# "))
       (point-min) (point-max))
      (copy-region-as-kill (point-min) (point-max))
      (kill-buffer nil)
      (set-buffer cb)
      (newline)
      (yank)
      (newline)
      (newline)
      ))

(defun vz-write-output-to-orgfile-as-src ()
  "Insert current shell output into org buffer surrounded with begin/end_src for exporting to HTML."
  (interactive)
  (let ((cb (current-buffer))
	)
      (set-buffer "*shell*")
      (save-excursion
	(let ((re (progn (forward-line -1)
			 (end-of-line)
			 (point)))
	      (rb (progn (re-search-backward "Output from buffer ")
			 (forward-line 1)
			 (point)))
	      )
	  (copy-region-as-kill rb re)))
      (set-buffer (get-buffer-create "*yank-temp*"))
      (yank)
      (apply-on-rectangle
       (lambda (beg end)
	 (insert"# "))
       (point-min) (point-max))
      (copy-region-as-kill (point-min) (point-max))
      (kill-buffer nil)
      (set-buffer cb)
      (if (looking-at "^#\\+end_src")
	  (forward-line))
      (newline)
      (insert "#+begin_example\n")
      (yank)
      (newline)
      (insert "#+end_example\n")
      ))

;; https://www.rosettacode.org/wiki/Count_occurrences_of_a_substring#Common_Lisp
(defun vz-count-sub (str pat)
  "Count occurences of stubstring in string"
  (interactive)
  (loop with z = 0 with s = 0 while s do
	(when (setf s (search pat str :start2 s))
	  (incf z) (incf s (length pat)))
	finally (return z)))


(defun xah-convert-latin-alphabet-gothic (@begin @end @reverse-direction-p)
  "Replace English alphabets to Unicode gothic characters.
For example, A → 𝔄, a → 𝔞.

When called interactively, work on current line or text selection.

If `universal-argument' is called first, reverse direction.

When called in elisp, the @begin and @end are region begin/end positions to work on.

URL `http://ergoemacs.org/misc/thou_shalt_use_emacs_lisp.html'
Version 2019-03-07"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end) current-prefix-arg )
     (list (line-beginning-position) (line-end-position) current-prefix-arg )))
  (let (
        ($latin-to-gothic [ ["A" "𝔄"] ["B" "𝔅"] ["C" "ℭ"] ["D" "𝔇"] ["E" "𝔈"] ["F" "𝔉"] ["G" "𝔊"] ["H" "ℌ"] ["I" "ℑ"] ["J" "𝔍"] ["K" "𝔎"] ["L" "𝔏"] ["M" "𝔐"] ["N" "𝔑"] ["O" "𝔒"] ["P" "𝔓"] ["Q" "𝔔"] ["R" "ℜ"] ["S" "𝔖"] ["T" "𝔗"] ["U" "𝔘"] ["V" "𝔙"] ["W" "𝔚"] ["X" "𝔛"] ["Y" "𝔜"] ["Z" "ℨ"] ["a" "𝔞"] ["b" "𝔟"] ["c" "𝔠"] ["d" "𝔡"] ["e" "𝔢"] ["f" "𝔣"] ["g" "𝔤"] ["h" "𝔥"] ["i" "𝔦"] ["j" "𝔧"] ["k" "𝔨"] ["l" "𝔩"] ["m" "𝔪"] ["n" "𝔫"] ["o" "𝔬"] ["p" "𝔭"] ["q" "𝔮"] ["r" "𝔯"] ["s" "𝔰"] ["t" "𝔱"] ["u" "𝔲"] ["v" "𝔳"] ["w" "𝔴"] ["x" "𝔵"] ["y" "𝔶"] ["z" "𝔷"] ])
        $useMap
        )
    (if @reverse-direction-p
        (progn (setq $useMap
                     (mapcar
                      (lambda ($x)
                        (vector (aref $x 1) (aref $x 0)))
                      $latin-to-gothic)))
      (progn (setq $useMap $latin-to-gothic)))
    (save-excursion
      (save-restriction
        (narrow-to-region @begin @end)
        (let ( (case-fold-search nil))
          (mapc
           (lambda ($x)
             (goto-char (point-min))
             (while (search-forward (elt $x 0) nil t)
               (replace-match (elt $x 1) "FIXEDCASE" "LITERAL")))
           $useMap))))))

(defun xah-convert-latin-to-braille (@begin @end @reverse-direction-p)
  "Replace English alphabet to Unicode braille characters.

When called interactively, work on current line or text selection.
If `universal-argument' is called first, reverse direction.
Note: original letter case are not preserved. B may become b.

URL `http://ergoemacs.org/misc/elisp_latin_to_braille.html'
Version 2019-09-17"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end) current-prefix-arg )
     (list (line-beginning-position) (line-end-position) current-prefix-arg )))
  (let (
        ($latin-to-braille
         [
          ["1" "⠼⠁"] ["2" "⠼⠃"] ["3" "⠼⠉"] ["4" "⠼⠙"] ["5" "⠼⠑"] ["6" "⠼⠋"] ["7" "⠼⠛"] ["8" "⠼⠓"] ["9" "⠼⠊"] ["0" "⠼⠚"]
          ["," "⠂"] [";" "⠆"] [":" "⠒"] ["." "⠲"] ["?" "⠦"] ["!" "⠖"] ["‘" "⠄"] ["“" "⠄⠶"] ["“" "⠘⠦"] ["”" "⠘⠴"] ["‘" "⠄⠦"] ["’" "⠄⠴"] ["(" "⠐⠣"] [")" "⠐⠜"] ["/" "⠸⠌"] ["\\","⠸⠡"] ["-" "⠤"] ["–" "⠠⠤"] ["—" "⠐⠠⠤"]
          ["a" "⠁"] ["b" "⠃"] ["c" "⠉"] ["d" "⠙"] ["e" "⠑"] ["f" "⠋"] ["g" "⠛"] ["h" "⠓"] ["i" "⠊"] ["j" "⠚"] ["k" "⠅"] ["l" "⠇"] ["m" "⠍"] ["n" "⠝"] ["o" "⠕"] ["p" "⠏"] ["q" "⠟"] ["r" "⠗"] ["s" "⠎"] ["t" "⠞"] ["u" "⠥"] ["v" "⠧"] ["w" "⠺"] ["x" "⠭"] ["y" "⠽"] ["z" "⠵"] ]
         )
        $useMap
        )
    (setq $useMap
          (if @reverse-direction-p
              (mapcar
               (lambda ($x)
                 (vector (aref $x 1) (aref $x 0)))
               $latin-to-braille)
            $latin-to-braille))
    (save-excursion
      (save-restriction
        (narrow-to-region @begin @end)
        (let ( (case-fold-search t))
          (mapc
           (lambda ($x)
             (goto-char (point-min))
             (while (search-forward (elt $x 0) nil t)
               (replace-match (elt $x 1) "FIXEDCASE" "LITERAL")))
           $useMap))))))

(defun xah-convert-latin-to-rune (@begin @end @to-latin-p)
  "Replace English alphabet to Unicode runic characters.
For example, f → ᚠ.
When called interactively, work on current line or text selection.

If `universal-argument' is called first, reverse direction.
Note: original letter case are not preserved. B may become b.

URL `http://ergoemacs.org/misc/elisp_latin_to_rune.html'
Version 2019-05-25"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end) current-prefix-arg )
     (list (line-beginning-position) (line-end-position) current-prefix-arg )))
  (let* (
         ($toLower
          [["A" "a"]
           ["B" "b"]
           ["C" "c"]
           ["D" "d"]
           ["E" "e"]
           ["F" "f"]
           ["G" "g"]
           ["H" "h"]
           ["I" "i"]
           ["J" "j"]
           ["K" "k"]
           ["L" "l"]
           ["M" "m"]
           ["N" "n"]
           ["O" "o"]
           ["P" "p"]
           ["Q" "q"]
           ["R" "r"]
           ["S" "s"]
           ["T" "t"]
           ["U" "u"]
           ["V" "v"]
           ["W" "w"]
           ["X" "x"]
           ["Y" "y"]
           ["Z" "z"]
           ]
          )
         ($toLatin
          [ ["ᛆ" "a"]
            ["ᛒ" "b"]
            ["ᛍ" "c"]
            ["ᛑ" "d"]
            ["ᚧ" "ð"]
            ["ᛂ" "e"]
            ["ᚠ" "f"]
            ["ᚵ" "g"]
            ["ᚼ" "h"]
            ["ᛁ" "i"]
            ["ᚴ" "k"]
            ["ᛚ" "l"]
            ["ᛘ" "m"]
            ["ᚿ" "n"]
            ["ᚮ" "o"]
            ["ᛔ" "p"]
            ["ᛕ" "p"]
            ["ᛩ" "q"]
            ["ᚱ" "r"]
            ["ᛌ" "s"]
            ["ᛋ" "s"]
            ["ᛐ" "t"]
            ["ᚢ" "u"]
            ["ᚡ" "v"]
            ["ᚢ" "v"]
            ["ᚥ" "w"]
            ["ᛪ" "x"]
            ["ᛦ" "y"]
            ["ᚤ" "y"]
            ["ᛨ" "y"]
            ["ᛎ" "z"]
            ["ᚦ" "þ"]
            ["ᛅ" "æ"]
            ["ᛆ" "ä"]
            ["ᚯ" "ø"]
            ["ᚯ" "ö"]
            ]
          )
         ($toRunic
          (mapcar
           (lambda ($x)
             (vector (aref $x 1) (aref $x 0)))
           $toLatin))
         ($useMap (if @to-latin-p
                      $toLatin
                    $toRunic)))
    (save-excursion
      (save-restriction
        (narrow-to-region @begin @end)
        (when (not @to-latin-p)
          ;; change to lower case, but only for English letters, not for example greek etc.
          (mapc
           (lambda ($x)
             (goto-char (point-min))
             (while (search-forward (elt $x 0) nil t)
               (replace-match (elt $x 1) "FIXEDCASE" "LITERAL")))
           $toLower))
        (let ( (case-fold-search nil))
          (mapc
           (lambda ($x)
             (goto-char (point-min))
             (while (search-forward (elt $x 0) nil t)
               (replace-match (elt $x 1) "FIXEDCASE" "LITERAL")))
           $useMap))))))

(defun vz-char-stats (&optional case-sensitive)
  (interactive "P")
  (message "case-sensitive: %s" case-sensitive)
  (let ((chars (make-char-table 'counting 0)) 
        current)
    (cl-labels ((%collect-statistics
                 ()
                 (goto-char (point-min))
                 (while (not (eobp))
                   (goto-char (1+ (point)))
                   (setf current (preceding-char))
                   (set-char-table-range
                    chars current
                    (1+ (char-table-range chars current))))))
      (if case-sensitive
          (save-excursion (%collect-statistics))
        (let ((contents (buffer-substring-no-properties
                         (point-min) (point-max))))
          (with-temp-buffer
            (insert contents)
            (upcase-region (point-min) (point-max))
            (%collect-statistics)))))
    (with-current-buffer (get-buffer-create "*character-statistics*")
      (erase-buffer)
      (insert "| Character | Occurences |
               |-----------+------------|\n")
      (map-char-table
       (lambda (key value)
         (when (and (numberp key) (not (zerop value)))
           (cl-case key
             (?\n)
             (?\| (insert (format "| \\vert | %d |\n" value)))
             (otherwise (insert (format "| '%c' | %d |\n" key value))))))
       chars)
      (org-mode)
      (indent-region (point-min) (point-max))
      (goto-char 100)
      (org-cycle)
      (goto-char 79)
      (org-table-sort-lines nil ?N))
    (pop-to-buffer "*character-statistics*")))

(defun vz-do-lines (fun &optional start end)
  "Invoke function FUN on the text of each line from START to END."
  (interactive
   (let ((fn (intern (completing-read "Function: " obarray 'functionp t))))
     (if (use-region-p)
         (list fn (region-beginning) (region-end))
       (list fn (point-min) (point-max)))))
  (save-excursion
    (goto-char start)
    (while (< (point) end)
      (funcall fun (buffer-substring (line-beginning-position) (line-end-position)))
      (forward-line 1))))


(provide 'vz-custom-functions)
