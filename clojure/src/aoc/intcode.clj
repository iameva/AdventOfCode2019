(ns aoc.int-code)

(def instructions
  { ;; opcode adden adder dest
   1 {:func     + 
      :size     4
      :args     [0 1]
      :dest     2
      :adv-args []
      :adv-func (partial + 4)
      :name     "add"}
   ;; opcode mutiplicand multiplier dest
   2  {:func     *
       :size     4
       :args     [0 1]
       :dest     2
       :adv-args []
       :adv-func (partial + 4)
       :name     "multi"}
   ;; opcode src
   4  {:func     println
       :size     2
       :args     [0]
       :adv-args []
       :adv-func (partial + 2)
       :name     "output"}
   ;; opcode dest
   3  {:func     (fn[](Integer/parseInt (read-line)))
       :size     2
       :dest     0
       :adv-args []
       :adv-func (partial + 2)
       :name     "input"}
   ;;jump-if-true
   5  {:func     (fn [] ())
       :size     3
       :args     []
       :adv-args [0 1]
       :adv-func (fn[ctr a b] (if (not= 0 a) b (+ ctr 3)))
       :name     "jump-if-true"}
   ;; jump if false
   6  {:name     "jump-if-false"
       :func     (fn [] ())
       :size     3
       :args     []
       :adv-args [0 1]
       :adv-func (fn[ctr a b] (if (= 0 a) b (+ ctr 3)))}
   ;; less than
   7  {:name     "less than"
       :func     (fn [a b] (if (< a b) 1 0))
       :size     4
       :dest     2
       :args     [0 1]
       :adv-args []
       :adv-func (partial + 4)}
   ;; equals
   8  {:name     "equals"
       :func     (fn[a b] (if (= a b) 1 0))
       :size     4
       :dest     2
       :args     [0 1]
       :adv-args []
       :adv-func (partial + 4)}
   99 "stop"
   })

(def is-pos? (partial = 0))
(def is-immediate? (partial = 1))

;; Mod the opcode by 100, and the instruction from the instructions map
(defn decode-instruction [memory prgm-counter]
  (instructions (mod (memory prgm-counter) 100)))

;; returns the mode from the opcode as an array. [1st 2nd 3rd]
(defn decode-modes [memory prgm-counter]
  (let [mode-params (quot (memory prgm-counter) 100)]
    [(mod mode-params 10)
     (-> mode-params (quot 10) (mod  10))
     (-> mode-params (quot 10) (quot 10) (mod 10))
     ]))

(defn decode-args [memory prgm-counter argc]
  (subvec memory (inc prgm-counter) (+ prgm-counter argc)))


(defn evaluate-param [memory, arg-with-mode]
  (if (is-pos? (arg-with-mode 0))
    (memory (arg-with-mode 1)) ;; evaluate at the position
    (arg-with-mode 1) ;; is immediate, return evaluation
    ))

;; returns the values used in the instructions functions
(defn evaluate-params [memory, args, modes]
  (into [] (map (partial evaluate-param memory) (map vector modes args))))

;; Execute instruction function against resolved parameters
#dbg(defn execute-instruction [memory instr args modes]
  (let [params (evaluate-params memory args modes)]
    (if (contains? instr :dest)
      (assoc memory (args (instr :dest))
             (apply (instr :func) (map params (instr :args))))
      (do
        (apply (instr :func) (map params (instr :args))) ;; output 
        memory))))
;;
#dbg(defn advance-pointer [memory instr args modes pgrm-counter]
  (let [params (evaluate-params memory args modes)]
    (apply (instr :adv-func) (concat [pgrm-counter] (map params (instr :adv-args))))))
  

(defn run [memory prgm-counter]
  (loop [memory memory
         prgm-counter prgm-counter]
    (if  (= "stop" (decode-instruction memory prgm-counter))
      memory
      (let [instr (decode-instruction memory prgm-counter)
            args  (decode-args memory prgm-counter (instr :size))
            modes (decode-modes memory prgm-counter)]
        (do
         (recur (execute-instruction memory instr args modes)
               (advance-pointer memory instr args modes prgm-counter)))))))

