; (defun add-widget (database widget)
;   (cons widget database))
; 
; (defparameter *database* nil)
; 
; (defun main-loop ()
;   (loop (princ "Please enter the name of a new widget:")
; 	(setf *database* (add-widget *data-base* (read)))
; 	(format t "The database contains the following: ~a~%"
; 		*database*)))

(defparameter *num-players* 2)
(defparameter *max-dice* 3)
(defparameter *board-size* 2)
(defparameter *board-hexnum* (* *board-size* *board-size*))

(defun board-array (lst)
  (make-array *board-hexnum* :initial-contents lst))

(defun gen-board ()
  (board-array (loop for n below *board-hexnum* collect
		     (list (random *num-players*)
			   (1+ (random *max-dice*))))))

(defun player-letter ()
  (code-char (+ 97 n)))

(defun draw-board (board)
  (loop for y below *board-size* do
	(progn (fresh-line)
	       (loop repeat (- *board-size* y)
		     do (princ "  "))
	       (loop for x below *board-size*
		     for hex = (aref board (+ x (* (*board-size* y)))
		     do (format t "~a-~a "
				(player-letter (first hex))
				(second hex)))))))

(defun game-tree (board player spare-dice first-move)
  (list player board (add-passing-move
		      board player spare-dice first-move
		      (attacking-moves board player spare-dice))))

(defun passing-moves (board player spare-dice first-move moves)
  (if first-move
      moves
    (cons (list nil (game-tree
		     (add-new-dice board player (1- spare-dice))
		     (mod (1+ player) *num-players*)
		     0
		     t))
	  moves)))

(defun attacking-moves (board cur-player spare-dice)
  (labels ((player (pos)
		   (car (aref board pos)))
	   (dice (pos)
		 (cadr (aref board pos))))
	  (mapcan (lambda (src)
		    (when (eq (player src) cur-player)
		      (mapcan
		       (lambda (dst)
			 (when (and (not (eq (player dst) cur-player))
				    (> (dice src) (dice dst)))
			   (list
			    (list (list src dst)
				  (game-tree (board-attack board cur-player src dst
							   (dice src))
					     cur-player
					     (+ spare-dice (dice dst))
					     nil)))))
		       (neighbors src))))
		  (loop for n below *board-hexnum*
			collect n))))

(defun neighbors (pos)
  (let ((up (- pos *board-size*))
	(down (+ pos *board-size*)))
    (loop for p in (append (list up down)
			   (unless (zerop (mod pos *board-size*))
			     (list (1- up) (1- pos)))
			   (unless (zerop (mod (1+ pos) *board-size*))
			     (list (1+ pos) (1+ down))))
	  (when (and (>= (p 0) (< p *board-hexnum*)) collect p)))
