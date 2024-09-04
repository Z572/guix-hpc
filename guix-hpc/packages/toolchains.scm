;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages toolchains)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages gcc)
  #:use-module (guix build utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix))

(define-public gfortran-toolchain-13
  (package
    (inherit ((@@ (gnu packages commencement) make-gcc-toolchain)
              gfortran-13))
    (synopsis "Complete GCC tool chain for Fortran development")
    (description
     "This package provides a complete GCC tool chain for
Fortran development to be installed in user profiles.  This includes
gfortran, as well as libc (headers and binaries, plus debugging symbols
in the @code{debug} output), and binutils.")))
