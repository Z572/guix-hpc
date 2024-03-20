;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages cpp)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix ui)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages cpp))

(define-public kokkos-openmp
  (package/inherit kokkos
    (name "kokkos-openmp")
    (arguments
     (substitute-keyword-arguments
         (package-arguments kokkos)
       ((#:configure-flags flags)
        #~(append (list "-DKokkos_ENABLE_OPENMP=ON")
                  #$flags))
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            ;; File is not present in CUDA build
            (delete 'remove-cruft)))))
    (synopsis "C++ abstractions for parallel execution and data management (with
OpenMP support)")))

(define-public kokkos-threads
  (package/inherit kokkos
    (name "kokkos-threads")
    (arguments
     (substitute-keyword-arguments
         (package-arguments kokkos)
       ((#:configure-flags flags)
        #~(append (list "-DKokkos_ENABLE_THREADS=ON")
                  #$flags))
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            ;; File is not present in build
            (delete 'remove-cruft)))))
    (synopsis "C++ abstractions for parallel execution and data management (with
threads support)")))
