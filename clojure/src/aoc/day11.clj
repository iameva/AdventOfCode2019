(ns aoc.day11
  (:require
   [aoc.int-code :as ic]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))

;; When you turn right, move right up the list.
;; When you turn left, move left down the list.
(def directions
  [{:x 0 :y 1} {:x 1 :y 0} {:x 0 :y -1} {:x -1 :y 0}])

(defn turn [cursor direction]
  (update cursor
          :direction-idx
          (fn [didx turn]
            (mod (if (= turn 0)
                     (dec didx)
                     (inc didx)) 4))
          direction))

#dbg(defn advance [cursor]
  (let [adv (directions (cursor :direction-idx))
        x (cursor :x)
        y (cursor :y)]
    (assoc cursor
           :x (+ x (adv :x))
           :y (+ y (adv :y)))))

(defn paint-hull [hull cursor color]
  (assoc hull (dissoc cursor :direction-idx) color))

(defn get-color [hull cursor]
  (get hull (dissoc cursor :direction-idx) 0))

(defn paint-hull-with-robot [shiphull in out]
  (go-loop [hull shiphull
            cursor {:x 0 :y 0 :direction-idx 0}]
    (>!! in (get-color hull cursor))
    (let [color (<!! out)
          direction (<!! out)]
      (if (or (nil? color) (nil? direction))
        hull
        (recur (paint-hull hull cursor color) (advance (turn cursor direction)))))))

#dbg(defn display-hull [hull]
      (for [y (range -40 40)
            x (range -40 40)]
    (if (= x 39) ;; end of the line
      \newline
      (if (= (get-color hull {:x (- x)  :y (- y)}) 1)
        \#
        \space ))))

(defn part-one []
  (let [in  (chan 256)
        out (chan 256)
        int-comp (ic/make-int-computer in out)
        paint-ch (paint-hull-with-robot {} in out)]
    (do
      (<!! (int-comp (ic/read-program "day11.txt")))
      (async/close! out)
      (async/close! in)
      (count (keys (<!! paint-ch))))))

(defn part-two []
  (let [in  (chan 256)
        out (chan 256)
        int-comp (ic/make-int-computer in out)
        paint-ch (paint-hull-with-robot {{:x 0 :y 0} 1} in out)]
    (do
      (<!! (int-comp (ic/read-program "day11.txt")))
      (async/close! out)
      (print (apply str (display-hull (<!! paint-ch)))))))

(defn daves []
  (let [in  (chan 256)
        out (chan 256)
        int-comp (ic/make-int-computer in out)
        paint-ch (paint-hull-with-robot {{:x 0 :y 0} 1} in out)]
    (do
      (<!! (int-comp (ic/read-program "dave_day11.txt")))
      (async/close! out)
      (print (apply str (display-hull (<!! paint-ch)))))))
