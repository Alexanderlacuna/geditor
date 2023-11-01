
# Geditor

GEditor  is a  small tool(WIP) written in guile to edit files and commit changes in a local repo 

## Features

* parse markdown to html
* edit markdown,preview and commit changes to a local repo



## Examples

;; using guix

```
guix shell 

```

```
guix shell --container --network --expose=$HOME/repo=/target_repo
```

* to commit changes
```bash

 curl -X POST -d "filename=<filename.md>&repo=/<path>/<repo_name>&msg=<msg>&content=<content>" http://127.0.0.1:8080/commit

```

* edit file

```bash
 curl -X POST -d "filename=<filename.md>&repo=/<path>/<repo_name" http://127.0.0.1:8080/edit


```

* parse markdown to html

```bash
 curl -X POST -d "markdown=<content>" http://127.0.0.1:8080/parse

```
## License
see License File


