#lang racket/base

(module+ main
  (require net/rfc6455)

  (define count 0)
  (define connects '())

  (define (ws-send-all connection-list m)
    (for-each (lambda (c) (ws-send! c m)) connects))
  
  (define (connection-handler c state)
    (cond
      [(not(memq c connects )) (begin (set! connects (cons c connects)) (set! count (add1 count)))])
    (let loop ()
      (sync (handle-evt c
                        (lambda _
                          (define m (ws-recv c #:payload-type 'text))
                          (unless (eof-object? m)
                            (cond
                              [(equal? m "") (loop)]
                              [else (begin (ws-send-all c m)
                                           (loop))]))))))
    (ws-close! c))

  (define stop-service
    (ws-serve #:port 8081 connection-handler))

  (printf "Server running. Hit enter to stop service.\n")
  (void (read-line))
  (stop-service))