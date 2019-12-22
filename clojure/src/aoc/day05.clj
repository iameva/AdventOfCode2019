(ns aoc.day05
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]
   [aoc.int-code :as ic]
   [clojure.core.async :as async :refer [chan buffer >!! <!! go]]))


(def input
  (->>
   (-> "day05.txt" io/resource slurp str/trim (str/split #","))
   (map #(Integer/parseInt %))
   (into [])))

(defn part-one []
  (let [in (chan 256)
        out (chan 256)]
    (do
      (>!! in 1)
      (<!! ((ic/make-int-computer in out) (ic/read-program "day05.txt")))
      (async/close! out)
      (take-while some? (repeatedly #(<!! out))))))

(defn part-two []
  (let [in (chan 256)
        out (chan 256)]
    (do
      (>!! in 5)
      (<!! ((ic/make-int-computer in out) (ic/read-program "day05.txt")))
      (async/close! out)
      (take-while some? (repeatedly #(<!! out))))))
