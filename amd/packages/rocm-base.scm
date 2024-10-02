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

(define-module (amd packages rocm-base)
  #:use-module (amd packages rocm-origin)
  #:use-module (amd packages logging)
  #:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system trivial)
  #:use-module (guix build utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pretty-print)
  #:use-module (gnu packages python)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages crypto)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages vim))

;; This package is needed only for the clan/llvm ROCm stack. Don't
;; export its symbol publicly as it might conflict with upstream
;; libffi (same package name and version).
(define-public libffi-shared
  (package
    (inherit libffi)
    (arguments
     (list
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'set-CFLAGS
                     (lambda _
                       (setenv "CFLAGS" " -fPIC"))))))
    (properties `((hidden? . #t) ,@(package-properties libffi)))))

; llvm
(define (make-llvm-rocm version llvm)
  (package
    (inherit llvm)
    (name (string-append (package-name llvm) "-rocm"))
    (version version)
    (source
     (rocm-origin "llvm-project" version))
    (inputs (modify-inputs (package-inputs llvm)
              (replace "libffi" libffi-shared)))
    (properties `((hidden? . #t) ,@(package-properties llvm)))))

(define-public llvm-rocm-6.2
  (make-llvm-rocm "6.2.0" llvm-18))
(define-public llvm-rocm-6.1
  (make-llvm-rocm "6.1.2" llvm-17))
(define-public llvm-rocm-6.0
  (make-llvm-rocm "6.0.2" llvm-17))
(define-public llvm-rocm-5.7
  (make-llvm-rocm "5.7.1" llvm-17))

; clang runtime
(define-public (make-clang-runtime-rocm llvm-rocm clang-runtime)
  (package
    (inherit clang-runtime)
    (name (string-append (package-name clang-runtime) "-rocm"))
    (version (package-version llvm-rocm))
    (source
     (rocm-origin "llvm-project" version))
    (inputs (modify-inputs (package-inputs clang-runtime)
              (replace "llvm" llvm-rocm)
              (replace "libffi" libffi-shared)
              (append libxcrypt)))
    (properties `((hidden? . #t) ,@(package-properties clang-runtime)))))

(define-public clang-runtime-rocm-6.2
  (make-clang-runtime-rocm llvm-rocm-6.2 clang-runtime-18))
(define-public clang-runtime-rocm-6.1
  (make-clang-runtime-rocm llvm-rocm-6.1 clang-runtime-17))
(define-public clang-runtime-rocm-6.0
  (make-clang-runtime-rocm llvm-rocm-6.0 clang-runtime-17))
(define-public clang-runtime-rocm-5.7
  (make-clang-runtime-rocm llvm-rocm-5.7 clang-runtime-17))

; clang
(define (make-clang-rocm llvm-rocm clang-runtime-rocm clang)
  (package
    (inherit clang)
    (name (string-append (package-name clang) "-rocm"))
    (version (package-version llvm-rocm))
    (source
     (package-source clang-runtime-rocm))
    (inputs (modify-inputs (package-inputs clang)
              (delete "clang-tools-extra")))
    (propagated-inputs (modify-inputs (package-propagated-inputs clang)
                         (replace "llvm" llvm-rocm)
                         (replace "clang-runtime" clang-runtime-rocm)))
    (arguments
     (substitute-keyword-arguments (package-arguments clang)
       ((#:phases phases
         '(@ () %standard-phases))
        #~(modify-phases #$phases
            (replace 'add-tools-extra
              (lambda _
                (copy-recursively "../clang-tools-extra" "tools/extra")))))))
    (properties `((hidden? . #t) ,@(package-properties clang)))))

(define-public clang-rocm-6.2
  (make-clang-rocm llvm-rocm-6.2 clang-runtime-rocm-6.2 clang-18))
(define-public clang-rocm-6.1
  (make-clang-rocm llvm-rocm-6.1 clang-runtime-rocm-6.1 clang-17))
(define-public clang-rocm-6.0
  (make-clang-rocm llvm-rocm-6.0 clang-runtime-rocm-6.0 clang-17))
(define-public clang-rocm-5.7
  (make-clang-rocm llvm-rocm-5.7 clang-runtime-rocm-5.7 clang-17))

; lld
(define (make-lld-rocm llvm-rocm lld)
  (package
    (inherit lld)
    (name (string-append (package-name lld) "-rocm"))
    (version (package-version llvm-rocm))
    (source
     (rocm-origin "llvm-project" version))
    (inputs (list llvm-rocm))
    (properties `((hidden? . #t) ,@(package-properties lld)))))

(define-public lld-rocm-6.2
  (make-lld-rocm llvm-rocm-6.2 lld-18))
(define-public lld-rocm-6.1
  (make-lld-rocm llvm-rocm-6.1 lld-17))
(define-public lld-rocm-6.0
  (make-lld-rocm llvm-rocm-6.0 lld-17))
(define-public lld-rocm-5.7
  (make-lld-rocm llvm-rocm-5.7 lld-17))

; rocm-device-libs
(define (make-rocm-device-libs clang-rocm)
  (package
    (name "rocm-device-libs")
    (version (package-version clang-rocm))
    (source
     (rocm-origin (if (version>=? version "6.1.1") "llvm-project" name)
                  version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'ockl_ocml_irif_inc
                     (lambda* (#:key outputs #:allow-other-keys)
                       (chdir #$(if (version>=? version "6.1.1")
                                    "amd/device-libs" "."))
                       (copy-recursively "irif/inc"
                                         (string-append (assoc-ref outputs
                                                                   "out")
                                                        "/irif/inc"))
                       (copy-recursively "oclc/inc"
                                         (string-append (assoc-ref outputs
                                                                   "out")
                                                        "/oclc/inc"))
                       (copy-recursively "ockl/inc"
                                         (string-append (assoc-ref outputs
                                                                   "out")
                                                        "/ockl/inc")))))))
    (native-inputs (list clang-rocm))
    (synopsis "ROCm Device libraries")
    (description
     "This repository contains the sources and CMake build system for 
a set of AMD specific device-side language runtime libraries.")
    (home-page "https://github.com/RadeonOpenCompute/ROCm-Device-Libs.git")
    (license license:ncsa)))

(define-public llvm-device-libs-6.2
  (make-rocm-device-libs clang-rocm-6.2))
(define-public llvm-device-libs-6.1
  (make-rocm-device-libs clang-rocm-6.1))
(define-public rocm-device-libs-6.0
  (make-rocm-device-libs clang-rocm-6.0))
(define-public rocm-device-libs-5.7
  (make-rocm-device-libs clang-rocm-5.7))

; roct-thunk-interface
(define (make-roct-thunk version)
  (package
    (name "roct-thunk-interface")
    (version version)
    (source
     (rocm-origin name version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f))
    (inputs (list libdrm numactl))
    (native-inputs (list `(,gcc "lib") pkg-config))
    (synopsis "ROCT Thunk interface")
    (description "This repository includes the user-mode API interfaces used
to interact with the ROCk driver.")
    (home-page "https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface.git")
    (license license:expat)))

(define-public roct-thunk-6.2
  (make-roct-thunk "6.2.0"))
(define-public roct-thunk-6.1
  (make-roct-thunk "6.1.2"))
(define-public roct-thunk-6.0
  (make-roct-thunk "6.0.2"))
(define-public roct-thunk-5.7
  (make-roct-thunk "5.7.1"))

; rocprof-register
(define (make-rocprof-register version)
  (package
    (name "rocprof-register")
    (version version)
    (source
     (rocm-origin "rocprofiler-register" version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags
      ;; Don't let CMake download and build these dependencies
      #~(list "-DROCPROFILER_REGISTER_BUILD_GLOG=OFF"
              "-DROCPROFILER_REGISTER_BUILD_FMT=OFF")))
    (inputs (list fmt glog-0.7))
    (synopsis "The rocprofiler-register helper library.")
    (description
     "The rocprofiler-register library is a helper library that coordinates
the modification of the intercept API table(s) of the HSA/HIP/ROCTx runtime libraries by the
ROCprofiler (v2) library. The purpose of this library is to provide a consistent and automated
mechanism of enabling performance analysis in the ROCm runtimes which does not rely on environment
variables or unique methods for each runtime library.")
    (home-page "https://github.com/rocm/rocprofiler-register")
    (license license:expat)))

(define-public rocprof-register-6.2
  (make-rocprof-register "6.2.0"))

; rocr-runtime
(define (make-rocr-runtime roct-thunk rocm-device-libs lld-rocm clang-rocm
                           rocprof-register)
  (package
    (name "rocr-runtime")
    (version (package-version rocm-device-libs))
    (source
     (rocm-origin name version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f ;No tests.
      #:configure-flags #~(list (string-append "-DBITCODE_DIR="
                                               #$(this-package-input
                                                  "rocm-device-libs")
                                               "/amdgcn/bitcode/"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'chdir
                     (lambda _
                       (chdir "src"))))))
    (inputs (append (list numactl libdrm libffi roct-thunk rocm-device-libs)
                    (if (version>=? version "6.2.0")
                        (list rocprof-register)
                        '())))
    (native-inputs (list xxd libelf lld-rocm clang-rocm pkg-config))
    (synopsis "HSA Runtime API and runtime for ROCm")
    (description
     "This repository includes the user-mode API interfaces and 
libraries necessary for host applications to launch compute kernels to 
available HSA ROCm kernel agents. Reference source code for the 
core runtime is also available.")
    (home-page "https://github.com/RadeonOpenCompute/ROCR-Runtime.git")
    (license license:ncsa)))

(define-public rocr-runtime-6.2
  (make-rocr-runtime roct-thunk-6.2 llvm-device-libs-6.2 lld-rocm-6.2
                     clang-rocm-6.2 rocprof-register-6.2))
(define-public rocr-runtime-6.1
  (make-rocr-runtime roct-thunk-6.1 llvm-device-libs-6.1 lld-rocm-6.1
                     clang-rocm-6.1 #f))
(define-public rocr-runtime-6.0
  (make-rocr-runtime roct-thunk-6.0 rocm-device-libs-6.0 lld-rocm-6.0
                     clang-rocm-6.0 #f))
(define-public rocr-runtime-5.7
  (make-rocr-runtime roct-thunk-5.7 rocm-device-libs-5.7 lld-rocm-5.7
                     clang-rocm-5.7 #f))

; lld-wrapper
(define-public lld-wrapper-rocm-6.2
  (make-lld-wrapper lld-rocm-6.2))
(define-public lld-wrapper-rocm-6.1
  (make-lld-wrapper lld-rocm-6.1))
(define-public lld-wrapper-rocm-6.0
  (make-lld-wrapper lld-rocm-6.0))
(define-public lld-wrapper-rocm-5.7
  (make-lld-wrapper lld-rocm-5.7))

; libomp
(define (make-libomp-rocm llvm-rocm
                          clang-rocm
                          lld-rocm
                          rocm-device-libs
                          rocr-runtime
                          roct-thunk
                          libomp)
  (package
    (inherit libomp)
    (name (string-append (package-name libomp) "-rocm"))
    (version (package-version llvm-rocm))
    (source
     (rocm-origin "llvm-project" version))
    (native-inputs (append (list `("gcc:lib" ,gcc "lib"))
                           (modify-inputs (package-native-inputs libomp)
                             (replace "clang" clang-rocm)
                             (replace "llvm" llvm-rocm)
                             (replace "python" python-wrapper)
                             (append lld-rocm)
                             (append elfutils))))
    (inputs (modify-inputs (package-inputs libomp)
              (append libdrm) ;required for rocm-5.7 onwards
              (append numactl) ;required for rocm-5.7 onwards
              (append roct-thunk) ;required for rocm-5.7 onwards
              (append libffi-shared)
              (append rocm-device-libs)
              (append rocr-runtime)))
    (arguments
     (substitute-keyword-arguments (package-arguments libomp)
       ((#:configure-flags flags)
        #~(append (list "-DOPENMP_ENABLE_LIBOMPTARGET=1"
                   "-DCMAKE_C_COMPILER=clang"
                   "-DCMAKE_CXX_COMPILER=clang++"
                   "-DCMAKE_BUILD_TYPE=Release" ;strictly speaking unnecesary as debug will be stripped
                   "-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld" ;can be removed if we use lld-as-ld-wrapper
                   "-DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld" ;can be removed if we use lld-as-ld-wrapper
                   "-DLIBOMPTARGET_AMDGCN_GFXLIST=gfx906;gfx908;gfx90a;gfx940;gfx1030"
                   (string-append "-DDEVICELIBS_ROOT="
                                  #$(this-package-input "rocm-device-libs"))
                   (string-append "-DLLVM_DIR="
                                  #$(this-package-native-input "llvm")))
                  #$flags))
       ((#:phases phases
         '(@ () %standard-phases))
        #~(modify-phases #$phases
            (add-after 'set-paths 'adjust-LD_LIBRARY_PATH
              (lambda* (#:key inputs #:allow-other-keys)
                (setenv "LD_LIBRARY_PATH"
                        (string-append (assoc-ref inputs "llvm") "/lib" ":"
                                       (assoc-ref inputs "gcc:lib") "/lib"))))
            (add-after 'unpack 'patch-clang-tools
              (lambda _
                ;; FIXME: Create a patch exposing a configuration option (e.g. -DCLANG_DIR=<...>)
                ;; to use instead of this substitution
                (substitute* (append '("openmp/libomptarget/CMakeLists.txt"
                                       "openmp/libomptarget/DeviceRTL/CMakeLists.txt")
                                     (if #$(version>=? "6.1.2" version)
                                         '("openmp/libomptarget/deviceRTLs/amdgcn/CMakeLists.txt")
                                         '()))
                  (("find_program\\(CLANG_TOOL clang PATHS \\$\\{LLVM_TOOLS_BINARY_DIR\\}")
                   (string-append "find_program(CLANG_TOOL clang PATHS "
                                  #$clang-rocm "/bin"))
                  (("find_program\\(CLANG_OFFLOAD_BUNDLER_TOOL clang-offload-bundler PATHS \\$\\{LLVM_TOOLS_BINARY_DIR\\}")
                   (string-append
                    "find_program(CLANG_OFFLOAD_BUNDLER_TOOL clang-offload-bundler PATHS "
                    #$clang-rocm "/bin"))
                  (("find_program\\(PACKAGER_TOOL clang-offload-packager PATHS \\$\\{LLVM_TOOLS_BINARY_DIR\\}")
                   (string-append
                    "find_program(PACKAGER_TOOL clang-offload-packager PATHS "
                    #$clang-rocm "/bin")))))))))
    (properties `((hidden? . #t) ,@(package-properties libomp)))))

(define-public libomp-rocm-6.2
  (make-libomp-rocm llvm-rocm-6.2
                    clang-rocm-6.2
                    lld-wrapper-rocm-6.2
                    llvm-device-libs-6.2
                    rocr-runtime-6.2
                    roct-thunk-6.2
                    libomp-18))
(define-public libomp-rocm-6.1
  (make-libomp-rocm llvm-rocm-6.1
                    clang-rocm-6.1
                    lld-wrapper-rocm-6.1
                    llvm-device-libs-6.1
                    rocr-runtime-6.1
                    roct-thunk-6.1
                    libomp-17))
(define-public libomp-rocm-6.0
  (make-libomp-rocm llvm-rocm-6.0
                    clang-rocm-6.0
                    lld-wrapper-rocm-6.0
                    rocm-device-libs-6.0
                    rocr-runtime-6.0
                    roct-thunk-6.0
                    libomp-17))
(define-public libomp-rocm-5.7
  (make-libomp-rocm llvm-rocm-5.7
                    clang-rocm-5.7
                    lld-wrapper-rocm-5.7
                    rocm-device-libs-5.7
                    rocr-runtime-5.7
                    roct-thunk-5.7
                    libomp-17))

; rocm-toolchain
(define (make-rocm-toolchain clang-rocm
                             libomp-rocm
                             lld-wrapper-rocm
                             rocr-runtime
                             rocm-device-libs
                             roct-thunk)
  (let ((rocm-clang-toolchain (make-clang-toolchain clang-rocm libomp-rocm)))
    (package
      (inherit rocm-clang-toolchain)
      (name "rocm-toolchain")
      (version (package-version rocm-clang-toolchain))
      (inputs (modify-inputs (package-inputs rocm-clang-toolchain)
                (append lld-wrapper-rocm rocr-runtime rocm-device-libs
                        roct-thunk)))
      (properties (alist-delete 'hidden?
                                (package-properties rocm-clang-toolchain)))
      (synopsis
       "Complete ROCm toolchain, based on the Clang toolchain, for C/C++ development")
      (description
       "This package provides a complete ROCm toolchain for C/C++
development to be installed in user profiles. This includes Clang, as well as
libc (headers and binaries, plus debugging symbols in the @code{debug}
output), Binutils, the ROCm device libraries, and the ROCr runtime."))))

(define-public rocm-toolchain-6.2
  (make-rocm-toolchain clang-rocm-6.2
                       libomp-rocm-6.2
                       lld-wrapper-rocm-6.2
                       rocr-runtime-6.2
                       llvm-device-libs-6.2
                       roct-thunk-6.2))
(define-public rocm-toolchain-6.1
  (make-rocm-toolchain clang-rocm-6.1
                       libomp-rocm-6.1
                       lld-wrapper-rocm-6.1
                       rocr-runtime-6.1
                       llvm-device-libs-6.1
                       roct-thunk-6.1))
(define-public rocm-toolchain-6.0
  (make-rocm-toolchain clang-rocm-6.0
                       libomp-rocm-6.0
                       lld-wrapper-rocm-6.0
                       rocr-runtime-6.0
                       rocm-device-libs-6.0
                       roct-thunk-6.0))
(define-public rocm-toolchain-5.7
  (make-rocm-toolchain clang-rocm-5.7
                       libomp-rocm-5.7
                       lld-wrapper-rocm-5.7
                       rocr-runtime-5.7
                       rocm-device-libs-5.7
                       roct-thunk-5.7))

; hipify
(define (make-hipify clang-rocm)
  (package
    (name "hipify")
    (version (package-version clang-rocm))
    (source
     (rocm-origin name version))
    (build-system cmake-build-system)
    (arguments
     (list
      #:build-type "Release"
      #:tests? #f ;No tests.
      #:configure-flags #~(list "-DCMAKE_C_COMPILER=clang"
                                "-DCMAKE_CXX_COMPILER=clang++"
                                (if (string=? #$(package-version this-package)
                                              "5.5.1") "-DSWDEV_375013=ON" ""))
      #:phases #~(modify-phases %standard-phases
                   (add-before 'configure 'prepare-cmake
                     (lambda _
                       (substitute* "CMakeLists.txt"
                         (("set.CMAKE_CXX_COMPILER.*")
                          "")
                         (("set.CMAKE_C_COMPILER.*")
                          "")
                         (("--disable-new-dtags")
                          ;; Required for 5.6.1 but does not seem to
                          ;; affect other versions.
                          "--enable-new-dtags")))))))
    (inputs (list clang-rocm perl))
    (synopsis "HIPIFY: Convert CUDA to HIP code.")
    (description
     "HIPIFY is a set of tools that you can use to automatically translate
CUDA source code into portable HIP C++.")
    (home-page "https://github.com/ROCm/HIPIFY")
    (license license:ncsa)))

(define-public hipify-6.2
  (make-hipify clang-rocm-6.2))
(define-public hipify-6.1
  (make-hipify clang-rocm-6.1))
(define-public hipify-6.0
  (make-hipify clang-rocm-6.0))
(define-public hipify-5.7
  (make-hipify clang-rocm-5.7))
