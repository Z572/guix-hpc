;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (cea utils)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system python))

(define-public zpp
  (package
    (name "zpp")
    (version "1.0.15")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jbigot/zpp")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0jmdqy8884q6sd5aab7zzf2asi40hizfs6ly8y3z35w3a9b8y2s7"))))
    (build-system python-build-system)
    (home-page "https://github.com/jbigot/zpp")
    (synopsis "\"Z\" pre-processor, the last preprocessor you'll ever need")
    (description
     "Zpp transforms bash in a pre-processor for F90 source files.
It offers a set of functions specifically tailored to build clean
Fortran90 interfaces by generating code for all types, kinds, and
array ranks supported by a given compiler.")
    (license (license:non-copyleft "file:///LICENSE.txt"))))
