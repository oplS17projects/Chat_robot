#lang racket

(require "main.rkt"
         "objects/intent.rkt")

(get "/intent"
     (lambda (req)
       (send* (new intent%) (parse "hi"))))

(run)
