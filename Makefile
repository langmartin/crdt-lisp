QL = ~/.quicklisp/local-projects
WD = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

repl: install-deps $(QL)/crdt-lisp
	sbcl --eval "(asdf:operate 'asdf:load-op 'crdt-lisp)"

test: install-deps $(QL)/cl-arrows
	sbcl --eval '(asdf:test-system :crdt-lisp)' --quit

libraries = crdt-lisp cl-arrows cl-zmq
install-deps: $(addprefix $(QL)/,$(libraries))

export LIBRARY_PATH=/opt/homebrew/lib
export CPATH=/opt/homebrew/include
export INCLUDE=/opt/homebrew/include

$(QL)/crdt-lisp:
	cd $(QL) && ln -sfn $(WD) $@
	sbcl --eval '(ql:register-local-projects)' --quit

$(QL)/cl-arrows:
	cd $(QL) && git clone https://github.com/nightfly19/cl-arrows.git
	sbcl --eval '(ql:quickload "cl-arrows")' --quit

$(QL)/cl-zmq:
	cd $(QL) && git clone https://repo.or.cz/cl-zmq.git
	sbcl \
	--eval '(ql:quickload "cffi-grovel")' \
	--eval '(ql:quickload "zeromq")' \
	--quit

