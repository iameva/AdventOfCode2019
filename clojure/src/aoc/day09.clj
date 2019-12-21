(ns aoc.day09
  (:require
   [aoc.util :as util]
   [aoc.int-code :as ic]
   [clojure.core.async :as async :refer [>!! <!! go chan]]))

(defn part-one []
  (let [in  (chan 256)
        out (chan 256)
        intcode (ic/make-int-computer in out)]
    (do
      (>!! in 1)
      (<!! (:out (<!! (intcode (ic/read-program "day09.txt"))))))))
      

(defn part-two []
  (let [in  (chan 256)
        out (chan 256)
        intcode (ic/make-int-computer in out)]
    (do
      (>!! in 2)
      (<!! (:out (<!! (intcode (ic/read-program "day09.txt"))))))))
