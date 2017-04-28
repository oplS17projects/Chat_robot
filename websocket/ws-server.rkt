#lang racket
(require net/url)

;; code from Óscar López stackoverflow
(define (urlopen url)
  (let* ((input (get-pure-port (string->url url) #:redirections 5))
         (response (port->string input)))
    (close-input-port input)
    response))

(urlopen "http://localhost:8081/parse?q=hello")

(module+ main
  (require net/rfc6455)
  (require json)
  (require request)

  ;; name of bot
  (define bot-name "@CHAT-BOT")

  ;; list of all client connections
  (define connects '())

  ;; sends message to every client on the connection list
  (define (ws-send-all connection-list m)
    (for-each (lambda (c) (ws-send! c m)) connection-list))

  ;; removes closed connections from the connection list
  (define (remove-closed-conns)
    (when (ormap ws-conn-closed? connects)
      (let ((updated-conn-list (filter (lambda (c) (not (ws-conn-closed? c))) connects)))
        (set! connects updated-conn-list))))

  ;; closes all connections on the connection list
  (define (close-all connection-list)
    (for-each (lambda (c) (ws-close! c)) connection-list))

  ;; gets the message from the json string
  (define (get-message json-str)
    (let ((m (string->jsexpr json-str)))
      (hash-iterate-value m 1)))

  ;; get connection count as string
  (define (get-conn-count c-list)
    (number->string (length c-list)))

  ;; checks if its a message for the bot
  (define (msg-for-bot? m)
    (let ((msg (get-message m)))
      (or (string-prefix? (string-upcase msg) bot-name) (string-prefix? (string-downcase msg) bot-name))))

  ;; make json for bot
  (define (make-bot-msg m)
    (string-append "{\"msg\":\"" m "\",\"username\":\"" (substring bot-name 1) "\"}"))

  ;; parses the message from the client to the bot and removes the bot name
  (define (get-msg-to-bot m)
    (string-trim (substring (get-message m) (string-length bot-name))))

  ;; connection handler
  (define (connection-handler c state)
    (cond
      [(not(memq c connects )) (begin (set! connects (cons c connects))
                                      (ws-send-all connects (get-conn-count connects)))])
    (let loop ()
      (sync (handle-evt c
                        (lambda _
                          (define m (ws-recv c #:payload-type 'text))
                          (unless (eof-object? m)
                            (cond
                              [(equal? m "close") (begin (ws-close! c)
                                                         (remove-closed-conns)
                                                         (ws-send-all connects (get-conn-count connects)))]
                              [(msg-for-bot? m)
                               (if (equal? (get-msg-to-bot m) "")
                                   (loop)
                                   (begin (ws-send-all connects m)
                                          (ws-send-all connects (make-bot-msg "i am bot"))
                                          (loop)))]
                              [(equal? (get-message m) "") (loop)]
                              [else (begin (ws-send-all connects m)
                                           (loop))]))))))
    (ws-close! c)
    (ws-send-all connects (get-conn-count connects)))

  (define stop-service
    (ws-serve #:port 3000 connection-handler))

  (printf "Server running. Hit enter to stop service.\n")
  (void (read-line))
  (stop-service))