# Chat Robot
## Saurabh Verma
### April 30, 2017

# Overview
The purpose of this project was to develop a basic chatbot that can engage with users and train its responses based on datasets.
I was primarily responsible for building the backend. This included setting up datasets, the parser (parser, intent manager) and a RESTful API that exposed this information to the front-end.
An earlier version of this Chat Robot used an open-source Python-based Natural Language Processing library to handle the complex task of training the bot based on large datasets. However, to further challenge myself, I removed all of the bot's dependency on Python after Demo Day and wrote the parser and the bot's "understanding" algorithms in Racket. Although it downgraded our bot's "intelligent" in the short-term, the transition to Racket improved consistency and will make future development significantly easier.

**Authorship note**: All of the code described here was written by myself.


# Libraries Used
The following libraries were used:

 - (require json)
 - (require web-server/servlet) / (require (planet dmac/spin))
 - (require net/url)

### (require json)
Most of the code is heavily dependent on the `json` library.

For example, in the following excerpt from `parser.rkt`, the `json` library is used to convert a JSON-based response-map to a native hash table. As a result, I was able to use `hash-ref` to retrieve `response` value for any `intent` key.

    (set! json (string->jsexpr "{\"greet\": \"Hi there, nice to meet you!\", \"affirm\": \"I am glad you agree.\", \"goodbye\": \"I don't really like goodbye's.\", \"weather\": \"The weather is always beautiful for me.\", \"personal\": \"I am good. How are you?\"}"))
    (hash-ref json (string->symbol intent)))

### (require web-server/servlet) / (require (planet dmac/spin))
In order to set up endpoints for the RESTful API, I used a user library called `spin` by `dmac`. However, instead of importing the entire library, only the essential parts of it were used. A few modifications were made to the web-server in order to better suit the needs of the application.

    ;; Handles HTTP GET request at /parse endpoint
    (get "/parse"
         (lambda (req)
           ...))

### (require net/url)
Up until demo day, `net/url` was an important component of this backend. It was the `bridge` between Racket and Python and allowed seamless data exchange between the two servers. It was removed in the most recent commit in favor of a Racket-based parser (thus, eliminating the need for interacting with an external server).

# Key Code Excerpts
This sections discusses the use of important class concepts in this project. Each concept has an appropriate title, brief discussion about it and corresponding code.

## Iteration/Recursion
As mentioned in the Overview, an earlier version of this project used Python as the processing server. While it provided us with a lot of power, it sacrificed the core idea of this project: Create a real-world application in Racket. While it was nearly impossible to single-handedly rewrite the entire Python-based Natural Language Processing library in Racket given the time-constraints, I wrote a basic manager and parser in Racket after demo day.
The "heart" of the Racket-based intent manager was the Levenshtein distance algorithm (implemented in `/engine/routes.rkt`). The purpose of this algorithm is to calculate the least amount of times a string needs to be modified to transform into another string. I used the following recursion algorithm:

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

The code above is an iterative/recursive approach to the Levenshtein distance algorithm. The main function, `ld`, accepts two string and passes them to an inner recursive function, `algorithm`, along with the two strings' lengths. There are three base cases: If the two strings are equal, then 0 is return. If length of string A is 0, then length of string B is returned. Similarly, if length of string B is 0, then length of string A returned. Otherwise, the minimum of the following three computations is returned:
 - The sum of a recursive call to `algorithm` with the second and subsequent characters of string A, the new length of string A, string B and the length of string B and 1.
 - The sum of a recursive call to `algorithm` with string A, the length of string A, second and subsequent characters of string B and the new length of string B and 1.
 - The sum of a recursive call to `algorithm` with the second and subsequent characters of string A, the new length of string A, second and subsequent characters of string B and the new length of string B and 0 (if first character of strings A and B match) or 1.

The minimum of the results of the three string-reduction operations is returned.

While I was unable to implement it, a more efficient way would have been to use two matrices and process the two words in order.


Another area where recursion was used is the `find` function (implemented in `engine/routes.rkt`):

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

While the `json` library provided important functions such as `read-json` and `string->jsexpr` for handling JSON data, I encountered a problem where the library was unable to handle multiple, independent JSON objects. This became more problematic due to the requirement of 3D arrays (for holding text, intent and Levenshtein score). `find` addresses the problem by becoming a "bridge" between the JSON and the expected array.

`find` takes each hash entry in the `json` hash table, extracts its text and passes it to the Levenshtein function, along with the user-provided query. The Levenshtein function returns a score after comparing the two strings, which is `cons`'d together with that specific text and its intent. It then recursively calls itself with the next set of hash entries in the `json` hash table. When the function finishes, for a given `val` string of "how do you do", the result typically looks like:

    '(((11 . "hey") . "greet")
      ((8 . "howdy") . "greet")
      ((11 . "hey there") . "greet")
      ((11 . "hello") . "greet")
      ((12 . "hi") . "greet")
      ((12 . "yes") . "affirm")
      ((12 . "yep") . "affirm")
      ((12 . "yeah") . "affirm")
      ((12 . "bye") . "goodbye")
      ((10 . "goodbye") . "goodbye"))

In the Levenshtein algorithm, the lower the resulting number, the closer a string is to the other string. In the above result, it can be seen that `((8 . "howdy") . "greet")` has the lowest Levenshtein score (8). At this point, all necessary data has been collected and stored in memory for later use.

## Objects
When we learned about objects, we primarily focused on closures, local state variables and assignments. For this project, I took the idea of objects two steps further and implemented fully object-oriented classes. For the backend, I created multiple objects and classes to store, manipulate and operate on data. For example, `engine/parser.rkt` is an object with class members and functions:

    (define parser%
      (class object%
        (field (output "parser")
               (json ""))
      (define/public (parse_intent intent)
        (set! json (string->jsexpr "..."))
	      (hash-ref json (string->symbol intent)))
	    (super-new)))

The `parser` class is a subclass of `object` and has two class members, `output` and `json`. There is also a public class function, `parse_intent`. The primary duty of this function is to accept an intent, find an associated response from a response map and return it. The function accomplishes this by doing the following:
 - Uses `set!` to change the value of the `json` variable to a `jsexpr` (hash table) representation of a JSON string.
 - Calls `hash-ref` to query the `json` variable data with a symbol representation (using `string->symbol`) of the `intent` variable.

Finally, the `parser` object calls `(super-new)` to invoke its superclass (`object`) initialization.

One problem I encountered in this file was referencing static files in the webserver. `(set! json (string->jsexpr "..."))` was written in a way that it would call `(call-with-input-file)`, read an external JSON file with intent-response mappings and then assign it to the value of `json` (using `set!`). However, this conflicted with the way the API web-server (`main.rkt`) was set up and I eventually had to use inline JSON mappings.


## List Sorting and Pair Accessors
Another important topic that we learned during the semester was list manipulation and the use of pair accessors to retrieve list elements. In `routes.rkt` (Line 42), once a 3D array/list was created using the Levenshtein algorithm and the `find` function, the next task was to find the pair with the lowest Levenshtein score (lower = more similar in this case).

I called `sort` on the 3D array/list and used the `#:key` parameter to sort using the `caar` accessor on every element. Calling `caar` on every element (`((12 . "hi") . "greet")`) returned the Levenshtein score (`12` in this example). Once I retrieved that data, I provided it the "less-than" operator (`<`) to sort the entire list ascendingly. **Observation**: This operation worked very similar to the `filter` higher-order function, but provided more flexibility.

Once the list was sorted, I used the `cdar` (`(cdar (car k))`) accessor to get the `intent` from the first pair (with the lowest Levenshtein score):

    car '(((8 . "howdy") . "greet")
          ((11 . "hey there") . "greet")
          ((12 . "yes") . "affirm")
          ((10 . "goodbye") . "goodbye"))`

returns `((8 . "howdy") . "greet")`

Next, `(cdr ((8 . "howdy") . "greet")) returns `"greet"`.

Once the `intent` is retrieved, it is passed to the `parser` object's `parse_intent` function and the resulting response string is returned to the API caller.
