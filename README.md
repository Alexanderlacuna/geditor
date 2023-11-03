
# Geditor

GEditor  is a  small tool(WIP) written in guile to edit files and commit changes in a local repo 

## Features

* parse markdown to html
* edit markdown,preview and commit changes to a local repo



## Examples

;; using guix 

```bash

# see manifest.scm for dependencies

guix shell --container --network --share=$HOME/test_repo=/test_repo

# replace test_repo with your preferred repo path


```


* server startup

``` bash


guix -L .. server.scm

```

###  Usage


*  to commit changes

```bash
 curl -X POST http://127.0.0.1:8080/edit -H 'Content-Type: application/json' -d '{"msg":"make test commit","filename":"test.md","repo":"/test_repo","filename":"test.md","content":"new content"}'

```


```json
//expected eample results
{"success":" : Committed changes with message: make test commit New Commit SHA: 6e47001cb9b596cda8c5a97fbd257b811867f983"}

```


* edit file

```bash
 
 curl -X POST http://127.0.0.1:8080/edit -H 'Content-Type: application/json' -d '{"repo":"/test_repo","filename":"test.md"}'


```

```json
//expected results
{"file_name":"test.md","file_content":"new content"}kabui@kabui-20NUS0EB00:~$ 

```

* parse markdown to html

```bash
 curl -X POST -d '{"markdown":"## Header 2"}' http://127.0.0.1:8080/parse

```

```html

<h2>Header 2</h2>

```
## License
see License File


