(define-module (guix-hpc packages bigdft)
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
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages maths)
  #:use-module (guix-hpc packages ntpoly)
  #:use-module (gnu packages chemistry)
  #:use-module (gnu packages)
  #:use-module (gnu packages ssh)
  #:use-module (guix-hpc packages libxc)
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages python-build)
  #:use-module (guix build-system trivial))

(define suite-version
  "1.9.5")

(define suite-home-page
  "https://gitlab.com/l_sim/bigdft-suite")

(define-public suite-source
  (origin
    (method git-fetch)
    (uri (git-reference (url suite-home-page)
                        (commit suite-version)))
    (sha256 (base32 "1asc3xvjvw9bv17xzpn1lq6jxlm6i8jac2kc213h0j81fn1mkib0"))
    (patches (search-patches "guix-hpc/packages/patches/bigdft-futile.patch"))))

(define* (mk-bigdft subproject)
  (package
    (name (string-append "bigdft-" subproject))
    (version suite-version)
    (home-page suite-home-page)
    (synopsis "FIXME")
    (description "FIXME")
    (license license:gpl2)
    (source
     suite-source)
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
  (let* ((base (mk-bigdft "futile")))
    (package/inherit base
      (synopsis
       "BigDFT-futile: a library handling most common FORTRAN low-level operations")
      (description
       "BigDFT-futile: a library handling most common FORTRAN low-level operations,
like memory managment, profiling routines, I/O operations.
It also supports yaml output and parsing for fortran programs.
It also provides wrappers routines to MPI and linear algebra operations.
This library is intensively used in BigDFT packages."))))

(define-public bigdft-atlab
  (let* ((base (mk-bigdft "atlab")))
    (package/inherit base
      (synopsis "BigDFT-atlab: library for ATomic related operations")
      (description "BigDFT-atlab: library for ATomic related operations.")

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
                              #$flags)))))))

(define-public bigdft-chess
  (let* ((base (mk-bigdft "chess")))
    (package/inherit base
      (synopsis
       "BigDFT-CheSS: A module for performing Fermi Operator Expansions via Chebyshev Polynomials")
      (description
       "BigDFT-CheSS: A module for performing Fermi Operator Expansions via Chebyshev Polynomials.")

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
                                      #$flags))))))))

(define-public bigdft-psolver
  (let* ((base (mk-bigdft "psolver")))
    (package/inherit base
      (synopsis
       "BigDFT-Psolver: a flexible real-space Poisson Solver based on Interpolating Scaling Functions")
      (description
       "BigDFT-Psolver: a flexible real-space Poisson Solver based on Interpolating Scaling Functions. 
It constitutes a fundamental building block of BigDFT code, and it can also be used separately and 
linked to other codes.")

      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-atlab)))

      (native-inputs (modify-inputs (package-native-inputs base)
                       (prepend openssh))))))

(define-public bigdft-libabinit
  (let* ((base (mk-bigdft "libABINIT")))
    (package/inherit base
      (name "bigdft-libabinit")
      (synopsis
       "BigDFT-libABINIT: this is a subsection of files coming from ABINIT software package")
      (description
       "BigDFT-libABINIT: this is a subsection of files coming from ABINIT software package, 
to which BigDFT has been coupled since the early days. It handles different parts like 
symmetries, ewald corrections, PAW routines, density and potential mixing routines and some
MD minimizers.")
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
                              #$flags)))))))

(define-public bigdft-liborbs
  (let* ((base (mk-bigdft "liborbs")))
    (package/inherit base
      (synopsis "BigDFT-liborbs: a library for orbital treatments in DFT")
      (description "BigDFT-liborbs: a library for orbital treatments in DFT.")
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-atlab)))
      (arguments (append `(#:tests? #f)
                         (package-arguments base))))))

;; NOTE: GaIn is a standalone library, but bundled as part of BigDFT
(define-public bigdft-gain
  (package
    (name "bigdft-gain")
    (version "1.0")
    (source
     (origin
       (uri (string-append "https://gitlab.com/l_sim/bigdft-suite/-/raw/"
                           suite-version "/tarballs/GaIn-" version ".tar.gz"))
       (method url-fetch)
       (sha256
        (base32 "0x1irgjmhsvfibhzc0bqcj5mxq2invfwsa9w7qb9593jacmqih5s"))))
    (build-system gnu-build-system)
    (synopsis "GaIn - a simple Gaussin Integral library")
    (description
     "GaIn is intended to provide routines with a relatively simple interface for 
calculation of overlap, kinetic and 2,3 and 4 center Coulomb integrals over either 
Solid or Cubic Harmonics Gaussian basis sets. Bundled as part of BigDFT.")
    (home-page suite-home-page)
    (license license:gpl3)
    (native-inputs (list gfortran))
    (arguments
     `(#:make-flags (list "FCFLAGS=-fPIC")))))

(define-public bigdft-core
  (let* ((base (mk-bigdft "bigdft")))
    (package/inherit base
      (name "bigdft-core")
      (synopsis "BigDFT-core: the core components of BigDFT")
      (description
       "BigDFT-core: the core components of BigDFT, an electronic structure 
calculation based on Daubechies wavelets.")
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
                         bigdft-gain
                         ntpoly)))
      (arguments (append (substitute-keyword-arguments (package-arguments base)
                           ((#:phases phases)
                            `(modify-phases ,phases
                               (add-after 'chdir 'fix-shebang
                                 (lambda* _
                                   (patch-shebang "config/m4/git-version-gen"))))))
                         '(#:tests? #f))))))

(define-public bigdft-spred
  (let* ((base (mk-bigdft "spred")))
    (package/inherit base
      (synopsis
       "BigDFT-spred: a library for structure prediction tools, that is compiled on top of BigDFT routines")
      (description
       "BigDFT-spred: a library for structure prediction tools, that is compiled on top of BigDFT routines.")
      (inputs (modify-inputs (package-inputs base)
                (prepend bigdft-futile bigdft-psolver bigdft-core bigdft-atlab
                         bigdft-libabinit)))
      (arguments (append (package-arguments base)
                         '(#:tests? #f))))))

(define-public python-pybigdft
  (package
    (name "python-pybigdft")
    (version suite-version)
    (home-page suite-home-page)
    (synopsis
     "BigDFT: the python interface of BigDFT for electronic structure calculation based on Daubechies wavelets")
    (description
     "BigDFT: the python interface of BigDFT for electronic structure calculation based on Daubechies wavelets.")
    (license license:gpl2)
    (source
     suite-source)
    (build-system pyproject-build-system)
    (native-inputs (list python-hatchling))
    (propagated-inputs (list python-numpy bigdft-futile))
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-after 'unpack 'chdir
                    (lambda* _
                      (chdir "PyBigDFT"))))))))

(define-public bigdft-suite
  (package
    (name "bigdft-suite")
    (version suite-version)
    (home-page suite-home-page)
    (synopsis
     "BigDFT-suite: the complete suite of BigDFT for electronic structure calculation based on Daubechies wavelets")
    (description
     "BigDFT-suite: the complete suite of BigDFT for electronic structure calculation based on Daubechies wavelets. ")
    (license license:gpl2)
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
                             python-pybigdft))))
