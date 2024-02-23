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
  #:use-module (amd rocm-tools)
  #:use-module (amd python-cppheaderparser)

  #:use-module (gnu packages mpi)

  #:use-module (gnu packages fabric-management))

; rocprim
(define %rocprim-hashes
  `(("5.7.1" . ,(base32 "0rawbvyilzb1swj03f03h56i0gs52cg9kbcyz591ipdgqmd0bsgs"))
    ("5.6.1" . ,(base32 "1dms8wm2b4f6h0jwmd76sibmb34g4fh1vdfqs178ncndsmcddgs0"))
    ("5.5.1" . ,(base32 "0dwkshxkbbx4v48mppmkfp4d0gj0y3j9dlgn9f24pq8pqmwc8zld"))
    ("5.4.4" . ,(base32 "1p1q95sw1d66kkh8s3m7nar68x91g147a6mxa85bp5i7pffp5j0s"))
    ("5.3.3" . ,(base32 "0m97rlay6q56gxnn17h79830rp96smvncd6sll8w1cpj8ccfxx4d"))))

(define (rocprim-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/ROCmSoftwarePlatform/rocPRIM.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "rocprim" version))
    (sha256 (assoc-ref %rocprim-hashes version))))

(define (make-rocprim rocm-cmake hipamd)
  (package
    (name "rocprim")
    (version (package-version hipamd))
    (source
     (rocprim-origin version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f ;No tests.
      #:configure-flags #~(list (string-append "-DCMAKE_CXX_COMPILER="
                                               #$(this-package-input "hipamd")
                                               "/bin/hipcc"))))
    (inputs (list hipamd))
    (native-inputs (list rocm-cmake python-wrapper))
    (synopsis
     "rocPRIM: a header-only library providing HIP parallel primitives")
    (description
     "The rocPRIM is a header-only library providing HIP parallel primitives 
for developing performant GPU-accelerated code on the AMD ROCm platform.")
    (home-page "https://github.com/ROCmSoftwarePlatform/rocPRIM.git")
    (license expat)))

(define-public rocprim-5.7
  (make-rocprim rocm-cmake-5.7 hipamd-5.7))
(define-public rocprim-5.6
  (make-rocprim rocm-cmake-5.6 hipamd-5.6))
(define-public rocprim-5.5
  (make-rocprim rocm-cmake-5.5 hipamd-5.5))
(define-public rocprim-5.4
  (make-rocprim rocm-cmake-5.4 hipamd-5.4))
(define-public rocprim-5.3
  (make-rocprim rocm-cmake-5.3 hipamd-5.3))

; libfabric built with rocm
(define (make-ofi-rocm rocr-runtime)
  (package
    (inherit libfabric)
    (name "libfabric")
    (version (string-append "1.20.x-rocm-"
                            (package-version rocr-runtime)))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ofiwg/libfabric")
             (commit "3a3f35fc6")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "01bkmh57gjgzamybm143zhvylcsvf6dbb7bai19bi0qzzfyp6hnr"))))
    (arguments
     (list
      #:configure-flags #~(list (string-append "--with-rocr="
                                               #$rocr-runtime))))
    (native-inputs (list autoconf automake libtool))
    (inputs (modify-inputs (package-inputs libfabric)
              (append rocr-runtime)))))

(define-public ofi-rocm-5.7
  (make-ofi-rocm rocr-runtime-5.7))
(define-public ofi-rocm-5.6
  (make-ofi-rocm rocr-runtime-5.6))
(define-public ofi-rocm-5.5
  (make-ofi-rocm rocr-runtime-5.5))
(define-public ofi-rocm-5.4
  (make-ofi-rocm rocr-runtime-5.4))
(define-public ofi-rocm-5.3
  (make-ofi-rocm rocr-runtime-5.3))

; ucx built with rocm
(define (make-ucx-rocm roct-thunk rocr-runtime hipamd)
  (package
    (inherit ucx)
    (name "ucx")
    (version (string-append "1.14.1-rocm-"
                            (package-version hipamd)))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/openucx/ucx")
             (commit "v1.14.1")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0jij2qzy655f1k3slj05lr679zflavj9f3g9bzlnxbqv524a0250"))))
    (arguments
     (list
      #:configure-flags #~(list
                           ;; XXX: Disable optimizations specific to the build
                           ;; machine (AVX, etc.)  There's apparently no way to
                           ;; have them picked up at load time.
                           "--disable-optimizations"

                           ;; "--enable-mt"
                           "--disable-logging"
                           "--disable-debug"
                           "--disable-assertions"
                           "--disable-params-check"
                           "--without-cuda"
                           "--without-knem"
                           "--without-java"
                           (string-append "--with-rocm="
                                          #$(this-package-input "rocr-runtime"))
                           (string-append "--with-hip="
                                          #$(this-package-input "hipamd")))
      #:make-flags #~(list "V=1")))
    (native-inputs (list autoconf automake libtool pkg-config roct-thunk))
    (inputs (list numactl hipamd rocr-runtime))
    (properties `((tunable? . #t) ,@(package-properties ucx)))))

(define-public ucx-rocm-5.7
  (make-ucx-rocm roct-thunk-5.7 rocr-runtime-5.7 hipamd-5.7))
(define-public ucx-rocm-5.6
  (make-ucx-rocm roct-thunk-5.6 rocr-runtime-5.6 hipamd-5.6))
(define-public ucx-rocm-5.5
  (make-ucx-rocm roct-thunk-5.5 rocr-runtime-5.5 hipamd-5.5))
(define-public ucx-rocm-5.4
  (make-ucx-rocm roct-thunk-5.4 rocr-runtime-5.4 hipamd-5.4))
(define-public ucx-rocm-5.3
  (make-ucx-rocm roct-thunk-5.3 rocr-runtime-5.3 hipamd-5.3))

; openmpi built with ucx-rocm and libfabric-rocm
(define (make-openmpi-rocm ucx ofi hipamd)
  (package
    (inherit openmpi)
    (version (string-append "5.0.2-rocm-"
                            (package-version hipamd)))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.2.tar.bz2")
       (sha256
        (base32 "13v9jqrqnr0ir3fv7hqb18rqrwybfzwbyq11fxqgzhz2xs7asipf"))))
    (arguments
     (list
      #:configure-flags #~(list
                           ;; "--enable-mca-no-build=btl-uct"
                           ;; "--enable-mpi1-compatibility"
                           "--with-pmix=internal"
                           (string-append "--with-rocm="
                                          #$(this-package-input "hipamd"))
                           (string-append "--with-ucx="
                                          #$(this-package-input "ucx"))
                           (string-append "--with-ofi="
                                          #$(this-package-input "libfabric")))
      #:phases #~(modify-phases %standard-phases
                   ;; opensm is needed for InfiniBand support.
                   (add-after 'unpack 'find-opensm-headers
                     (lambda* (#:key inputs #:allow-other-keys)
                       (setenv "C_INCLUDE_PATH"
                               (search-input-directory inputs
                                                       "/include/infiniband"))
                       (setenv "CPLUS_INCLUDE_PATH"
                               (search-input-directory inputs
                                                       "/include/infiniband")))))))
    (native-inputs (list perl python-wrapper pkg-config))
    (inputs (list hwloc-2
                  libevent
                  opensm
                  rdma-core
                  gfortran
                  ucx
                  ofi
                  hipamd))))

(define-public openmpi-rocm-5.7
  (make-openmpi-rocm ucx-rocm-5.7 ofi-rocm-5.7 hipamd-5.7))
(define-public openmpi-rocm-5.6
  (make-openmpi-rocm ucx-rocm-5.6 ofi-rocm-5.6 hipamd-5.6))
(define-public openmpi-rocm-5.5
  (make-openmpi-rocm ucx-rocm-5.5 ofi-rocm-5.5 hipamd-5.5))
(define-public openmpi-rocm-5.4
  (make-openmpi-rocm ucx-rocm-5.4 ofi-rocm-5.4 hipamd-5.4))
(define-public openmpi-rocm-5.3
  (make-openmpi-rocm ucx-rocm-5.3 ofi-rocm-5.3 hipamd-5.3))

; roctracer
(define %roctracer-hashes
  `(("5.7.1" . ,(base32 "11bd53vylassbg0xcpa9hncvwrv0xcb04z51b12h2iyc1341i91z"))
    ("5.6.1" . ,(base32 "1hsgmgil0k675y5arnhm1338r9b3ikiivfxifghwlisqjw3zy51g"))
    ("5.5.1" . ,(base32 "0gvfawcnc5hr8cxg9c443hqzmjz88rdc9iins2lh5j2gdw8macfw"))
    ("5.4.4" . ,(base32 "1dpc2jmsq2mcilz63fr4vxg99hhzpxdspqavhsg1v57jrhsi9xp6"))
    ("5.3.3" . ,(base32 "0i0qy3mlq0yynrw0s3jh1x9wlpwimjjcn9xavrixf5l00xkljr18"))))

(define (roctracer-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/ROCm-Developer-Tools/roctracer.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "roctracer" version))
    (sha256 (assoc-ref %roctracer-hashes version))))

(define (make-roctracer hipamd)
  (package
    (name "roctracer")
    (version (package-version hipamd))
    (source
     (roctracer-origin version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f ;No tests.
      #:build-type "Release"
      #:configure-flags #~(list (string-append "-DROCM_PATH="
                                               #$hipamd)
                                #$(if (version>=? version "5.5.0") ""
                                      "-DCMAKE_CXX_COMPILER=g++"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'update-filesystem
                     ;; only needed from 5.5 onwards
                     (lambda _
                       (substitute* (append (find-files "." ".cpp$")
                                            (find-files "." ".h$"))
                         (("std::experimental::filesystem")
                          "std::filesystem")
                         (("<experimental/filesystem>")
                          "<filesystem>")))))))
    (inputs (list numactl hipamd python python-cppheaderparser))
    (synopsis "A callback/activity library for performance tracing AMD GPUs.")
    (description "ROCm tracer provides an API to provide functionality for registering
the runtimes API callbacks and asynchronous activity records pool support.")
    (home-page "https://github.com/ROCm-Developer-Tools/roctracer.git")
    (license #f)))

(define-public roctracer-5.7
  (make-roctracer hipamd-5.7))
(define-public roctracer-5.6
  (make-roctracer hipamd-5.6))
(define-public roctracer-5.5
  (make-roctracer hipamd-5.5))
(define-public roctracer-5.4
  (make-roctracer hipamd-5.4))
(define-public roctracer-5.3
  (make-roctracer hipamd-5.3))

; rocblas
(define %rocblas-hashes
  `(("5.7.1" . ,(base32 "1ffwdyn5f237ad2m4k8b2ah15s0g2jfd6hm9qsywnsrby31af0nz"))
    ("5.6.1" . ,(base32 "1vi927lzym8q063xllqlbay8v0yaqy5wvf687gdvc62vp2i22x73"))
    ("5.5.1" . ,(base32 "1x1mp8fb05qrfd5sh6hyas2rfzr462xl9hixrhryi7ph8pi8r2aq"))
    ("5.4.4" . ,(base32 "08qy5rrj6jwwqi1vnn3km92c0hl3pnc9aymifpack27g2p62j5jy"))
    ("5.3.3" . ,(base32 "16iq2rjc4pljdycvflc55p8zc8jvs69mhh98cs4cgf5cbz21d3fg"))))

(define %rocblas-patches
  '(("5.7.1")
    ("5.6.1" "amd/patches/rocblas-5.6.1.patch")
    ("5.5.1" "amd/patches/rocblas-5.5.1.patch")
    ("5.4.4" "amd/patches/rocblas-5.4.4.patch")
    ("5.3.3" "amd/patches/rocblas-5.3.3.patch")))

(define (rocblas-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/ROCmSoftwarePlatform/rocBLAS.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "rocblas" version))
    (sha256 (assoc-ref %rocblas-hashes version))
    (patches (map search-patch
                  (assoc-ref %rocblas-patches version)))))

(define (make-rocblas tensile rocm-cmake hipamd)
  (package
    (name "rocblas")
    (version (package-version hipamd))
    (source
     (rocblas-origin version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f
      #:validate-runpath? #f
      #:configure-flags #~(list (string-append "-DCMAKE_CXX_COMPILER="
                                               #$hipamd "/bin/hipcc")
                                (string-append "-DTensile_CPU_THREADS="
                                               (number->string (parallel-job-count)))
                                "-DBUILD_WITH_PIP=OFF"
                                (if (string=? #$version "5.3.3")
                                 "-DCMAKE_TOOLCHAIN_FILE=toolchain-linux.cmake"
                                 "") "-DAMDGPU_TARGETS=gfx1030;gfx90a")
      #:phases #~(modify-phases %standard-phases
                   (add-after 'set-paths 'adjust-CPLUS_INCLUDE_PATH
                     ;; only needed for version<=5.4
                     (lambda* (#:key inputs #:allow-other-keys)
                       (define cplus-include-path
                         ;; Delete glibc/include and gcc/include/c++ from CPLUS_INCLUDE_PATH
                         ;; to allow clang to include the cuda_wrappers first.
                         (delete (string-append (assoc-ref inputs "libc")
                                                "/include")
                                 (delete (string-append (assoc-ref inputs
                                                                   "gcc")
                                                        "/include/c++")
                                         (string-split (getenv
                                                        "CPLUS_INCLUDE_PATH")
                                                       #\:))))
                       (setenv "CPLUS_INCLUDE_PATH"
                               (string-join cplus-include-path ":")))))))
    (native-inputs (list python-wrapper tensile hipamd rocm-cmake))
    (synopsis "Next generation BLAS implementation for ROCm platform.")
    (description
     "rocBLAS is the ROCm Basic Linear Algebra Subprograms (BLAS) library.
rocBLAS is implemented in the HIP programming language and optimized for AMD GPUs.")
    (home-page "https://github.com/ROCmSoftwarePlatform/rocBLAS.git")
    (license #f)))

(define-public rocblas-5.7
  (make-rocblas tensile-5.7 rocm-cmake-5.7 hipamd-5.7))
(define-public rocblas-5.6
  (make-rocblas tensile-5.6 rocm-cmake-5.6 hipamd-5.6))
(define-public rocblas-5.5
  (make-rocblas tensile-5.5 rocm-cmake-5.5 hipamd-5.5))
(define-public rocblas-5.4
  (make-rocblas tensile-5.4 rocm-cmake-5.4 hipamd-5.4))
(define-public rocblas-5.3
  (make-rocblas tensile-5.3 rocm-cmake-5.3 hipamd-5.3))
