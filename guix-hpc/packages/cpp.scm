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
  #:use-module (gnu packages cpp)
  #:use-module (amd packages rocm-hip)
  #:use-module (amd packages rocm-libs))

(define-public kokkos-openmp
  (package/inherit kokkos
    (name "kokkos-openmp")
    (arguments (substitute-keyword-arguments (package-arguments kokkos)
                 ((#:configure-flags flags)
                  #~(append (list "-DKokkos_ENABLE_OPENMP=ON")
                            #$flags))
                 ((#:phases phases
                   '%standard-phases)
                  #~(modify-phases #$phases
                      ;; File is not present in CUDA build
                      (delete 'remove-cruft)))))
    (synopsis
     "C++ abstractions for parallel execution and data management (with
OpenMP support)")))

(define-public kokkos-threads
  (package/inherit kokkos
    (name "kokkos-threads")
    (arguments (substitute-keyword-arguments (package-arguments kokkos)
                 ((#:configure-flags flags)
                  #~(append (list "-DKokkos_ENABLE_THREADS=ON")
                            #$flags))
                 ((#:phases phases
                   '%standard-phases)
                  #~(modify-phases #$phases
                      ;; File is not present in build
                      (delete 'remove-cruft)))))
    (synopsis
     "C++ abstractions for parallel execution and data management (with
threads support)")))

(define-public kokkos-hip
  (package/inherit kokkos
    (name "kokkos-hip")
    (arguments (substitute-keyword-arguments (package-arguments kokkos)
                 ((#:configure-flags flags)
                  #~(list "-DKokkos_ENABLE_SERIAL=ON"
                          ;; Shared libs are not compatible with relocatable code.
                          "-DBUILD_SHARED_LIBS=OFF"
                          "-DKokkos_ENABLE_TESTS=OFF" ;See below.
                          ;; Some examples don't compile with HIPCC.
                          "-DKokkos_ENABLE_EXAMPLES=OFF"
                          "-DKokkos_ENABLE_HWLOC=ON"
                          "-DKokkos_ENABLE_MEMKIND=ON"
                          "-DKokkos_ENABLE_HIP=ON"
                          "-DKokkos_ARCH_VEGA90A=ON"
                          "-DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=ON"
                          (string-append "-DCMAKE_CXX_COMPILER="
                                         #$(this-package-input "hipamd")
                                         "/bin/hipcc")))
                 ;; Cannot run tests due to lack of specific hardware
                 ((#:tests? _ #t)
                  #f)
                 ((#:phases phases
                   '%standard-phases)
                  #~(modify-phases #$phases
                      ;; File is not present in build
                      (delete 'remove-cruft)))))
    (inputs (modify-inputs (package-inputs kokkos)
              (prepend hipamd)
              (append rocthrust)
              (append rocprim)))
    (synopsis
     "C++ abstractions for parallel execution and data management (with HIP
support)")))

(define-public napp
  (package
    (name "napp")
    (version "0.3.0")
    (source
     (origin
       (method git-fetch)
       (file-name (git-file-name name version))
       (uri (git-reference
             (url "https://github.com/vincentchabannes/napp")
             (commit (string-append "v" version))))
       (sha256
        (base32 "0xbgsi3zvx1jcdix28nzi455j05yc6lrcy1cx9gr6375v4n768ps"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DNAPP_ENABLE_TESTS=OFF"
                                "-DNAPP_ENABLE_EXAMPLES=OFF"
                                "-DNAPP_ENABLE_DOC=OFF")
      #:tests? #f))
    (synopsis "C++ argument parser")
    (description "NAPP is an C++ library for parsing named command line arguments.")
    (home-page "https://github.com/vincentchabannes/napp")
    (license license:expat)))

(define-public tabulate
  (package
    (name "tabulate")
    (version "1.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/p-ranav/tabulate")
             (commit (string-append "v" version))))
       (sha256
        (base32 "0cddjkc8gjsiadwr8myn68f75iaq194kbncrqx57qz366hvyr1q3"))))
    (build-system cmake-build-system)
    (arguments
      (list
        #:tests? #f))
    (synopsis "Header only Table Maker for Modern C++")
    (description "Header only Table Maker for Modern C++")
    (home-page "https://github.com/p-ranav/tabulate")
    (license license:expat)))
