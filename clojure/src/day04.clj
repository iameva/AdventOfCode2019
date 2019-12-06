(ns aoc.day04)

(defn dupes? [password] (not= password (apply str (dedupe password))))
(defn increase? [password] (apply <= (map int password)))
(defn only-dupes? [password]
  (->> password
       (partition-by identity)
       (map count)
       (filter (partial < 1))
       (filter (partial = 2))
       empty?
       not))

;; part one
(->> (range 193651 649730)
     (map str)
     (filter increase?)
     (filter dupes?)
     count)

;; part two
(->> (range 193651 649730)
     (map str)
     (filter increase?)
     (filter only-dupes?)
     count)
