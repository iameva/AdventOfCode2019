(ns aoc.day15
  (:require
   [aoc.util :as util]
   [aoc.intcode :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))

(def directions [_
                 {:x 0 :y 1} ;; north
                 {:x 0 :y -1} ;; south
                 {:x -1 :y 0} ;; west
                 {:x 1 :y -1}]) ;; east

(defn move-cursor [maze direction]
  (let [vector (directions directions)]
    (update maze
            :cursor
            (fn[prev]
              (util/advance-cursor prev vector)))))

(defn update-maze [maze tile direction]
  (let [cursor (:cursor maze)
        map    (:map maze)]
    (cond
      (= tile 0) maze
      (= tile 1) (move-cursor maze direction)
      (= tile 2) (assoc maze :o2 cursor
                        cursor tile)
      )))

(defn choose-direction [maze]
  
  )

(defn stumble-around-maze [in out]
  (loop [maze {}]
    (let [direction (choose-direction maze)
          _ (>!! in direction)
          tile (<!! out)]
      (if (= tile 2)
        maze
        (recur (update-maze maze tile direction))))))



