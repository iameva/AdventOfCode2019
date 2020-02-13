(ns aoc.ascii
  (:require
   [aoc.intcode :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))

(defn printer [out]
  (go-loop [rune (<!! out)]
    (if (nil? rune)
      nil
      (do
        (print (char rune))
        (flush)
        (recur (<!! out))))))

(defn reader [in]
  (go-loop [line (read-line)]
    (map (comp (partial <!! in) int) (concat line "\n"))
    (recur (read-line))))

(defn run-ascii [program]
  (let [in  (chan 256)
        out (chan 256)
        comp (ic/make-int-computer in out)
        p (printer out)
        r (reader in)]
    (do
      (<!! (comp program))
      (async/close! out))))
