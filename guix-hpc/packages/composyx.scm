(define-module (guix-hpc packages composyx)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (inria solverstack)
  #:use-module (lrz librsb)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pretty-print)
  #:use-module (gnu packages python-science))

(define-public composyx
  (package
    (name "composyx")
    (version "1.0.1")
    (home-page "https://gitlab.inria.fr/composyx/composyx.git")
    (synopsis "Composable numerical solver")
    (description
     "Composyx is a linear algebra C++ library focused on composability. Its
purpose is to allow the user to express a large pannel of algorithms
using a high-level interface to range from laptop prototypes to many
node supercomputer parallel computations.")
    (license license:cecill-c)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))
             ;; We need the submodule in 'cmake_modules/morse_cmake'.
             (recursive? #t)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 "1bl26vj7wygi6wdf3hqfpbhlbfbjfcjkh2834zzj3gqn18m019wm"))))
    (arguments
     '(#:configure-flags '("-DCOMPOSYX_USE_EIGEN=OFF"
                           "-DCOMPOSYX_USE_FABULOUS=ON"
                           "-DCOMPOSYX_USE_PADDLE=ON"
                           "-DCOMPOSYX_USE_CHAMELEON=ON"
                           "-DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON")

       #:phases (modify-phases %standard-phases
                  ;; Allow tests with more MPI processes than available CPU cores,
                  ;; which is not allowed by default by OpenMPI
                  (add-before 'check 'prepare-test-environment
                    (lambda _
                      (setenv "OMPI_MCA_rmaps_base_oversubscribe" "1") #t))
                  ;; Some of the tests use StarPU, which expects $HOME
                  ;; to be writable.
                  (add-before 'check 'set-home
                    (lambda _
                      (setenv "HOME"
                              (getcwd)))))))

    (build-system cmake-build-system)
    (inputs (list blaspp
                  lapackpp
                  openblas
                  pastix
                  mumps-openmpi
                  arpack-ng
                  paddle
                  fabulous
                  chameleon+nompi))
    (propagated-inputs (list `(,hwloc "lib") openmpi))
    (native-inputs (list gfortran pkg-config openssh))
    (properties '((tunable? . #t)))))

(define-public composyx-header-only
  (package/inherit composyx
    (name "composyx-header-only")
    (arguments '(#:configure-flags '("-DCOMPOSYX_USE_PASTIX=OFF"
                                     "-DCOMPOSYX_USE_MUMPS=OFF"
                                     "-DCOMPOSYX_USE_ARPACK=OFF"
                                     "-DCOMPOSYX_USE_LAPACKPP=OFF"
                                     "-DCOMPOSYX_USE_TLAPACK=ON"
                                     "-DCOMPOSYX_DRIVERS=OFF"
                                     "-DCOMPOSYX_C_DRIVER=OFF"
                                     "-DCOMPOSYX_Fortran_DRIVER=OFF"
                                     "-DCOMPOSYX_COMPILE_EXAMPLES=OFF"
                                     "-DCOMPOSYX_COMPILE_TESTS=OFF"
                                     "-DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON")))
    ;; NB: no header-only tests at the moment
    (inputs '())
    (propagated-inputs '())
    (native-inputs (list gfortran))))

;; Only mpi, blaspp & lapackpp dependencies
(define-public composyx-minimal
  (package/inherit composyx
    (name "composyx-minimal")
    (arguments (substitute-keyword-arguments (package-arguments composyx)
                 ((#:configure-flags flags)
                  ''("-DCOMPOSYX_USE_PASTIX=OFF" "-DCOMPOSYX_USE_MUMPS=OFF"
                     "-DCOMPOSYX_USE_ARPACK=OFF"
                     "-DCOMPOSYX_DRIVERS=OFF"
                     "-DCOMPOSYX_C_DRIVER=OFF"
                     "-DCOMPOSYX_Fortran_DRIVER=OFF"
                     "-DCOMPOSYX_COMPILE_EXAMPLES=OFF"
                     "-DCOMPOSYX_COMPILE_TESTS=ON"))))
    (inputs (modify-inputs (package-inputs composyx)
              (delete "pastix" "mumps" "arpack" "paddle" "fabulous")))))

;; Minimal + pastix and arpack-ng dependencies
(define-public composyx-lite
  (package/inherit composyx
    (name "composyx-lite")
    (arguments (substitute-keyword-arguments (package-arguments composyx)
                 ((#:configure-flags flags)
                  ''("-DCOMPOSYX_USE_PASTIX=ON" "-DCOMPOSYX_USE_MUMPS=OFF"
                     "-DCOMPOSYX_USE_ARPACK=ON"
                     "-DCOMPOSYX_DRIVERS=OFF"
                     "-DCOMPOSYX_C_DRIVER=OFF"
                     "-DCOMPOSYX_Fortran_DRIVER=OFF"
                     "-DCOMPOSYX_COMPILE_EXAMPLES=OFF"
                     "-DCOMPOSYX_COMPILE_TESTS=ON"))))
    (inputs (modify-inputs (package-inputs composyx)
              (delete "mumps" "paddle" "fabulous")))))

;; composyx with librsb for sparse matrix operations
(define-public composyx-librsb
  (package/inherit composyx
    (name "composyx-librsb")
    (arguments (substitute-keyword-arguments (package-arguments composyx)
                 ((#:configure-flags flags)
                  ''("-DCOMPOSYX_USE_RSB=ON" "-DCOMPOSYX_USE_RSB_SPBLAS=ON"))))
    (inputs (modify-inputs (package-inputs composyx)
              (prepend librsb)))))
