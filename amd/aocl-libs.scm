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

(define-module (amd aocl-libs)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
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
    (synopsis "Basic Linear Algebra Subprograms (BLAS) Libraries (without multi-threading support)")))
