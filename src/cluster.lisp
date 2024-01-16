(in-package :crdt-lisp/cluster)

(defstruct cluster name listen connect node-id hlc)

(defun join-cluster (&key name listen connect)
  (make-cluster
   :name name
   :listen listen
   :connect connect
   :hlc (crdt-lisp/hlc:zero)))

(defun send (c message)
  nil)
