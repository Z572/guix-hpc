(define-module (inria mipp)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:))

(define-public mipp
  (let ((commit "cd9779111e238c4ea7ff4239394b7d208262b208")
        (revision "0"))
  (package
    (name "mipp")
    (version (git-version "0.0" revision commit))
    (home-page "https://github.com/aff3ct/MIPP.git")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url home-page) (commit commit)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "05mdjy7j7lnzbp579inysmch3g7azfadqnxd9d66ck68j08r2s69"))))
    (build-system cmake-build-system)
    (synopsis "MIPP is a portable wrapper for SIMD instructions written in C++11.")
    (description "MIPP is a portable wrapper for SIMD instructions written in C++11.")
    (license license:expat))))
