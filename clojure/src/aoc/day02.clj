(ns aoc.day02
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]))

(def input
  (->>
   (-> "day02.txt" io/resource slurp str/trim (str/split #","))
   (map #(Integer/parseInt %))
   (into [])))

(def ops {1 + 2 * 99 "stop"})

(defn process-chunk [tape position]
  (let [chunk (subvec tape position (+ position 4))]
    (if (= 99 (chunk 0))
      tape
      (process-chunk
       (assoc tape
              (chunk 3)
              ((ops (chunk 0)) (tape (chunk 1)) (tape (chunk 2)))) (+ position 4))
      )))

