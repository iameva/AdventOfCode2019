(ns aoc.day22
  (:require
   [clojure.string :as cljstr]
   [aoc.util :as util]))

(defn deal-new-stack [deck]
  (into [] (reverse deck)))

(defn cut [amount deck]
  (let [cut-pos (if (< amount 0) (+ (count deck) amount) amount)]
    (vec (concat (subvec deck cut-pos) (subvec deck 0 cut-pos)))))

(defn increment-new-pos [size skip pos]
  (let [increment (* pos skip)
        offset (quot increment size)]
    (mod increment size)))

(defn deal-with-increment [increment deck]
  (let [size (count deck)] 
    (reduce-kv (fn[new-deck pos card]
                 (assoc new-deck (increment-new-pos size pos increment) card))
               (vec (repeat size -1))
               deck)))

(defn parse-command [cmd]
  (cond
    (cljstr/starts-with? cmd "cut") (partial cut (Integer/parseInt (re-find #"-?\d+" cmd)))
    (cljstr/starts-with? cmd "deal with") (partial deal-with-increment (Integer/parseInt (re-find #"-?\d+" cmd)))
    (cljstr/starts-with? cmd "deal into") deal-new-stack))

(defn run-algo [filename deck]
  (let[actions (map parse-command (util/read-lines filename))]
    ((apply comp (reverse actions)) deck)))

(defn part-one []
  (.indexOf (run-algo "day22.txt" (into [] (range 10007))) 2019))



(defn new-stack-pos [size pos]
  (dec (- (size pos))))

(defn cut-pos [size amount pos]
  (mod (- pos amount) size))

(defn run-transformations [transformations position]
  (apply comp (reverse transformations) position))

(defn find-period [transformations]
  (loop [pos (run-transformations transformations 0)
         ctr 0]
    (if (= pos 0)
      ctr
      (recur (run-transformations transformations pos) (inc ctr)))))

(defn parse-command-for-pos [size cmd]
  (cond
    (cljstr/starts-with? cmd "cut") (partial cut-pos size (Integer/parseInt (re-find #"-?\d+" cmd)))
    (cljstr/starts-with? cmd "deal with") (partial increment-new-pos size (Integer/parseInt (re-find #"-?\d+" cmd)))
    (cljstr/starts-with? cmd "deal into") (partial new-stack-pos size)))
;; (defn part-two [filename size]
;;   (let [transformations (map (partial parse-command-for-pos size) (util/read-lines filename))]
;;     )
  
