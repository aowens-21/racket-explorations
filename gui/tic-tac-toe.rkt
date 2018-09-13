#lang racket

(require racket/gui/base)

(define main-frame (new frame%
                        [label "Tic Tac Toe"]
                        [width 100]))

; The possible dropdown options
(define options (list "-" "X" "O"))

; Our initial selections will be blank
(define current-selection-vector (make-vector 9 "-"))

; Each set is a potential way the player can win
(define win-permutations
  (list
   (set 0 1 2)
   (set 3 4 5)
   (set 6 7 8)
   (set 0 3 6)
   (set 1 4 7)
   (set 2 5 8)
   (set 0 4 8)
   (set 2 4 6)))

; Sets the win message if a player wins
(define (check-for-win x-selection-list o-selection-list)
  ; Turn the lists into sets
  (let* ([x-set (list->set x-selection-list)]
         [o-set (list->set o-selection-list)])
  ; See if any of our win permutations are a subset of the positions of O's, if so, O has won
  (define o-wins (ormap (lambda (winner)
                          (subset? winner o-set))
                        win-permutations))
  ; Same as above but for X
  (define x-wins (ormap (lambda (winner)
                          (subset? winner x-set))
                        win-permutations))
  ; Set the label or return void if neither has won
  (cond
    [x-wins (send win-message set-label "X Wins!")]
    [o-wins (send win-message set-label "O Wins!")]
    [else (send win-message set-label "")])))

; Called each time an option is selected by a player
(define (update-game-with-selection c e index)
  ; Get the selection from the choice control
  (define selection (list-ref options (send c get-selection)))
  ; Set it in the "game state vector"
  (vector-set! current-selection-vector index selection)
  ; Get the x-selections and o-selections as lists
  (let*
      ([selections-as-list (vector->list current-selection-vector)]
       [x-selections (indexes-of selections-as-list "X")]
       [o-selections (indexes-of selections-as-list "O")])
    (check-for-win x-selections o-selections)))

; top row and checkboxes
(define top-row (new horizontal-panel% [parent main-frame]
                                       [alignment '(center top)]))

(define top-left (new choice% [parent top-row]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 0))]))
(define top-center (new choice% [parent top-row]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 1))]))
(define top-right (new choice% [parent top-row]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 2))]))


; center row and checkboxes
(define center (new horizontal-panel% [parent main-frame]
                                    [alignment  '(center center)]))

(define center-left (new choice% [parent center]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 3))]))
(define center-middle (new choice% [parent center]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 4))]))
(define center-right (new choice% [parent center]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 5))]))

; bottom row and checkboxes
(define bottom-row (new horizontal-panel% [parent main-frame]
                                       [alignment '(center bottom)]))

(define bottom-left (new choice% [parent bottom-row]
                                 [label ""]
                                 [choices options]
                                 [callback (lambda (c e) (update-game-with-selection c e 6))]))
(define bottom-center (new choice% [parent bottom-row]
                                 [label ""]
                                 [choices options]
                                 [callback  (lambda (c e) (update-game-with-selection c e 7))]))
(define bottom-right (new choice% [parent bottom-row]
                                 [label ""]
                                 [choices options]
                                 [callback  (lambda (c e) (update-game-with-selection c e 8))]))

; win message area

(define win-message (new message% [parent main-frame]
                                  [label ""]))

(send main-frame show #t)



