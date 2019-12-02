(ns aoc.core
  (:require
   [clojure.java.io :as io]
  (:gen-class)))


(def input (map #(Integer/parseInt %) (->> "day01.txt" io/resource io/reader line-seq)))
;;(println (reduce + (map #( - %1 2) (map #( quot %1 3) input))))

(defn calc-fuel [mass]
  (def req-fuel (- (quot mass 3) 2))
  (if (< req-fuel 0)
    0
    (+ req-fuel (calc-fuel req-fuel))))

(println (reduce + (map calc-fuel input)))
