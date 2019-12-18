(ns aoc.day07
  (:require
   [aoc.int-code :as ic]
   [aoc.util :as util]
   [clojure.math.combinatorics :as combo]
   [clojure.core.async :as async :refer [chan buffer >!! <!! go]]))

(defn tails [coll] (take-while seq (iterate rest coll)))
(defn inits [coll] (reductions conj [] coll))
(defn rotations [a-seq]
  (rest (map concat (tails a-seq) (inits a-seq))))
(defn permutations [a-set]
  (if (empty? a-set)
    (list ())
    (mapcat
     (fn [[x & xs]] (map #(cons x %) (permutations xs)))
     (rotations a-set))))


(defn create-channels [powers]
  (map (fn[power]
         (do
           (def c (chan (buffer 256)))
           (>!! c power)
           c))
       powers))

;; Creates an instance of an IntCode computer, and returns a go channel
;; that contains the output channel for the computer.
(defn create-async-amplifier [io]
  (let [in-ch (first io)
        out-ch (first (next io))
        intcode (ic/make-int-computer
                 (partial <!! in-ch)
                 (partial >!! out-ch))]
    (fn [memory]
      (go 
        (intcode memory)
        out-ch))))

;; 
(defn create-amp-ring [cs]
  (do
    (>!! (first cs) 0) ;; add initial start to first input channel
    (map
     (fn [io]
       (create-async-amplifier io))
     ;; Below creates a ring of channels
     ;; Given channes C1, C2, ..., C4, C5, it will return
     ;; pairs of adajent channels, with wrap-around.
     ;; => [(C1 C2) (C2 C3) ... (C4 C5) (C5 C1)]
     (concat (partition 2 1 cs) [(seq [(last cs) (first cs)])]))))

(defn amp-output-async [program power-seq]
  (->> power-seq
       create-channels
       create-amp-ring
       (map #(%1 program))
       doall
       (map <!!)
       last
       <!!))

(defn part-one [memory]
  (apply max (->> (range 5)
                  (combo/permutations)
                  (map (partial amp-output-async memory)))))

(defn part-two [memory]
  (apply max (->> (range 5 10)
                  (combo/permutations)
                  (map (partial amp-output-async memory)))))
