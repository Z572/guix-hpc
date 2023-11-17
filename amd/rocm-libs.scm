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

(define-module (amd rocm-libs)
    #:use-module (guix packages)
    #:use-module (guix gexp)
    #:use-module (guix build-system cmake)
    #:use-module (guix build-system gnu)
    #:use-module (guix git-download)
    #:use-module (guix download)
    #:use-module (guix licenses)

    #:use-module (gnu packages)
    #:use-module (gnu packages python)
    #:use-module (gnu packages linux)
    #:use-module (gnu packages libevent)
    #:use-module (gnu packages gcc)
    #:use-module (gnu packages perl)
    #:use-module (gnu packages pkg-config)
    #:use-module (gnu packages autotools)

    #:use-module (amd rocm-base)
    #:use-module (amd rocm-hip)

    #:use-module (gnu packages mpi)

    #:use-module (gnu packages fabric-management)
)


; rocprim
(define %rocprim-hashes
    '(
        ("5.7.1" . "0rawbvyilzb1swj03f03h56i0gs52cg9kbcyz591ipdgqmd0bsgs")
        ("5.6.1" . "1dms8wm2b4f6h0jwmd76sibmb34g4fh1vdfqs178ncndsmcddgs0")
        ("5.5.1" . "0dwkshxkbbx4v48mppmkfp4d0gj0y3j9dlgn9f24pq8pqmwc8zld")
        ("5.4.4" . "1p1q95sw1d66kkh8s3m7nar68x91g147a6mxa85bp5i7pffp5j0s")
        ("5.3.3" . "0m97rlay6q56gxnn17h79830rp96smvncd6sll8w1cpj8ccfxx4d")
    )
)

(define (rocprim-origin version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/ROCmSoftwarePlatform/rocPRIM.git")
                (commit (string-append "rocm-" version))))
        (file-name (git-file-name "rocprim" version))
        (sha256 (base32 (assoc-ref %rocprim-hashes version)))))

(define (make-rocprim rocm-cmake hipamd)
    (package
        (name "rocprim")
        (version (package-version hipamd))
        (source (rocprim-origin version))
        (build-system cmake-build-system)
        (arguments
            (list
                #:build-type "Release"
                #:tests? #f ; No tests.
                #:configure-flags
                #~(list (string-append "-DCMAKE_CXX_COMPILER=" #$(this-package-input "hipamd") "/bin/hipcc"))))
        (inputs (list hipamd))
        (native-inputs (list rocm-cmake python-wrapper))
        (synopsis "rocPRIM: a header-only library providing HIP parallel primitives")
        (description "The rocPRIM is a header-only library providing HIP parallel primitives 
for developing performant GPU-accelerated code on the AMD ROCm platform.")
        (home-page "https://github.com/ROCmSoftwarePlatform/rocPRIM.git")
        (license expat)))

(define-public rocprim-5.7 (make-rocprim rocm-cmake-5.7 hipamd-5.7))
(define-public rocprim-5.6 (make-rocprim rocm-cmake-5.6 hipamd-5.6))
(define-public rocprim-5.5 (make-rocprim rocm-cmake-5.5 hipamd-5.5))
(define-public rocprim-5.4 (make-rocprim rocm-cmake-5.4 hipamd-5.4))
(define-public rocprim-5.3 (make-rocprim rocm-cmake-5.3 hipamd-5.3))


; ucx built with rocm
(define (make-ucx-rocm roct-thunk rocr-runtime hipamd)
  (package
    (name "ucx")
    (version (string-append "1.14.1-rocm-" (package-version hipamd)))
    (source
        (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/openucx/ucx")
                    (commit "v1.14.1")))
              (file-name (git-file-name name version))
              (sha256 (base32 "0jij2qzy655f1k3slj05lr679zflavj9f3g9bzlnxbqv524a0250")))
    )
    (build-system gnu-build-system)
    (arguments
        (list
            #:configure-flags
                #~(list
                    "--enable-optimizations"
;                    "--enable-mt"
                    "--disable-logging"
                    "--disable-debug"
                    "--disable-assertions"
                    "--disable-params-check"
                    "--without-cuda"
                    "--without-knem"
                    "--without-java"
                    (string-append "--with-rocm=" #$(this-package-input "rocr-runtime"))
                    (string-append "--with-hip="  #$(this-package-input "hipamd"))
                )
                #:make-flags
                #~(list "V=1")))
    (native-inputs (list autoconf automake libtool pkg-config roct-thunk))
    (inputs (list numactl hipamd rocr-runtime))
    (synopsis "Optimized communication layer for message passing in HPC")
    (description
     "Unified Communication X (UCX) provides an optimized communication layer
for message passing (MPI), portable global address space (PGAS) languages and
run-time support libraries, as well as RPC and data-centric applications.

UCX utilizes high-speed networks for inter-node communication, and shared
memory mechanisms for efficient intra-node communication.")
    (home-page "https://www.openucx.org/")
    (license bsd-3)
    (supported-systems '("x86_64-linux" "aarch64-linux")))
)

(define-public ucx-rocm-5.7 (make-ucx-rocm roct-thunk-5.7 rocr-runtime-5.7 hipamd-5.7))
(define-public ucx-rocm-5.6 (make-ucx-rocm roct-thunk-5.6 rocr-runtime-5.6 hipamd-5.6))
(define-public ucx-rocm-5.5 (make-ucx-rocm roct-thunk-5.5 rocr-runtime-5.5 hipamd-5.5))
(define-public ucx-rocm-5.4 (make-ucx-rocm roct-thunk-5.4 rocr-runtime-5.4 hipamd-5.4))
(define-public ucx-rocm-5.3 (make-ucx-rocm roct-thunk-5.3 rocr-runtime-5.3 hipamd-5.3))


; openmpi built with ucx-rocm
(define (make-openmpi-rocm ucx)
    (package
        (name "openmpi")
        (version (string-append "5.0.0-ucx-"(package-version ucx)))
        (source
            (origin
                (method url-fetch)
                (uri "https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.0.tar.bz2")
                (sha256 (base32 "04ynmkyxns0nxiwhyfzps1xfrxh8rlwd561xz12v9bn19flmr14x"))))
        (build-system gnu-build-system)
        (arguments
            (list
                #:configure-flags
                #~(list
                    ;"--enable-mca-no-build=btl-uct"
                    ;"--enable-mpi1-compatibility"
                    (string-append "--with-ucx=" #$(this-package-input "ucx")))
                #:phases
                #~(modify-phases %standard-phases
                    ;; opensm is needed for InfiniBand support.
                    (add-after 'unpack 'find-opensm-headers
                        (lambda* (#:key inputs #:allow-other-keys)
                            (setenv "C_INCLUDE_PATH" (search-input-directory inputs "/include/infiniband"))
                            (setenv "CPLUS_INCLUDE_PATH" (search-input-directory inputs "/include/infiniband")))))))
        (native-inputs (list perl python-wrapper pkg-config))
        (inputs (list hwloc-2 libfabric libevent opensm rdma-core gfortran ucx))
        (synopsis "synopsis")
        (description "description")
        (home-page "home-page")
        (license bsd-3)
    )
)

(define-public openmpi-rocm-5.7 (make-openmpi-rocm ucx-rocm-5.7))
(define-public openmpi-rocm-5.6 (make-openmpi-rocm ucx-rocm-5.6))
(define-public openmpi-rocm-5.5 (make-openmpi-rocm ucx-rocm-5.5))
(define-public openmpi-rocm-5.4 (make-openmpi-rocm ucx-rocm-5.4))
(define-public openmpi-rocm-5.3 (make-openmpi-rocm ucx-rocm-5.3))
