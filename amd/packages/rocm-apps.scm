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

(define-module (amd packages rocm-apps)
  #:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix licenses)
  #:use-module (guix download)
  #:use-module (guix utils)

  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages version-control)

  #:use-module (amd packages rocm-libs)
  #:use-module (amd packages aocl-libs)
  #:use-module (amd packages rocm-hip)

  #:use-module (guix-hpc packages benchmark))

(define %hpcg-hashes
  `(
    ("6.2" . ,(base32 "1y63ypkblnhdrpf81lnn5643j7mdpk8fxpjj8ksc543qa2dg8r1s"))
    ("6.1" . ,(base32 "1y63ypkblnhdrpf81lnn5643j7mdpk8fxpjj8ksc543qa2dg8r1s"))
    ("6.0" . ,(base32 "1hd3wzxvs33a9cj9d26931rw0xh22vl3nr0715i9nmnriwwysig4"))
    ("5.7" . ,(base32 "1dz32xsiccpb7099jvp2hkbabqnmsdjfn0p0h1x2z745c7a6p2ac"))
    ("5.6" . ,(base32 "0fnivjkbk875jis97c5qaxn53a26wzaz6dccwfq20ch6g5fchrnd"))
    ("5.5" . ,(base32 "0fnivjkbk875jis97c5qaxn53a26wzaz6dccwfq20ch6g5fchrnd"))
    ("5.4" . ,(base32 "0fnivjkbk875jis97c5qaxn53a26wzaz6dccwfq20ch6g5fchrnd"))
    ("5.3" . ,(base32 "0fnivjkbk875jis97c5qaxn53a26wzaz6dccwfq20ch6g5fchrnd"))
  )
)

(define (hpcg-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference
      (url "https://github.com/ROCmSoftwarePlatform/rocHPCG.git")
      (commit (string-append "release/rocm-rel-" version))))
    (file-name (git-file-name "rochpcg" version))
    (sha256 (assoc-ref %hpcg-hashes version))
    (modules '((guix build utils)))
    (snippet
      ;; Build without '-march=native' so that the binaries can be used on
      ;; all the CPUs.
      #~(substitute* "src/CMakeLists.txt" (("[ ;]-march=native") "")))))

(define (make-hpcg hipamd rocm-cmake rocprim openmpi version)
  (package
    (name "hpcg")
    (version version)
    (source (hpcg-origin version))
    (build-system cmake-build-system)
    (arguments
      (list
        #:tests? #f ; No tests.
        #:configure-flags
        #~(list
            "-DGPU_AWARE_MPI=ON"
            "-DHPCG_OPENMP=ON"
            "-DOPT_MEMMGMT=ON"
            "-DOPT_DEFRAG=ON"
            "-DOPT_ROCTX=OFF"
            "-DCMAKE_CXX_FLAGS=-fPIC"
            (string-append "-DROCM_PATH=" #$hipamd))))
    (native-inputs (list git hipamd rocm-cmake))
    (inputs (list numactl rocprim))
    (propagated-inputs (list openmpi))
    (synopsis "ROCm version of the synthetic HPCG benchmark")
    (description
     "rocHPCG is implemented on top of ROCm runtime and toolchains using the HIP programming language, and optimized for AMD's discrete GPUs.")
    (home-page "https://github.com/ROCmSoftwarePlatform/rocHPCG.git")
    (license bsd-3)))

(define-public hpcg-rocm-6.2
  (make-hpcg hipamd-6.2
             rocm-cmake-6.2
             rocprim-6.2
             openmpi-rocm-6.2
             "6.2"))
(define-public hpcg-rocm-6.1
  (make-hpcg hipamd-6.1
             rocm-cmake-6.1
             rocprim-6.1
             openmpi-rocm-6.1
             "6.1"))
(define-public hpcg-rocm-6.0
  (make-hpcg hipamd-6.0
             rocm-cmake-6.0
             rocprim-6.0
             openmpi-rocm-6.0
             "6.0"))
(define-public hpcg-rocm-5.7
  (make-hpcg hipamd-5.7
             rocm-cmake-5.7
             rocprim-5.7
             openmpi-rocm-5.7
             "5.7"))
(define-public hpcg-rocm-5.6
  (make-hpcg hipamd-5.6
             rocm-cmake-5.6
             rocprim-5.6
             openmpi-rocm-5.6
             "5.6"))
(define-public hpcg-rocm-5.5
  (make-hpcg hipamd-5.5
             rocm-cmake-5.5
             rocprim-5.5
             openmpi-rocm-5.5
             "5.5"))
(define-public hpcg-rocm-5.4
  (make-hpcg hipamd-5.4
             rocm-cmake-5.4
             rocprim-5.4
             openmpi-rocm-5.4
             "5.4"))
(define-public hpcg-rocm-5.3
  (make-hpcg hipamd-5.3
             rocm-cmake-5.3
             rocprim-5.3
             openmpi-rocm-5.3
             "5.3"))

(define (make-hpcg-sans-mpi hpcg)
  (package/inherit hpcg
    (name "hpcg-sans-mpi")
    (propagated-inputs
      (modify-inputs (package-propagated-inputs hpcg)
      (delete "openmpi")))
    (synopsis
      "ROCm version of the synthetic HPCG benchmark (without MPI support)")))

(define-public hpcg-rocm-sans-mpi-6.2
  (make-hpcg-sans-mpi hpcg-rocm-6.2))
(define-public hpcg-rocm-sans-mpi-6.1
  (make-hpcg-sans-mpi hpcg-rocm-6.1))
(define-public hpcg-rocm-sans-mpi-6.0
  (make-hpcg-sans-mpi hpcg-rocm-6.0))
(define-public hpcg-rocm-sans-mpi-5.7
  (make-hpcg-sans-mpi hpcg-rocm-5.7))

(define (make-babelstream hipamd)
  (package
    (name "babelstream-hip")
    (version (string-append "5.0-rocm-" (package-version hipamd)))
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
          (url "https://github.com/UoB-HPC/BabelStream.git")
          (commit "v5.0")))
        (file-name (git-file-name name version))
        (sha256 (base32 "0xkkxkmyi99qly427gkdijm9vwvmhwkgfm283ay6f83r66f712g4"))))
    (build-system cmake-build-system)
    (arguments
      (list
        #:build-type "Release"
        #:tests? #f ; No tests.
        #:substitutable? #f
        #:configure-flags
        #~(list
            (string-append "-DMODEL=hip")
            (string-append "-DCMAKE_CXX_COMPILER=" #$hipamd "/bin/hipcc")
            (string-append "-DCXX_EXTRA_FLAGS=--offload-arch=gfx1030,gfx908,gfx90a"))))
    (inputs (list hipamd))
    (properties `((tunable? . #t)))
    (synopsis "BabelStream: Stream benchmark for GPUs using HIP")
    (description
    "Measure memory transfer rates to/from global device memory on GPUs.
This benchmark is similar in spirit, and based on, John D McCalpin's STREAM benchmark for CPUs.
The version of BabelStream is built targeting AMD GPUs using HIP.")
    (home-page "https://github.com/UoB-HPC/BabelStream.git")
    (license
      (fsf-free "https://github.com/UoB-HPC/BabelStream/blob/main/LICENSE"
                "Custom permissive license based on John D. McCalpin's original STREAM benchmark."))))

(define-public babelstream-hip-6.2
  (make-babelstream hipamd-6.2))
(define-public babelstream-hip-6.1
  (make-babelstream hipamd-6.1))
(define-public babelstream-hip-6.0
  (make-babelstream hipamd-6.0))
(define-public babelstream-hip-5.7
  (make-babelstream hipamd-5.7))
(define-public babelstream-hip-5.6
  (make-babelstream hipamd-5.6))
(define-public babelstream-hip-5.5
  (make-babelstream hipamd-5.5))
(define-public babelstream-hip-5.4
  (make-babelstream hipamd-5.4))
(define-public babelstream-hip-5.3
  (make-babelstream hipamd-5.3))

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
       (patches (search-patches "amd/packages/patches/rochpl-6.0.0-cmake.patch"))))
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

(define-public rochpl-6.2
  (make-rochpl rocm-cmake-6.2
               hipamd-6.2
               openmpi-rocm-6.2
               rocblas-6.2
               aocl-blis
               roctracer-6.2))
(define-public rochpl-6.1
  (make-rochpl rocm-cmake-6.1
               hipamd-6.1
               openmpi-rocm-6.1
               rocblas-6.1
               aocl-blis
               roctracer-6.1))
(define-public rochpl-6.0
  (make-rochpl rocm-cmake-6.0
               hipamd-6.0
               openmpi-rocm-6.0
               rocblas-6.0
               aocl-blis
               roctracer-6.0))
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

; osu benchmarks
(define (make-osubench-rocm openmpi-rocm hipamd rccl)
  (package/inherit osu-micro-benchmarks
    (name (string-append (package-name osu-micro-benchmarks) "-rocm"))
    (version (string-append (package-version osu-micro-benchmarks) ".rocm"
                            (package-version hipamd)))

    (arguments
     (substitute-keyword-arguments (package-arguments osu-micro-benchmarks)
       ((#:configure-flags _)
        #~(list (string-append "CC="
                               #$openmpi-rocm
                               "/bin/mpicc")
                (string-append "CXX="
                               #$openmpi-rocm
                               "/bin/mpicxx")"--enable-rocm"
                               (string-append "--with-rocm="
                                              #$(this-package-input "hipamd"))
                               "--enable-rcclomb"
                               (string-append "--with-rccl="
                                              #$ (this-package-input "rccl"))))
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            (add-after 'unpack 'patch-configure
              (lambda _
                (substitute* (list "configure" "configure.ac")
                  (("__HIP_PLATFORM_HCC__")
                   "__HIP_PLATFORM_AMD__"))))))))
    ;; Needed due to modified configure.ac.
    (native-inputs (list automake autoconf))
    (inputs (modify-inputs (package-inputs osu-micro-benchmarks)
                           (append hipamd)
                           (append rccl)
                           (replace "openmpi" openmpi-rocm)))
    (synopsis "MPI microbenchmarks with ROCm support.")
    (description "A collection of host-based and device-based microbenchmarks for MPI
communication with ROCm support.")))

(define-public osubench-rocm-6.2
  (make-osubench-rocm openmpi-rocm-6.2 hipamd-6.2 rccl-6.2))
(define-public osubench-rocm-6.1
  (make-osubench-rocm openmpi-rocm-6.1 hipamd-6.1 rccl-6.1))
(define-public osubench-rocm-6.0
  (make-osubench-rocm openmpi-rocm-6.0 hipamd-6.0 rccl-6.0))
(define-public osubench-rocm-5.7
  (make-osubench-rocm openmpi-rocm-5.7 hipamd-5.7 rccl-5.7))
(define-public osubench-rocm-5.6
  (make-osubench-rocm openmpi-rocm-5.6 hipamd-5.6 rccl-5.6))
(define-public osubench-rocm-5.5
  (make-osubench-rocm openmpi-rocm-5.5 hipamd-5.5 rccl-5.5))
(define-public osubench-rocm-5.4
  (make-osubench-rocm openmpi-rocm-5.4 hipamd-5.4 rccl-5.4))
(define-public osubench-rocm-5.3
  (make-osubench-rocm openmpi-rocm-5.3 hipamd-5.3 rccl-5.3))
