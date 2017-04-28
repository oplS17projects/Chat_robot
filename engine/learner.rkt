#lang racket

(require "../values.rkt")

(provide learner)

(define learner
  (class object%
    (field (output "intent")
           (greet (list "hello" "hi" "hey" "yo"))
           (leave (list "bye" "goodbye" "peace" "later")))
    (define/public (learn intent text)
      
      1)
    (super-new)))

