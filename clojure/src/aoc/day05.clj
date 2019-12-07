(ns aoc.day05
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]
   [aoc.int-code :as ic]))


(def input
  (->>
   (-> "day05.txt" io/resource slurp str/trim (str/split #","))
   (map #(Integer/parseInt %))
   (into [])))


;;(ic/run [4 0 99 0] 0)
;;(println 234)
;;(ic/run [3 225 1 225 6 6 1100 1 238 225 104 0 1101 37 34 224 101 -71 224 224 4 224 1002 223 8 223 99 0 0 0] 0)
;; part-1
(ic/run input 0)

;;(ic/run [3 9 8 9 10 9 4 9 99 -1 8] 0)
;;(ic/run [3 9 7 9 10 9 4 9 99 -1 8] 0)
;;(ic/run [3 3 1107 -1 8 3 4 3 99] 0)
;;(ic/run [3 21 1008 21 8 20 1005 20 22 107 8 21 20 1006 20 31 1106 0 36 98 0 0 1002 21 125 20 4 20 1105 1 46 104 999 1105 1 46 1101 1000 1 20 4 20 1105 1 46 98 99] 0)
