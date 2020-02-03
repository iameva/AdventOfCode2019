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

(defn bound-to-zero [num]
  (if (< num 0)
    0
    num))

(defn calc-ore [chemical amount inventory graph]
  (cond
    (= "ORE" chemical) amount
    :else (let [available (get @inventory chemical 0)
                needed (- amount available)
                ingredients (:components (get graph chemical))
                ratio (+ (quot (- needed 1) ((get graph chemical) :produces)) 1)
                produced (* ratio ((get graph chemical) :produces))]
            (cond
              (> needed 0) (reduce + (map (fn[[chem requirement]]
                                            (swap! inventory assoc chemical (+ available (- produced amount)))
                                            (calc-ore chem 
                                                      (* ratio requirement)
                                                      inventory ;; store excess
                                                      graph)) ingredients))
              :else (do
                     (swap! inventory assoc chemical (- available amount))
                     0)
    ))))

(defn part-one [filename]
  (->>
   (build-graph filename)
   (calc-ore "FUEL" 1 (atom {}))
   ))


(def trillion 1000000000000)

(defn binary-search [lo hi graph]
  (let [mid (-> (- hi lo) (quot 2) (+ lo))
        ore (calc-ore "FUEL" mid (atom {}) graph)](cond
    (>= lo hi) lo
    (< ore trillion) (binary-search (+ mid 1) hi graph)
    (> ore trillion) (binary-search lo (- mid 1) graph)
    (= ore trillion) mid
    )))

(defn part-two [filename]
  (let [graph (build-graph filename)
        lo-bound (quot trillion (calc-ore "FUEL" 1 (atom {}) graph))
        hi-bound (* lo-bound 2)]
    (binary-search lo-bound hi-bound graph)))
