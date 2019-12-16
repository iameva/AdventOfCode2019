(ns aoc.day10
  (:require
   [aoc.util :as util]))

(defn is-asteroid? [pt]
  (= pt \#))


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
  (if (= station asteroid)
    seen
    (conj seen (get-seen station asteroid))))

#dbg(defn spot-asteroids [asteroids asteroid]
  (reduce (partial line-of-sight asteroid) #{} asteroids))

#dbg(defn part-one [asteroids]
  (->> asteroids
       (map (partial spot-asteroids asteroids))
       (map count)
       sort
       reverse
       first))

