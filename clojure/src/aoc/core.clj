(ns aoc.core
  (:require
   [clojure.java.io :as io]
   [aoc.day01 :as day01]
  (:gen-class)))

(defn -main
  [& args]
  (println(case (first args)
    "day01" [(day01/part-one) (day01/part-two)]
    "default" "unknown arg"
  )))
