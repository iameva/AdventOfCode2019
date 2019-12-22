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
        out (chan 256)
        intcomp ((ic/make-int-computer in out) (ic/read-program "day13.txt"))
        consumer (async/go (consume-output out))]
    (do
      (async/close! (:out (<!! intcomp)))
      (count-block-tiles (<!! consumer)))))
  
(defn part-one []
  (let [in (chan)
        out (chan 256)
        intcomp ((ic/make-int-computer in out) (ic/read-program "day13.txt"))]
    (async/go
      (let [frame (consume-output out)]
        )
