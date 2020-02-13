(ns aoc.day16
  (:require
   [aoc.util :as util]))

(def pattern '(0 1 0 -1))

(defn expand-pattern [repeat-count]
  (->> pattern
       (map (partial repeat repeat-count))
       flatten
       cycle
       (drop 1)))

(defn calc-phase [signal]
  (defn calc-column [col _]
    (rem (->> signal
              (interleave (expand-pattern (inc col)))
              (partition 2)
              (map (partial apply *))
              (reduce +)
              Math/abs) 10))
    
;;    (Math/abs (rem (reduce + (map (partial apply *) (partition 2 (interleave (expand-pattern col) signal)))) 10)))
  (map-indexed calc-column signal))

(defn parse-input [signal] 
  (map util/char-to-int signal))

(defn part-one [raw-signal]
  (let [signal (parse-input raw-signal)]
    (clojure.string/join "" (nth (iterate calc-phase signal) 100))))
