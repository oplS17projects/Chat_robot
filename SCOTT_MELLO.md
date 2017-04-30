# WebSockets for Chat Robot

## Scott Mello
### April 30, 2017

#Overview
This code is for the WebSocket server of the chat robot. 

A WebSocket provides full-duplex communication over a TCP connection. 
This allows for clients to send messages to a server at the same time that 
the server is sending messages to one or many clients.

The main function of the WebSocket server is to handle and manage client 
connections. When a client makes a handshake request with the server, a connection
is added to the connection list, and is put into a recursive loop within the
connection handler. When the client sends a messages, the connection handler
handles it by sending it to all clients on the connection list, and continues
the recursive loop.

**Authorship note:** All of the code described here was written by myself.

# Libraries Used

This code uses 3 libraries:

(require net/rfc6455)
(require json)
(require net/url)

* Tony Garnock-Jones' ```rfc6455``` library provides a WebSocket interfaces for racket. 
* The ```json``` library is used to parse json messages sent from the client.
* The ```net/url``` library is used to make RESTful web requests to the python machine learning server.

# Key Code Excerpts

The following represents the code I wrote for this project that displays the core concepts taught in this course.


## Recursion

```racket

  ;; my own filter function
  (define (filter-conns pred lst)
    (cond
      [(empty? lst) '()]
      [(pred (car lst)) (add-conn (car lst) (filter-conns pred (cdr lst)))]
      [else (filter-conns pred (cdr lst))]))

```

This is a filter function that I wrote to display the key concept of recursion. 
It will be used in the below example to show the management of connections.

## Higher-Order Functions

```racket

  ;; removes closed connections from the connection list
  (define (remove-closed-conns)
    (when (ormap ws-conn-closed? connects)
      (let ((updated-conn-list (filter-conns (lambda (c) (not (ws-conn-closed? c))) connects)))
        (set! connects updated-conn-list))))

  ;; sends message to every client on the connection list
  (define (ws-send-all connection-list m)
      (map (lambda (c) (ws-send! c m)) connection-list))
    
```

I used higher-order function numerous times in my code. In removed closed-conns,
I am using ormap to check if there are any closed connections. ormap is very
similar to map, except that it functions like or. When it first evauates to true,
it does not evaluate the rest of the items in the list. map is  unnecessary because
we only need to know if there is a single closed connection, then we can use
the fiter I wrote to filter out any closed connections, and update the connection
list with set!

In the ws-send-all function, I am  using map to iterate through each connection
in the list, and send a message to each client. It is worth noting that for-each
can also be used in place of map.

## Abstraction

```racket

  ;; my own filter function
  (define (filter-conns pred lst)
    (cond
      [(empty? lst) '()]
      [(pred (car lst)) (add-conn (car lst) (filter-conns pred (cdr lst)))]
      [else (filter-conns pred (cdr lst))]))

  ;; some basic abstraction for cons
  (define (add-conn x y)
    (cons x y))

```

I used some basic abstraction similar to our very first lesson in functional abstraction.
the add-conn function is using cons to add x to y. In the case of the filter
function, x represents a connection, and y represents the connection list.