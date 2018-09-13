#lang racket

(module our-submod br
  (require racket/contract)
  (define (our-div num denom)
    "string boi")
  (provide (contract-out
            ; our div will take a number, a nonzero denominator, and return a number!
            [our-div (number? (not/c zero?) . -> . number?)])))

(require (submod "." our-submod))
(our-div 42 10)