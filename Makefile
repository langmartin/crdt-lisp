test: ~/.quicklisp/local-projects/cl-arrows
	sbcl --eval '(asdf:test-system :crdt-lisp)' --quit

~/.quicklisp/local-projects/cl-arrows:
	cd ~/.quicklisp/local-projects
	git clone https://github.com/nightfly19/cl-arrows.git
	sbcl --eval '(ql:quickload "cl-arrows")' --quit
