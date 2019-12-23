(ns aoc.day13
  (:require
   [aoc.intcode :as ic]
   [aoc.util :as util]
   [clojure.core.async :as async :refer [>!! <!! go-loop chan]]))

(defn parse-tripple [tripple]
  {:left (first tripple)
   :top (first (next tripple))
   :type (-> tripple next next first)
   })

(defn consume-output [output-ch]
  (loop [tiles []]
    (let [left (<!! output-ch)
          top  (<!! output-ch)
          type (<!! output-ch)]
      (if (or (nil? left) (nil? top) (nil? type) (>= (count tiles) 1012))
        tiles
        (recur (conj tiles {:left left :top top :type type}))))))
    
(defn count-block-tiles [output]
  (do
    (println "total Count: " (count output))
    (->> output
         (map #(:type %1))
         (filter (partial = 2))
         (count))))

(defn part-one []
  (let [in (chan 256)
        out (chan 2048)
        intcomp ((ic/make-int-computer in out) (ic/read-program "day13.txt"))
        consumer (async/go (consume-output out))]
    (do
      (async/close! (:out (<!! intcomp)))
      (count-block-tiles (<!! consumer)))))

(defn update-frame [frame tile]
  (assoc frame
         (case (:type tile)
           4 :ball
           3 :paddle
           0 :empty
           1 :wall
           2 :block
           :score)
         tile))

(defn get-paddle-direction [frame ball]
  (let [paddle (:paddle frame)]
    (cond
      (nil? paddle) 0
      (= (:left paddle) (:left ball)) 0
      (< (:left paddle) (:left ball)) 1
      (> (:left paddle) (:left ball)) -1)))

(defn play-game [in-ch output-ch]
  (loop [frame {}]
    (let [left (<!! output-ch)
          top  (<!! output-ch)
          type (<!! output-ch)
          tile {:left left :top top :type type}]
      (do
        (when (= type 4) ;; ball
            (>!! in-ch (get-paddle-direction frame tile)))
        (if (or (nil? left) (nil? top) (nil? type))
          frame
          (recur (update-frame frame tile)))))))

(defn part-two []
  (let [in (chan)
        out (chan 2048)
        intcomp ((ic/make-int-computer in out) (assoc (ic/read-program "day13.txt") 0 2))
        frame-ch (async/go (play-game in out))]
    (do
      (async/close! (:out (<!! intcomp)))
      (:score (<!! frame-ch)))))
