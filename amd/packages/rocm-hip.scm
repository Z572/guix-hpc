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

(define-module (amd packages rocm-hip)
  #:use-module (guix gexp)
  #:use-module (guix utils)
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

  #:use-module (amd packages rocm-origin)
  #:use-module (amd packages python-cppheaderparser)
  #:use-module (amd packages rocm-tools)
  #:use-module (amd packages rocm-base))

; rocm-comgr
(define (make-rocm-comgr rocm-device-libs llvm-rocm lld-rocm clang-rocm)
  (package
    (name "rocm-comgr")
    (version (package-version rocm-device-libs))
    (source
     (rocm-origin (if (version>=? version "6.1.1") "llvm-project" "rocm-compilersupport") version))
    (build-system cmake-build-system)
    (arguments
        (list
            #:tests? #f
            #:phases
            #~(modify-phases %standard-phases
                (add-after 'unpack 'chdir
                    (lambda _
                        (setenv "HIP_DEVICE_LIB_PATH" (string-append #$(this-package-input "rocm-device-libs") "/amdgcn/bitcode"))
                        (chdir #$(if (version>=? version "6.1.1") "amd/comgr" "lib/comgr"))))
                (add-before 'configure 'fix-path
                    (lambda _
                        (substitute* "src/comgr-env.cpp"
                            (("getDetector\\(\\)->getLLVMPath\\(\\)") (string-append "\"" #$clang-rocm "\""))))))))
    (inputs (list rocm-device-libs))
    (native-inputs (list llvm-rocm lld-rocm clang-rocm))
    (synopsis "The ROCm Code Object Manager")
    (description
     "The Comgr library provides APIs for compiling and inspecting AMDGPU code objects.")
    (home-page "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport")
    (license ncsa)))

(define-public llvm-comgr-6.2
  (make-rocm-comgr llvm-device-libs-6.2 llvm-rocm-6.2 lld-rocm-6.2
                   clang-rocm-6.2))
(define-public llvm-comgr-6.1
  (make-rocm-comgr llvm-device-libs-6.1 llvm-rocm-6.1 lld-rocm-6.1
                   clang-rocm-6.1))
(define-public rocm-comgr-6.0
  (make-rocm-comgr rocm-device-libs-6.0 llvm-rocm-6.0 lld-rocm-6.0
                   clang-rocm-6.0))
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
(define (make-hip version)
  (hidden-package (package
                    (name "hip")
                    (version version)
                    (source
                     (rocm-origin name version))
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

(define-public hip-6.2
  (make-hip "6.2.0"))
(define-public hip-6.1
  (make-hip "6.1.2"))
(define-public hip-6.0
  (make-hip "6.0.2"))
(define-public hip-5.7
  (make-hip "5.7.1"))
(define-public hip-5.6
  (make-hip "5.6.1"))

; hipcc
(define (make-hipcc rocminfo rocm-toolchain)
  (hidden-package (package
                    (name "hipcc")
                    (version (package-version rocm-toolchain))
                    (source
                     (rocm-origin (if (version>=? version "6.1.1") "llvm-project" name) version))
                    (build-system cmake-build-system)
                    (arguments
                     (list
                      #:build-type "Release"
                      #:tests? #f
                      #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'chdir
                            (lambda _
                                (chdir #$(if (version>=? version "6.1.1") "amd/hipcc" ".")))))))
                    (propagated-inputs (list rocminfo rocm-toolchain))
                    (synopsis "HIP compiler driver (hipcc)")
                    (description
                     "The HIP compiler driver (hipcc) is a compiler utility that will call
clang and pass the appropriate include and library options for the target compiler and HIP infrastructure.")
                    (home-page
                     "https://github.com/ROCm-Developer-Tools/HIPCC.git")
                    (license expat))))

(define-public hipcc-6.2
  (make-hipcc rocminfo-6.2 rocm-toolchain-6.2))
(define-public hipcc-6.1
  (make-hipcc rocminfo-6.1 rocm-toolchain-6.1))
(define-public hipcc-6.0
  (make-hipcc rocminfo-6.0 rocm-toolchain-6.0))
(define-public hipcc-5.7
  (make-hipcc rocminfo-5.7 rocm-toolchain-5.7))
(define-public hipcc-5.6
  (make-hipcc rocminfo-5.6 rocm-toolchain-5.6))

; clr "hipamd" versions >= 5.6
(define (make-clr-hipamd hip hipcc rocm-comgr)
  (package
    (name "hipamd")
    (version (package-version hip))
    (source
     (rocm-origin "clr" version))
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
                                "-DHIP_ENABLE_ROCPROFILER_REGISTER=OFF"
                                "-D__HIP_ENABLE_PCH=OFF"
                                "-DHIP_PLATFORM=amd")
      #:phases #~(modify-phases %standard-phases
                   (add-after 'install 'info-version'
                     (lambda _
                       (mkdir (string-append #$output "/.info"))
                       (with-output-to-file (string-append #$output
                                                           "/.info/version")
                         (lambda ()
                           (display (string-append #$version "-0"))))))
                   (add-after 'install 'overwrite-hipvars
                     (lambda* (#:key outputs inputs #:allow-other-keys)
                       (with-output-to-file (string-append (assoc-ref outputs
                                                                      "out")
                                                           "/bin/hipvars.pm")
                         (lambda ()
                           (display (string-append "package hipvars;\n"
                                     "$isWindows = 0;\n"
                                     "$doubleQuote = \"\\\"\";\n"
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

(define-public hipamd-6.2
  (make-clr-hipamd hip-6.2 hipcc-6.2 llvm-comgr-6.2))
(define-public hipamd-6.1
  (make-clr-hipamd hip-6.1 hipcc-6.1 llvm-comgr-6.1))
(define-public hipamd-6.0
  (make-clr-hipamd hip-6.0 hipcc-6.0 rocm-comgr-6.0))
(define-public hipamd-5.7
  (make-clr-hipamd hip-5.7 hipcc-5.7 rocm-comgr-5.7))
(define-public hipamd-5.6
  (make-clr-hipamd hip-5.6 hipcc-5.6 rocm-comgr-5.6))

; hipamd package definitions for versions prior to 5.6.X

; hip headers
(define (make-hip-headers rocminfo rocm-toolchain)
  (hidden-package (package
                    (name "hip")
                    (version (package-version rocm-toolchain))
                    (source
                     (rocm-origin name version))
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
(define (make-hipamd hip rocm-comgr rocclr rocm-opencl)
  (package
    (name "hipamd")
    (version (package-version hip))
    (source
     (rocm-origin name version))
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
  (make-hipamd hip-5.5 rocm-comgr-5.5
               (rocm-origin "rocclr" "5.5.1")
               (rocm-origin "rocm-opencl-runtime" "5.5.1")))
(define-public hipamd-5.4
  (make-hipamd hip-5.4 rocm-comgr-5.4
               (rocm-origin "rocclr" "5.4.4")
               (rocm-origin "rocm-opencl-runtime" "5.4.4")))
(define-public hipamd-5.3
  (make-hipamd hip-5.3 rocm-comgr-5.3
               (rocm-origin "rocclr" "5.3.3")
               (rocm-origin "rocm-opencl-runtime" "5.3.3")))

; rocm-cmake
(define (make-rocm-cmake version)
  (package
    (name "rocm-cmake")
    (version version)
    (source
     (rocm-origin name version))
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

(define-public rocm-cmake-6.2
  (make-rocm-cmake "6.2.0"))
(define-public rocm-cmake-6.1
  (make-rocm-cmake "6.1.2"))
(define-public rocm-cmake-6.0
  (make-rocm-cmake "6.0.2"))
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
