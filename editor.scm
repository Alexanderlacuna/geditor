

(define-module (geditor editor)

#:export (commit-file
        convert-markdown-to-xml
        commit-file
        get-file-content
        parse-markdown-text
  )
#:use-module  (commonmark)
#:use-module  (commonmark sxml)
#:use-module  (sxml simple)
#:use-module (ice-9 popen)
#:use-module (ice-9 format)
#:use-module (ice-9 rdelim)
#:use-module (ice-9 match)
#:use-module (ice-9  receive)
#:use-module (ice-9 textual-ports)
#:use-module (web request)
#:use-module (web response)
#:use-module (web uri)
#:use-module (sxml simple)
#:use-module (web client)

)

(define (git-invoke repo-path . args)
  (apply system* "git" "-C" repo-path args))


(define (is-git-repo? dir)
  (define git-dir (string-append dir "/.git"))
  (file-exists? git-dir))


(define (get_latest_commit_sha1 repo-path)
  (let* ((output-port (open-input-pipe (string-append "git -C " repo-path " log -n 1 --pretty=format:%H HEAD")))
         (commit-sha (read-line output-port)))
    (close-port output-port)
    commit-sha))



(define (commit-file repo-path file-path new-content commit-message)
  (if (not (is-git-repo? repo-path))
      (list (cons 'error (string-append "The Folder  *" repo-path  "* is  not a Git repository")))
      (begin

  (let* ((full-file-path (string-append repo-path "/" file-path)))
    (match (file-exists? full-file-path)
    (#f
     (list (cons 'error (string-append "The file " file-path " does not exist"))))
    (#t
     (begin
       (with-output-to-file full-file-path
         (lambda ()
           (display new-content)))
       (let* ((add-status (git-invoke repo-path "add" file-path))
              (commit-status (git-invoke repo-path "commit" "-m" commit-message))
              (commit-sha (if (= commit-status 0)
                              (get_latest_commit_sha1 repo-path)
                              #f)))
       ;;use a match expression
         (if (= add-status 0)
             (if (= commit-status 0)
                 (list (cons 'success (string-append " : Committed changes with message: " commit-message " New Commit SHA: " commit-sha)))
                 (list (cons 'success "  :nothing to commit, working tree clean")))
             (list (cons 'error "Error adding changes"))))))))
        )
      )
  )

;;parse implemenontation
(define (read-file filename)
  "Return a string with the contents of FILENAME."
  (call-with-input-file filename
    (lambda (port)
      (peek-char port)    
      (drain-input port))))

(define (fetch-remote-file url)
  (receive (response-status response-body)
      (http-request url)
    response-body))

(define (write-xml-to-file file-name xml)
  (display xml)
  (with-output-to-file file-name
    (lambda ()
      (sxml->xml xml))))

(define (convert-markdown-to-xml markdown-text output-filename)
  "Convert Markdown from MARKDOWN-TEXT to XML and save it to OUTPUT-FILENAME."
  (let ((markdown-parser (commonmark->sxml markdown-text)))
    (write-xml-to-file output-filename markdown-parser)))


(define (parse-markdown-text markdown-text)
  "parse markdown file"
  (let ((markdown-parser (commonmark->sxml markdown-text)))
    (sxml->xml markdown-parser))
  )

(define (get-file-content file-path)
  (if (file-exists? file-path)
      (let ((lines '())
            (file-name (basename file-path))) ; Get the file name from the path
        (call-with-input-file file-path
          (lambda (port)
            (let loop ()
              (let ((line (read-line port)))
                (if (eof-object? line)
                    (list (cons 'file_name file-name)
                          (cons 'file_content (string-join (reverse lines) "\n")))
                    (begin
                      (set! lines (cons line lines))
                      (loop))))))))
      #f))

