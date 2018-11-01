#lang br/quicklang

(require "tokenizer.rkt" "parser.rkt")

(module+ reader
  (provide read-syntax))
(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (strip-bindings
   #`(module freechick-mod freechick/expander
       #,parse-tree)))
  