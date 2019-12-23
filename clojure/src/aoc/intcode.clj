(ns aoc.intcode
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]
   [clojure.core.async :as async :refer [>!! <!! go]]))

(defn evaluate-arg [state arg-with-mode]
  (let [memory (state :ram)
        arg (:arg arg-with-mode)
        mode (:mode arg-with-mode)]
    (case mode
      0  (memory arg) ;; POSITION
      1  arg           ;; IMMEDIATE
      2  (memory (+ arg (state :rel-offset))))))

(defn eval-write-to-arg [state arg]
  (if (= (:mode arg) 0)
    (:arg arg)
    (+ (:arg arg ) (state :rel-offset))))

(def instruction-template
  { ;; opcode adden adder dest
   1 {:name  "add"
      :func  (fn [state args]
               (-> state
                   (update :ram (fn [ram args]
                                  (assoc ram (eval-write-to-arg state (args 2))
                                         (apply + (map (partial evaluate-arg state) (map args [0 1])))))
                           args)
                   (update :pgm-ctr + 4)))
      :size  4}
   2 {:name  "multi"
      :func  (fn [state args]
               (-> state
                   (update :ram (fn [ram args]
                                  (assoc ram (eval-write-to-arg state (args 2))
                                         (apply * (map (partial evaluate-arg state) (map args [0 1])))))
                           args)
                   (update :pgm-ctr + 4)))
      :size  4}
   3 {:name  "input"
      :func  (fn [state args]
               (-> state
                   (update :ram (fn [ram args]
                                  (assoc ram (eval-write-to-arg state (args 0)) (<!! (:in state))))
                           args)
                   (update :pgm-ctr + 2)))
      :size  2}
   4 {:name  "output"
      :func  (fn[state args]
               (do
                 (>!! (:out state) (apply (partial evaluate-arg state) args))
                 (update state :pgm-ctr + 2)))
      :size  2}
   5 {:name  "jump-if-true"
      :func  (fn [state args]
               (-> state
                   (update :pgm-ctr (fn[ctr args]
                                      (let [a (evaluate-arg state (first args))
                                            b (evaluate-arg state (last args))]
                                        (if (not= 0 a) b (+ ctr 3))))
                           args)))
      :size  3}
   6 {:name  "jump-if-false"
      :func  (fn [state args]
               (update state
                       :pgm-ctr
                       (fn[ctr args]
                         (let [a (evaluate-arg state (first args))
                               b (evaluate-arg state (last args))]
                           (if (= 0 a) b (+ ctr 3))))
                       args))
      :size  3}
   7 {:name  "less than"
      :func  (fn[state args]
               (-> state
                   (update :ram
                           (fn[ram args]
                             (assoc ram (eval-write-to-arg state (args 2))
                                    (if (< (evaluate-arg state (args 0)) (evaluate-arg state (args 1))) 1 0)))
                           args)
                   (update :pgm-ctr + 4)))
      :size  4}
   8 {:name  "equals"
      :func  (fn[state args]
               (-> state
                   (update :ram
                           (fn[ram args]
                             (assoc ram (eval-write-to-arg state (args 2))
                                    (if (= (evaluate-arg state (args 0)) (evaluate-arg state (args 1))) 1 0)))
                           args)
                   (update :pgm-ctr + 4)))
      :size  4}
   9 {:name  "base adjust"
      :func  (fn[state args]
               (-> state
                   (update :rel-offset
                           (fn[offset args] (+ offset (evaluate-arg state (args 0))))
                           args)
                   (update :pgm-ctr + 2)))
      :size  2}
   99 "stop"
   })

(defn read-program [filename]
  (->>
   (-> filename io/resource slurp str/trim (str/split #","))
   (map #(Long/parseLong %))
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

(defn decode-args [state instr]
  (let [args (subvec (:ram state) (inc (:pgm-ctr state)) (+ (:pgm-ctr state) (:size instr)))
        modes (decode-modes state)]
    (into [] (map (fn[pair] {:mode (pair 0) :arg (pair 1)}) (map vector modes args)))))

(defn run [state instructions]
  (loop [state state]
    (if  (= "stop" (decode-instruction state instructions))
      state
      (let [instr (decode-instruction state instructions)
            args  (decode-args state instr)]
;;        (println "Instr: " (:name instr))
        (recur ((:func instr) state args))))))

(defn init-state [in out program]
  {:ram (into [] (concat program (repeat 1024 0)))
    :pgm-ctr 0
    :rel-offset 0
    :in in
    :out out})

(defn make-int-computer [input-channel output-channel]
  (fn [memory]
    (go
      (run
        (init-state input-channel output-channel memory)
        instruction-template))))
