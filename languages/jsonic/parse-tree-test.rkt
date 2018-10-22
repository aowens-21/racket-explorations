#lang br

(require jsonic/parser jsonic/tokenizer brag/support)

(parse-to-datum (apply-tokenizer-maker make-tokenizer
#<<ALEX
"foo"
// comment
@$ 42 $@
@$ (* 8 8) $@
ALEX
))

