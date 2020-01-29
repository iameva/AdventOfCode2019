(ns aoc.day17
  (:require
   [clojure.string :as cljstr]
   [aoc.util :as util]
   [aoc.intcode :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))


(defn print-output [out]
  (go-loop [rune (<!! out)]
    (if (nil? rune)
      nil
      (do
        (print (char rune))
        (recur (<!! out))))))

(defn consume-output [out]
  (go-loop [rune (<!! out)]
    (if (nil? rune)
      nil
      (do
        (print rune)
        (recur (<!! out))))))

(defn run-ascii []
  (let [in (chan 256)
        out (chan 256)
        ascii-comp (ic/make-int-computer in out)
        printer (print-output out)]
    (do
      (<!! (ascii-comp (ic/read-program "day17.txt")))
      (async/close! out))))
