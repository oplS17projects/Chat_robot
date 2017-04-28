#lang racket

(require "values.rkt"
         "main.rkt"
         json
         net/url)

(provide parser%)

(define parser%
  (class object%
    (field (output "parser")
           (json ""))
    (define/public (parse_intent intent)
      (set! json (string->jsexpr "{\"greet\": \"Hi there, nice to meet you!\", \"affirm\": \"I am glad you agree.\", \"goodbye\": \"I don't really like goodbye's.\", \"weather\": \"The weather is always beautiful for me.\", \"personal\": \"I am good. How are you?\"}"))
      (display json)
      (hash-ref json (string->symbol intent)))
    (super-new)))