;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (llnl geos)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system copy))

(define-public camp
  (package
    (name "camp")
    (version "0.4.0")
    (home-page "https://github.com/LLNL/camp")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url home-page)
                                  (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1allmiszvl4dy5z7vzbf4zrvnw2i92fd7hwl3vlch3w6hl6dfg96"))))
    (build-system copy-build-system)
    (arguments '(#:install-plan '(("." "camp_dir"))))
    (synopsis "CAMP Concepts And Meta-Programming library")
    (description
     "CAMP collects a variety of macros and metaprogramming facilities for C++
projects. It's in the direction of projects like metal (a major influence)
but with a focus on wide compiler compatibility across HPC-oriented systems.")
    (license license:bsd-3)))

(define-public blt
  (let ((commit "6a73c2cc3ad8147d2686c4eaa79beb43e77e1724")
        (revision "20230605"))
    (package
      (name "blt")
      (version (git-version "0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/LLNL/blt")
                      (commit commit)))
                (sha256
                 (base32
                  "1jiygcb2wzxxf82x95xcs8469z3ik0y7d14dblp1zaxq8vyz6x7p"))))
      (build-system copy-build-system)
      (arguments
       '(#:install-plan '(("." "blt_dir"))))
      (home-page "https://llnl-blt.readthedocs.io/en/develop/")
      (synopsis "CMake macros and tools assembled to simplify HPC software development")
      (description
       "BLT is a streamlined CMake-based foundation for Building, Linking and
Testing large-scale high performance computing (HPC) application.")
      (license license:bsd-3))))
