#lang racket

(require "../values.rkt")
(require json)

(provide parser)

(define parser
  (class object%
    (field (output "parser")
           (json "")
           (leave (list "bye" "goodbye" "peace" "later")))
    (define/public (parse_intent intent)
      (set! json (call-with-input-file NL_SERVER_PARSER_JSON read-json))
      (hash-ref json (string->symbol intent)))
    (super-new)))

