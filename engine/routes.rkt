#lang racket

(require "main.rkt"
         "values.rkt"
         "intent.rkt"
         "parser.rkt"
         json)

(get "/intent"
     (lambda (req)
       (send* (new intent%) (parse "hi"))))

(get "/parse"
     (lambda (req)
       (define q (params req 'q))
       (define cmd_path (string-append "curl '" NL_LIVE_SERVER "parse?q=" q "'"))
       (display cmd_path)
       (define cmd (process cmd_path))
       (define res (port->string (first cmd)))
       (send* (new parser%) (parse_intent (hash-ref (hash-ref (string->jsexpr res) 'intent) 'name)))))
(run)
