QL = ~/.quicklisp/local-projects
WD = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

repl: install-deps $(QL)/crdt-lisp
	sbcl --eval "(asdf:operate 'asdf:load-op 'crdt-lisp)"

libraries = cl-arrows cl-zmq
install-deps: $(addprefix $(QL)/,$(libraries))

test: $(QL)/cl-arrows
	sbcl --eval '(asdf:test-system :crdt-lisp)' --quit

$(QL)/crdt-lisp:
	cd $(QL) && ln -sfn $(WD) $@

$(QL)/cl-arrows:
	cd $(QL) && clone https://github.com/nightfly19/cl-arrows.git
	sbcl --eval '(ql:quickload "cl-arrows")' --quit

$(QL)/cl-zmq:
	cd $(QL) && git clone https://repo.or.cz/cl-zmq.git
	LIBRARY_PATH=/opt/homebrew/lib \
	CPATH=/opt/homebrew/include \
	sbcl \
	--eval '(ql:quickload "cffi-grovel")' \
	--eval '(ql:quickload "zeromq")' \
	--quit
