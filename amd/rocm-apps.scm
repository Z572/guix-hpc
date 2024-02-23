;;; Copyright © 2023 Advanced Micro Devices, Inc.
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

(define-module (amd rocm-apps)
  #:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix licenses)

  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages version-control)

  #:use-module (amd rocm-libs)
  #:use-module (amd aocl-libs)
  #:use-module (amd rocm-hip))

(define-public hpcg
  (package
    (name "hpcg")
    (version "rocm-5.7")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ROCmSoftwarePlatform/rocHPCG.git")
             (commit "release/rocm-rel-5.7")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1dz32xsiccpb7099jvp2hkbabqnmsdjfn0p0h1x2z745c7a6p2ac"))
       (modules '((guix build utils)))
       (snippet
        ;; Build without '-march=native' so that the binaries can be used on
        ;; all the CPUs.
        #~(substitute* "src/CMakeLists.txt"
            (("[ ;]-march=native")
             "")))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f ;Not tests provided.
      #:configure-flags #~(list "-DGPU_AWARE_MPI=ON"
                                "-DHPCG_OPENMP=ON"
                                "-DOPT_MEMMGMT=ON"
                                "-DOPT_DEFRAG=ON"
                                "-DOPT_ROCTX=OFF"
                                (string-append "-DHIP_ROOT_DIR="
                                               #$(this-package-native-input
                                                  "hipamd"))
                                (string-append "-DROCM_PATH="
                                               #$(this-package-native-input
                                                  "hipamd"))
                                (string-append "-DCMAKE_CXX_COMPILER="
                                               #$(this-package-native-input
                                                  "hipamd") "/bin/hipcc"))))
    (native-inputs (list git hipamd-5.7 rocm-cmake-5.7))
    (inputs (list numactl rocprim-5.7))
    (propagated-inputs (list openmpi-rocm-5.7))
    (properties '((tunable? . #t)))
    (synopsis "ROCm version of the synthetic HPCG benchmark")
    (description
     "rocHPCG is implemented on top of ROCm runtime and toolchains using the HIP programming language, and optimized for AMD's discrete GPUs.")
    (home-page "https://github.com/ROCmSoftwarePlatform/rocHPCG.git")
    (license bsd-3)))

(define-public hpcg-sans-mpi
  (package/inherit hpcg
    (name "hpcg-sans-mpi")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs hpcg)
       (delete "openmpi")))
    (synopsis
     "ROCm version of the synthetic HPCG benchmark (without MPI support)")))

(define-public babelstream-hip
  (package
    (name "babelstream-hip")
    (version "5.0")
    (home-page "https://github.com/UoB-HPC/BabelStream")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xkkxkmyi99qly427gkdijm9vwvmhwkgfm283ay6f83r66f712g4"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f ;No tests.
      #:configure-flags #~(list (string-append "-DMODEL=hip")
                                (string-append "-DCMAKE_CXX_COMPILER="
                                               #$(this-package-input "hipamd")
                                               "/bin/hipcc")
                                (string-append
                                 "-DCXX_EXTRA_FLAGS=--offload-arch=gfx1030,gfx908,gfx90a"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'remove-march=native
                     (lambda _
                       ;; Do not attempt to build with '-march=native'.
                       (substitute* "CMakeLists.txt"
                         (("-march=native") "")))))))
    (inputs (list hipamd-5.7))
    (properties `((tunable? . #t)))
    (synopsis "BabelStream: Stream benchmark for GPUs using HIP")
    (description
     "Measure memory transfer rates to/from global device memory on GPUs.
This benchmark is similar in spirit, and based on, John D McCalpin's STREAM benchmark for CPUs.
The version of BabelStream is built targeting AMD GPUs using HIP.")
    (license
     (fsf-free "https://github.com/UoB-HPC/BabelStream/blob/main/LICENSE"
               "Custom permissive license based on John D. McCalpin’s original STREAM
benchmark."))))

; rochpl
(define (make-rochpl rocm-cmake
                     hipamd
                     openmpi-rocm
                     rocblas
                     blis
                     roctracer)
  (package
    (name "rochpl")
    (version (package-version hipamd))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ROCmSoftwarePlatform/rocHPL.git")
             (commit "30d80ede0189b0aa594658c47ddc13dad1534d02")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1m7cvynkk785iyk1yldslqx3221h9vg035ddc5z4rr67w79j3a1m"))
       (patches (search-patches
                 "amd/packages/patches/rochpl-6.0.0-cmake.patch"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f ;No tests.
      #:configure-flags #~(list (string-append "-DROCM_PATH="
                                               #$hipamd)
                                (string-append "-DHPL_BLAS_DIR="
                                               #$aocl-blis "/lib")
                                (string-append "-DHPL_MPI_DIR="
                                               #$openmpi-rocm)
                                (string-append "-DROCTRACER_PATH="
                                               #$roctracer))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'rocblas-header-includes
                     (lambda _
                       (substitute* "include/hpl_blas.hpp"
                         (("<rocblas.h>")
                          "<rocblas/rocblas.h>")
                         (("<roctracer.h>")
                          "<roctracer/roctracer.h>")
                         (("<roctx.h>")
                          "<roctracer/roctx.h>")))))))
    (native-inputs (list rocm-cmake git))
    (inputs (list hipamd openmpi-rocm rocblas blis roctracer))
    (synopsis "HPL benchmark for ROCm")
    (description
     "rocHPL is a benchmark based on the HPL benchmark application, implemented on top of
AMD's Radeon Open Compute ROCm Platform, runtime, and toolchains. rocHPL is created using the HIP programming
language and optimized for AMD's latest discrete GPUs.")
    (home-page "https://github.com/ROCmSoftwarePlatform/rocHPL.git")
    (license (list bsd-4 bsd-3))))

(define-public rochpl-5.7
  (make-rochpl rocm-cmake-5.7
               hipamd-5.7
               openmpi-rocm-5.7
               rocblas-5.7
               aocl-blis
               roctracer-5.7))
(define-public rochpl-5.6
  (make-rochpl rocm-cmake-5.6
               hipamd-5.6
               openmpi-rocm-5.6
               rocblas-5.6
               aocl-blis
               roctracer-5.6))
(define-public rochpl-5.5
  (make-rochpl rocm-cmake-5.5
               hipamd-5.5
               openmpi-rocm-5.5
               rocblas-5.5
               aocl-blis
               roctracer-5.5))
(define-public rochpl-5.4
  (make-rochpl rocm-cmake-5.4
               hipamd-5.4
               openmpi-rocm-5.4
               rocblas-5.4
               aocl-blis
               roctracer-5.4))
(define-public rochpl-5.3
  (make-rochpl rocm-cmake-5.3
               hipamd-5.3
               openmpi-rocm-5.3
               rocblas-5.3
               aocl-blis
               roctracer-5.3))
