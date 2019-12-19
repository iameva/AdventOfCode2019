(ns aoc.int-code
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]
   [clojure.core.async :as async :refer [>!! <!! go]]))

(def instruction-template
  { ;; opcode adden adder dest
   1 {:name  "add"
      :func  (fn [state args]
               (-> state
                   (update :ram (fn [ram args]
                                  (assoc ram (args 2) (+ (args 0) (args 1)))))
                   args)
               (update :pgm-ctr + 4))
      :size  4}
   2 {:name  "multi"
      :func  (fn [state args]
               (-> state
                   (update :ram (fn [ram args]
                                  (assoc ram (args 2) (apply * (map args [0 1])))))
                   (update :pgm-ctn + 4)))
      :size  4}
   3 {:name  "input"
      :func  (fn [state args]
               (-> state
                   (update :ram (fn [ram args]
                                  (assoc ram (args 0) (<!! (:in state)))))
                   (update :pgm-ctr + 2)))
      :size  2}
   4 {:name  "output"
      :func  (fn[state args]
               (do
                 (>!! (:out state) (state :ram))
                 (update state :pgm-ctr + 2)))
      :size  2}
   5 {:name  "jump-if-true"
      :func  (fn [state args]
               (-> state
                   (update :pgm-ctr (fn[ctr args]
                                      (let [a (first args)
                                            b (last args)]
                                        (if (not= 0 a) b (+ ctr 3))) args))))
      :size  3}
   6 {:name  "jump-if-false"
      :func  (fn [state args]
               (update state
                       :pgm-ctr
                       (fn[ctr args]
                         (let [a (first args)
                               b (last args)]
                           (if (= 0 a) b (+ ctr 3))))
                       args))
      :size  3}
   7 {:name  "less than"
      :func  (fn[state args]
               (-> state
                   (update :ram
                           (fn[ram args]
                             (assoc ram (args 2) (if (< (args 0) (args 1)) 1 0)))
                           args)
                   (update :pgm-ctr + 4)))
      :size  4}
   8 {:name  "equals"
      :func  (fn[state args]
               (-> state
                   (update :ram
                           (fn[ram args]
                             (assoc ram (args 2) (if (= (args 0) (args 1)) 1 0)))
                           args)
                   (update :pgm-ctr + 4)))
      :size  4}
   9 {:name  "base adjust"
      :func  (fn[state args]
               (-> state
                   (update :rel-offest
                           (fn[offset args] (+ offset (args 0)))
                           args)
                   (update :pgm-ctr + 2)))
      :size  2}
   99 "stop"
   })

(defn read-program [filename]
  (->>
   (-> filename io/resource slurp str/trim (str/split #","))
   (map #(Integer/parseInt %))
   (into [])))

(def POSITION 0)
(def IMMEDIATE 1)
(def RELATIVE 2)

;; Mod the opcode by 100, and the instruction from the instructions map
(defn decode-instruction [state instructions]
  (instructions (mod ((:ram state) (:pgm-ctr state)) 100)))

;; returns the mode from the opcode as an array. [1st 2nd 3rd]
(defn decode-modes [state]
  (let [mode-params (quot ((:ram state) (:pgm-ctr state)) 100)]
    [(mod mode-params 10)
     (-> mode-params (quot 10) (mod  10))
     (-> mode-params (quot 10) (quot 10) (mod 10))
     ]))

#dbg(defn decode-args [state size]
  (subvec (:ram state) (inc (:pgm-ctr state)) (+ (:pgm-ctr state) size)))

#dbg(defn evaluate-param [state arg-with-mode]
  (let [memory (state :ram)]
    (case (arg-with-mode 0)
      0  (memory (arg-with-mode 1)) ;; POSITION
      1 (arg-with-mode 1)           ;; IMMEDIATE
      2  (memory (+ (arg-with-mode 1) (state :rel-offest)))))) ;; RELATIVE

;; returns the values used in the instructions functions
#dbg(defn evaluate-params [state, args, modes]
  (into [] (map (partial evaluate-param state) (map vector modes args))))

;; Execute instruction function against resolved parameters
#dbg(defn execute-instruction [state instr params]
      (let [operation (:func instr)]
        (operation state params)))

(defn run [state instructions]
  (loop [state state]
    (if  (= "stop" (decode-instruction state instructions))
      state
      (let [instr (decode-instruction state instructions)
            args  (decode-args state (instr :size))
            modes (decode-modes state)]
        (recur (execute-instruction state instr (evaluate-params state args modes)))))))

(defn make-int-computer [input-channel output-channel]
  (fn [memory]
    (go
      (run
        {:ram (into [] (concat memory (repeat 1024 0)))
         :pgm-ctr 0
         :rel-offset 0
         :in input-channel
         :out output-channel}
        instruction-template))))
