(ns aoc.day17
  (:require
   [clojure.string :as cljstr]
   [aoc.util :as util]
   [aoc.intcode :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]
   [aoc.ascii :as ascii]))


(defn print-output [out]
  (go-loop [rune (<!! out)]
    (if (nil? rune)
      nil
      (do
        (print (char rune))
        (recur (<!! out))))))

(defn build-scaffold [out]
  (go-loop [rune (<!! out)
            scaffold #{}
            cursor {:x 0 :y 0}]
    (if (nil? rune)
      scaffold
      (recur
       (<!! out)
       (if (= (char rune) \#)
         (conj scaffold cursor)
         scaffold)
       (if (= rune 10)
         (-> cursor
             (assoc :x 0)
             (update :y inc))
         (update cursor :x inc))))))

(defn run-ascii []
  (let [in (chan 256)
        out (chan 256)
        ascii-comp (ic/make-int-computer in out)
        printer (print-output out)]
    (do
      (<!! (ascii-comp (ic/read-program "day17.txt")))
      (async/close! out))))

(defn calibrate [scaffold]
  (defn is-intersection [pair]
    (and
     (contains? scaffold (update pair :y inc))
     (contains? scaffold (update pair :y dec))
     (contains? scaffold (update pair :x inc))
     (contains? scaffold (update pair :x dec))))
  (reduce + (map #(* (%1 :x) (%1 :y)) (filter is-intersection scaffold))))

(defn part-one []
  (let [in (chan 256)
        out (chan 256)
        ascii-comp (ic/make-int-computer in out)
        scaffold (build-scaffold out)]
    (calibrate (do
                 (<!! (ascii-comp (ic/read-program "day17.txt")))
                 (async/close! out)
                 (<!! scaffold)))))

(defn part-two []
  (let [program (assoc (ic/read-program "day17.txt") 0 2)]
    (ascii/run-ascii program)))
