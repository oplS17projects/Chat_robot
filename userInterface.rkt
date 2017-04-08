#lang racket

(require web-server/servlet
         web-server/servlet-env)

(define root (current-directory))

(define (chat-robot-form req)
  (response/xexpr
   `(html (head (title "Chat Robot")
                (link ((rel "stylesheet")
                       (href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")
                       (type "text/css")))
                (link ((rel "stylesheet")
                       (href "/chat_robot.css")
                       (type "text/css")))
                (script ((src "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js")))
                (script ((src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js")))
                (script ((src "/chat_robot.js"))))
          (body (div ((class "jumbotron text-center"))
                     (h1 "Chat Robot")
                     (p "Talk to the chat robot"))
                (div ((class "container"))
                     (div ((id "chatBox")))
                     (form ((name "message")
                            (action ""))
                           (div ((class "form-group"))
                                (div ((class "input-group centered"))
                                     (input ((name "usermsg")
                                        (type "text")
                                        (class "form-control")))
                                     (span ((class "input-group-btn"))
                                           (button ((class "btn btn-primary")
                                                    (id "submitButton")
                                                    (type "submit")) "Send"))))))))))

(serve/servlet chat-robot-form
                 #:extra-files-paths
                 (list
                  (build-path root "css")
                  (build-path root "js")))