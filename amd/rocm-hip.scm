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

(define-module (amd rocm-hip)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module (guix licenses)

  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages python)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages version-control)

  #:use-module (amd python-cppheaderparser)
  #:use-module (amd rocm-tools)
  #:use-module (amd rocm-base))

(define %rocm-comgr-hashes
  `(("5.7.1" . ,(base32 "0p28jsbwjk19c4i6vwqkwgwpa4qkmqsgpyhhxsx3albnbz8wc7a0"))
    ("5.6.1" . ,(base32 "15s2dx0pdvjv3xfccq5prkplcbwps8x9jas5qk93q7kv8wx57p3b"))
    ("5.5.1" . ,(base32 "1xh09ljh3i28r3wwx44680jaq0dbyr9mmyad5ail4cmbnd4bwqjc"))
    ("5.4.4" . ,(base32 "02vcbw5da8pkn8rxvaw0jdjcd6w2y2883z0b47jrx8lj6w2jpfx8"))
    ("5.3.3" . ,(base32 "0s22jplls3sfgwp746qvbzyalhzcsgwz2xxdnzmcr6qnly38q31d"))))

(define (rocm-comgr-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "rocm-comgr" version))
    (sha256 (assoc-ref %rocm-comgr-hashes version))))

(define (make-rocm-comgr rocm-device-libs llvm-rocm lld-rocm clang-rocm)
  (package
    (name "rocm-comgr")
    (version (package-version rocm-device-libs))
    (source
     (rocm-comgr-origin version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'chdir
                     (lambda _
                       (chdir "lib/comgr"))))))
    (inputs (list rocm-device-libs))
    (native-inputs (list llvm-rocm lld-rocm clang-rocm))
    (synopsis "The ROCm Code Object Manager")
    (description
     "The Comgr library provides APIs for compiling and inspecting AMDGPU code objects.")
    (home-page "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport")
    (license ncsa)))

(define-public rocm-comgr-5.7
  (make-rocm-comgr rocm-device-libs-5.7 llvm-rocm-5.7 lld-rocm-5.7
                   clang-rocm-5.7))
(define-public rocm-comgr-5.6
  (make-rocm-comgr rocm-device-libs-5.6 llvm-rocm-5.6 lld-rocm-5.6
                   clang-rocm-5.6))
(define-public rocm-comgr-5.5
  (make-rocm-comgr rocm-device-libs-5.5 llvm-rocm-5.5 lld-rocm-5.5
                   clang-rocm-5.5))
(define-public rocm-comgr-5.4
  (make-rocm-comgr rocm-device-libs-5.4 llvm-rocm-5.4 lld-rocm-5.4
                   clang-rocm-5.4))
(define-public rocm-comgr-5.3
  (make-rocm-comgr rocm-device-libs-5.3 llvm-rocm-5.3 lld-rocm-5.3
                   clang-rocm-5.3))

; hipamd for versions 5.6 and above

; hip headers
(define %hip-hashes
  `(("5.7.1" . ,(base32 "0p7w17mv14xrn1dg98mss43haa1k5qz1bnn9ap10l2wrvavy41nl"))
    ("5.6.1" . ,(base32 "0vkx3ncjz80xdyi37f80lb2mma4ygqs5rvkvidqqfvamc96v75j1"))))

(define %hip-patches
  '(("5.7.1" . "amd/patches/hip-headers-5.6.1.patch")
    ("5.6.1" . "amd/patches/hip-headers-5.6.1.patch")))

(define (make-hip version)
  (hidden-package (package
                    (name "hip")
                    (version version)
                    (source
                     (origin
                       (method git-fetch)
                       (uri (git-reference
                             (url
                              "https://github.com/ROCm-Developer-Tools/HIP.git")
                             (commit (string-append "rocm-" version))))
                       (sha256
                        (assoc-ref %hip-hashes version))
                       (patches (search-patches (assoc-ref %hip-patches
                                                           version)))))
                    (build-system copy-build-system)
                    (arguments
                     (list
                      #:install-plan #~`(("." "/"))))
                    (synopsis
                     "The Heterogeneous Interface for Portability (HIP) framework")
                    (description
                     "The Heterogeneous Interface for Portability (HIP) framework is a
C++ Runtime API and Kernel Language that allows developers to create portable applications
for AMD and NVIDIA GPUs from single source code.")
                    (home-page "https://github.com/ROCm-Developer-Tools/HIP")
                    (license expat))))

(define-public hip-5.7
  (make-hip "5.7.1"))
(define-public hip-5.6
  (make-hip "5.6.1"))

; hip wrappers for the clang compiler
(define %hipcc-hashes
  `(("5.7.1" . ,(base32 "0n5ra5biv2r5yjbzwf88vbfwc6cmswmqxfx8wn58kqambnfgm5cl"))
    ("5.6.1" . ,(base32 "1mrpgpvrya2vb21crar5rskdcvlrannv5mvnqgadw559yax4jm9f"))))

(define %hipcc-patches
  '(("5.7.1" . "amd/patches/hipcc-5.6.1.patch")
    ("5.6.1" . "amd/patches/hipcc-5.6.1.patch")))

(define (make-hipcc rocminfo rocm-toolchain)
  (hidden-package (package
                    (name "hipcc")
                    (version (package-version rocm-toolchain))
                    (source
                     (origin
                       (method git-fetch)
                       (uri (git-reference
                             (url
                              "https://github.com/ROCm-Developer-Tools/HIPCC.git")
                             (commit (string-append "rocm-" version))))
                       (sha256
                        (assoc-ref %hipcc-hashes version))
                       (patches (search-patches (assoc-ref %hipcc-patches
                                                           version)))))
                    (build-system cmake-build-system)
                    (arguments
                     (list
                      #:build-type "Release"
                      #:tests? #f))
                    (propagated-inputs (list rocminfo rocm-toolchain))
                    (synopsis "HIP compiler driver (hipcc)")
                    (description
                     "The HIP compiler driver (hipcc) is a compiler utility that will call
clang and pass the appropriate include and library options for the target compiler and HIP infrastructure.")
                    (home-page
                     "https://github.com/ROCm-Developer-Tools/HIPCC.git")
                    (license expat))))

(define-public hipcc-5.7
  (make-hipcc rocminfo-5.7 rocm-toolchain-5.7))
(define-public hipcc-5.6
  (make-hipcc rocminfo-5.6 rocm-toolchain-5.6))

; clr "hipamd" versions >= 5.6
(define %clr-hipamd-hashes
  `(("5.7.1" . ,(base32 "1300wrbdjpswps8ds850rxy7yifcbwjfszys3x55fl2vy234j1nn"))
    ("5.6.1" . ,(base32 "1i1zj47x473qh94y27ly14cfhwqdc4qw54j02zl7l82dglvz65sx"))))

(define %clr-hipamd-patches
  '(("5.7.1" . "amd/patches/hipamd-5.6.1.patch")
    ("5.6.1" . "amd/patches/hipamd-5.6.1.patch")))

(define (make-clr-hipamd hip hipcc rocm-comgr)
  (package
    (name "hipamd")
    (version (package-version hip))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ROCm-Developer-Tools/clr.git")
             (commit (string-append "rocm-" version))))
       (file-name (git-file-name name version))
       (sha256
        (assoc-ref %clr-hipamd-hashes version))
       (patches (search-patches (assoc-ref %clr-hipamd-patches version)))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f
      #:configure-flags #~(list (string-append "-DHIP_COMMON_DIR="
                                               #$hip)
                                (string-append "-DHIPCC_BIN_DIR="
                                               #$hipcc "/bin")
                                "-DCLR_BUILD_HIP=ON"
                                "-DCLR_BUILD_OCL=OFF"
                                "-D__HIP_ENABLE_PCH=OFF"
                                "-DHIP_PLATFORM=amd")
      #:phases #~(modify-phases %standard-phases
                   (add-after 'install 'overwrite-hipvars
                     (lambda* (#:key outputs inputs #:allow-other-keys)
                       (with-output-to-file (string-append (assoc-ref outputs
                                                                      "out")
                                                           "/bin/hipvars.pm")
                         (lambda ()
                           (display (string-append "package hipvars;\n"
                                     "$isWindows = 0;\n"
                                     "$CUDA_PATH = \"\";\n"
                                     "$HIP_PLATFORM = \"amd\";\n"
                                     "$HIP_COMPILER = \"clang\";\n"
                                     "$HIP_RUNTIME = \"rocclr\";\n"
                                     "$HIP_CLANG_RUNTIME = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "\";\n"
                                     "$DEVICE_LIB_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "/amdgcn/bitcode\";\n"
                                     "$HIP_CLANG_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "/bin\";\n"
                                     "$HIP_PATH = \""
                                     #$output
                                     "\";\n"
                                     "$HIP_VERSION= \""
                                     #$version
                                     "\";\n"
                                     "$ROCMINFO_PATH = \""
                                     (assoc-ref inputs "rocminfo")
                                     "\";\n"
                                     "$ROCR_RUNTIME_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "\";\n"
                                     "$HIP_INFO_PATH = \"$HIP_PATH/lib/.hipInfo\";
"
                                     "$HIP_ROCCLR_HOME = $HIP_PATH;\n"
                                     "$ROCM_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "\";")))))))))
    (native-inputs (list mesa
                         libffi
                         git
                         perl
                         python-wrapper
                         python-cppheaderparser
                         hip
                         hipcc))
    (propagated-inputs (modify-inputs (package-propagated-inputs hipcc)
                         (append rocm-comgr)))
    (synopsis "AMD CLR - Compute Language Runtimes for HIP applications")
    (description
     "AMD Common Language Runtime contains source code for AMD's
compute languages runtimes: HIP and OpenCL. This package is built for HIP only.")
    (home-page "https://github.com/ROCm-Developer-Tools/clr.git")
    (license expat)))

(define-public hipamd-5.7
  (make-clr-hipamd hip-5.7 hipcc-5.7 rocm-comgr-5.7))
(define-public hipamd-5.6
  (make-clr-hipamd hip-5.6 hipcc-5.6 rocm-comgr-5.6))

; hipamd package definitions for versions prior to 5.6.X

; rocclr sources
(define %rocclr-repo-hashes
  `(("5.5.1" . ,(base32 "0r9z85kh64ax8jimihw0kf8h52kfdhz8b7zld7qm3p0ka17isk73"))
    ("5.4.4" . ,(base32 "0hg2s2za462xb8937ngsmgmifz1gg87zax80c7ga7j98py87pcqd"))
    ("5.3.3" . ,(base32 "10agrf2g1iaws97rczbyc9rcls7ds3kdyyg6fj87301zna9gsqkn"))))

(define (rocclr-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/ROCm-Developer-Tools/ROCclr.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "rocclr" version))
    (sha256 (assoc-ref %rocclr-repo-hashes version))))

(define-public rocclr-src-5.5
  (rocclr-origin "5.5.1"))
(define-public rocclr-src-5.4
  (rocclr-origin "5.4.4"))
(define-public rocclr-src-5.3
  (rocclr-origin "5.3.3"))

; rocm-opencl runtime sources
(define %rocm-opencl-runtime-repo-hashes
  `(("5.5.1" . ,(base32 "0cxhi7pk9xsw6iggkw0fdl2vllpn51iyj1ac80zdifhqss3aba75"))
    ("5.4.4" . ,(base32 "1hpvxbpxxn0l9cigp0j2fkyv8n61bznzikaj3yxvzr99z3yrhpqk"))
    ("5.3.3" . ,(base32 "1bsdwgbn9gf9an70sc9zmk732s7qjayv527j6dsxgaszjvdhbw22"))))

(define (rocm-opencl-runtime-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "rocm-opencl-runtime" version))
    (sha256 (assoc-ref %rocm-opencl-runtime-repo-hashes version))))

(define-public rocm-opencl-runtime-src-5.5
  (rocm-opencl-runtime-origin "5.5.1"))
(define-public rocm-opencl-runtime-src-5.4
  (rocm-opencl-runtime-origin "5.4.4"))
(define-public rocm-opencl-runtime-src-5.3
  (rocm-opencl-runtime-origin "5.3.3"))

; hip headers
(define %hip-headers-repo-hashes
  `(("5.5.1" . ,(base32 "0rm143x4c1h73rfcsa2ggyfg62g1y3x5az9n1jsxfbivqlmmxgs5"))
    ("5.4.4" . ,(base32 "192jg9bbiyrxq9qszhmvg5d1yszhqmh552qpkqhf0idkvdyp5lsn"))
    ("5.3.3" . ,(base32 "1lfr2niqa646bfm3y14377frcrxyfpbiygn20jfivlnk16pnyr4j"))))

(define %hip-headers-repo-patches
  '(("5.5.1" "amd/patches/hip-5.5.1.patch")
    ("5.4.4" "amd/patches/hip-5.4.4.patch")
    ("5.3.3" "amd/patches/hip-5.3.3.patch")))

(define (hip-headers-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url "https://github.com/ROCm-Developer-Tools/HIP.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "hip" version))
    (sha256 (assoc-ref %hip-headers-repo-hashes version))
    (patches (map search-patch
                  (assoc-ref %hip-headers-repo-patches version)))))

(define (make-hip-headers rocminfo rocm-toolchain)
  (hidden-package (package
                    (name "hip")
                    (version (package-version rocm-toolchain))
                    (source
                     (hip-headers-origin version))
                    (build-system copy-build-system)
                    (arguments
                     (list
                      #:install-plan #~`(("." "/"))))
                    (propagated-inputs (list rocminfo rocm-toolchain))
                    (synopsis
                     "The Heterogeneous Interface for Portability (HIP) framework")
                    (description
                     "The Heterogeneous Interface for Portability (HIP) framework is a
C++ Runtime API and Kernel Language that allows developers to create portable applications
for AMD and NVIDIA GPUs from single source code.")
                    (home-page "https://github.com/ROCm-Developer-Tools/HIP")
                    (license expat))))

(define-public hip-5.5
  (make-hip-headers rocminfo-5.5 rocm-toolchain-5.5))
(define-public hip-5.4
  (make-hip-headers rocminfo-5.4 rocm-toolchain-5.4))
(define-public hip-5.3
  (make-hip-headers rocminfo-5.3 rocm-toolchain-5.3))

; hipamd - implementation of HIP for AMD platforms
(define %hipamd-repo-hashes
  `(("5.5.1" . ,(base32 "0qqr89zlv3pny6b7b729p3k4z7wywhic2gypzdjqfld514j2r83c"))
    ("5.4.4" . ,(base32 "0lx02yg6adiqxvhrw7pkn0hl91g88fijgxbic65pmv0636bb5jqm"))
    ("5.3.3" . ,(base32 "07j709nf7z7r3q71gjh8xa17aw99n86735xdapxb9l4m7zz57f4b"))))

(define %hipamd-repo-patches
  '(("5.5.1")
    ("5.4.4" "amd/patches/hipamd-5.4.4.patch")
    ("5.3.3")))

(define (hipamd-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/ROCm-Developer-Tools/hipamd.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "hipamd" version))
    (sha256 (assoc-ref %hipamd-repo-hashes version))
    (patches (map search-patch
                  (assoc-ref %hipamd-repo-patches version)))))

(define (make-hipamd hip rocm-comgr rocclr rocm-opencl)
  (package
    (name "hipamd")
    (version (package-version hip))
    (source
     (hipamd-origin version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f
      #:configure-flags #~(list (string-append "-DHIP_COMMON_DIR="
                                               #$hip)
                                (string-append "-DROCCLR_PATH="
                                               #$rocclr)
                                (string-append "-DAMD_OPENCL_PATH="
                                               #$rocm-opencl)
                                "-D__HIP_ENABLE_PCH=OFF" "-DHIP_PLATFORM=amd")
      #:phases #~(modify-phases %standard-phases
                   (add-after 'install 'fix-clangrt-search-path
                     (lambda* (#:key outputs inputs #:allow-other-keys)
                       (substitute* (string-append (assoc-ref outputs "out")
                                     "/lib/cmake/hip/hip-config.cmake")
                         (("\\$\\{HIP_CLANGRT_LIB_SEARCH_PATHS\\}")
                          (string-append (assoc-ref inputs "rocm-toolchain")
                                         "/lib/linux")))))
                   (add-after 'install 'overwrite-hipvars
                     (lambda* (#:key outputs inputs #:allow-other-keys)
                       (make-file-writable (string-append (assoc-ref outputs
                                                                     "out")
                                                          "/bin/hipvars.pm"))
                       (with-output-to-file (string-append (assoc-ref outputs
                                                                      "out")
                                                           "/bin/hipvars.pm")
                         (lambda ()
                           (display (string-append "package hipvars;\n"
                                     "$isWindows = 0;\n"
                                     "$CUDA_PATH = \"\";\n"
                                     "$HIP_PLATFORM = \"amd\";\n"
                                     "$HIP_COMPILER = \"clang\";\n"
                                     "$HIP_RUNTIME = \"rocclr\";\n"
                                     "$HIP_CLANG_RUNTIME = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "\";\n"
                                     "$DEVICE_LIB_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "/amdgcn/bitcode\";\n"
                                     "$HIP_CLANG_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "/bin\";\n"
                                     "$HIP_PATH = \""
                                     #$output
                                     "\";\n"
                                     "$HIP_VERSION= \""
                                     #$version
                                     "\";\n"
                                     "$ROCMINFO_PATH = \""
                                     (assoc-ref inputs "rocminfo")
                                     "\";\n"
                                     "$ROCR_RUNTIME_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "\";\n"
                                     "$HIP_INFO_PATH = \"$HIP_PATH/lib/.hipInfo\";
"
                                     "$HIP_ROCCLR_HOME = $HIP_PATH;\n"
                                     "$ROCM_PATH = \""
                                     (assoc-ref inputs "rocm-toolchain")
                                     "\";")))))))))
    (native-inputs (list mesa
                         libffi
                         git
                         perl
                         python-wrapper
                         python-cppheaderparser))
    (inputs (modify-inputs (package-inputs hip)
              (append numactl)))
    (propagated-inputs (modify-inputs (package-propagated-inputs hip)
                         (append rocm-comgr)))
    (synopsis "HIPamd: HIP implementation for the AMD platform")
    (description
     "This repository provides HIP implementation specifically for the AMD platform.")
    (home-page "https://github.com/ROCm-Developer-Tools/hipamd")
    (license expat)))

(define-public hipamd-5.5
  (make-hipamd hip-5.5 rocm-comgr-5.5 rocclr-src-5.5
               rocm-opencl-runtime-src-5.5))
(define-public hipamd-5.4
  (make-hipamd hip-5.4 rocm-comgr-5.4 rocclr-src-5.4
               rocm-opencl-runtime-src-5.4))
(define-public hipamd-5.3
  (make-hipamd hip-5.3 rocm-comgr-5.3 rocclr-src-5.3
               rocm-opencl-runtime-src-5.3))

; rocm-cmake
(define %rocm-cmake-hashes
  `(("5.7.1" . ,(base32 "0dfhqffgmrbcyxyri2qxpyfdyf8b75bprvnq77q2g281kswg6n39"))
    ("5.6.1" . ,(base32 "183s2ksn142r7nl7l56qvyrgvvkdgqfdzmgkfpp4a6g9mjp88ady"))
    ("5.5.1" . ,(base32 "1g89irfx3f1lmz4p2ys663kc524i6airmkc9n7l20l7l6xm446rv"))
    ("5.4.4" . ,(base32 "0rhg2rs1nv66plfvfa389ga8v8g3z40ckbyysnasbpwr52md1ai5"))
    ("5.3.3" . ,(base32 "1dwm7k22p9jwbax46nlsgd86s2s4c43qsa2wv2ldf7bbp94ggs80"))))

(define (rocm-cmake-origin version)
  (origin
    (method git-fetch)
    (uri (git-reference (url
                         "https://github.com/RadeonOpenCompute/rocm-cmake.git")
                        (commit (string-append "rocm-" version))))
    (file-name (git-file-name "rocm-cmake" version))
    (sha256 (assoc-ref %rocm-cmake-hashes version))))

(define (make-rocm-cmake version)
  (package
    (name "rocm-cmake")
    (version version)
    (source
     (rocm-cmake-origin version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f)) ;No tests.
    (synopsis
     "ROCm-CMake is a collection of CMake modules for common build and development
tasks within the ROCm project.")
    (description
     "ROCm-CMake is a collection of CMake modules for common build and development
tasks within the ROCm project. It is therefore a build dependency for many of the libraries that
comprise the ROCm platform. ROCm-CMake is not required for building libraries or programs that use ROCm;
it is required for building some of the libraries that are a part of ROCm.")
    (home-page "https://github.com/RadeonOpenCompute/rocm-cmake.git")
    (license expat)))

(define-public rocm-cmake-5.7
  (make-rocm-cmake "5.7.1"))
(define-public rocm-cmake-5.6
  (make-rocm-cmake "5.6.1"))
(define-public rocm-cmake-5.5
  (make-rocm-cmake "5.5.1"))
(define-public rocm-cmake-5.4
  (make-rocm-cmake "5.4.4"))
(define-public rocm-cmake-5.3
  (make-rocm-cmake "5.3.3"))
