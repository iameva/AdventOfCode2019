(ns aoc.day10
  (:require
   [aoc.util :as util]))

(defn is-asteroid? [pt]
  (= pt \#))

(def right-angle (/ Math/PI 2))

(defn parse-asteroids [filename]
  (set (flatten (map-indexed (fn [row, line]
               (keep identity (map-indexed (fn[col, hash-or-dot]
                                             (if (is-asteroid? hash-or-dot)
                                               (util/make-point col row))) line))) (util/read-lines filename)))))

(defn calc-slope [station asteroid]
  (if (= (- (:x station) (:x asteroid)) 0)
    "vert"
    (/ (- (:y station) (:y asteroid))
       (- (:x station) (:x asteroid)))))

(defn get-direction [station asteroid]
  (cond
    (< (:x station) (:x asteroid)) "-"
    (= (:x station) (:x asteroid)) (if (<= (:y station) (:y asteroid)) "" "-")
    :else "+"))

(defn get-seen [station asteroid]
  (str (get-direction station asteroid) (calc-slope station asteroid)))


(defn line-of-sight [station seen asteroid]
  "station - co-ordinates for the current proposed station.
   seen - set of possible seen asterois from proposed station
   asteroid - an asteroid to test if the station has line of sight"
  (if (= station asteroid)
    seen
    (conj seen (get-seen station asteroid))))

(defn spot-asteroids [asteroids asteroid]
  (reduce (partial line-of-sight asteroid) #{} asteroids))

(defn part-one [asteroids]
  (->> asteroids
       (map (partial spot-asteroids asteroids))
       (map count)
       (interleave asteroids)
       (apply hash-map)
       (sort-by second)
       reverse
       first))

;; part one result is {:x 26 :y 29}
;; part two.

(defn calc-angle [asteroid]
  (if (= (asteroid :x) 0)
    (if (> (asteroid :y) 0)
      0
      (Math/PI))
    (Math/atan (/ (asteroid :y) (asteroid :x)))))

(defn get-quadrant [asteroid]
  "Returns the quadrant the point is in on a cartesian coordinate plane.
   Starts in the upper left, then rotates clockwise. Vertial lines are not in a quadrant,
   horizontal lines are in 1 and 4."
  (cond
    (and (> (asteroid :x) 0) (>= (asteroid :y) 0)) 1
    (and (> (asteroid :x) 0) (< (asteroid :y) 0)) 2
    (and (< (asteroid :x) 0) (<  (asteroid :y) 0)) 3
    (and (< (asteroid :x) 0) (>=  (asteroid :y) 0)) 4
    :else 0
    ))


(defn adjust-origin-as-station [station asteroid]
  "Remaps asteroid coordinates relative to the station.
   If station is at (1, 1), and asteroid is at (1, 5) the outputed value
   is (0, -4)"
  {:x (- (asteroid :x) (station :x))
   :y (- (station :y) (asteroid :y))})

(defn adjust-back [station asteroid]
  {:x (+ (station :x) (asteroid :x))
   :y (- (station :y) (asteroid :y))})

(defn get-vaporize-coordinates [asteroid]
  "Return a map of angle and distance. Angle is calculated as 0 heading 'north', 
   and increases as radians clockwise, until 2 PI. Asteroid at (1, 1) would have 
   a vaporization coordinate of {:angle PI/4 :distance sqrt(2)}. Asteroid at
   (-1, 1) would have a vaporization coodrinate at {:angle 7PI/4 :distance sqrt(2)}"
  (let [base-angle (calc-angle asteroid)
        distance (util/euclid-distance {:x 0 :y 0} asteroid)
        quadrant (get-quadrant asteroid)]
    {:angle (cond
              (= 0 quadrant) base-angle
              (= 1 quadrant) (- right-angle base-angle)
              (= 2 quadrant) (+ right-angle (- base-angle))
              (= 3 quadrant) (+ (- right-angle base-angle) Math/PI)
              (= 4 quadrant) (+ (+ right-angle (- base-angle)) Math/PI))
     :distance distance
     :coord asteroid}))

(defn vaporize-order [left right]
  (if (= 0 (compare (left :distance) (right :distance)))
    (compare (left :angle) (right :angle))
    (compare (left :distance) (right :distance))))

(defn adjust-angle-for-distance [pair]
  "Given a kvp of (angle, [{:angle :distance :coord}, ...]), update the asteroid's angle to
   be a angle + (order of angle * 2PI). This let's me know which two asteroids on the same angle
   gets vaporized first. Effictively, turn all angles into their "
  (map-indexed (fn [idx coord]
                 (assoc coord :angle (+ (coord :angle) (* (* 2 Math/PI) idx)))) (second pair)))

(defn get-vaporize-order [asteroids station]
  (->> asteroids
            (filter #( not(= %1 station)))
            (map (partial adjust-origin-as-station station)) ;; redefine asteroid coords with the station as origin.
            (map get-vaporize-coordinates) ;; transform to {:angle :distance :coord}
            (sort-by :distance) 
            (group-by :angle)   ;; the sort-by and group-by let me know 
            (map adjust-angle-for-distance)
            flatten
            (sort-by :angle)
            (map #(assoc %1 :coord (adjust-back station (%1 :coord))))))

(defn part-two [asteroids station]
  (nth (get-vaporize-order asteroids station) 199))
