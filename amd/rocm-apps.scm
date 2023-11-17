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

    #:use-module (gnu packages)
    #:use-module (gnu packages linux)
    #:use-module (gnu packages version-control)

    #:use-module (amd rocm-libs)
    #:use-module (amd rocm-hip)
)

(define-public hpcg
    (package
        (name "hpcg")
        (version "rocm-5.6")
        (source
            (origin
                (method git-fetch)
                (uri (git-reference
                            (url "https://github.com/ROCmSoftwarePlatform/rocHPCG.git")
                            (commit "c3fdac837c6a8359d75a9858783f68ef675ce98f")))
                (file-name (git-file-name name version))
                (sha256 (base32 "0fnivjkbk875jis97c5qaxn53a26wzaz6dccwfq20ch6g5fchrnd"))
                (patches (search-patches "amd/patches/hpcg-cmake.patch"))))
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
                    "-DCMAKE_CXX_FLAGS=--offload-arch=gfx1030,gfx90a"
                    (string-append "-DHIP_ROOT_DIR=" #$(this-package-native-input "hipamd"))
                    (string-append "-DROCM_PATH=" #$(this-package-native-input "hipamd"))
                    (string-append "-DCMAKE_CXX_COMPILER=" #$(this-package-native-input "hipamd") "/bin/hipcc"))))
        (native-inputs (list git hipamd-5.6 rocm-cmake-5.6))
        (inputs (list numactl rocprim-5.6))
        (propagated-inputs (list openmpi-rocm-5.6))
        (synopsis "This is rocHPCG")
        (description "Using Guix to deliver to you the latest and greatest rocHPCG")
        (home-page "https://github.com/ROCmSoftwarePlatform/rocHPCG.git")
        (license #f)))


(define-public babelstream-hip
    (package
        (name "babelstream-hip")
        (version "5.0")
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
                    (string-append "-DCMAKE_CXX_COMPILER=" #$(this-package-input "hipamd") "/bin/hipcc")
                    (string-append "-DCXX_EXTRA_FLAGS=--offload-arch=gfx1030,gfx908,gfx90a"))))
        (inputs (list hipamd-5.6))
        (synopsis "BabelStream: Stream benchmark for GPUs using HIP")
        (description "Measure memory transfer rates to/from global device memory on GPUs.
This benchmark is similar in spirit, and based on, John D McCalpin's STREAM benchmark for CPUs.
The version of BabelStream is built targeting AMD GPUs using HIP.")
        (home-page "https://github.com/UoB-HPC/BabelStream.git")
        (license #f))) ; Uses a custom permissive license based on John D. McCalpin’s original STREAM benchmark
