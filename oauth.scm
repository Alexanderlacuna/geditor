(use-modules (web request))
(define (get-session-token request)
  (let ((headers (request-headers request)))
    (let ((authorization-header (assoc-ref headers 'authorization)))
      (if (string-prefix? "Bearer " authorization-header)
          (substring authorization-header 7) 
          #f)))) 