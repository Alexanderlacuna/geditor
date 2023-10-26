;;;; glibc-locales is always required so Guix can find the locale
;;;; everything else I do in alphabetical order making it easy to maintain
(specifications->manifest
    '( "glibc-locales"
       "guile"
       "git"
       "guile-commonmark"
       "guile-json"
       ))