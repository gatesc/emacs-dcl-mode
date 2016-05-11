;;;
;;; A mode for the DCL language (Delay Calculation Language)
;;;
;;;
(provide 'dcl-mode)

;;
;; Provides some elisp functions, when needed
;;
(require 'crg-common)

(defvar dcl-mode-version "$Revision: 1.1.1.1 $")
(defvar dcl-mode-maintainer "Charles Gates email: gatesc@us.ibm.com")

;;;
;;; Get the version of this mode
;;;
(defun dcl-get-version ()
   "Returns the version of this mode."
   (interactive "*")
   (message "dcl-mode version %s" dcl-mode-version)
   dcl-mode-version
)

(defun dcl-get-maintainer ()
  "Returns the maintainer of the mode."
  (interactive "*")
  (message "dcl-mode maintained by %s" dcl-mode-maintainer)
  dcl-mode-maintainer
)

;;
;; A list of things to fix and add
;;
;(defvar dcl-mode-todo (list
;		

;;;
;;; Setup the Customize Group and Variables
;;;
(defgroup dcl nil
  "DCL Mode"
  :group 'languages)

;;;
;;; Some useful variables
;;;
(defcustom dcl-basic-indent-level 2
  "*Indentation of C statements with respect to containing block."
  :type 'integer
  :group 'dcl)
(defcustom dcl-primary-keyword-offset 0
  "*Indentation of a line that starts with a primary dcl keyword."
  :type 'integer
  :group 'dcl)
(defcustom dcl-primary-statement-offset 0
  "*Indentation of a line that starts with a primary dcl statement."
  :type 'integer
  :group 'dcl)
(defcustom dcl-secondary-keyword-offset 0
  "*Extra indentation for secondary dcl keywords. This number is added to the basic indent."
  :type 'integer
  :group 'dcl)
;(defcustom dcl-argdecl-indent 5
;  "*Indentation level of declarations of C function arguments."
;  :type 'integer
;  :group 'dcl)
;(defcustom dcl-label-offset -2
;  "*Offset of C label lines and case statements relative to usual indentation."
;  :type 'integer
;  :group 'dcl)
;(defcustom dcl-continued-statement-offset 2
;  "*Extra indent for lines not starting new statements."
;  :type 'integer
;  :group 'dcl)
;(defcustom dcl-continued-brace-offset 0
;  "*Extra indent for substatements that start with open-braces.
;This is in addition to `dcl-continued-statement-offset'."
;  :type 'integer
;  :group 'dcl)
;
;(defcustom dcl-auto-newline nil
;  "*Non-nil means automatically newline before and after braces,
;and after colons and semicolons, inserted in DCL code.
;If you do not want a leading newline before braces then use:
;  (define-key c-mode-map \"{\" 'electric-dcl-semi)"
;  :type 'boolean
;  :group 'dcl)
;
;(defcustom dcl-tab-always-indent t
;  "*Non-nil means TAB in DCL mode should always reindent the current line,
;regardless of where in the line point is when the TAB command is used."
;  :type 'boolean
;  :group 'dcl)

(setq max-specpdl-size 2000)

;;
;; EXPERIMENTAL
;;

(defvar dcl-pos1 nil)
(defvar dcl-pos2 nil)
(defvar dcl-dif nil)

(defun good-enter ()
  "Do the enter key as end-line plus enter."
  (interactive)
  (newline-and-indent)
  )

(defun new-newline ()
   "Creates a new line and moves to it - without breaking the current line"
   (interactive)
   (beginning-of-line)
   (skip-chars-forward " \t")
   (setq cc-pos (current-column))
   (end-of-line)
   (newline)
   (while (< (current-column) cc-pos)
      (insert " ")
    )
   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment, below line the cursor is on.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-block-lo ()
  "Create a comment block appropriately indented, with electric continuation, below the line the cursor is on"
   (interactive)
   ;;
   ;; Position for the first line of the box.
   ;;
   (dcl-open-comment-lo)
   (insert "/*")
   ;;
   ;; Now form the top edge of the box.
   ;;
   (dcl-form-edge)
   ;;
   ;; Now make the initial portion of the informational part.
   ;;
   (new-newline)
   (insert "** ")
   ;;
   ;;  Define new keys to allow electric continuation and
   ;;  electric closure of the comment box.
   ;;
   (define-key dcl-mode-map [tab]   'dcl-comment-block-tab)
   (define-key dcl-mode-map [return] 'dcl-comment-block-enter)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment, above line the cursor is on.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-block-hi ()
   "Create a comment block appropriately indented, with electric continuation, above the line the cursor is on."
   (interactive)
   ;;
   ;; Position for the first line of the box.
   ;;
   (dcl-open-comment-hi)
   (insert "/*")
   ;;
   ;; Now form the top edge of the box.
   ;;
   (dcl-form-edge)
   ;;
   ;; Now make the initial portion of the informational part.
   ;;
   (new-newline)
   (insert "** ")
   ;;
   ;;  Define new keys to allow electric continuation and
   ;;  electric closure of the comment-box.
   ;;
   (define-key dcl-mode-map [tab]   'dcl-comment-block-tab)
   (define-key dcl-mode-map [return] 'dcl-comment-block-enter)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add a new blank comment line for extending box comments.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-extend-block-comment ()
  "Add a new blank comment line for extending box comments."
  (interactive)
  (dcl-open-comment-lo)
  (insert "** ")
  ;;
  ;;  Define new keys to allow electric continuation and
  ;;  electric closure of the comment addition.
  ;;
  (define-key dcl-mode-map [tab]    'dcl-comment-extend-tab)
  (define-key dcl-mode-map [return] 'dcl-comment-inline-enter)

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; For generating new inline comments.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-inline-comment ()
  "Generate fresh inline comments."
  (interactive)
  ;;
  ;; Get to end of line and space over to col 38
  ;; if that is possible.
  ;;
  (end-of-line)
  (while (< (current-column) 38)
    (insert " ")
  )
  ;;
  ;; Always start with a blank before the delimiter.
  ;;
  (insert " // ")
  ;;
  ;;  Define new keys to allow electric continuation and
  ;;  electric closure of the comment box.
  ;;
;  (define-key dcl-mode-map [tab]   'dcl-comment-inline-tab)
;  (define-key dcl-mode-map [return]   'dcl-comment-inline-enter)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General purpose electric comment ender.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(setq saved-shifted-motion-keys-select-region shifted-motion-keys-select-region)
(defun dcl-finish-comment ()
  "Finish and seal off an electric comment."
  (interactive)
  (end-of-line)
;  (setq shifted-motion-keys-select-region saved-shifted-motion-keys-select-region)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General purpose electric comment continuation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-open-comment-lo ()
  "Continue an electric comment."
  (interactive)

  ;; ensure the shift keys aren't being used to highlight a region
  (setq shifted-motion-keys-select-region nil)

  ;;
  ;;  Find how much the line is indented.
  ;;
  (beginning-of-line)
  (setq c-pos1 (current-column))
  (skip-chars-forward " \t")
  (setq c-pos2 (current-column))
  (setq c-dif (- c-pos2 c-pos1))
  ;;
  ;; Put a new line underneath current line.
  ;;
  (end-of-line)
  (newline)
  ;;
  ;; Indent the comment continuation.
  ;;
  (while (< c-pos1 c-pos2)
    (insert " ")
    (setq c-pos1 (1+ c-pos1))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General purpose electric comment continuation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-open-comment-hi ()
  "Continue an electric comment."
  (interactive)

  ;; ensure the shift keys aren't being used to highlight a region
;(debug-print-str "dcl-mode> shift-motion val " (ptos shifted-motion-keys-select-region))
;  (setq shifted-motion-keys-select-region nil)

  ;;
  ;;  Find how much the line is indented.
  ;;
  (beginning-of-line)
  (setq c-pos1 (current-column))
  (skip-chars-forward " \t")
  (setq c-pos2 (current-column))
  (setq c-dif (- c-pos2 c-pos1))
  ;;
  ;; Put a new line over current line.
  ;;
  (beginning-of-line)
  (backward-char 1)
  (newline)
  ;;
  ;; Indent the comment continuation.
  ;;
  (while (< c-pos1 c-pos2)
    (insert " ")
    (setq c-pos1 (1+ c-pos1))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General purpose electric comment continuation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-open-commentN ()
  "Continue an electric comment."
  (interactive)
  ;;
  ;;  Find how much the line is indented.
  ;;
  (beginning-of-line)
  (setq c-pos1 (current-column))
  (skip-chars-forward " \t")
  (setq c-pos2 (current-column))
  (setq c-dif (- c-pos2 c-pos1))
  ;;
  ;; Put a new line underneath current line.
  ;;
  (end-of-line)
  (newline)
  ;;
  ;; Indent the comment continuation.
  ;;
  (while (< c-pos1 c-pos2)
    (insert " ")
    (setq c-pos1 (1+ c-pos1))
  )
  ;;
  ;; Start the comment continuation.
  ;; Note: do NOT put extra space in this function!
  ;;
  (insert "**")
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment continuation for use on special key.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-block-enter()
  "Continue an electric comment"
  (interactive)
  (dcl-finish-comment)         ;; Finish off previous comment entry.
  (dcl-open-commentN)          ;; Generate a new open comment.
  (insert " ")                 ;; Add one space first.
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment sealer for use on special key.
;; Restore stolen key values.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-block-tab ()
  "Seal off an electric comment.  Restore keys."
  (interactive)
  (dcl-finish-comment)         ;; Finish off previous comment entry.
  (dcl-open-commentN)           ;; Generate new open comment.
  ;;
  ;; Fill new open comment with stars.
  ;;
  (setq countx (- 70 c-dif))
  (while (> countx 0)
    (insert "*")
    (setq countx (1- countx))
    )
  ;;
  ;; Add ending slash.
  ;;
  (insert "/")
  ;;
  ;; Put keys back.
  ;;
  (define-key dcl-mode-map [tab]      'dcl-indent-command)
  (define-key dcl-mode-map [return]   'good-enter)

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment continuation for use on special key.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-inline-enter ()
  "Continue an electric comment"
  (interactive)
  (dcl-finish-comment)          ;; Finish off previous comment entry.
  (dcl-open-commentN)           ;; Generate a new open comment.
  (insert " ")                  ;; Add one space first.
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment sealer for use on special key.
;; Restore stolen key values.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-inline-tab ()
  "Seal off an electric comment.  Restore keys."
  (interactive)
  ;;
  ;; Fill new open comment with blanks
  ;;
  (while (< (current-column) 71)
    (insert " ")
  )
  ;;
  ;; Add ending slash.
  ;;
  (insert "*/")
  ;;
  ;; Put keys back.
  ;;
  (define-key dcl-mode-map [tab]    'dcl-indent-command)
  (define-key dcl-mode-map [return] 'good-enter)

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electric comment sealer for use on comment extensions
;; Restore stolen key values.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-comment-extend-tab ()
  "Seal off an electric comment.  Restore keys."
  (interactive)
  ;;
  ;; Put keys back.
  ;;
  (define-key dcl-mode-map [tab]    'dcl-indent-command)
  (define-key dcl-mode-map [return] 'good-enter)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Form edge of a box comment.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dcl-form-edge ()
  (setq count (- 71 c-dif))
  (while (> count 0)
     (insert "*")
     (setq count (1- count))
   )
)

;;
;;
;;

;;;
;;;
;;;
(defvar dcl-mode-map nil
  "Keymap used in DCL mode.")

(if dcl-mode-map
    nil
  (let ((map (make-sparse-keymap)))

;;
;; Set up some short cuts for the c mode
;;
   (define-key map [(control return)]   'newline)
;   (define-key map [return]     'good-enter)
   (define-key map [return]     'newline-and-indent)
   (define-key map [end]        'end-of-line)
   (define-key map [home]       'beginning-of-line)
   (define-key map [tab]        'dcl-indent-command)
;;
;; Set up the comment keys for c mode
;;
   (define-key map [(shift up)]    'dcl-comment-block-hi)     ;;shift-up-arrow
   (define-key map [(shift down)]  'dcl-comment-block-lo)     ;;shift-down-arrow
   (define-key map [(shift right)] 'dcl-inline-comment)       ;;shift-right-arrow
   (define-key map [(shift left)]  'dcl-extend-block-comment) ;;shift-left-arrow
   (define-key map [(alt up)]      'dcl-comment-block-hi)     ;;shift-up-arrow
   (define-key map [(alt down)]    'dcl-comment-block-lo)     ;;shift-down-arrow
   (define-key map [(alt right)]   'dcl-inline-comment)       ;;shift-right-arrow
   (define-key map [(alt left)]    'dcl-extend-block-comment) ;;shift-left-arrow
   (define-key map [(meta up)]     'dcl-comment-block-hi)     ;;shift-up-arrow
   (define-key map [(meta down)]   'dcl-comment-block-lo)     ;;shift-down-arrow
   (define-key map [(meta right)]  'dcl-inline-comment)       ;;shift-right-arrow
   (define-key map [(meta left)]   'dcl-extend-block-comment) ;;shift-left-arrow

   (define-key map ";" 'electric-dcl-semi)

   (define-key map ":" 'electric-dcl-colon)
   (define-key map "{" 'electric-dcl-open-brace)
   (define-key map "}" 'electric-dcl-close-brace)
   (define-key map "\C-c\C-c"     'dcl-comment-region)
   (define-key map "\C-u\C-c\C-c" 'dcl-uncomment-region)
;(define-key c-mode-map "\C-c\C-u" 'c-up-conditional)
   (define-key map "\t" 'dcl-indent-command)
;(define-key c-mode-map "\C-c\C-q"  'c-indent-defun)
;(define-key c-mode-map "\C-c\C-\\" 'c-backslash-region)

   (define-key map "\C-c\C-n" 'forward-sexp)
   (define-key map [(control right)] 'forward-sexp)

   (define-key map "\C-c\C-p" 'backward-sexp)
   (define-key map [(control left)] 'backward-sexp)

(setq dcl-mode-map map)))

;;;
;;; DCL Syntax Table
;;;
(defun dcl-populate-syntax-table (table)
  ;; Populate the syntax TABLE
  ;; DO NOT TRY TO SET _ (UNDERSCORE) TO WORD CLASS!
;  (modify-syntax-entry ?_  "_"     table)
  ;; In dcl, the underscore is a valid symbol constituent, so
  ;; it belongs in class "_", but it is not a word delimiter, so
  ;; for correct font highlighting, it belongs in class "w" (word).
  ;; I added it to both classes. Is there any undesired affects? (CRG)
  (modify-syntax-entry ?_  "w_"    table)
  (modify-syntax-entry ?\\ "\\"    table)
  (modify-syntax-entry ?+  "."     table)
  (modify-syntax-entry ?-  "."     table)
  (modify-syntax-entry ?=  "."     table)
  (modify-syntax-entry ?%  "."     table)
  (modify-syntax-entry ?<  "."     table)
  (modify-syntax-entry ?>  "."     table)
  (modify-syntax-entry ?&  "."     table)
  (modify-syntax-entry ?|  "."     table)
  (modify-syntax-entry ?\' "\""    table)
  ; for backtick to be a word character so it can be used to setup some abbreviations
  (modify-syntax-entry ?`  "w"     table)
  ;; Set up block and line oriented comments.  The new C standard
  ;; mandates both comment styles even in C, so since all languages
  ;; now require dual comments, we make this the default.
  (modify-syntax-entry ?/  ". 1456" table)
  (modify-syntax-entry ?*  ". 23"   table)
;  (cond
;   ;; XEmacs 19 & 20
;   ((memq '8-bit c-emacs-features)
;    (modify-syntax-entry ?/  ". 1456" table)
;    (modify-syntax-entry ?*  ". 23"   table))
;   ;; Emacs 19 & 20
;   ((memq '1-bit c-emacs-features)
;    (modify-syntax-entry ?/  ". 124b" table)
;    (modify-syntax-entry ?*  ". 23"   table))
;   ;; incompatible
;   (t (error "DCL Mode is incompatible with this version of Emacs"))
;   )
  (modify-syntax-entry ?\n "> b"  table)
  ;; Give CR the same syntax as newline, for selective-display
  (modify-syntax-entry ?\^m "> b" table))

(defvar dcl-mode-syntax-table nil
  "Syntax table used in dcl-mode buffers.")
(if dcl-mode-syntax-table
    ()
  (setq dcl-mode-syntax-table (make-syntax-table))
  (dcl-populate-syntax-table dcl-mode-syntax-table)
)


(defun dcl-comment-region ()
  "Inserts a double slash comment before each line in a highlighted region"
  (interactive)
  (setq begPos (region-beginning))
  (setq endPos (region-end))

  ; get number of lines in the region
  (setq numlines 0)
  (save-excursion
    (setq curPos begPos)
    (beginning-of-line)
    (goto-char curPos)
    (while (< curPos endPos)
      (setq numlines (+ numlines 1))
      (forward-line 1)
      (setq curPos (point))
      )
    )

  ; insert comment chars before each line
  (setq curPos begPos)
  (goto-char curPos)
  (beginning-of-line)
  (setq cnt 0)
  (while (< cnt numlines)
    (save-excursion
      (insert "//  ")
      )
    (forward-line 1)
    (beginning-of-line)
    (setq curPos (point))
    (goto-char curPos)
    (setq cnt (+ cnt 1))
    )
  )

(defun dcl-uncomment-region ()
  "Removes leading double slashes at the beginning of each line in the region."
  (interactive)
  (setq begPos (region-beginning))
  (setq endPos (region-end))
  (setq curPos begPos)

  ; get number of lines in the region
  (setq numlines 0)
  (save-excursion
    (setq curPos begPos)
    (beginning-of-line)
    (goto-char curPos)
    (while (< curPos endPos)
      (setq numlines (+ numlines 1))
      (forward-line 1)
      (setq curPos (point))
      )
    )

  ; remove the comment chars at the start of a line
  (setq curPos begPos)
  (goto-char curPos)
  (beginning-of-line)
  (setq cnt 0)
  (while (< cnt numlines)
    (save-excursion
      (beginning-of-line)
      (if (looking-at "^//  ")
	  (delete-char 4)
	)
      )
    (forward-line 1)
    (beginning-of-line)
    (setq curPos (point))
    (goto-char curPos)
    (setq cnt (+ cnt 1))
    )
  )

;;;
;;; Indentation functions
;;;
(defun electric-dcl-open-brace ()
  "Insert character and correct line's indentation."
  (interactive)
  (progn
    (insert "{")
    (if (not (dcl-is-comment-line))
	(progn
	  (dcl-indent-line)
	  (delete-trailing-whitespace)
	  (if (not (is-middle-of-line t))
	      (end-of-line)
	    )
	  )
      )
    )
)

(defun electric-dcl-close-brace ()
  "Insert character and correct line's indentation."
  (interactive)
  (progn
    (insert "}")
    (if (not (dcl-is-comment-line))
	(progn
	  (dcl-indent-line)
	  (delete-trailing-whitespace)
	  (if (not (is-middle-of-line t))
	      (end-of-line)
	    )
	  )
      )
  )
)

(defun electric-dcl-semi ()
  "Insert character and correct line's indentation."
  (interactive)
  (progn
    (insert ";")
    (if (not (dcl-is-comment-line))
	(progn
          (setq rem-current-column (current-column))
	  (beginning-of-line-text)
	  (setq rem-current-column (- rem-current-column (current-column)))
	  (dcl-indent-line)
	  (delete-trailing-whitespace)
	  (goto-char (+ (point) rem-current-column))
;;	  (if (not (is-middle-of-line t))
;;	      (end-of-line)
;;	    )
	  )
      )
    )
)

(defun electric-dcl-colon ()
  "Insert character and correct line's indentation."
  (interactive)
  (progn
    (insert ":")
    (if (not (dcl-is-comment-line))
	(progn
          (setq rem-current-column (current-column))
	  (beginning-of-line-text)
	  (setq rem-current-column (- rem-current-column (current-column)))
	  (dcl-indent-line)
	  (delete-trailing-whitespace)
	  (goto-char (+ (point) rem-current-column))
;;	  (if (not (is-middle-of-line t))
;;	      (end-of-line)
;;	    )
	  )
      )
    )
)


(defun dcl-indent-command (&optional whole-exp)
  "Indent current line as DCL code, or in some cases insert a tab character.
If `dcl-tab-always-indent' is non-nil (the default), always indent current line.
Otherwise, indent the current line only if point is at the left margin or
in the line's indentation; otherwise insert a tab.

A numeric argument, regardless of its value, means indent rigidly all the
lines of the expression starting after point so that this line becomes
properly indented.  The relative indentation among the lines of the
expression are preserved."
  (interactive)
  (debug-print-str "dcl-mode> " "INSIDE dcl-indent-command")
;  (if whole-exp
;      ;; If arg, always indent this line as DCL
;      ;; and shift remaining lines of expression the same amount.
;      (let ((shift-amt (dcl-indent-line)) beg end)
;	(save-excursion
;	  (if dcl-tab-always-indent
;	      (beginning-of-line)
;	  )
;	  ;; Find beginning of following line.
;	  (save-excursion
;	    (forward-line 1) (setq beg (point))
;	  )
;	  ;; Find first beginning-of-sexp for sexp extending past this line.
;	  (while (< (point) beg)
;	    (forward-sexp 1)
;	    (setq end (point))
;	    (skip-chars-forward " \t\n")
;	  )
;	)
;	(if (> end beg)
;	    (indent-code-rigidly beg end shift-amt "#")
;	)
;      )
;    (if (and (not dcl-tab-always-indent)
;	     (save-excursion
;	       (skip-chars-backward " \t")
;	       (not (bolp))
;	     )
;	)
;	(insert-tab)
      (dcl-indent-line)
;      (delete-line-trailing-whitespace)
      (end-of-line)
;    )
;  )
)


(defun dcl-indent-line ()
  "Indent current line as DCL code.
Return the amount the indentation changed by."
  (interactive)
  (debug-print-str "dcl-mode> " "INSIDE dcl-indent-line")
  (let ((indent (calculate-dcl-indent nil))
	beg shift-amt
	(case-fold-search nil)
	(pos (- (point-max) (point)))
       )
   (save-excursion
    (beginning-of-line)
    (setq beg (point))

;    (cond ((eq indent nil)     ; inside a string
;	   (setq indent (current-indentation)))
;	  ((eq indent t)       ; inside a comment
;	   (setq indent (calculate-dcl-indent-within-comment)))
;	  ((looking-at "[ \t]*#")
;	   (setq indent 0))
;	  (t
;	   (skip-chars-forward " \t")
;	   (if (listp indent) (setq indent (car indent)))
;	   (cond ((and (looking-at "otherwise\\b")
;		       (not (looking-at "otherwise\\s_")))
;		  (setq indent (save-excursion
;				 (dcl-backward-to-start-of-when)
;				 (current-indentation))))
;		 ((and (looking-at "}[ \t]*otherwise\\b")
;		       (not (looking-at "}[ \t]*otherwise\\s_")))
;		  (setq indent (save-excursion
;				 (forward-char)
;				 (backward-sexp)
;				 (dcl-backward-to-start-of-when)
;				 (current-indentation))))
;		 ((and (looking-at "until\\b")
;		       (not (looking-at "until\\s_"))
;		       (save-excursion
;			 (dcl-backward-to-start-of-until)))
;		  (setq indent (save-excursion
;				 (dcl-backward-to-start-of-until)
;				 (current-indentation))))
;		 ((= (following-char) ?})
;		  (setq indent (- indent dcl-basic-indent-level)))
;		 ((= (following-char) ?{)
;		  (setq indent (+ indent dcl-brace-offset)))
;	    )
;	  )
;    )
;    (skip-chars-forward " \t")
;    (setq shift-amt (- indent (current-column)))
;    (if (zerop shift-amt)
;	(if (> (- (point-max) pos) (point))
;	    (goto-char (- (point-max) pos)))
;      (delete-region beg (point))
;(debug-print (cons "indent = " indent) (get-buffer "foo"))
      ;; If initial point was within line's indentation,
      ;; position after the indentation.  Else stay at same point in text.
;      (if (> (- (point-max) pos) (point))
;	  (goto-char (- (point-max) pos)))
;      )
;    shift-amt
  )
  (beginning-of-line)
  ; since the cursor may start in the middle of an exisiting line, the leading
  ; spaces on the line must be deleted before indenting
  (delete-horizontal-space)
  (indent-to indent)
;  (end-of-line)
 (debug-print-str "dcl-mode> " "LEAVING dcl-indent-line")
  indent
 )
)

(defun calculate-dcl-indent (&optional parse-start)
  "Return appropriate indentation for current line as DCL code.
In usual case returns an integer: the column to indent to.
Returns nil if line starts inside a string, t if in a comment."
  (interactive)
  (save-excursion
    (debug-print-str "dcl-mode> " "inside calculate-dcl-indent")
    (beginning-of-line)
    (cond
     ; if first line of the buffer
     ((bobp)
      (debug-print-str "dcl-mode> " "  first line of buffer")
	(setq indentto 0)
     )
     ; handle primary keywords -- put in first column
     ;
     ; tech_family, expose, import, typedef, subrule, external
     ;
     ((dcl-is-primary-keyword)
      (debug-print-str "dcl-mode> " "  primary keyword")
        (setq indentto (dcl-get-primary-keyword-indent))
     )
     ; handle primary statement
     ;
     ; calc, delay, assign, slew, check
     ;
     ((dcl-is-primary-statement)
      (debug-print-str "dcl-mode> " "  primary statement")
        (setq indentto (dcl-get-primary-statement-indent))
     )
     ; handle secondary keywords -- indent sometimes, but not after a previous sec. keyword
     ;
     ; local, passed, result
     ;
     ((dcl-is-secondary-keyword)
      (debug-print-str "dcl-mode> " "  secondary keyword")
      (setq indentto (dcl-get-secondary-keyword-indent))
     )
     ; handle "when", "repeat", "for"
     ;
     ((dcl-is-loop)
      (debug-print-str "dcl-mode> " "  loop/when")
      (setq indentto (dcl-get-loop-indent))
     )
     ; handle the keyword "otherwise"
     ((dcl-is-otherwise)
      (debug-print-str "dcl-mode> " "  otherwise")
      (setq indentto (dcl-get-otherwise-indent))
     )
     ; handle keyword "until"
     ((dcl-is-until)
      (debug-print-str "dcl-mode> " "  until")
      (setq indentto (dcl-get-until-indent))
     )
     ; handle "try", "catch""
     ;
     ((dcl-is-try)
      (debug-print-str "dcl-mode> " "  try")
      (setq indentto (dcl-get-try-indent))
     )
     ; handle the keyword "catch"
     ((dcl-is-catch)
      (debug-print-str "dcl-mode> " "  catch")
      (setq indentto (dcl-get-catch-indent))
     )
     ; handle cpp directives
     ((dcl-is-preprocessor)
      (debug-print-str "dcl-mode> " "  preprocessor")
      (setq indentto (dcl-get-preprocessor-indent))
     )
     ; handle case with a close brace on a line without an opening brace on the line
     ((dcl-is-close-brace)
      (debug-print-str "dcl-mode> " "  close brace")
      (setq indentto (dcl-get-close-brace-indent))
     )
     ; handle case with a opening brace as the first item on the line
     ((dcl-is-open-brace)
      (debug-print-str "dcl-mode> " "  opening brace")
      (setq indentto (dcl-get-open-brace-indent))
     )
     ; handle case with a close paren on a line without an opening paren
     ((dcl-is-close-paren)
      (debug-print-str "dcl-mode> " "  close paren")
      (setq indentto (dcl-get-close-paren-indent))
     )
     ;  unknown indentation case (e.g. not a keyword)
     (t
      (progn
	(save-excursion
	  (debug-print-str "dcl-mode> " "  starting unknown indentation")
          (dcl-previous-code-line)
	  (beginning-of-line)
	  (cond
	   ((bobp)
	    (debug-print-str "dcl-mode> " "    beginning of buffer encountered")
	    (setq indentto 0)
	   )
	   ; handle case of open paren on previous line
	   ((and (looking-at ".*(") (progn (beginning-of-line) (not (looking-at ".*(.*)"))))
	    (debug-print-str "dcl-mode> " "    open paren encountered")
	      (setq indentto
		(progn
  	           (end-of-line)
		   (skip-chars-backward "^(")
		   (current-column)
		)
	      )
	   )
	   ; handle case of open brace on previous line
	   ((and (looking-at "^[ \t]*{") (progn (beginning-of-line) (not (looking-at ".*{.*}"))))
	    (progn
	      (end-of-line)
	      (skip-chars-backward "^{")
	      (setq indentto (+ (- (current-column) 1)  dcl-basic-indent-level))
	      (debug-print-str "dcl-mode> " "    open brace encountered")
	    )
	   )
	   ; handle case where previous line is a opening main group
	   ((looking-at "^[ \t]*\\(when\\|otherwise\\|repeat\\|while\\|for\\)\\([ \t]*\\|\(\\|\{\\)")
	    (setq indentto (+ (current-indentation) dcl-basic-indent-level))
	    (debug-print-str "dcl-mode> " "    open main keyword encountered")
	   )
           ; all other cases indent to previous line indentation
	   (t
	    (setq indentto (current-indentation) )
	    (debug-print-str "dcl-mode> " "    indent to previous indentation")
	   )
	  )
	)
      )
     )
    )
  )
  indentto

)

(defun dcl-previous-code-line ()
  "Move the point to the beginning of the next dcl code line
going backwards through the buffer"
  (beginning-of-line)
  (if (not (bobp))
      (forward-line -1)
  )
  (while (and (not (bobp)) (or (dcl-is-blank-line) (dcl-is-comment-line)))
    (forward-line -1)
    (beginning-of-line)
  )
)

(defun dcl-is-blank-line ()
  "Returns t if the line only contains whitespace, otherwise
it returns nil"
  (beginning-of-line)
  (if (looking-at "[ \t]*\n")
       (setq result t)
    (setq result nil)
  )
  result
)

(defun dcl-is-comment-line ()
  "Returns t if the line is part of a comment,
otherwise it returns nil"
  (interactive)

; (setq presline (dcl-current-line))
 (setq isComment nil)
 (setq bmlc_regexp "^[ \t]*\/\\*")
 (setq emlc_regexp "^[ \t]*.*\\*\/")
 (setq lc_regexp "^[ \t]*\/\/")
 (save-excursion
   (beginning-of-line)
   (if (or (or (looking-at lc_regexp)
	       (looking-at bmlc_regexp))
	   (looking-at emlc_regexp))
       (setq isComment t)
     )
 )


 (if (not isComment)
     (let ()
      ; Check if point is in the middle of a comment
      (setq presline (dcl-current-line))
      (setq endline   presline)
      (setq startline presline)
      (setq foundBOC nil)
      (setq foundEOC nil)
      (save-excursion
        (setq done nil)
        (beginning-of-line)
        (while (and (and (not done) (not (bobp))) (not (looking-at emlc_regexp)) )
          (if (looking-at bmlc_regexp)
	    (progn
	      (setq startline (dcl-current-line))
	      (setq foundBOC t)
	      (setq done t)
	    )
	  (forward-line -1)
         )
         (beginning-of-line)
       )
     )

     (if foundBOC
       (save-excursion
         (setq done nil)
         (while (and (and (not done) (not (eobp))) (not (looking-at bmlc_regexp)))
           (if (looking-at emlc_regexp)
  	        (progn
  	          (setq endline (dcl-current-line))
 	          (setq foundEOC t)
  	          (setq done t)
 	        )
 	      (forward-line 1)
           )
           (beginning-of-line)
         )
       )
     )

     (if (and foundBOC foundEOC)
        (setq isComment t)
     )
    )
   )

 isComment
)

(defun dcl-is-primary-keyword ()
  (interactive)
  (setq res nil)
  (if (looking-at "^[ \t]*\\(tech_family\\|expose\\|import\\|export\\|forward\\|typedef\\|subrule\\|subrules\\|model\\|modelproc\\)\\([ \t]+\\|\(\\)")
      (setq res t)
    (setq res nil)
  )
  res
)

(defun dcl-get-primary-keyword-indent ()
  dcl-primary-keyword-offset
)

(defun dcl-is-primary-statement ()
  (if (looking-at "^[ \t]*\\(calc\\|delay\\|assign\\|slew\\|check\\|internal\\|external\\|submodel\\|load_table\\|unload_table\\|write_table\\|add_row\\|tabledef\\|external\\|internal\\)\\([ \t]+\\|\(\\)")
      (setq res t)
    (setq res nil)
  )
  res
)

(defun dcl-get-primary-statement-indent ()
  dcl-primary-statement-offset
)

(defun dcl-is-secondary-keyword ()
  (if (looking-at "^[ \t]*\\(local\\|passed\\|result\\|qualifiers\\|default\\|data\\)\\([ \t]+\\|\(\\)")
      (setq res t)
    (setq res nil)
  )
  res
)

(defun dcl-get-secondary-keyword-indent ()
  (progn
    (save-excursion
      (dcl-previous-code-line)
      (cond
       ((looking-at "^[ \t]*\\(local\\|passed\\|result\\|qualifiers\\|data\\)\\([ \t]+\\|\(\\)")
	  (setq res (current-indentation))
       )
       ((and (looking-at ".*)") (progn (beginning-of-line) (not (looking-at ".*(.*)"))))
	(progn
	  ; need to continue backwards until associated open paren is found
	  (setq done nil)
	  (while (and (not done) (not (bobp)))
	    (if (and (looking-at ".*(") (progn (beginning-of-line) (not (looking-at ".*(.*)"))))
		(setq done t)
	      (progn (dcl-previous-code-line)
		     (beginning-of-line))
	    )
	  )
	  (setq res (current-indentation))
	)
       )
       ((dcl-is-primary-keyword)
	(setq res (+ (current-indentation) (+ dcl-basic-indent-level dcl-secondary-keyword-offset)))
       )
       ((looking-at "^[ \t]*\\(\)\\|\}\\)")
        (setq res (current-indentation))
       )
       (t	
	(setq res (+ (current-indentation) (+ dcl-basic-indent-level) dcl-secondary-keyword-offset))
       )
      )
    )
  )
  res
)

(defun dcl-is-loop ()
  (if (looking-at "^[ \t]*\\(when\\|repeat\\|for\\)\\([ \t]+\\|\(\\|\{\\)")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-loop-indent ()
  (progn
    (save-excursion
      (dcl-previous-code-line)
      (setq res (current-indentation))
    )
  )
  res
)

(defun dcl-is-otherwise ()
  (if (looking-at "^[ \t]*otherwise")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-otherwise-indent ()
  (progn
    (save-excursion
      (setq res (current-indentation))
      ;find the associated "when"
      (setq done nil)
      (while (not done)
	(dcl-previous-code-line)
	(if (looking-at "^[ \t]*when\\([ \t]+\\|\(\\)")
	    (progn
	      (setq res (current-indentation))
	      (setq done t)
	    )
	  (setq done nil)
	)
      )
    )
  )
  res
)

(defun dcl-is-until ()
  (if (looking-at "^[ \t]*until\\([ \t]+\\|\(\\)")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-until-indent ()
  (progn
    (save-excursion
      (setq res (current-indentation))
      ;find the associated "repeat"
      (setq done nil)
      (while (not done)
	(dcl-previous-code-line)
	(if (looking-at "^[ \t]*repeat\\([ \t]+\\|\{\\)")
	    (progn
	      (setq res (current-indentation))
	      (setq done t)
	    )
	  (setq done nil)
	)
      )
    )
  )
  res
)

(defun dcl-is-try ()
  (if (looking-at "^[ \t]*\\(try\\)\\([ \t]+\\|\(\\|\{\\)")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-try-indent ()
  (progn
    (save-excursion
      (dcl-previous-code-line)
      (setq res (current-indentation))
    )
  )
  res
)

(defun dcl-is-catch ()
  (if (looking-at "^[ \t]*catch")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-catch-indent ()
  (progn
    (save-excursion
      (setq res (current-indentation))
      ;find the associated "when"
      (setq done nil)
      (while (not done)
	(dcl-previous-code-line)
	(if (looking-at "^[ \t]*try\\([ \t]+\\|\(\\)")
	    (progn
	      (setq res (current-indentation))
	      (setq done t)
	    )
	  (setq done nil)
	)
      )
    )
  )
  res
)

(defun dcl-is-preprocessor ()
  (if (looking-at "^[ \t]*\\(#define\\|#include\\|#ifdef\\|#ifndef\\|#endif|#error\\)")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-preprocessor-indent ()
 0
)

(defun dcl-is-close-brace ()
  (if (and (looking-at ".*}.*") (progn (beginning-of-line) (not (looking-at ".*{.*}.*"))))
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-close-brace-indent ()
  (progn
    (save-excursion
      (beginning-of-line)
      (search-forward "}")
      (backward-sexp)
      (search-backward "(")
      (backward-sexp)
      (setq theindent (current-indentation))
      (setq res theindent)
    )
  )
  res
)

(defun dcl-is-open-brace ()
  (if (looking-at "^[ \t]*\{.*")
      (setq res t)
    (setq res nil)
  )
)

(defun dcl-get-open-brace-indent ()
  (progn
    (save-excursion
      (dcl-previous-code-line)
      (setq res (current-indentation))
    )
  )
  res
)

(defun dcl-is-close-paren ()
  (interactive)
  (setq res nil)
  (if (and (looking-at "[ \t]*).*")
	   (progn
	     (beginning-of-line)
	     (not (looking-at ".*(.*)"))
	   )
      )
      (setq res t)
    (setq res nil)
  )
  res
)

(defun dcl-get-close-paren-indent ()
  (progn
    (save-excursion
      (beginning-of-line)
      (search-forward ")")
      (backward-sexp)
      (setq theindent (current-column))
      (setq res theindent)
    )
  )
  res
)

(defun dcl-current-line ()
  "Return the vertical position of point..."
  (+ (count-lines (window-start) (point))
     (if (= (current-column) 0) 1 0)
     -1
  )
)


(defun calculate-dcl-indent-after-brace ()
  "Return the proper DCL indent for the first line after an open-brace.
This function is called with point before the brace."
  ;; For open brace in column zero, don't let statement
  ;; start there too.  If dcl-basic-indent-level is zero,
  ;; use c-brace-offset + dcl-continued-statement-offset instead.
  ;; For open-braces not the first thing in a line,
  ;; add in dcl-brace-imaginary-offset.

  )

(defun calculate-dcl-indent-within-comment (&optional after-star)
  "Return the indentation amount for line inside a block comment.
Optional arg AFTER-STAR means, if lines in the comment have a leading star,
return the indentation of the text that would follow this star."

  )


;;;
;;; define which file extensions start this mode
;;;
(setq auto-mode-alist
      (append
       '(("\\.r\\'" . dcl-mode)
	 ("\\.rh\\'" . dcl-mode)
	 )
       auto-mode-alist))

;;;
;;; Setup the faces
;;;
(require 'font-lock)

; force the matching to be case sensitive
(setq font-lock-keywords-case-fold-search nil)

(defvar dcl-keywords-1
  (list
   "add_row"       "ADD_ROW"
   "assign"        "ASSIGN"
   "bus"           "BUS"
   "calc"          "CALC"
   "check"         "CHECK"
   "delay"         "DELAY"
   "delete_row"    "DELETE_ROW"
   "do"            "DO"
   "end"           "END"
   "export"        "EXPORT"
   "expose"        "EXPOSE"
   "external"      "EXTERNAL"
   "import"        "IMPORT"
   "input"         "INPUT"
   "internal"      "INTERNAL"
   "load_table"    "LOAD_TABLE"
   "local"         "LOCAL"
   "method"        "METHOD"
   "model"         "MODEL"
   "modelproc"     "MODELPROC"
   "output"        "OUTPUT"
   "passed"        "PASSED"
   "path"          "PATH"
   "properties"    "PROPERTIES"
   "pragma"        "PRAGMA"
   "result"        "RESULT"
   "setvar"        "SETVAR"
   "slew"          "SLEW"
   "submodel"      "SUBMODEL"
   "subrule"       "SUBRULE"
   "subrules"      "SUBRULES"
   "table"         "TABLE"
   "tabledef"      "TABLEDEF"
   "tech_family"   "TECH_FAMILY"
   "test"          "TEST"
   "typedef"       "TYPEDEF"
   "unload_table"  "UNLOAD_TABLE"
   "write_table"   "WRITE_TABLE"
   "#define"       "#DEFINE"
   "#include"      "#INCLUDE"
  )
)

(defvar dcl-match-keywords-1
  (concat "\\<\\("
	  (regexp-opt dcl-keywords-1)
	  "\\)\\>")
  "regexp to match the dcl keywords")

(defvar dcl-keywords-2
  (list
   "break"            "BREAK"
   "bias"             "BIAS"
   "busy"             "BUSY"
   "catch"            "CATCH"
   "checks"           "CHECKS"
   "compare"          "COMPARE"
   "consistent"       "CONSISTENT"
   "continue"         "CONTINUE"
   "corrind"          "CORRIND"
   "cycleadj"         "CYCLEADJ"
   "data"             "DATA"
   "default"          "DEFAULT"
   "defines"          "DEFINES"
   "delayadj"         "DELAYADJ"
   "early"            "EARLY"
   "edges"            "EDGES"
   "end"              "END"
   "file"             "FILE"
   "file_path"        "FILE_PATH"
   "filter"           "FILTER"
   "for"              "FOR"
   "from"             "FROM"
   "key"              "KEY"
   "late"             "LATE"
   "lock"             "LOCK"
   "methods"          "METHODS"
   "node"             "NODE"
   "object_type"      "OBJECT_TYPE"
   "objtype"          "OBJTYPE"
   "otherwise"        "OTHERWISE"
   "propagate"        "PROPAGATE"
   "prototype_record" "PROTOTYPE_RECORD"
   "proxy"            "PROXY"
   "qualifiers"       "QUALIFIERS"
   "read_lock"        "READ_LOCK"
   "repeat"           "REPEAT"
   "retry"            "RETRY"
   "statements"       "STATEMENTS"
   "table_path"       "TABLE_PATH"
   "to"               "TO"
   "try"              "TRY"
   "until"            "UNTIL"
   "using"            "USING"
   "wait"             "WAIT"
   "when"             "WHEN"
   "while"            "WHILE"
   "write_lock"       "WRITE_LOCK"
  )
)

(defvar dcl-match-keywords-2
  (concat "\\<\\("
	  (regexp-opt dcl-keywords-2)
	  "\\)\\>")
  "regexp to match the dcl keywords")

(defvar dcl-keywords-3
  (list
   "abs"                             "ABS"
   "abstract"                        "ABSTRACT"
   "aggregate"                       "AGGREGATE"
   "anyin"                           "ANYIN"
   "anyout"                          "ANYOUT"
   "argv"                            "ARGV"
   "autolock"                        "AUTOLOCK"
   "bhc"                             "BHC"
   "bit"                             "BIT"
   "binary"                          "BINARY"
   "both"                            "BOTH"
   "brc"                             "BRC"
   "btr"                             "BTR"
   "by"                              "BY"
   "calc_mode"                       "CALC_MODE"
   "calc_mode_scalar"                "CALC_MODE_SCALAR"
   "call"                            "CALL"
   "cell"                            "CELL"
   "cell_data"                       "CELL_DATA"
   "cell_qual"                       "CELL_QUAL"
   "char"                            "CHAR"
   "character"                       "CHARACTER"
   "ckttype"                         "CKTTYPE"
   "clkflg"                          "CLKFLG"
   "common"                          "COMMON"
   "compiler_time_stamp"             "COMPILER_TIME_STAMP"
   "complex"                         "COMPLEX"
   "compressed"                      "COMPRESSED"
   "compressor"                      "COMPRESSOR"
   "control_parm"                    "CONTROL_PARM"
   "cght"                            "CGHT"
   "cgpw"                            "CGPW"
   "cst"                             "CST"
   "data_type"                       "DATA_TYPE"
   "dcm_neg_dynamic_latch"           "DCM_NEG_DYNAMIC_LATCH"
   "dcm_neg_precharge_node"          "DCM_NEG_PRECHARGE_NODE"
   "dcm_pos_dynamic_latch"           "DCM_POS_DYNAMIC_LATCH"
   "dcm_pos_precharge_node"          "DCM_POS_PRECHARGE_NODE"
   "dcm_off"                         "DCM_OFF"
   "dcm_low"                         "DCM_LOW"
   "dcm_medium"                      "DCM_MEDIUM"
   "dcm_high"                        "DCM_HIGH"
   "dcm_fullbore"                    "DCM_FULLBORE"
   "deadlock"                        "DEADLOCK"
   "debug_off"                       "DEBUG_OFF"
   "debug_low"                       "DEBUG_LOW"
   "debug_medium"                    "DEBUG_MEDIUM"
   "debug_high"                      "DEBUG_HIGH"
   "debug_fullbore"                  "DEBUG_FULLBORE"
   "defer"                           "DEFER"
   "descriptor"                      "DESCRIPTOR"
   "dht"                             "DHT"
   "differential_skew"               "DIFFERENTIAL_SKEW"
   "double"                          "DOUBLE"
   "dpw"                             "DPW"
   "dst"                             "DST"
   "duplicate_pins"                  "DUPLICATE_PINS"
   "dynamic"                         "DYNAMIC"
   "early_slew"                      "EARLY_SLEW"
   "ect"                             "ECT"
   "error"                           "ERROR"
   "eval"                            "EVAL"
   "excess64"                        "EXCESS64"
   "excess128"                       "EXCESS128"
   "expand"                          "EXPAND"
   "expanded"                        "EXPANDED"
   "fall"                            "FALL"
   "first"                           "FIRST"
   "float"                           "FLOAT"
   "force"                           "FORCE"
   "forward"                         "FORWARD"
   "from_point"                      "FROM_POINT"
   "from_point_pin_association"      "FROM_POINT_PIN_ASSOCIATION"
   "function"                        "FUNCTION"
   "generate"                        "GENERATE"
   "hold"                            "HOLD"
   "imag_part"                       "IMAG_PART"
   "import_export_tag"               "IMPORT_EXPORT_TAG"
   "impure"                          "IMPURE"
   "inconsistent"                    "INCONSISTENT"
   "inform"                          "INFORM"
   "input_pin_count"                 "INPUT_PIN_COUNT"
   "input_pins"                      "INPUT_PINS"
   "instantiated"                    "INSTANTIATED"
   "int"                             "INT"
   "integer"                         "INTEGER"
   "is_empty"                        "IS_EMPTY"
   "last"                            "LAST"
   "late_slew"                       "LATE_SLEW"
   "launchable"                      "LAUNCHABLE"
   "leading"                         "LEADING"
   "like"                            "LIKE"
   "long"                            "LONG"
   "model_domain"                    "MODEL_DOMAIN"
   "model_name"                      "MODEL_NAME"
   "modifiers"                       "MODIFIERS"
   "monolithic"                      "MONOLITHIC"
   "new"                             "NEW"
   "nil"                             "NIL"
   "nochange"                        "NOCHANGE"
   "node_count"                      "NODE_COUNT"
   "node_point"                      "NODE_POINT"
   "node_point_pin_association"      "NODE_POINT_PIN_ASSOCIATION"
   "nodes"                           "NODES"
   "nofail"                          "NOFAIL"
   "num_dimensions"                  "NUM_DIMENSIONS"
   "num_elements"                    "NUM_ELEMENTS"
   "number"                          "NUMBER"
   "one_to_z"                        "ONE_TO_Z"
   "optional"                        "OPTIONAL"
   "output_pin_count"                "OUTPUT_PIN_COUNT"
   "output_pins"                     "OUTPUT_PINS"
   "override"                        "OVERRIDE"
   "path_data"                       "PATH_DATA"
   "path_separator"                  "PATH_SEPARATOR"
   "phase"                           "PHASE"
   "pin"                             "PIN"
   "pin_range_delimiter"             "PIN_RANGE_DELIMITER"
   "pinlist"                         "PINLIST"
   "plane"                           "PLANE"
   "primitive"                       "PRIMITIVE"
   "print_value"                     "PRINT_VALUE"
   "process_variation"               "PROCESS_VARIATION"
   "process_variation_scalar"        "PROCESS_VARIATION_SCALAR"
   "pure"                            "PURE"
   "pwr"                             "PWR"
   "real"                            "REAL"
   "real_part"                       "REAL_PART"
   "recovery"                        "RECOVERY"
   "reference"                       "REFERENCE"
   "reference_edge"                  "REFERENCE_EDGE"
   "reference_edge_scalar"           "REFERENCE_EDGE_SCALAR"
   "reference_mode"                  "REFERENCE_MODE"
   "reference_mode_scalar"           "REFERENCE_MODE_SCALAR"
   "reference_point"                 "REFERENCE_POINT"
   "reference_point_pin_association" "REFERENCE_POINT_PIN_ASSOCIATION"
   "reference_slew"                  "REFERENCE_SLEW"
   "removal"                         "REMOVAL"
   "route"                           "ROUTE"
   "replace"                         "REPLACE"
   "rise"                            "RISE"
   "rule_path"                       "RULE_PATH"
   "setup"                           "SETUP"
   "severe"                          "SEVERE"
   "shared"                          "SHARED"
   "short"                           "SHORT"
   "signal"                          "SIGNAL"
   "signal_edge"                     "SIGNAL_EDGE"
   "signal_edge_scalar"              "SIGNAL_EDGE_SCALAR"
   "signal_mode"                     "SIGNAL_MODE"
   "signal_mode_scalar"              "SIGNAL_MODE_SCALAR"
   "signal_point"                    "SIGNAL_POINT"
   "signal_point_pin_association"    "SIGNAL_POINT_PIN_ASSOCIATION"
   "signal_slew"                     "SIGNAL_SLEW"
   "signed"                          "SIGNED"
   "sink_edge"                       "SINK_EDGE"
   "sink_edge_scalar"                "SINK_EDGE_SCALAR"
   "sink_mode"                       "SINK_MODE"
   "sink_mode_scalar"                "SINK_MODE_SCALAR"
   "sink_strands"                    "SINK_STRANDS"
   "sink_strands_lsb"                "SINK_STRANDS_LSB"
   "sink_strands_msb"                "SINK_STRANDS_MSB"
   "skew"                            "SKEW"
   "slew"                            "SLEW"
   "source_edge"                     "SOURCE_EDGE"
   "source_edge_scalar"              "SOURCE_EDGE_SCALAR"
   "source_mode"                     "SOURCE_MODE"
   "source_mode_scalar"              "SOURCE_MODE_SCALAR"
   "source_strands"                  "SOURCE_STRANDS"
   "source_strands_lsb"              "SOURCE_STRANDS_LSB"
   "source_strands_msb"              "SOURCE_STRANDS_MSB"
   "space"                           "SPACE"
   "step_table_current"              "STEP_TABLE_CURRENT"
   "step_table_start"                "STEP_TABLE_START"
   "step_table_end"                  "STEP_TABLE_END"
   "step_table_forwards"             "STEP_TABLE_FORWARDS"
   "step_table_backwards"            "STEP_TABLE_BACKWARDS"
   "step_table_to_default_record"    "STEP_TABLE_TO_DEFAULT_RECORD"
   "store"                           "STORE"
   "string"                          "STRING"
   "suppress"                        "SUPPRESS"
   "sync"                            "SYNC"
   "term"                            "TERM"
   "test_type"                       "TEST_TYPE"
   "to_point"                        "TO_POINT"
   "to_point_pin_association"        "TO_POINT_PIN_ASSOCIATION"
   "transient"                       "TRANSIENT"
   "trailing"                        "TRAILING"
   "type_string"                     "TYPE_STRING"
   "uncompress"                      "UNCOMPRESS"
   "uncompressor"                    "UNCOMPRESSOR"
   "uncompress_on_recall"            "UNCOMPRESS_ON_RECALL"
   "uncompress_on_store"             "UNCOMPRESS_ON_STORE"
   "unsigned"                        "UNSIGNED"
   "user_defined_macro"              "USER_DEFINED_MACRO"
   "user_defined_logic"              "USER_DEFINED_LOGIC"
   "user_defined_type"               "USER_DEFINED_TYPE"
   "var"                             "VAR"
   "vector"                          "VECTOR"
   "verify_path"                     "VERIFY_PATH"
   "void"                            "VOID"
   "warning"                         "WARNING"
   "zero_to_z"                       "ZERO_TO_Z"
   "z_to_one"                        "Z_TO_ONE"
   "z_to_zero"                       "Z_TO_ZERO"
  )
)

(defvar dcl-match-keywords-3
  (concat "\\<\\("
	  (regexp-opt dcl-keywords-3)
	  "\\)\\>")
  "regexp to match the dcl keywords")

;;(unless (facep 'font-lock-builtin-face)
;;  (copy-face 'font-lock-keyword-face 'font-lock-builtin-face))

;;(unless (facep 'font-lock-constant-face)
;;  (copy-face 'font-lock-keyword-face 'font-lock-constant-face))

(defvar dcl-font-lock-keywords-1
  `(
    (,dcl-match-keywords-1 . font-lock-keyword-face))
  "Subdued level highlighting for DCL mode.")

(defvar dcl-font-lock-keywords-2
  (append dcl-font-lock-keywords-1
   `(
     (,dcl-match-keywords-2 . font-lock-type-face)))
   "Medium level highlighting for DCL mode.")

(defvar dcl-font-lock-keywords-3
  (append dcl-font-lock-keywords-2
   `(
     (,dcl-match-keywords-3 . font-lock-builtin-face)))
  "Gaudy level highlighting")

(defvar dcl-font-lock-keywords dcl-font-lock-keywords-1
  "Default expressions to highlight in DCL mode.")

(defun dcl-font-setup ()
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults
        '((dcl-font-lock-keywords
	   dcl-font-lock-keywords-1
           dcl-font-lock-keywords-2
	   dcl-font-lock-keywords-3)
          nil nil
	 )
  )
)

(add-hook 'dcl-mode-hook 'dcl-font-setup)

;;;
;;; Setup an abbreviation table
;;;
(define-abbrev-table 'dcl-mode-abbrev-table
  '(
    ("`ar"   "add_row() suppress: tabledef()" nil 0)
    ("`arr"  "add_row() replace suppress: tabledef();" nil 0)
    ("`b1"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 1\');" nil 0)
    ("`b2"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 2\');" nil 0)
    ("`b3"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 3\');" nil 0)
    ("`b4"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 4\');" nil 0)
    ("`b5"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 5\');" nil 0)
    ("`b6"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 6\');" nil 0)
    ("`b7"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 7\');" nil 0)
    ("`b8"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 8\');" nil 0)
    ("`b9"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 9\');" nil 0)
    ("`b10"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 10\');" nil 0)
    ("`b11"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 11\');" nil 0)
    ("`b12"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 12\');" nil 0)
    ("`b13"   ":issue_message(112233, inform, \'<FOR DEBUG>    BLAH 13\');" nil 0)
    ("`c"    "calc("                nil 0)
    ("`cdl"  ":change_debug_level(" nil 0)
    ("`cdl3" ":change_debug_level(3);" nil 0)
    ("`cdl0" ":change_debug_level(0);" nil 0)
    ("`crg"  "/*<CRG>*/ " nil 0)
    ("`crgdebug" "/*<CRG DEBUG>*/" nil 0)
    ("`cons" "consistent"           nil 0)
    ("`f"    "force("               nil 0)
    ("`glh"  "get_load_history("   nil 0)
    ("`gpn"  "get_plane_name("     nil 0)
    ("`gsp"  "get_space_name("     nil 0)
    ("`icons" "inconsistent"        nil 0)
    ("`ieit" "is_expose_in_tech("  nil 0)
    ("`ie"   "is_empty("           nil 0)
    ("`im"   ":issue_message("      nil 0)
    ("`imi"  ":issue_message(9999, inform, " nil 0)
    ("`imw"  ":issue_message(9999, warning, " nil 0)
    ("`ime"  ":issue_message(9999, error, " nil 0)
    ("`ir"   "iround("              nil 0)
    ("`le"   "calc(LATENT_EXPRESSION):" nil 0)
    ("`lx"   "calc(LATENT_EXPRESSION):" nil 0)
    ("calc(latent_expression):" "calc(LATENT_EXPRESSION):" nil 0)
    ("`li"   ":locate_input("       nil 0)
    ("`ln"   ":locate_node("        nil 0)
    ("`lo"   ":locate_output("      nil 0)
    ("`lp"   ":load_path("          nil 0)
    ("`lt"   "load_table() : tabledef() passed(string: f) file(f) suffix('');" nil 0)
    ("`main" "expose (MAIN):" nil 0)
    ("`mp"   "max_planes("         nil 0)
    ("`ms"   "max_spaces("         nil 0)
    ("`mtf"  ":map_tech_family("    nil 0)
    ("`nd"   "num_dimensions("     nil 0)
    ("`ne"   "num_elements("       nil 0)
    ("`np"   ":new_plane("          nil 0)
    ("`pa"   "passed("              nil 0)
    ("`pc"   ":plane_coordinate("   nil 0)
    ("`pv"   ":print_value("        nil 0)
    ("`rc"   "record_count("       nil 0)
    ("`rn"   ":rule_name("          nil 0)
    ("`sc"   ":space_coordinate("   nil 0)
    ("`sl"   ":struct_lock("        nil 0)
    ("`slc"  ":struct_lock_count("  nil 0)
    ("`st"   "step_table("         nil 0)
    ("`stc"  "STEP_TABLE_CURRENT"  nil 0)
    ("`stf"  "STEP_TABLE_FORWARDS"  nil 0)
    ("`sts"  "STEP_TABLE_START"     nil 0)
    ("`stl"  ":struct_trylock("     nil 0)
    ("`stt"  ":subrule_tech_type("  nil 0)
    ("`su"   ":struct_unlock("      nil 0)
    ("`swtt" ":switch_tech_type("   nil 0)
    ("`te"   "calc(TERMINATE_EXPRESSION):" nil 0)
    ("`tx"   "calc(TERMINATE_EXPRESSION):" nil 0)
    ("calc(terminate_expression):" "calc(TERMINATE_EXPRESSION):" nil 0)
    ("`tf"   "tech_family("         nil 0)
    ("`tfm"  "tech_family(APP) MAIN;" nil 0)
    ("`tfn"  ":tech_family_name("   nil 0)
    ("`tfp"  ":tech_family_present(" nil 0)
    ("`ut"   "unload_table() : tabledef() passed(string: f) file(f) suffix('')"       nil 0)
    ("`wt"   "write_table() : tabledef() passed(string: f) file(f) suffix('')"        nil 0)
    ("`fprintf(" ":$fprintf(" nil 0)
    ("`fprintf(" ":$fprintf($stderr" nil 0)
    ("`==="  "// ========================================\n// \n// ========================================" ((forward-line -1) (end-of-line)) 0)
  )
)

;;;
;;;
;;;
(defun dcl-mode ()
  "Major mode for editing DCL code.
Variables controlling indentation style:
 dcl-tab-always-indent
    Non-nil means TAB in DCL mode should always reindent the current line,
    regardless of where in the line point is when the TAB command is used.
 dcl-auto-newline
    Non-nil means automatically newline before and after braces,
    and after colons and semicolons, inserted in DCL code.
 dcl-basic-indent-level
    Indentation of DCL statements within surrounding block.
    The surrounding block's indentation is the indentation
    of the line on which the open-brace appears.
 dcl-continued-statement-offset
    Extra indentation given to a substatement, such as the
    then-clause of an if or body of a while.
 dcl-continued-brace-offset
    Extra indentation given to a brace that starts a substatement.
    This is in addition to dcl-continued-statement-offset.
 dcl-brace-offset
    Extra indentation for line if it starts with an open brace.
 dcl-brace-imaginary-offset
    An open brace following other text is treated as if it were
    this far to the right of the start of its line.
 dcl-argdecl-indent
    Indentation level of declarations of DCL function arguments.


Turning on DCL mode calls the value of the variable c-mode-hook with no args,
if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
;  (use-local-map c++-mode-map)
  (setq major-mode 'dcl-mode)
  (setq mode-name "DCL")

  (make-local-variable 'require-final-newline)
  (make-local-variable 'parse-sexp-ignore-comments)
  (make-local-variable 'indent-line-function)
  (make-local-variable 'indent-region-function)
  (make-local-variable 'outline-regexp)
  (make-local-variable 'outline-level)
  (make-local-variable 'normal-auto-fill-function)
  (make-local-variable 'comment-start)
  (make-local-variable 'comment-end)
  (make-local-variable 'comment-column)
  (make-local-variable 'comment-start-skip)
  (make-local-variable 'comment-multi-line)
  (make-local-variable 'paragraph-start)
  (make-local-variable 'paragraph-separate)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (make-local-variable 'adaptive-fill-mode)
  (make-local-variable 'adaptive-fill-regexp)
  ;; now set their values
  (setq require-final-newline t
	parse-sexp-ignore-comments t
	indent-line-function 'dcl-indent-line
	indent-region-function 'dcl-indent-region
	outline-regexp "[^#\n\^M]"
	comment-column 32
	comment-start-skip "/\\*+ *\\|//+ *"
	comment-multi-line t)

  ;; setup the comment indent variable in a Emacs version portable way
  ;; ignore any byte compiler warnings you might get here
  (make-local-variable 'comment-indent-function)
  (setq comment-indent-function 'dcl-comment-indent)
  ;; add menus to menubar
;  (easy-menu-add (dcl-mode-menu mode-name))

  (setq local-abbrev-table dcl-mode-abbrev-table)
  (set-syntax-table dcl-mode-syntax-table)
  (abbrev-mode t)
  (make-local-variable 'fill-paragraph-function)
  (setq fill-paragraph-function 'dcl-fill-paragraph)
  (setq comment-start "/* ")
  (setq comment-end " */")
;  (make-local-variable 'imenu-generic-expression)
;  (setq imenu-generic-expression c-imenu-generic-expression)
  (setq indent-tabs-mode nil)
  (setq default-abbrev-mode t)
  (use-local-map dcl-mode-map)
  (run-hooks 'dcl-mode-hook)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; CVS LOG:
;;
;; $Log: dcl-mode.el,v $
;; Revision 1.1.1.1  2009-12-17 14:19:36  gates
;; elisp files
;;
;; Revision 1.11  2008/08/20 14:25:19  gates
;; Added try/catch and fixed a couple of highlights
;;
;; Revision 1.10  2006/09/13 20:24:54  beatty
;;
;; Corrected the electric colon and semicolon so that when you type a colon or semicolon it indents the line and places the cursor just after the colon or semicolon. I also added to the regular expressions for keywords such that they require that the keyword be a word and not a part of a word. This eliminates the incorrect indention of words starting with a dcl keyword.
;;
;; Revision 1.9  2006/06/01 17:29:49  gates
;; added latent_expression and terminate_expression abbrevs
;;
;; Revision 1.8  2006/04/20 11:16:03  gates
;; added some abbrevs
;;
;; Revision 1.7  2005/01/25 21:06:05  gates
;; added revision version
;;
;; Revision 1.6  2005/01/25 21:04:16  gates
;; fixed missing argument when loading abbreviation mode
;;
;;
;;
;; 0.7.3 Fixed the abbreviations for emacs
;; 0.7.2 Changed the max-specpdl-size to 2000 (1000000 was way too large)
;; 0.7.1 Fixed a problem with the regexp-opt function on emacs. To fix it, I increased the max-specpdl-size.
;; 0.7   Fixed the newline-and-indent and the dcl-indent-line commands (wasn't moving cursor to end-of-line)
;; 0.6.9 Changed the underscore syntax class to be symbol and word to correct the font highlighting
;; 0.6.8 End of line comments no longer need "*/" characters
;; 0.6.7 Prevented the electric functions from indenting while inside a comment
;; 0.6.6 Fixed some electric insertion bugs added in 0.6.5
;; 0.6.5 Fixed the indentation of closing braces and closing parens
;; 0.6.4 Added electric brace fcns and fixed insertion of semis in the middle of a line
;; 0.6.3 Modified dcl-get-version to print in the minibuffer (aka, the echo area)
;; 0.6.2 Added a function to delete the trailing whitespace on a line
;; 0.6.1 Fixed inserting a colon into the middle of a string
;; 0.6   Added comment keys
;; 0.5   Initial release
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
