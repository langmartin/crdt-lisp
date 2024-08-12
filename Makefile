QL = ~/.quicklisp/local-projects
WD = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

repl: install-deps
	sbcl --eval "(asdf:operate 'asdf:load-op 'crdt-lisp)"

test: install-deps
	sbcl --eval '(asdf:test-system :crdt-lisp)' --quit

# ========================================================================
# Some libraries have to be cloned to local-projects because they're
# not available in quicklisp repos. Homebrew includes are required for
# c ffi compilation dependencies.

libraries = crdt-lisp cl-arrows cl-zmq

install-deps: ~/.quicklisp $(addprefix $(QL)/,$(libraries))

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

~/.quicklisp:
	curl -o .ql.lisp http://beta.quicklisp.org/quicklisp.lisp
	sbcl --no-sysinit --no-userinit --load .ql.lisp \
	--eval '(quicklisp-quickstart:install :path "~/.quicklisp")' \
	--eval '(ql:add-to-init-file)' \
	--quit
	rm .ql.lisp
