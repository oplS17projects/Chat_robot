#lang racket

(require web-server/servlet
         web-server/servlet-env)

(define root (current-directory))

(define (asset-url path)
  (string-append "/assets/" path))

(define port (if (getenv "PORT")
                 (string->number (getenv "PORT"))
                 8080))

(define (chat-robot-form req)
  (response/xexpr
   `(html (head (title "Chat Robot")
                (link ((rel "stylesheet")
                       (href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")
                       (type "text/css")))
                (link ((rel "stylesheet")
                       (href ,( asset-url "css/chat_robot.css"))
                       (type "text/css"))))
          (body (div ((class "jumbotron text-center"))
                     (h1 "Chat Robot")
                     (p "Talk to the chat robot")
                     (div ((id "clients"))))
                (div ((class "container"))
                     (div ((id "chatBox")))
                     (form ((name "message")
                            (action ""))
                           (div ((class "row "))
                                (div ((class "form-group col-sm-3"))
                                     (input ((name "username")
                                                  (id "username")
                                                  (placeholder "Enter username")
                                                  (type "text")
                                                  (class "form-control"))))
                                (div ((class "form-group col-sm-9"))
                                     (div ((class "input-group centered"))
                                          (input ((name "usermsg")
                                                  (id "usermsg")
                                                  (type "text")
                                                  (placeholder "Enter message")
                                                  (class "form-control")))
                                          (span ((class "input-group-btn"))
                                                (button ((class "btn btn-primary")
                                                         (id "submitButton")
                                                         (type "submit")) "Send")))))))
                (script ((src "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js")))
                (script ((src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js")))
                (script ((src ,(asset-url "js/chatRobot.js"))))))))


(serve/servlet chat-robot-form
                 #:servlet-path "/"
                 #:port port
                 #:listen-ip #f
                 #:command-line? #t
                 #:extra-files-paths (list "public"))