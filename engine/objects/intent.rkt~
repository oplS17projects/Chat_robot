#lang racket

(require json)

(provide intent%)

(define intent%
  (class object%
    (field (output "intent")
           (greet (list "hello" "hi" "hey" "yo"))
           (leave (list "bye" "goodbye" "peace" "later")))
    (define/public (process t)
      (with-output-to-string
          (λ () (write-json #hasheq((intent . #hasheq((confidence . 1.0) (name . (parse t)))))))))
    (define/public (parse t)
      (begin
        (define lt (string-downcase t))
        (cond ((member lt greet) "greet")
              ((member lt leave) "goodbye")
              (else "None"))))
    (super-new)))
