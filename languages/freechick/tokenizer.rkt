#lang br
(require brag/support)
(require br-parser-tools/lex-sre)

(define (make-tokenizer port)
  (define (next-token)
    (define freechick-lexer
      (lexer
        [(from/to "--" "\n") (next-token)]
        ["draw:" (token 'DRAW-TOKEN lexeme)]
        [(:: "\"" (:= 1 alphabetic) "\"")
         (token 'ID lexeme)]
        [(from/to "\"" "\"")
         (token 'STRING-TOKEN lexeme)]
        ["action:" (token 'ACTION-TOKEN)]
        ["win:" (token 'WIN-TOKEN)]
        ["interactions:" (token 'INTERACTIONS-TOKEN)]
        ["push" (token 'PUSH-TOKEN lexeme)]
        ["stop" (token 'STOP-TOKEN lexeme)]
        ["grab" (token 'GRAB-TOKEN lexeme)]
        ["==" (token 'EQUALS-TOKEN lexeme)]
        ["\n" (token 'NEWLINE-TOKEN lexeme)]
        [whitespace (token lexeme #:skip? #t)]
        ["START_MAP" (token 'START-MAP-TOKEN lexeme)]
        ["END_MAP" (token 'END-MAP-TOKEN lexeme)]
        ["->" (token 'RULE-RESULT-TOKEN lexeme)]
        [(or (:= 1 alphabetic) (:= 1 "#"))
         (token 'MAP-CHAR-TOKEN lexeme)]
        [(or (:= 1 numeric) (:: "-" (:= 1 numeric)))
         (token 'NUM-TOKEN lexeme)]
        [any-char (token lexeme)]))
    (freechick-lexer port))
  next-token)

(provide make-tokenizer)
