(ns aoc.day08
  (:require
   [aoc.util :as util]))

(defn count-zeros [pix-data]
  (count (filter (partial = 0) pix-data)))
  

(def part-one-layer
  (->> (map util/char-to-int (util/input-as-string "day08.txt"))
       (partition (* 25 6))
       (sort-by count-zeros)
       (first)))

;;part one solution
(* (count (filter (partial = 1) part-one-layer))
   (count (filter (partial = 2) part-one-layer)))


(def part-one-layer
  (->> (map util/char-to-int (util/input-as-string "day08.txt"))
       (partition (* 25 6))
       (sort-by count-zeros)
       (first)))

;; part two
(defn fill-frame [size frame layer]
  (into []
        (for [i (range size)]
          (if (= 2 (layer i))
            (frame i)
            (layer i)))))

(def part-two-frame
  (->> (map util/char-to-int (util/input-as-string "day08.txt"))
       (partition (* 25 6))
       (map #(into [] %1))
       reverse
       (reduce (partial fill-frame 150) (into [] (repeat 150 2)))))
