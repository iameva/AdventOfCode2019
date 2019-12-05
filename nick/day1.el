(load-file "utils.el")

(defun process(mass)
  "Do AoC process on MASS."
  (let ((mn (if (numberp mass)
                mass
              (string-to-number mass))))
    (- (/ mn 3) 2)))


(defun process-with-fuel(mass so-far)
  "Process required fuel for MASS. SO-FAR is previous amounts."
  (let ((fuel (process mass)))
    (if (<= fuel 0)
        so-far
      (let ((next (cons fuel so-far)))
        (process-with-fuel fuel next)))))

(defun full-fuel(mass)
  "Get the full amount of fuel required for MASS including fuel fuel."
  (apply '+ (process-with-fuel mass '())))


;; solution part 1
(let ((lines (read-lines "day1input")))
  (apply '+ (mapcar 'process lines)))

;; solution part 2
(let ((lines (read-lines "day1input")))
  (apply '+ (mapcar 'full-fuel lines)))
