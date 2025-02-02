;;; org-tagged.el --- Dynamic block for tagged org-mode todos -*- lexical-binding: t -*-
;; Copyright (C) 2022 Christian Köstlin

;; This file is NOT part of GNU Emacs.

;; Author: Christian Köstlin <christian.koestlin@gmail.com>
;; Keywords: org-mode, org, gtd, tools
;; Package-Requires: ((s) (dash "2.17.0") (emacs "24.4") (org "9.1"))
;; Package-Version: 0.0.1
;; Homepage: http://github.com/gizmomogwai/org-tagged

;;; Commentary:
;; To create a tagged table for an org file, simply put the dynamic block
;; `
;; #+BEGIN: tagged :tags "tag1|tag2" :match "kanban"
;; #+END:
;; '
;; somewhere and run `C-c C-c' on it.

;;; Code:
(require 's)
(require 'dash)
(require 'org)
(require 'org-table)

(defun org-tagged--get-data-from-heading ()
  "Extract the needed information from a heading.
Return a list with
- the heading
- the tags as list of strings."
  (list
    (nth 4 (org-heading-components))
    (remove "" (s-split ":" (nth 5 (org-heading-components))))))

(defun org-tagged--row-for (heading item-tags tags)
  "Create a row for a HEADING and its ITEM-TAGS for a table with TAGS."
  (format "|%s|" (s-join "|" (-map (lambda (tag)
                      (if (-elem-index tag item-tags) heading "")) tags))))

(defun org-tagged-version ()
  "Print org-tagge version."
  (interactive)
  (message "org-tagged 0.0.1"))

;;;###autoload
(defun org-dblock-write:tagged (params)
  "Create a tagged dynamic block.
PARAMS must contain: `:tags`."
  (insert
    (let*
      (
        (tags (s-split "|" (plist-get params :tags)))
        (table-title (plist-get params :tags))
        (todos (org-map-entries 'org-tagged--get-data-form-heading (plist-get params :match)))
        (row-for (lambda (todo) (org-tagged--row-for (nth 0 todo) (nth 1 todo) tags)))
        (table (s-join "\n" (-map row-for todos))))
      (format "|%s|\n|--|\n%s" table-title table)))
  (org-table-align))
(provide 'org-tagged)
;;; org-tagged.el ends here

