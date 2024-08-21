;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages chemistry)
  #:use-module (guix)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module (guix build utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages python)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages chemistry)
  #:use-module (gnu packages)
  #:use-module (gnu packages ssh)
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages python-build)
  #:use-module (guix build-system trivial)
  #:use-module (guix-hpc packages math))

(define bigdft-version
  "1.9.5")

(define bigdft-home-page
  "https://bigdft.org")

(define bigdft-source-page
  "https://gitlab.com/l_sim/bigdft-suite")

(define bigdft-source
  (origin
    (method git-fetch)
    (uri (git-reference (url bigdft-source-page)
                        (commit bigdft-version)))
    (sha256 (base32 "1asc3xvjvw9bv17xzpn1lq6jxlm6i8jac2kc213h0j81fn1mkib0"))
    (patches (search-patches "guix-hpc/packages/patches/bigdft-futile.patch"
              "guix-hpc/packages/patches/bigdft-type-corrected.patch"))))

(define* (make-bigdft subproject)
  (package
    (name (string-append "bigdft-" subproject))
    (version bigdft-version)
    (home-page bigdft-home-page)
    (synopsis "placeholder")
    (description "placeholder")
    (license license:gpl2+)
    (source
     bigdft-source)
    (build-system gnu-build-system)

    (native-inputs (list autoconf
                         automake
                         libtool
                         gfortran
                         pkg-config
                         ;; tests
                         ;; python
                         python-wrapper ;they call python instead of python3
                         python-pyyaml
                         python-numpy))
    ;; doc
    ;; doxygen))

    (inputs (list libyaml lapack openmpi))

    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-after 'unpack 'chdir
                    (lambda* _
                      (chdir ,subproject))))

       #:configure-flags '("--enable-dynamic-libraries" "--enable-mpi"
                           "CC=mpicc" "CXX=mpicxx" "FC=mpifort")

       ;; Some instability with parallelism
       ;; TODO: check again
       #:parallel-tests? #f
       #:parallel-build? #f))))

(define-public bigdft-futile
  (let* ((base (make-bigdft "futile")))
    (package/inherit base
      (synopsis
       "Library for handling most common FORTRAN low-level operations")
      (description
       "Library for handling most common FORTRAN low-level operations,
like memory managment, profiling routines, I/O operations.
It also supports yaml output and parsing for fortran programs.
It also provides wrappers routines to MPI and linear algebra operations.
This library is intensively used in BigDFT packages."))))

(define-public bigdft-atlab
  (let* ((base (make-bigdft "atlab")))
    (package/inherit base
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile openbabel)))

      (arguments (substitute-keyword-arguments (package-arguments base)
                   ((#:configure-flags flags)
                    #~(append (list
                               ;; not autodetected with pkg-config
                               ;; TODO still doesn't pick it up
                               "--enable-openbabel"
                               (string-append "--with-openbabel-libs="
                                              "-lopenbabel" " "
                                              (string-append "-L"
                                                             #$(this-package-input
                                                                "openbabel")
                                                             "/lib"))
                               (string-append "--with-openbabel-incs="
                                              (string-append "-I"
                                               #$(this-package-input
                                                  "openbabel")
                                               "/include/openbabel3")))
                              #$flags))))
      (synopsis "BigDFT-atlab: library for ATomic related operations")
      (description "BigDFT-atlab: library for ATomic related operations."))))

(define-public bigdft-chess
  (let* ((base (make-bigdft "chess")))
    (package/inherit base
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-atlab ntpoly)))

      (arguments (append (list
                          ;; Fatal Error: Cannot open module file
                          ;; ‘sparsematrix_init.mod’ for reading at (1): No such file or directory
                          ;; I believe the tests don't have a proper include path
                          #:tests? #f)
                         (substitute-keyword-arguments (package-arguments base)
                           ((#:configure-flags flags)
                            #~(append (list "--enable-ntpoly")
                                      #$flags)))))
      (synopsis
       "Module for performing Fermi Operator Expansions via Chebyshev Polynomials")
      (description
       "Module for performing Fermi Operator Expansions via Chebyshev Polynomials."))))

(define-public bigdft-psolver
  (let* ((base (make-bigdft "psolver")))
    (package/inherit base
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-atlab)))

      (native-inputs (modify-inputs (package-native-inputs base)
                       (prepend openssh)))
      (synopsis
       "Flexible real-space Poisson Solver based on Interpolating Scaling Functions")
      (description
       "Flexible real-space Poisson Solver based on Interpolating Scaling Functions.
It constitutes a fundamental building block of BigDFT code, and it can also be used separately and
linked to other codes."))))

(define-public bigdft-libabinit
  (let* ((base (make-bigdft "libABINIT")))
    (package/inherit base
      (name "bigdft-libabinit")
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile libxc)))
      (arguments (substitute-keyword-arguments (package-arguments base)
                   ((#:configure-flags flags)
                    #~(append (list (string-append "--with-libxc-libs="
                                                   "-lxc"
                                                   " "
                                                   "-lxcf90"
                                                   " "
                                                   (string-append "-L"
                                                                  #$(this-package-input
                                                                     "libxc")
                                                                  "/lib"))
                                    (string-append "--with-libxc-incs="
                                                   (string-append "-I"
                                                                  #$(this-package-input
                                                                     "libxc")
                                                                  "/include")))
                              #$flags))))
      (synopsis "Subsection of files coming from ABINIT software package")
      (description
       "Subsection of files coming from ABINIT software package,
to which BigDFT has been coupled since the early days. It handles different parts like
symmetries, ewald corrections, PAW routines, density and potential mixing routines and some
MD minimizers."))))

(define-public bigdft-liborbs
  (let* ((base (make-bigdft "liborbs")))
    (package/inherit base
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-atlab)))
      ;; FIXME: $out/bin/f_unit_test_driver.py: No such file or directory
      ;; Perhaps it tries to run the tests before installing the test driver
      (arguments (append `(#:tests? #f)
                         (package-arguments base)))
      (synopsis "Library for orbital treatments in DFT")
      (description "Library for orbital treatments in DFT."))))

(define-public gain
  (package
    (name "gain")
    (version "1.0")
    (source
     (origin
       (uri (string-append "https://gitlab.com/l_sim/bigdft-suite/-/raw/"
                           bigdft-version "/tarballs/GaIn-" version ".tar.gz"))
       (method url-fetch)
       (sha256
        (base32 "0x1irgjmhsvfibhzc0bqcj5mxq2invfwsa9w7qb9593jacmqih5s"))))
    (build-system gnu-build-system)
    (native-inputs (list gfortran))
    (arguments
     `(#:make-flags (list "FCFLAGS=-fPIC")))
    (synopsis "GaIn - a simple Gaussian Integral library")
    (description
     "Library is intended to provide routines with a relatively simple interface for
calculation of overlap, kinetic and 2,3 and 4 center Coulomb integrals over either
Solid or Cubic Harmonics Gaussian basis sets.")
    (home-page bigdft-home-page)
    (license license:lgpl3+)))

(define-public bigdft-core
  (let* ((base (make-bigdft "bigdft")))
    (package/inherit base
      (name "bigdft-core")
      (native-inputs (modify-inputs (package-native-inputs base)
                       (prepend openssh)))
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile
                         bigdft-chess
                         bigdft-psolver
                         bigdft-libabinit
                         bigdft-liborbs
                         bigdft-atlab
                         libxc
                         gain
                         ntpoly)))
      (arguments (substitute-keyword-arguments (package-arguments base)
                    ((#:phases phases)
                     `(modify-phases ,phases
                        (add-after 'chdir 'fix-shebang
                          (lambda* _
                            (patch-shebang "config/m4/git-version-gen")))))
                    ;; TODO: Some tests fail with numerical precision errors
                    ;; They take +1h to run
                    ((#:tests? _ #t)
                     #f)))
      (synopsis "BigDFT-core: the core components of BigDFT")
      (description "Core components of BigDFT, an electronic structure
calculation based on Daubechies wavelets."))))

(define-public bigdft-spred
  (let* ((base (make-bigdft "spred")))
    (package/inherit base
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-psolver bigdft-core bigdft-atlab
                         bigdft-libabinit)))
      (arguments (append (package-arguments base)
                         '(#:tests? #f)))
      (synopsis
       "Library for structure prediction tools, that is compiled on top of BigDFT routines")
      (description
       "Library for structure prediction tools, that is compiled on top of BigDFT routines."))))

(define-public python-pybigdft
  (package
    (name "python-pybigdft")
    (version bigdft-version)
    (source
     bigdft-source)
    (build-system pyproject-build-system)
    (native-inputs (list python-hatchling))
    (propagated-inputs (list python-numpy python-scipy python-pyyaml
                             bigdft-futile))
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-after 'unpack 'chdir
                    (lambda* _
                      (chdir "PyBigDFT")))
                  (add-after 'chdir 'rm-setup-py
                    (lambda* _
                      (delete-file "setup.py")))
                  ;; TODO: pyfutile from bigdft-futile doesn't build
                  ;; a proper .dist-info
                  (delete 'sanity-check))
       #:tests? #f))
    (synopsis
     "Python interface of BigDFT for electronic structure calculation based on Daubechies wavelets")
    (description
     "Python interface of BigDFT for electronic structure calculation based on Daubechies wavelets.")
    (home-page bigdft-home-page)
    (license license:gpl2)))

(define-public bigdft-suite
  (package
    (name "bigdft-suite")
    (version bigdft-version)
    (source
     #f)
    (build-system trivial-build-system)
    (arguments
     `(#:builder (mkdir (assoc-ref %outputs "out"))))
    (propagated-inputs (list bigdft-futile
                             bigdft-psolver
                             bigdft-libabinit
                             bigdft-chess
                             bigdft-core
                             bigdft-spred
                             bigdft-atlab
                             python-pybigdft))
    (synopsis
     "Complete suite of BigDFT for electronic structure calculation based on Daubechies wavelets")
    (description
     "Complete suite of BigDFT for electronic structure calculation based on Daubechies wavelets. ")
    (home-page bigdft-home-page)
    (license license:gpl2)))
