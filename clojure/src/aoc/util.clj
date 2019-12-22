(ns aoc.util
  (:require
   [clojure.java.io :as io]
   [clojure.core.async :as async :refer [close! <!!]]))

;; Takes a map of {x -> number y-:> number}
;; returns manhattan distance
(defn manhattan-2d [p1 p2]
  (+ (Math/abs (- (p1 :x) (p2 :x))) (Math/abs (- (p1 :y) (p2 :y)))))

(def sort-vec (comp (partial into []) sort))

(defn input-as-string [filename]
  (-> filename io/resource slurp))

(defn char-to-int [character]
  (- (int character) (int \0)))

(defn read-lines [filename]
  (->> filename io/resource io/reader line-seq))

(defn make-point [x y]
  {:x x :y y})


(defn drain-channel [c]
  (do
    (close! c)
    (take-while some? (repeatedly #(<!! c)))))
