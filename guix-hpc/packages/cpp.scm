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
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages benchmark)
  #:use-module (gnu packages check)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages serialization)
  #:use-module (guix-hpc packages pdi)
  #:use-module (guix-hpc packages utils)
  #:use-module (amd packages rocm-hip)
  #:use-module (amd packages rocm-libs))

(define-public mdspan
  (package
    (name "mdspan")
    (version "0.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kokkos/mdspan")
             (commit (string-append name "-" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "17zmjid1vjvpmvgd1k023ljk8yygqw18xilx78b7pxg7xws3w0bg"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DMDSPAN_ENABLE_TESTS=ON"
                                "-DMDSPAN_USE_SYSTEM_GTEST=ON")))
    (native-inputs (list googletest))
    (synopsis "Reference implementation of mdspan targeting C++23")
    (description
     "This package aims to provide a production-quality implementation of
the ISO-C++ proposal P0009, which will add support for non-owning
multi-dimensional array references to the C++ standard library.")
    (home-page "https://github.com/kokkos/mdspan")
    (license license:asl2.0)))

;; This should be at the same version as upstream Kokkos package.
(define-public kokkos-kernels
  (package
    (name "kokkos-kernels")
    (version "4.3.01")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kokkos/kokkos-kernels")
             (commit version)))
       (sha256
        (base32 "082yqvha5012zrgxz67kc4famn1alnxrka3mfi8ybfp98g23ppd0"))
       (file-name (git-file-name name version))))
    (build-system cmake-build-system)
    (inputs (list kokkos))
    (home-page "https://github.com/kokkos/kokkos-kernels")
    (synopsis "Kokkos C++ Performance Portability Programming Ecosystem: Math Kernels")
    (description "KokkosKernels implements local computational kernels for linear
algebra and graph operations, using the Kokkos shared-memory parallel
programming model.")
    (license license:bsd-2)))

(define-public ddc
  (let ((commit "e9e1435eae2d4a56243e167c49026035277418bb") ;; Commit from 12-09-2024.
        (version "0.0.1")
        (revision "1"))
    (package
      (name "ddc")
      (version (git-version version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/CExA-project/ddc")
               (commit commit)))
         (sha256
          (base32 "106lh7vshkrf9khlk42vslpk3fydplrwfmzisc8725y7jmklkrn3"))
         (file-name (git-file-name name version))))
      (build-system cmake-build-system)
      (inputs (list kokkos
                    kokkos-kernels
                    mdspan
                    fftw
                    fftwf
                    pdi
                    paraconf
                    libyaml
                    ginkgo
                    openblas))
      (native-inputs (list googletest
                           benchmark
                           pkg-config))
      (synopsis "Discrete domain computation library")
      (description "DDC is a C++-17 library that aims to offer to the C++/MPI world an
equivalent to the xarray.DataArray/dask.Array python environment.")
      (home-page "https://ddc.mdls.fr/")
      (license license:expat))))

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

(define-public kokkos-hip
  (package/inherit kokkos
    (name "kokkos-hip")
    (arguments
     (substitute-keyword-arguments
         (package-arguments kokkos)
       ((#:configure-flags flags)
        #~(list "-DKokkos_ENABLE_SERIAL=ON"
                ;; Shared libs are not compatible with relocatable code.
                "-DBUILD_SHARED_LIBS=OFF"
                "-DKokkos_ENABLE_TESTS=OFF" ; See below.
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
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            ;; File is not present in build
            (delete 'remove-cruft)))))
    (inputs
     (modify-inputs (package-inputs kokkos)
       (prepend hipamd-5.7)
       (append rocthrust-5.7)
       (append rocprim-5.7)))
    (synopsis "C++ abstractions for parallel execution and data management (with HIP
support)")))
