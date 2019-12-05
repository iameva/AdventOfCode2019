(ns aoc.util)

;; Takes a map of {x -> number y-:> number}
;; returns manhattan distance
(defn manhattan-2d [p1 p2]
  (+ (Math/abs (- (p1 :x) (p2 :x))) (Math/abs (- (p1 :y) (p2 :y)))))

(def sort-vec (comp (partial into []) sort))
