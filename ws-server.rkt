#lang racket/base
;; Demonstrates the ws-serve interface.
;; Public Domain.

(module+ main
  (require net/rfc6455)

  (define (connection-handler c state)
    (let loop ()
      (sync (handle-evt c
                        (lambda _
                          (define m (ws-recv c #:payload-type 'text))
                          (unless (eof-object? m)
                            (cond
                              [(equal? m "goodbye") (ws-send! c "Goodbye!")]
                              [(equal? m "") (loop)]
                              [else (begin (ws-send! c m)
                                       (loop))]))))))
    (ws-close! c))

  (define stop-service
    (ws-serve #:port 8081 connection-handler))

  (printf "Server running. Hit enter to stop service.\n")
  (void (read-line))
  (stop-service))