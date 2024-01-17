libraries = cl-arrows cl-zmq
install-deps: $(addprefix ~/.quicklisp/local-projects/,$(libraries))

test: ~/.quicklisp/local-projects/cl-arrows
	sbcl --eval '(asdf:test-system :crdt-lisp)' --quit

~/.quicklisp/local-projects/cl-arrows:
	cd ~/.quicklisp/local-projects && git clone https://github.com/nightfly19/cl-arrows.git
	sbcl --eval '(ql:quickload "cl-arrows")' --quit

~/.quicklisp/local-projects/cl-zmq:
	cd ~/.quicklisp/local-projects && git clone https://repo.or.cz/cl-zmq.git
	LIBRARY_PATH=/opt/homebrew/lib \
	CPATH=/opt/homebrew/include \
	sbcl \
	--eval '(ql:quickload "cffi-grovel")' \
	--eval '(ql:quickload "zeromq")' \
	--quit
