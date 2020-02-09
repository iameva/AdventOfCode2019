(ns aoc.day15
  (:require
   [aoc.util :as util]
   [aoc.intcode :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))

(def directions [{:x 0 :y 0} ;; empty 
                 {:x 0 :y 1} ;; north
                 {:x 0 :y -1} ;; south
                 {:x -1 :y 0} ;; west
                 {:x 1 :y 0}]) ;; east

(def reverse-directions
  {0 0
   1 2
   2 1
   3 4
   4 3})

(def default-maze 
  { :cursor {:x 0 :y 0}
   :walls #{}
   :paths #{}
   })

(defn has-visited? [maze point]
;;  (println (count (maze :walls)) (count (maze :paths)))
  (or (contains? (maze :walls) point)
      (contains? (maze :paths) point)))

(defn query-for-tile [in out direction]
  "Submits a direction to the int-code computer. This might update the internal player
   depending on what tile is returned."
  (if (> direction 0)
    (do
      (>!! in direction)
      (<!! out))
    0))

(defn possible-unexplored-directions [maze location]
  "Returns a sequence of 1..4, depending on unexplored criteria: we haven't seen
   a wall in that direction, nor have we already visited that path."
  (remove nil? (map-indexed
   #(if %2 (inc %1) nil)
   (map
    ;; advance the cursor -> check if we've visited -> negate
    (comp not (partial has-visited? maze) (partial util/advance-cursor location))
    (rest directions)))))

(defn explore-dfs [maze in out came-from-direction]
  (defn check-direction [m direction]
;;        (println "Checking:" (util/advance-cursor (m :cursor) (directions direction)))
    (let [tile (query-for-tile in out direction)
          location (util/advance-cursor (m :cursor) (directions direction))]
;;      (println "Tile:" tile "at" location)
      (cond
        (= tile 1) (explore-dfs m in out direction)
        (= tile 0) (update m :walls conj location)
        (= tile 2) (-> m
                       (assoc :o2 location)
                       (update :paths conj location)
                       (explore-dfs in out direction)))))
  "The caller enters this funciton with the droid already advanced in the int-code computer,
   but the maze out of date.
   1) Update maze's cursor to the current position, add cursor to paths
   2) Generate valid paths to continue exploring
   3) Explore those paths
   4) Return to the callers cursor position."
;;  (println (maze :cursor))
  (let [location (util/advance-cursor (maze :cursor) (directions came-from-direction))
        next-steps (possible-unexplored-directions maze location)
        maze (-> maze
                 (assoc :cursor location) ;; move cursor to 'this' location
                 (update :paths conj location)
                 ((fn [m] (reduce check-direction m next-steps)));; recursion happens here
                 (assoc :cursor (maze :cursor)))] ;; reset cursor to "from" 
    (query-for-tile in out (reverse-directions came-from-direction))
    maze))

(defn next-to-visit [paths visited location]
  (->> (rest directions)
       (map (partial util/advance-cursor location))
       (filter (fn [x]
                 (and (contains? paths x)
                      (not (contains? visited x)))))))

(defn build-visited [maze]
  (loop [visited {{:x 0 :y 0} nil}
         q (conj clojure.lang.PersistentQueue/EMPTY {:x 0 :y 0})]
    (let [children (next-to-visit (maze :paths) visited (peek q))]
      (if (seq q)
        (recur (if (seq children)
                 (apply assoc visited (interleave children (repeat (peek q))))
                 visited)
               (into (pop q) children))
        visited))))

(defn find-shortest-path [visited start end]
  (loop [path '()
         step end]
    (if (nil? step)
      path
      (recur (conj path step) (visited step)))))

(defn part-one []
  (let [in (chan)
        out (chan)
        droider ((ic/make-int-computer in out) (ic/read-program "day15.txt"))
        maze (explore-dfs default-maze in out 0)]
    (-> maze
        build-visited
        (find-shortest-path {:x 0 :y 0} (maze :o2))
        count)))

(defn build-levels [maze]
  (loop [visited {(maze :o2) 0}
         q (conj clojure.lang.PersistentQueue/EMPTY {:loc (maze :o2) :lvl 0})]
    (if (seq q)
      (let [head (peek q)
            children (next-to-visit (maze :paths) visited (head :loc))
            next-lvl (inc (head :lvl))
            _ (println head)]
;;        (println "head:" head)
        (recur (if (seq children)
                 (apply assoc visited (interleave children (repeat next-lvl)))
                 visited)
               (into (pop q) (map (fn [c] {:loc c :lvl  next-lvl}) children))))
      visited)))

(defn part-two []
  (let [in (chan)
        out (chan)
        droider ((ic/make-int-computer in out) (ic/read-program "day15.txt"))
        maze (explore-dfs default-maze in out 0)]
    (->> maze
         build-levels
         (group-by second))))
