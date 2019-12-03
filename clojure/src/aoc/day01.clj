(ns aoc.day01
  (:require
   [clojure.java.io :as io]
   ))

(def input (map #(Integer/parseInt %) (->> "day01.txt" io/resource io/reader line-seq)))

(defn calc-fuel [mass]
  (-> mass (quot 3) (- 2)))
  ;; Could be written as (- (quot 3 mass) 2)

(defn part-one []
  (reduce + (map calc-fuel input)))

(defn part-two []
  (reduce + (map
             (fn [mass] (->> mass (iterate calc-fuel) (take-while (partial <= 0)) rest (reduce +)))
             input)))


;; Old, recursive solution.
;; (defn calc-fuel [mass]
;;   (def req-fuel (- (quot mass 3) 2))
;;   (if (< req-fuel 0)
;;     0
;;     (+ req-fuel (calc-fuel req-fuel))))
