(ns aoc.ascii
  (:require
   [aoc.intcode :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))

(defn decode-rune [rune]
  (if (<= rune 127) ;; if in ascii range
    (char rune)
    rune))

(defn printer [out]
  (go-loop [rune (<!! out)]
    (if (nil? rune)
      nil
      (do
        (print (decode-rune rune))
        (flush)
        (recur (<!! out))))))

(defn reader [in]
  (go-loop [line (read-line)]
    (if (= line "q")
      nil
      (let [encoded (map int (concat line "\n"))]
        (async/onto-chan in encoded false)
        (recur (read-line))))))

(defn run-ascii [program]
  (let [in  (chan 256)
        out (chan 256)
        comp (ic/make-int-computer in out)
        p (printer out)
        r (reader in)]
    (do
      (<!! (comp program))
      (async/close! out))))
