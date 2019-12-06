(ns aoc.day03
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]
   [aoc.util :as util]))

;; Returns an ordered pair the move
;; R23 -> {x: 23 y: 0}
(defn parse-step [move]
  (let [direction (subs move 0 1)
        amount (Integer/parseInt (subs move 1))]
    (case direction
      "R" {:x amount :y 0}
      "U" {:x 0 :y amount}
      "L" {:x (- amount) :y 0}
      "D" {:x 0 :y (- amount)})))

(defn flip-axis [axis] (if (= axis :x) :y :x))
(def input
  (-> "day03.txt" io/resource io/reader line-seq))

(defn parse-line [line]
  (map parse-step (str/split line #",")))

;; Adds a segement to the path, updates cursor position.
;; Return new 'path', which is a cursor and list of segments
;; path => {:cursor {:x 0 :y 0} :segments []}
(defn add-segment-to-path [path move]
  (let [cursor (path :cursor {:x 0 :y 0})
        segments (path :segments [])
        end {:x (+ (cursor :x) (move :x))
             :y (+ (cursor :y) (move :y))
            }]
    (assoc path
            :cursor end
            :segments (conj segments [cursor end]))))

;; Takes in the grid and a segment, adds to grid.
;; Grid is represented by the all the ranges [a_i - a_j] for a given b
;; For example, the lines [(1, 3), (3,3)], [(0,0) (0, 3)], [(6, 3), (8, 3)]
;; is represnted as
;; {:y {3 [[1 3] [6-8]]}
;;  :x {0 [[0 3]]
;; }
;; orders will be sorted.
;; segment => [{x: ? y : ? } {x: ? y ?}]
(defn build-grid [grid segment]
  (let [axis (if (= ((segment 0) :x) ((segment 1) :x)) :x :y)
        axis-val (->> grid axis ((segment 1) axis))
        runs (-> grid (get axis) (get axis-val []));get the correct list of run-ranges from grid
        run-range (util/sort-vec [((segment 0) (flip-axis axis)) ((segment 1) (flip-axis axis))])] 
    (assoc grid axis
           (assoc (grid axis) axis-val
                  (conj runs run-range)))))

(def paths (->> input
                (map parse-line)
                (map #(reduce add-segment-to-path {} %1))))

(def first-path  ((first paths) :segments))
(def second-path ((first (next paths)) :segments))

;; Now we have mapped the first wire to the gird. Next
;; step is to take the second wire, and compare it with the grid.
;; We'll reduce to 
(def grid (reduce build-grid {} first-path))

(defn intersect? [value segment]
  (and (< (segment 0) value) (< value (segment 1))))

(defn grid-searcher [grid]
  (fn [intersections segment]
     (let [axis (if (= ((segment 0) :x) ((segment 1) :x)) :x :y)
           axis-val (->> grid axis ((segment 0) axis))
           runs (-> grid (get axis) (get axis-val []));get the correct list of ranges from grid
           run-range (util/sort-vec [((segment 0) (flip-axis axis)) ((segment 1) (flip-axis axis))])]
       (into intersections
              (for [tick (range (run-range 0) (inc (run-range 1)))
                    :let [cross-ticks ((grid (flip-axis axis)) tick)]
                    :when (seq (filter (partial intersect? axis-val) cross-ticks))]
                {axis axis-val (flip-axis axis) tick})))))

(def intersections (reduce (grid-searcher grid) [] second-path))

(->> intersections
     (map (partial util/manhattan-2d {:x 0 :y 0}))
     (sort)
     (first))


;;;; part two
;; seg looks like [{:x ? :y ?} {:x? :y ?}]
(defn generate-points-from-segment [segment]
  (for [x (range (:x (segment 0)) (:x (segment 1)) (if (< (:x (segment 0)) (:x (segment 1))) 1 -1))
        y (range (:y (segment 0)) (:y (segment 1)) (if (< (:y (segment 0)) (:y (segment 1))) 1 -1))]
    {:x x :y y}))


