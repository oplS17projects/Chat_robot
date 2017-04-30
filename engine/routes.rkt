#lang racket

(require "main.rkt"
         "values.rkt"
         "intent.rkt"
         "parser.rkt"
         json)

(define json (string->jsexpr (file->string "dataset.json")))

(define (ld x y)
  (define (algorithm a lA b lB)
    (cond ((equal? a b) 0)
          ((= lA 0) lB)
          ((= lB 0) lA)
          (else (min (+ (algorithm (substring a 1) (- lA 1) b lB) 1)
                     (+ (algorithm a lA (substring b 1) (- lB 1)) 1)
                     (+ (algorithm (substring a 1) (- lA 1) (substring b 1) (- lB 1))
                        (cond ((string=? (substring a 0 1) (substring b 0 1)) 0)
                              (else 1)))))))
  (algorithm x (string-length x) y (string-length y)))

(define (find json val)
  (if (empty? json)
      '()
      (begin
        (cons
         (cons
          (cons (ld (hash-ref (car json) 'text) val)
                (hash-ref (car json) 'text))
          (hash-ref (car json) 'intent))
         (find (cdr json) val)))))

(get "/intent"
     (lambda (req)
       (send* (new intent%) (parse "hi"))))

(get "/parse"
     (lambda (req)
       (define q (string-replace (params req 'q) " " "+"))
       (define expanded (find json q))
       (define sorted (sort expanded #:key caar <))
       (define intent (cdar sorted))
       (send* (new parser%) (parse_intent intent))))
(run)