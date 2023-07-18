;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (inria dtk)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages qt)
  #:use-module ((guix licenses) #:prefix license:))

(define-public dtk
  (package
    (name "dtk")
    (version "1.7.1")
    (home-page "https://gitlab.inria.fr/dtk/dtk")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "099j4ridsnmn4b77zi99sx2kjhv766qfylp9f7rmgi85nnpwpb4y"))))
    (build-system cmake-build-system)
    (synopsis "A set of libraries based on Qt5 for modular scientific software development")
    (arguments (list #:tests? #false))
    (inputs (list qtbase-5
                  qtdeclarative-5
                  qtsvg-5
                  ))
    (description "A set of libraries based on Qt5 for modular scientific software development")
    (license license:bsd-3)))

