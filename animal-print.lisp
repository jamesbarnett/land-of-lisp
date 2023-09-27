(defun random-animal ()
  (nth (random 5) '("dog" "tick" "tiger" "walrus" "kangaroo")))

(defparameter *animals* (loop repeat 10 collect (random-animal)))
