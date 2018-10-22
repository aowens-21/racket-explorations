#lang br/quicklang
(require json)


(define-macro (jsonic-mb PARSE-TREE)
  #'(#%module-begin
     (define result-string PARSE-TREE)
     (define validated-jsexpr (string->jsexpr result-string))
     (display result-string)))
(provide (rename-out [jsonic-mb #%module-begin]))

(define-macro (jsonic-char CHAR-TOKEN-VALUE)
  #'CHAR-TOKEN-VALUE)
(provide jsonic-char)

(define-macro (jsonic-program SEXPR-OR-JSON-STR ...)
  #'(string-trim (string-append SEXPR-OR-JSON-STR ...)))
(provide jsonic-program)

(define-macro (jsonic-sexpr SEXPR-STR)
  (with-pattern ([SEXPR-DATUM (format-datum '~a #'SEXPR-STR)])
    #'(jsexpr->string SEXPR-DATUM)))
(provide jsonic-sexpr)