#lang br/quicklang
(require brag/support racket/contract)

(module+ test
  (require rackunit))

(define (make-tokenizer port)
  (port-count-lines! port)
  (define (next-token)
    (define jsonic-lexer
      (lexer
       [(from/to "//" "\n") (next-token)]
       [(from/to "@$" "$@")
        (token 'SEXPR-TOKEN (trim-ends "@$" lexeme "$@")
               #:position (+ (pos lexeme-start) 2)
               #:line (pos lexeme-start)
               #:column (+ (col lexeme-start) 2)
               #:span (- (pos lexeme-end) (pos lexeme-start) 4))]
       [any-char (token 'CHAR-TOKEN lexeme
                        #:position (pos lexeme-start)
                        #:line (line lexeme-start)
                        #:column (col lexeme-start)
                        #:span (- (pos lexeme-end) (pos lexeme-start)))]))
    (jsonic-lexer port))
  next-token)

(module+ test
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "// comment \n")
   empty)
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "@$ (+ 6 7) $@")
   (list (token-struct 'SEXPR-TOKEN " (+ 6 7) " 3 1 2 9 #f)))
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "hi")
   (list (token-struct 'CHAR-TOKEN "h" 1 1 0 1 #f)
         (token-struct 'CHAR-TOKEN "i" 2 1 1 1 #f))))
  

(define (jsonic-token? x)
  (or (eof-object? x) (string? x) (token-struct? x)))

(module+ test
  (check-true (jsonic-token? eof))
  (check-true (jsonic-token? "a string"))
  (check-true (jsonic-token? (token 'A-TOKEN "12")))
  (check-false (jsonic-token? 232)))

(provide (contract-out
          [make-tokenizer (input-port? . -> . (-> jsonic-token?))]))