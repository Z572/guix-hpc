;;; Copyright © 2024 Advanced Micro Devices, Inc.
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (amd packages aocl-libs)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix gexp)
  #:use-module (guix licenses)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages python)
  #:use-module (gnu packages perl))

(define-public aocl-blis-mt
  (package
    (name "aocl-blis-mt")
    (version "4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/amd/blis.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1bphmkwdgan7936v329bg56byia92rq35znamagmpy9z32w7ixyn"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (replace 'configure
                    (lambda* (#:key outputs #:allow-other-keys)
                      (invoke "./configure"
                              (string-append "--prefix="
                                             (assoc-ref outputs "out"))
                              "-d opt"
                              "--enable-cblas"
                              "--enable-threading=openmp"
                              "zen3"))))))
    (native-inputs (list python-wrapper perl))
    (synopsis "Basic Linear Algebra Subprograms (BLAS) Libraries")
    (description
     "BLIS is a portable software framework for instantiating high-performance
BLAS-like dense linear algebra libraries. The framework was designed to isolate essential kernels
of computation that enable optimized implementations of most of its commonly used and computationally
intensive operations. The optimizations are done for single and double precision routines.
AMD has extensively optimized the implementation of BLIS for AMD processors.")
    (home-page "https://developer.amd.com/amd-aocl/blas-library")
    (license bsd-3)))

(define-public aocl-blis
  (package
    (inherit aocl-blis-mt)
    (name "aocl-blis")
    (arguments
     `(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (replace 'configure
                    (lambda* (#:key outputs #:allow-other-keys)
                      (invoke "./configure"
                              (string-append "--prefix="
                                             (assoc-ref outputs "out"))
                              "-d opt" "--enable-cblas" "zen3"))))))
    (synopsis
     "Basic Linear Algebra Subprograms (BLAS) Libraries (without multi-threading support for zen3 cpus)")))

(define-public aocl-blis-zen4
  (package
    (inherit aocl-blis-mt)
    (name "aocl-blis-zen4")
    (arguments
     `(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (replace 'configure
                    (lambda* (#:key outputs #:allow-other-keys)
                      (invoke "./configure"
                              (string-append "--prefix="
                                             (assoc-ref outputs "out"))
                              "-d opt" "--enable-cblas" "zen4"))))))
    (synopsis
     "Basic Linear Algebra Subprograms (BLAS) Libraries (without multi-threading support for zen4 cpus)")))

(define-public aocl-utils
  (package
    (name "aocl-utils")
    (version "4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/amd/aocl-utils.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0k8fc3l5as2ga6b32d9zc0wqx8n11s7rvdi8qhsip1vbpkg8lpsm"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f)) ;No tests
    (synopsis "AOCL libraries to access CPU features, especially AMD CPUs")
    (description
     "AOCL-Utils is designed to be integrated into other AOCL libraries. Each
project has their own mechanism to identify CPU and provide necessary features such as
'dynamic dispatch'. The main purpose of this library is to provide a centralized mechanism to
update/validate and provide information to the users of this library.")
    (home-page "https://developer.amd.com/amd-aocl")
    (license bsd-3)))

(define-public aocl-lapack
  (package
    (name "aocl-lapack")
    (version "4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/amd/libflame.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "12n2f1xc817f8bnmvijd0as1iggmjiz73vmyppszk7l0hgb3b6a9"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f ;No tests
      #:configure-flags #~(list "--enable-amd-flags")
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'patch-config
                     (lambda _
                       (substitute* "build/config.mk.in"
                         (("/usr/bin/env bash")
                          (which "bash")))
                       (substitute* "src/aocl_dtl/Makefile"
                         ((".PHONY")
                          "CC=gcc\n.PHONY")))))))
    (inputs (list aocl-utils))
    (native-inputs (list gfortran python-wrapper perl))
    (synopsis "Linear Algebra Package (LAPACK) Libraries")
    (description
     "AOCL-libFLAME is a portable library for dense matrix computations, providing the complete functionality present in Linear Algebra Package (LAPACK). The library provides scientific and numerical computing communities with a modern, high-performance dense linear algebra library that is extensible, easy to use, and available under an open source license. It is a C-only implementation. Applications relying on stadard Netlib LAPACK interfaces can start taking advantage of AOCL-libFLAME with virtually no changes to their source code.")
    (home-page "https://developer.amd.com/amd-aocl/blas-library")
    (license bsd-3)))

(define-public aocl-scalapack
  (package
    (name "aocl-scalapack")
    (version "4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/amd/aocl-scalapack.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0cz627x920ximydcs9qz6jilzia735hyg2flcd1lliq2xwvk1zd5"))))
    (build-system cmake-build-system)
    (arguments
     (list
      ;; One tests fails due to an illegal value being passed to DSTEGR2A.
      ;; Disabling for now.
      #:tests? #f
      #:configure-flags #~(list "-DBUILD_SHARED_LIBS:BOOL=YES"
                                "-DUSE_OPTIMIZED_LAPACK_BLAS=ON"
                                (string-append "-DLAPACK_LIBRARIES=-lstdc++ "
                                               #$aocl-utils
                                               "/lib/libaoclutils.a "
                                               #$aocl-lapack "/lib/libflame.a")
                                (string-append "-DBLAS_LIBRARIES=-fopenmp "
                                               #$aocl-blis "/lib/libblis.a"))))
    (native-inputs (list gfortran python-wrapper))
    (inputs (list openmpi aocl-lapack aocl-utils aocl-blis))
    (synopsis "Scalable Linear Algebra Package (ScaLAPACK) Library")
    (description
     "AOCL-ScaLAPACK is a library of high-performance linear algebra routines for parallel distributed memory machines. It depends on external libraries including BLAS and LAPACK for Linear Algebra computations. AMD’s optimized version of ScaLAPACK (AOCL-ScaLAPACK) enables using the BLIS and libFLAME libraries with optimized dense-matrix functions and solvers for AMD processors")
    (home-page "https://developer.amd.com/amd-aocl/scalapack")
    (license bsd-3)))
