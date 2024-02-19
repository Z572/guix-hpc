;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages lsp)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages check)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages version-control)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1))

(define-public fortls
  (package
    (name "fortls")
    (version "2.13.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/fortran-lang/fortls")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "158lpwwvrs4kr1p3rhx6jn10q06ql0pv6bwbvp65bl6vb473cnch"))))
    (build-system python-build-system)
    (propagated-inputs (list python-json5 python-packaging))
    (native-inputs (list python-black python-isort python-pytest
                         python-pytest-cov))
    (synopsis "Language Server for Fortran providing code completion and more")
    (description
     "@command{fortls} is a tool known as a language server that interfaces with your
code editor (VS Code, Vim, etc.) to provide features like code
completion, code navigation, hover messages, and many more.")
    (home-page "https://fortls.fortran-lang.org/")
    (license license:expat)))
