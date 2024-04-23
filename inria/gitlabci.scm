;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017, 2019, 2024 Inria

(define-module (inria gitlabci)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages check))

(define-public gitlabci-gallery-benchmarking
  (package
    (name "gitlabci-gallery-benchmarking")
    (version "0.1")
    (home-page
     "https://gitlab.inria.fr/gitlabci_gallery/dashboards/benchmarking.git")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit "91aba634bc236f21802b0272872259523b6e1813")))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 "0a72y5z51blj4m33g55hi4n5mps63zmk54014aslr5giibrb66zs"))))
    (build-system cmake-build-system)
    (inputs (list googletest))
    (synopsis "Examples of performance tests")
    (description
     "Examples of: performance tests, how to save results in the course of
time, monitor key metrics performances with figures, charts etc, and detect
regressions. Keywords: performance profiling, non-regression testing, cdash,
reframe, jube, sqlite, elasticsearch, kibana, pages.")
    (license license:bsd-3)))
