(define-module (libnegf libnegf)
  #:use-module (guix)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages version-control)
  #:use-module ((guix licenses) #:prefix license:))

(define-public python-fypp
  (package
   (name "python-fypp")
   (version "3.2")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/aradi/fypp/archive/refs/tags/"
           version ".tar.gz"))
     (sha256
      (base32
       "07fff7bqkcg8nz3imlybm8hxbr2hghyf6p16cnc57nrp4f6qrx1k"))))
   (build-system python-build-system)
   (home-page "https://github.com/aradi/fypp.git")
   (synopsis "Python powered Fortran preprocessor")
   (description
    "Fypp is a Python powered preprocessor. It can be used for any programming
languages but its primary aim is to offer a Fortran preprocessor, which helps to
extend Fortran with condititional compiling and template metaprogramming
capabilities. Instead of introducing its own expression syntax, it uses Python
expressions in its preprocessor directives, offering the consistency and
versatility of Python when formulating metaprogramming tasks. It puts strong
emphasis on robustness and on neat integration into developing toolchains.")
   (license license:bsd-2)))

(define-public mpifx
  (package
   (name "mpifx")
   (version "1.4")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/dftbplus/mpifx/archive/refs/tags/"
           version ".tar.gz"))
     (sha256
      (base32
       "1ydwd5zwk565lxxjkfvf8rrsw4vbr7rjpyw64id8pldb1xl0kzb3"))))
   (build-system cmake-build-system)
   (arguments `(#:configure-flags (list "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")))
   (native-inputs (list gfortran openssh))
   (inputs (list python-fypp))
   (propagated-inputs (list openmpi))
   (home-page "https://github.com/dftbplus/mpifx/")
   (synopsis "Modern Fortran wrappers around MPI routines")
   (description
    "The open source library MpiFx provides modern Fortran (Fortran 2003)
wrappers around routines of the MPI library to make their use as simple as
possible. Currently several data distribution routines are covered.")
   (license license:bsd-2)))

(define-public libnegf
  (package
   (name "libnegf")
   (version "1.1.3")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/libnegf/libnegf/archive/refs/tags/"
           "v" version ".tar.gz"))
     (patches (search-patches "libnegf/patches/libnegf-fypp.patch"))
     (sha256
      (base32
       "0zi35w1zpkqij6qbpccirpi4qhq4b0wskwz4nhyj16j53rwl2ald"))))
   (build-system cmake-build-system)
   (arguments
    `(#:configure-flags (list "-DBUILD_SHARED_LIBS=ON"
                              "-DWITH_MPI=ON")))
   (native-inputs (list gfortran openssh python))
   (inputs (list mpifx openblas python-fypp))
   (propagated-inputs (list openmpi))
   (home-page "https://github.com/libnegf/libnegf")
   (synopsis "a general library for Non Equilibrium Green's Functions")
   (description
    "With libNEGF you can calculate Equilibrium and Non Equilibrium Green's
Function in open systems and related quantities, within an efficient sparse
iterative scheme.")
   (license license:lgpl3+)))
