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

;; (->> (range 4)
;;      permutations
;;      (map ) ;; turn permutations into intiailzed initial inputs
;;      () ;; turn groupings of inputs into intcode compter instances
;;      ()) ;; run int-code, output final value
        ;; sort

(defn input [q]
  (.take q))

(defn output [q val]
  (do
    (.put q val)))

(defn config-amplifier [qgroup]
  (ic/make-int-computer
   (partial input (first qgroup))
   (partial output (first (next qgroup)))))

;; (map #(%1 memory) amplifiers)
(defn create-queues [powers]
  (map (fn[power]
         (do
           (def q (new java.util.concurrent.ArrayBlockingQueue 2))
           (.offer q power)
           q))
       powers))

(defn create-amplifier [io]
  (let [in-q (first io)
        out-q (first (next io))
        intcode (ic/make-int-computer
     (partial input in-q)
     (partial output out-q))]
    (fn [memory]
      (do
        (intcode memory)
        (.peek out-q)))))

;; takes in a sequence of queues 
(defn create-amp-chains [qs]
   (let [q-chain (concat qs [(new java.util.concurrent.ArrayBlockingQueue 2)])]
     (do
       (.put (first q-chain) 0)
       (map
        (fn [io]
          (create-amplifier io))
        (partition 2 1 q-chain)))))

(defn amp-output [program power-seq]
  ;; forget the aggregate, just return the last number in the sequence.
  (reduce #(%2 program) 0 (create-amp-chains (create-queues power-seq))))

(defn part-one [memory]
  (max (->> (range 5)
       (combo/permutations)
       (map (partial amp-output memory)))))
 

;;; part two almost entirely different.

(defn create-chans [powers]
  (map (fn[power]
         (do
           (def c (chan (buffer 256)))
           (>!! c power)
           c))
       powers))

(defn input-ch [ch]
  (<!! ch))

(defn output-ch [ch valu]
  (>!! ch val))

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

(defn create-channel-ring [cs]
  (do
    (>!! (first cs) 0)
    (map
     (fn [io]
       (create-async-amplifier io))
     (concat (partition 2 1 cs) [(seq [(last cs) (first cs)])]))))

(defn amp-output-async [program power-seq]
  (->> power-seq
       create-chans
       create-channel-ring
       (map #(%1 program))
       doall
       (map <!!)
       last
       <!!))

  ;; (Map <!! (doall (map
  ;;   #(%1 program)
  ;;   (create-channel-ring (create-chans power-seq))))))

(defn part-two [memory]
  (max (->> (range 5 10)
            (combo/permutations)
            (map (partial amp-output-async memory)))))
