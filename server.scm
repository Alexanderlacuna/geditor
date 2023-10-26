
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


(define (not-found-handler)
  (values (build-response #:code 404)
          "Resource not found"))

(define (redirect-response uri)
  (values (build-response #:code 302
                          #:headers `((location . ,(string->uri uri))))
          "Nan"))


(define (edit-file-handler request body)
  (let ((post-data (if (eq? (request-method request) 'POST)
                     (decode-request-body body)
                     #f)))
    (if post-data
        (let ((file-name (assoc-ref post-data 'filename)) ;;todo
              (repo (assoc-ref post-data 'repo))) 
            (with-output-to-response 'application/json
              (lambda ()
                 (display (scm->json-string (get-file-content  (string-append repo "/" file-name)))) ;;add check for is repo here
              )))
        (with-output-to-response 'text/plain
          (lambda ()
            (display "No valid data received.")
          )))))


(define (parse-markdown-handler request body)
  (let ((post-data (if (eq? (request-method request) 'POST)
                     (decode-request-body body)
                     #f)))
    (if post-data
        (let ((metadata (assoc-ref post-data 'metadata)) ;;todo
              (markdown-text (assoc-ref post-data 'markdown))) 
            (with-output-to-response 'text/html 
              (lambda ()
                 (parse-markdown-text  markdown-text)
              )))
        (with-output-to-response 'text/plain
          (lambda ()
            (display "No valid data received.")
          )))))


(define (commit-file-handler request body)
  (let ((post-data (if (eq? (request-method request) 'POST)
                     (decode-request-body body)
                     #f)))
    (if post-data
        (let ((file-name (assoc-ref post-data 'filename)) ;;todo
              (msg   (assoc-ref post-data 'msg))
              (content (assoc-ref post-data 'content))
              (repo (assoc-ref post-data 'repo))) 
            (with-output-to-response 'application/json
              (lambda ()
                 (display (scm->json-string (commit-file repo file-name content msg))) ;;add check for is repo here
              )))
        (with-output-to-response 'text/plain
          (lambda ()
            (display "No valid data received.")
          )))))


(define (main-handler request body)
  (match (cons (request-method request)
               (request-path-components request))
    (('POST "commit") 
      ;;add 
      (commit-file-handler request body))
    (('POST "edit") (edit-file-handler request body))
    (('POST "parse") (parse-markdown-handler request body))
    (_ (not-found-handler))))



(display "\nNow go to http://127.0.0.1:8080\n")
(run-server main-handler)