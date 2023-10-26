
#!/usr/bin/env guile \
-e main -s
!#
;; Minimal web server can be started from command line. Current example routes:
;;
;;    localhost:8080/


(use-modules (ice-9 match)
             (ice-9 receive)
             (sxml simple)
             (srfi srfi-11)
             (web request)
             (web response)
             (web server)
             (web http)
             (web uri)
             (rnrs bytevectors)
             (geditor editor)
             (json))




(define (render-json json)
  (list '((content-type . (application/json)))
        (lambda (port)
          (scm->json-string json) port)))


(define (request-path-components request)
  (split-and-decode-uri-path (uri-path (request-uri request))))



(define (decode-query query)
  (if (not query)
      '()
    (map decode-query-component (string-split query #\&))))

(define (decode-query-component component)
  (let* ([index (string-index component #\=)]
         [key (if index (substring component 0 index) component)]
         [value (if index (substring component (1+ index)) "")])
    (cons (string->symbol (uri-decode key))
          (uri-decode value))))

(define (decode-request-body body)
  (if (not body)
      '()
    (decode-query (utf8->string body))))


(define (with-output-to-response content-type thunk)
  (values `((content-type . (,content-type (charset . "UTF-8"))))
          (lambda (port)
            (with-output-to-port port thunk))))


;;fetch queries
(define* (alist-ref alist key #:optional [default #f])
  (cond [(assoc key alist) => cdr]
        [else default]))



;;test implementation
(define (main-form request body)
  `(html
    (@ (xmlns "http://www.w3.org/1999/xhtml"))
    (head (title "Gn markdown editor"))
    (script ,"test1")
    (body
     (input (@ (id "number") (type "text") (size "50") (value "")))
     (button (@ (type "button") (onclick "test_btn()")) "Compute "))))

;;define handlers implementations
(define (main-form-handler request body)
  (values (build-response
           #:headers '((content-type . (application/xhtml+xml))))
          (lambda (port)
            (sxml->xml (main-form request body) port))))



(define (not-found-handler)
  (values (build-response #:code 404)
          "Resource not found"))

(define (redirect-response uri)
  (values (build-response #:code 302
                          #:headers `((location . ,(string->uri uri))))
          "Nan"))

(define (render-main-page blog)
  (display  "
    <h3>Edit markdown</h3>
    <ul>
        <li><a href='/editor?rss=entries'>Feed dos posts</a>
    </ul>
"))

;;test  for general handler
(define (handle-collection-request request body)
  (define query  (decode-query (uri-query (request-uri request))))
  (let*-values ([(page) (string->number (alist-ref query 'page "1"))]
                [(tag) (alist-ref query 'tag)])
    (with-output-to-response 'text/html
      (lambda ()
        (render-main-page "editor")
        ))))


(define (edit-file-handler request body)
  (let ([post-data (if (eq? (request-method request) 'POST)
                     (decode-request-body body)
                     #f)])
   ;;implementation in  edito scm file
    (with-output-to-response 'application/json
      (lambda ()
       (display (scm->json-string post-data))
        ))))


(define (commit-file-handler request body)
  (let ([post-data (if (eq? (request-method request) 'POST)
                     (decode-request-body body)
                     #f)])
  ;;see editor scm for the implementation
    (with-output-to-response 'application/json
      (lambda ()
       (display (scm->json-string post-data))
        ))))



(define (main-handler request body)
  (match (cons (request-method request)
               (request-path-components request))
    (('POST "commit") (commit-file-handler request body))
    (('POST "edit") (edit-file-handler request body))
    (('POST "parse") (parse-markdown-handler request body))
    (('GET) (main-form-handler request body))
    (_ (not-found-handler))))



(display "\nNow go to http://127.0.0.1:8080\n")
(run-server main-handler)