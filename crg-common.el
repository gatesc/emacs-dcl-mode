(provide 'crg-common)

;;
;; Provide a version to the file
;;
;;

;; 0.2.2 Added the is-middle-of-line fcn
;; 0.2.1 Added some more debug fcns
;; 0.2   Initial release
;;
(defvar crg-common-version "0.2.2")
;;;
;;; Get the version of this mode
;;;
(defun crg-common-get-version ()
   "Returns the version of this mode."
   (interactive "*")
   (message "crg-common version %s" crg-common-version)
   crg-common-version
)

;;
;; If a "debug" buffer exists, then
;; the message will be printed in it
;; otherwise, the message is discarded
;;
;; This is useful when debugging lisp code
;; Basically, open a buffer /tmp/debug and
;; then the messages will print, otherwise
;; they won't
;;
;; if useBob is t, then the messages print
;; at the top of the buffer; by default,
;; they print at the bottom
;;
(defun debug-print (s &optional suppressNewline useBob)
  (setq b (get-buffer "debug"))
  (if b
    (progn
       ; we are going to append to the beginning or the end of the buffer
       ; we need to make sure that the proper buffer has the
       ; point before doing anything
       (with-current-buffer b
	 (if useBob
	     (goto-char (point-min))
	   (goto-char (point-max)))
	 (if suppressNewline
	     (prin1 s b)
             ;(prin1 (format "%s\n" s) b))
	   (print s b))
	 )
       )
    )
  )

;;
;; concatenates two strings and sends the results to the debug buffer
;;
(defun debug-print-strings (str1 str2 &optional useBob)
  "Concatenates two strings and sends the results to the debug buffer"
  (interactive "*")
  (debug-print (format "%s%s" str1 str2) useBob)
  )

;;
;; These debug print statements assume a leading string. If not needed, use ""
;;
(defun debug-print-str (msg s)
  (debug-print-strings msg s)
  )

(defun debug-print-int (msg i)
  (debug-print-strings msg (itos i))
  )

(defun debug-print-float (msg f)
  (debug-print-strings msg (ftos f))
  )

;;
;; Returns the current line as a string
;;
(defun get-current-line ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (setq s "")
    (while (not (eolp))
      (setq c (char-to-string (following-char)))
      (setq s (concat s c))
      (forward-char 1)
      )
    s
  )
)

;;
;; prints the current line to the debug buffer
;;
(defun debug-show-current-line ()
  (interactive)
  (debug-print (get-current-line))
  )

;;
;; Some data type to string conversion routines
;;
(defun itos (i)
  (interactive)
  (format "%d" i)
  )

(defun ctos (c)
  (interactive)
  (format "%c" c)
  )

(defun ftos (f)
  (interactive)
  (format "%f" f)
  )

(defun ptos (p)
  (interactive)
  (setq s "nil")
  (if p
     (setq s "t"))
  s
  )

;;
;; Checks whether the point is in the middle of a line
;;
;; It returns t if it is in the middle, nil otherwise
;; If ignoreSurrondWhite is t, then whitespace that is at
;; the beginning or end of the line is treated as the
;; beginning (or end) of the line (e.g. it is ignored)
;;
(defun is-middle-of-line (&optional ignoreSurrondWhite)
  "Checks whether the point is in the middle of a line."
  (interactive)
  (progn
    (setq res nil)
    (setq cp (point))
    (setq bp (save-excursion (beginning-of-line) (point)))
    (setq ep (save-excursion (end-of-line) (point)))
    (if ignoreSurrondWhite
	(progn
	  (save-excursion
	    (goto-char bp)
	    (skip-chars-forward " \t")
	    (setq bp (point))

	    (goto-char ep)
	    (skip-chars-backward " \t")
	    (setq ep (point))
	    )
	  )
      )
    
    (if (and (> cp bp) (< cp ep))
      (progn
	(setq res t)
	)
      (progn
	(setq res nil)
	)
      )
  res
    )
  )

;;
;; Show abbrevations in a buffer called "*Abbrevs*"
;;
(defun show-abbrevs (abbList)
  "Show abbrevations in a buffer called *Abbrevs*"
  (interactive "*")
;  (get-buffer-create "*Abbrevs*")
  (with-current-buffer (get-buffer-create "*Abbrevs*")
(print "These are the abbreviations" (current-buffer))
    (dolist val abbList
      (progn
	(setq abbrevName car(val))
	(setq abbrevExp  cadr(val))
	(print (format "%s  %s" abbrevName abbrevExp) (current-buffer))
	)
      )
;    (buffer-read-only t)
    )
  )

;;
;; grabbed this from the internet
;;
(defun delete-trailing-whitespace ()
  "Delete all the trailing whitespace across the current buffer.
All whitespace after the last non-whitespace character in a line is deleted.
This respects narrowing, created by \\[narrow-to-region] and friends.
A formfeed is not considered whitespace by this function."
  (interactive "*")
(debug-print-str "" "INSIDE DELETE-TRAILING-WHITESPACE")  
  (save-match-data
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\s-$" nil t)
       (skip-syntax-backward "-" (save-excursion (forward-line 0) (point)))
       ;; Don't delete formfeeds, even if they are considered whitespace.
       (save-match-data
         (if (looking-at ".*\f")
             (goto-char (match-end 0))))
       (delete-region (point) (match-end 0))))))
         
;;
;; deletes the the trailing whitespace on a given line
;;
(defun delete-line-trailing-whitespace ()
  "Deletes the trailing whitespace on the current line."
  (interactive "*")
  (save-excursion
    (end-of-line)
    (setq pe (point))
    (skip-chars-backward " \t")
    (delete-region (point) pe)
    )
  )
