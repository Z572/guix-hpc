(define-module (guix-hpc packages ntpoly)
  #:use-module (guix)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (guix build utils)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages swig)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages documentation))

(define-public ntpoly
  (package
    (name "ntpoly")
    (version "3.1.0")
    (home-page "https://github.com/william-dawson/NTPoly")
    (synopsis
     "A massively parallel library for computing the functions of sparse matrices")
    (description
     "NTPoly is a massively parallel library for computing the functions of 
sparse, Hermitian matrices based on polynomial expansions. For sufficiently 
sparse matrices, most of the matrix functions in NTPoly can be computed in linear time.")
    (license license:expat)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "ntpoly-v" version))))
       (sha256
        (base32 "1pjc1hhawxpfg08xxbbbhd5a32rx6cyczilmi9g3wlilfrzxq6xp"))))
    (build-system cmake-build-system)
    (native-inputs (list gfortran
                         swig
                         python
                         ;; tests
                         python-mpi4py
                         python-numpy
                         python-scipy
                         python-pyyaml
                         openssh))

    (inputs (list openmpi lapack))
    (arguments
     `(#:configure-flags (list "-DBUILD_SHARED_LIBS=ON")))))
