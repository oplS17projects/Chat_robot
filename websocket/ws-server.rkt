#lang racket/base

(module+ main
  (require net/rfc6455)
  (require json)

  ;; number of connected clients
  (define count 0)

  ;; list of all client connections
  (define connects '())

  ;; sends message to every client on the connection list
  (define (ws-send-all connection-list m)
    (for-each (lambda (c) (ws-send! c m)) connection-list))

  ;; removes closed connections from the connection list
  (define (remove-closed-conns)
    (when (ormap ws-conn-closed? connects)
      (let ((updated-conn-list (filter (lambda (c) (not (ws-conn-closed? c))) connects)))
        (set! count (- (length connects) (length updated-conn-list)))
        (set! connects updated-conn-list))))

  ;; closes all connections on the connection list
  (define (close-all connection-list)
    (for-each (lambda (c) (ws-close! c)) connection-list))

  ;;(define (get-message))
  
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
                              [else (begin (ws-send-all connects m)
                                           (loop))]))))))
    (ws-close! c)
    (remove-closed-conns))

  (define stop-service
    (ws-serve #:port 8081 connection-handler))

  (printf "Server running. Hit enter to stop service.\n")
  (void (read-line))
  (stop-service))