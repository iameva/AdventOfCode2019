(load-file "utils.el")

(defun args (index input)
  "get the input args for opcode at INDEX from INPUT."
  (let ((i1 (nth (nth (+ index 1) input) input))
        (i2 (nth (nth (+ index 2) input) input)))
    (list i1 i2)))

(defun replace-nth (input n new)
  "return a new list where INPUT's element at N is replaced with NEW"
  (cond
   ((null input) ())
   ((= n 0) (cons new (cdr input)))
   (t (cons (car input) (replace-nth (cdr input) (- n 1) new)))))

(defun output (index result input)
  "construct the new ouput for opcode at INDEX. RESULT is the opcode's result, INPUT the orignal input."
  (let ((outpos (nth (+ index 3) input)))
    (replace-nth input outpos result)))

(defun execute (index input)
  "execute the opcode at INDEX in INPUT and return (continue-bool (outlist))."
  (let ((opcode (nth index input)))
    (cond ((= opcode 1)
           (list t
            (output index (apply '+ (args index input)) input)))
          ((= opcode 2)
           (list t
            (output index (apply ' * (args index input)) input) t))
          ((= opcode 99)
           (list nil input)))))

(defun process-at (index input)
  "fully process INPUT. execute starting at INDEX"
  (let ((res (execute index input)))
    (if (car res)
        (process-at (+ index 4) (car (cdr res)))
      (car (cdr res)))))

;; testing
;; (process-at 0 '(1 9 10 3 2 3 11 0 99 30 40 50))
;; (process-at 0 '(1 0 0 0 99))
;; (process-at 0 '(1 1 1 4 99 5 6 0 99))

;; part1
(let ((input (mapcar 'string-to-number (read-csv "day2input"))))
  (process-at 0
              (replace-nth (replace-nth input 1 12) 2 2)))

;; part2 (76 21)
(let ((input (mapcar 'string-to-number (read-csv "day2input"))))
  (progn
    (setq in1 0 in2 0)
    (while (not (eq (car
                (process-at 0
                            (replace-nth (replace-nth input 1 in1) 2 in2)))
               19690720))
      (progn
        (setq in1 (+ in1 1))
        (if (eq in1 99)
            (setq in1 0 in2 (+ in2 1)))
        ))
    (message (format "answer: %d %d" in1 in2)) ) )

