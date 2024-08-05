(define-module (guix-hpc packages libxc)
  #:use-module (guix packages)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages gcc))

(define-public libxc
  (package
    (name "libxc")
    (version "4.3.4")
    (home-page "https://gitlab.com/libxc/libxc")
    (synopsis
     "Library of exchange-correlation functionals for density-functional theory.")
    (description
     "Library of exchange-correlation functionals for
density-functional theory. The aim is to provide a portable, well
tested and reliable set of exchange and correlation functionals that
can be used by a variety of programs.")
    (license license:mpl2.0)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (sha256
        (base32 "03vnmh9ygx8rg7nm1wfgkx15yzjxzccgjvjzvai5y00hwmybk5y7"))))
    (build-system cmake-build-system)
    (native-inputs (list python gfortran perl))
    (arguments
     `(#:configure-flags '("-DBUILD_SHARED_LIBS=ON" "-DENABLE_FORTRAN=ON")))))
