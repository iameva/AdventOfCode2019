(defun read-lines (file)
  "Get list of lines in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (split-string (buffer-string) "\n" t)))


(defun read-csv (file)
  "Get list of values separated by ',' in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (split-string (buffer-string) "," t)))
