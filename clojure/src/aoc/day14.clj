(ns aoc.day14
  (:require
   [aoc.util :as util]
   [clojure.string :as cljstr]))

;; Graph is structured like so.
;; {"ChemName" { :components { "ChemName" amount
;;                             "ChemName" amount
;;                             "ChemName" amount
;;                           }
;;               :produces Number
;;               :name "ChemName" (for debugging)
;;             }
;; }
(defn parse-ingredients [ingredients token]
  (let [[amount name] (cljstr/split token #" ")]
    (assoc ingredients name (Integer/parseInt amount))))

(defn parse-line [graph line]
  (let [[ingredients product] (cljstr/split line #" => ")
        [amount name] (cljstr/split product #" ")]
    (assoc graph
           name {:components (reduce parse-ingredients {} (map first (re-seq #"(\d+ [A-Z]+)" ingredients)))
                 :produces (Integer/parseInt amount)
                 :name name
                 })))

(defn build-graph [filename]
  (reduce parse-line {} (util/read-lines filename)))

(defn calc-ore [chemical available needed graph]
  (let [ingredients (:components (get graph chemical))]
    (cond
      (contains? ingredients "ORE") (* needed (ingredients "ORE")))))

(defn part-one [filename]
  (->>
   (build-graph filename)
   ))

;;(def graph (reduce build-graph {} (util/read-lines "day14/input.txt")))

;;  (map first (re-seq #"(\d+ [A-Z]+)" "2 AB, 3 BC, 4 CA => 1 FUEL")))
