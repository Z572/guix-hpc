;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (inria hawen)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix packages)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (inria mpi)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (inria hiepacs)
  #:use-module (inria storm)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages ssh)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages mpi))

(define (make-hawen-with-cmake problem direction)
  (let ((commit "1511625e2baf0e19e84589de2949ad1ba73a46bb")
        (revision "0"))
    (package
      (name (string-append "hawen-int32" "-" problem "-" direction))
      (version (git-version "0.1" revision commit))
      (home-page "https://ffaucher.gitlab.io/hawen-website/")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://gitlab.com/ffaucher/hawen")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "00qy8x235hcjz44c3p1jygjhb8hvg86d7jvgjihji2xa96xgbps0"))))
      (build-system cmake-build-system)
      (arguments
       `(#:phases (modify-phases %standard-phases
                    (add-after 'build 'mpi-setup
                       ;Set the test environment for Open MPI.
                      ,%openmpi-setup))
         #:configure-flags (list (format #f "-DPROBLEM=~a"
                                         ,problem)
                                 (format #f "-DPROPAGATOR=helmholtz_~a-iso"
                                         ,direction) "-DIKIND_METIS=4"))) ;currently only int 32
      (native-inputs (list gfortran))
      (inputs (list mumps-openmpi
                    arpack-ng-openmpi
                    metis
                    lapack ;instead of openblas probleme with USE_OPENMP=1
                    scalapack
                    pt-scotch
                    openssh
                    scotch
                    openmpi
                    arb))
      (synopsis "Hawen")
      (description
       "Hawen stands for time-HArmonic Wave modEling and INversion using
Hybridizable Discontinuous Galerkin Discretization.  The code is written in
Fortran90, for forward and inverse time-harmonic wave problems.  It uses MPI
and OpenMP parallelism.")
      (license license:gpl3+))))

;; for now only supports the elastic case
;; need for more test case
(define-public hawen-elastic-inversion
  (make-hawen-with-cmake "inversion" "elastic"))
(define-public hawen-elastic-forward
  (make-hawen-with-cmake "forward" "elastic"))
