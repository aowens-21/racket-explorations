#lang racket

(require racket/gui/base)
(require racket/draw)

(define window-width 500)
(define window-height 500)
(define rows 8)
(define columns 8)

; top left position of each grid square
(define grid-positions (list 25 81 137 193 249 305 361 417))

(define initial-grid-contents (list (list "B" "B" "B" "B" "B" "B" "B" "B")
                                 (list "B" "B" "" "B" "B" "B" "B" "B")
                                 (list "B" "B" "" "" "" "" "" "B")
                                 (list "B" "B" "" "" "" "B" "B" "B")
                                 (list "B" "B" "" "" "B" "" "" "B")
                                 (list "B" "B" "" "" "B" "" "" "B")
                                 (list "B" "B" "" "" "B" "" "" "B")
                                 (list "B" "B" "B" "B" "B" "B" "B" "B")))

(define grid-contents (map list->vector initial-grid-contents))

(define chick-bitmap (read-bitmap "chick.jpg"))
(define chick-pos (list 5 5))

(define player-bitmap (read-bitmap "player.png"))
(define current-player-pos (vector 1 1))


(define game-frame (new frame%
                        [label "Free The Chick!"]
                        [width window-width]
                        [height window-height]))

(define (paint-to-canvas canvas dc)
  (send dc set-pen "black" 2 'solid)
  (draw-game-grid dc window-width window-height rows columns)
  (draw-game-state dc))

(define canvas-with-events%
  (class canvas%
    (define/override (on-char key-event)
      (handle-key-press (send key-event get-key-code)))
    (super-new)))

(define game-canvas (new canvas-with-events%
                         [parent game-frame]
                         [paint-callback paint-to-canvas]))

(define (draw-game-grid dc width height rows columns)
  (let* ([grid-x-start 25]
         [grid-x-end (+ grid-x-start (- width 50))]
         [grid-y-start 25]
         [grid-y-end (+ grid-y-start (- height 50))])
    
    (send dc draw-rectangle grid-x-start grid-y-start (- width 50) (- height 50))
    (draw-rows dc grid-x-start grid-x-end grid-y-start grid-y-end rows)
    (draw-columns dc grid-x-start grid-x-end grid-y-start grid-y-end columns)))

(define (draw-rows dc x-start x-end y-start y-end rows)
  (let* ([height (- y-end y-start)]
         [row-height (quotient height rows)] ; subtract 1 from rows because we need rows-1 lines
         [row-y-values (map (lambda (x) (+ y-start (* row-height x))) (build-list (- rows 1) (lambda (y) (+ y 1))))])
    (for-each (lambda (y-value)
                (send dc draw-line x-start y-value x-end y-value))
              row-y-values)))

(define (draw-columns dc x-start x-end y-start y-end columns)
  (let* ([width (- x-end x-start)]
         [col-width (quotient width columns)]
         [col-x-values (map (lambda (x) (+ x-start (* col-width x))) (build-list (- columns 1) (lambda (y) (+ y 1))))])
    (for-each (lambda (x-value)
                (send dc draw-line x-value y-start x-value y-end))
              col-x-values)))

(define (draw-game-state dc)
  (send dc set-brush "black" 'solid)
  (for-each (lambda (x-draw grid-row)
              (for-each (lambda (y-draw grid-space)
                          (cond
                            [(string=? grid-space "B") (send dc draw-rectangle x-draw y-draw 56 56)]
                            [(string=? grid-space "C") (send dc draw-bitmap chick-bitmap x-draw y-draw)]
                            [(string=? grid-space "P") (send dc draw-bitmap player-bitmap x-draw y-draw)]))
                        grid-positions (vector->list grid-row)))
            grid-positions grid-contents)
  (send dc set-brush "white" 'solid))

(define (update-grid-space! x y val)
  (cond
    [(string=? val "P") (vector-set! current-player-pos 0 x) (vector-set! current-player-pos 1 y)])
  (vector-set! (list-ref grid-contents x) y val)
  (send game-canvas refresh-now))

(define (get-grid-space x y)
  (cond
    [(in-bounds x y) (vector-ref (list-ref grid-contents x) y)]
    [else "OOB"]))

; Takes in a keycode and updates game state accordingly
(define (handle-key-press key)
  ; Convert the player's position to a list so we have pair accessors
  (let* ([player-pos-list (vector->list current-player-pos)]
         [px (first player-pos-list)]
         [py (second player-pos-list)])
    (cond
      [(and (equal? key 'left) (in-bounds (- px 1) py)) (cond
                            [(space-free (- px 1) py) (update-grid-space! px py "") (update-grid-space! (- px 1) py "P")]
                            [(block-in-space (- px 1) py) (cond
                                                            [(block-can-move (- px 1) py 'left) (update-grid-space! px py "") (update-grid-space! (- px 1) py "P") (update-grid-space! (- px 2) py "B")])])]
      [(and (equal? key 'right) (in-bounds (+ px 1) py)) (cond
                             [(space-free (+ px 1) py) (update-grid-space! px py "") (update-grid-space! (+ px 1) py "P")]
                             [(block-in-space (+ px 1) py) (cond
                                                             [(block-can-move (+ px 1) py 'right) (update-grid-space! px py "") (update-grid-space! (+ px 1) py "P") (update-grid-space! (+ px 2) py "B")])])]
      [(and (equal? key 'up) (in-bounds px (- py 1))) (cond
                          [(space-free px (- py 1)) (update-grid-space! px py "") (update-grid-space! px (- py 1) "P")]
                          [(block-in-space px (- py 1)) (cond
                                                          [(block-can-move px (- py 1) 'up) (update-grid-space! px py "") (update-grid-space! px (- py 1) "P") (update-grid-space! px (- py 2) "B")])])]
      [(and (equal? key 'down) (in-bounds px (+ py 1))) (cond
                            [(space-free px (+ py 1)) (update-grid-space! px py "") (update-grid-space! px (+ py 1) "P")]
                            [(block-in-space px (+ py 1)) (cond
                                                            [(block-can-move px (+ py 1) 'down) (update-grid-space! px py "") (update-grid-space! px (+ py 1) "P") (update-grid-space! px (+ py 2) "B")])])]))
  (check-for-win))

(define (space-free x y)
  (not (string=? (get-grid-space x y) "B")))

(define (block-in-space x y)
  (string=? (get-grid-space x y) "B"))

(define (block-can-move x y dir)
  (cond
    [(equal? dir 'left) (and (in-bounds (- x 1) y) (string=? (get-grid-space (- x 1) y) ""))]
    [(equal? dir 'right) (and (in-bounds (+ x 1) y) (string=? (get-grid-space (+ x 1) y) ""))]
    [(equal? dir 'up) (and (in-bounds x (- y 1)) (string=? (get-grid-space x (- y 1)) ""))]
    [(equal? dir 'down) (and (in-bounds x (+ y 1)) (string=? (get-grid-space x (+ y 1)) ""))]))

(define (in-bounds x y)
  (and (>= x 0) (>= y 0) (< x columns) (< y rows)))

(define (check-for-win)
  (cond
    [(equal? chick-pos (vector->list current-player-pos)) (send player-bitmap load-file "player_with_chick.png") (send game-canvas refresh-now) (writeln "YOU WIN, THE CHICK IS FREE!")]))    

(define (init-game-state)
  (update-grid-space! (first chick-pos) (second chick-pos) "C")
  (update-grid-space! (vector-ref current-player-pos 0) (vector-ref current-player-pos 1) "P"))
  
  

(init-game-state)
(send game-frame show #t)