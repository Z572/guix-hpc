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

(define-module (amd rocm-base)
    #:use-module (guix gexp)
    #:use-module (guix build-system cmake)
    #:use-module (guix build-system trivial)
    #:use-module (guix download)
    #:use-module (guix git-download)
    #:use-module (guix packages)
    #:use-module (guix utils)
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
    #:use-module (gnu packages python)
    #:use-module (gnu packages perl)
    #:use-module ((guix licenses) #:prefix license:)
    #:use-module (gnu packages linux)
    #:use-module (gnu packages xdisorg)
    #:use-module (gnu packages vim)
)

(define-public libffi-shared
    (package (inherit libffi)
        (arguments
            (list
                #:phases
                #~(modify-phases %standard-phases
                    (add-after 'unpack 'set-CFLAGS
                        (lambda _ (setenv "CFLAGS" " -fPIC"))))))))


; llvm
(define %llvm-monorepo-hashes
    '(
        ("rocm-5.7.1" . "1bwqrsvl2gdygp8lqz25xifhmrqwmwjhjhdnc51dr7lc72f4ksfk")
        ("rocm-5.6.1" . "080pmr2f7hmnpgixikwrrj8pb67b2mw5c5s5649ik2rl8dyjnmmi")
        ("rocm-5.5.1" . "0g4w7grbl3qf96biflamhgf0f1hvzxnd747cc0kjzpqa1bfcfrhl")
        ("rocm-5.4.4" . "1q3jlnmyrrj5mhyx33xpnfdbi8ikw8r28rnq0fhxc5j307lw4fq4")
        ("rocm-5.3.3" . "06r4zrgjsaifnjc7lsp18nwkg6xvalfrlxmn0r7ixghnrhvkpai0")
    )
)

(define %llvm-patches
    '(
        ("rocm-5.7.1" . ("amd/patches/llvm-rocm-5.6.1.patch" "amd/patches/libomp-rocm-5.6.1.patch" "amd/patches/llvm-rocm-5.7.1-gtest.patch"))
        ("rocm-5.6.1" . ("amd/patches/llvm-rocm-5.6.1.patch" "amd/patches/libomp-rocm-5.6.1.patch"))
        ("rocm-5.5.1" . ("amd/patches/llvm-rocm-5.5.1.patch" "amd/patches/libomp-rocm-5.5.1.patch"))
        ("rocm-5.4.4" . ("amd/patches/rocm-5.4-llvm-project.patch"))
        ("rocm-5.3.3" . ("amd/patches/rocm-5.3-llvm-project.patch"))
    )
)

(define (llvm-rocm-monorepo version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/RadeonOpenCompute/llvm-project.git")
                (commit version)))
        (file-name (git-file-name "llvm-project" version))
        (sha256 (base32 (assoc-ref %llvm-monorepo-hashes version)))
        (patches (map search-patch (assoc-ref %llvm-patches version)))))

(define (make-llvm-rocm version)
    (package
        (inherit llvm-15)
        (version (string-append "rocm-" version))
        (source (llvm-rocm-monorepo version))
        (inputs (modify-inputs (package-inputs llvm-15) (replace "libffi" libffi-shared)))))

(define-public llvm-rocm-5.7 (make-llvm-rocm "5.7.1"))
(define-public llvm-rocm-5.6 (make-llvm-rocm "5.6.1"))
(define-public llvm-rocm-5.5 (make-llvm-rocm "5.5.1"))
(define-public llvm-rocm-5.4 (make-llvm-rocm "5.4.4"))
(define-public llvm-rocm-5.3 (make-llvm-rocm "5.3.3"))


; clang runtime
(define-public (make-clang-runtime-rocm llvm-rocm)
    (package
        (inherit clang-runtime-15)
        (version (package-version llvm-rocm))
        (source (llvm-rocm-monorepo version))
        (inputs (modify-inputs (package-inputs clang-runtime-15)
            (replace "llvm" llvm-rocm)
            (replace "libffi" libffi-shared)))))

(define-public clang-runtime-rocm-5.7 (make-clang-runtime-rocm llvm-rocm-5.7))
(define-public clang-runtime-rocm-5.6 (make-clang-runtime-rocm llvm-rocm-5.6))
(define-public clang-runtime-rocm-5.5 (make-clang-runtime-rocm llvm-rocm-5.5))
(define-public clang-runtime-rocm-5.4 (make-clang-runtime-rocm llvm-rocm-5.4))
(define-public clang-runtime-rocm-5.3 (make-clang-runtime-rocm llvm-rocm-5.3))


; clang
(define (make-clang-rocm llvm-rocm clang-runtime-rocm)
    (package
        (inherit clang-15)
        (version (package-version llvm-rocm))
        (source (llvm-rocm-monorepo version))
        (inputs (modify-inputs (package-inputs clang-15)
            (delete "clang-tools-extra")))
        (propagated-inputs (modify-inputs (package-propagated-inputs clang-15)
            (replace "llvm" llvm-rocm)
            (replace "clang-runtime" clang-runtime-rocm)))
        (arguments
            (substitute-keyword-arguments (package-arguments clang-15)
                ((#:phases phases '(@ () %standard-phases))
                    #~(modify-phases #$phases
                        (replace 'add-tools-extra
                            (lambda _ (copy-recursively "../clang-tools-extra" "tools/extra")))))))))

(define-public clang-rocm-5.7 (make-clang-rocm llvm-rocm-5.7 clang-runtime-rocm-5.7))
(define-public clang-rocm-5.6 (make-clang-rocm llvm-rocm-5.6 clang-runtime-rocm-5.6))
(define-public clang-rocm-5.5 (make-clang-rocm llvm-rocm-5.5 clang-runtime-rocm-5.5))
(define-public clang-rocm-5.4 (make-clang-rocm llvm-rocm-5.4 clang-runtime-rocm-5.4))
(define-public clang-rocm-5.3 (make-clang-rocm llvm-rocm-5.3 clang-runtime-rocm-5.5))


; lld
(define (make-lld-rocm llvm-rocm)
    (package
        (inherit lld-15)
        (version (package-version llvm-rocm))
        (source (llvm-rocm-monorepo version))
        (inputs (list llvm-rocm))))

(define-public lld-rocm-5.7 (make-lld-rocm llvm-rocm-5.7))
(define-public lld-rocm-5.6 (make-lld-rocm llvm-rocm-5.6))
(define-public lld-rocm-5.5 (make-lld-rocm llvm-rocm-5.5))
(define-public lld-rocm-5.4 (make-lld-rocm llvm-rocm-5.4))
(define-public lld-rocm-5.3 (make-lld-rocm llvm-rocm-5.3))


; rocm-device-libs
(define %rocm-device-libs-hashes
    '(
        ("5.7.1" . "1xc4g5qb8x5hgnvrpzxqxqbsdnwaff1r12aqb8a84mmj5bznq701")
        ("5.6.1" . "1jg96ycy99s9fis8sk1b7qx5p33anw16mqlm07zqbnhry2gqkcbh")
        ("5.5.1" . "0apwrwa8av5ylf318blwid4xgz6j6bgdpc4frgzwd8vsjwzwkmm8")
        ("5.4.4" . "069nc6yg5scp9r0mj8ckb7a5mg74dsavb2ls6fqi75c65n1ny37j")
        ("5.3.3" . "15bcgwy5azmx7ldimhz5mdmbrmi4wzdfwdwmznj3g4793z81x8xc")
    )
)

(define (rocm-device-libs-origin version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/RadeonopenCompute/ROCm-Device-Libs.git")
                (commit (string-append "rocm-" version))))
        (file-name (git-file-name "rocm-device-libs" version))
        (sha256 (base32 (assoc-ref %rocm-device-libs-hashes version)))))

(define (make-rocm-device-libs clang-rocm)
    (package
        (name "rocm-device-libs")
        (version (list-ref (string-split (package-version clang-rocm) #\-) 1)); extract version without the rocm prefix
        (source (rocm-device-libs-origin version))
        (build-system cmake-build-system)
        (arguments
            (list
                #:build-type "Release"
                #:tests? #f
                #:phases
                #~(modify-phases %standard-phases
                    (add-after 'unpack 'ockl_ocml_irif_inc
                        (lambda* (#:key outputs #:allow-other-keys)
                            (copy-recursively "irif/inc" (string-append (assoc-ref outputs "out") "/irif/inc"))
                            (copy-recursively "oclc/inc" (string-append (assoc-ref outputs "out") "/oclc/inc"))
                            (copy-recursively "ockl/inc" (string-append (assoc-ref outputs "out") "/ockl/inc")))))))
        (native-inputs (list clang-rocm))
        (synopsis "ROCm Device libraries")
        (description "This repository contains the sources and CMake build system for 
a set of AMD specific device-side language runtime libraries.")
        (home-page "https://github.com/RadeonOpenCompute/ROCm-Device-Libs.git")
        (license license:ncsa)))

(define-public rocm-device-libs-5.7 (make-rocm-device-libs clang-rocm-5.7))
(define-public rocm-device-libs-5.6 (make-rocm-device-libs clang-rocm-5.6))
(define-public rocm-device-libs-5.5 (make-rocm-device-libs clang-rocm-5.5))
(define-public rocm-device-libs-5.4 (make-rocm-device-libs clang-rocm-5.4))
(define-public rocm-device-libs-5.3 (make-rocm-device-libs clang-rocm-5.3))


; roct-thunk-interface
(define %roct-thunk-hashes
    '(
        ("5.7.1" . "075advkplqlj9y3m3bsww4yiz3qxrfmxwhcf0giaa9dzrn9020wc")
        ("5.6.1" . "0v8j4gkbb21gqqmz1b4nmampx5ywva99ipsx8lcjr5ckcg84fn9x")
        ("5.5.1" . "1digw626k4m3kzcyi89kvba8j69xj4agqgi4avqsnkq5yf0vw9cz")
        ("5.4.4" . "0can34ccy2dm31m0wq9hhrxb8ykd6jj8bn3gfrlycmdklahnskhi")
        ("5.3.3" . "1adzhpa38lfsk0xj0m09fm11ird84vc594nspmhwqqmf3q3zrkkh")
    )
)

(define (roct-thunk-origin version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/RadeonopenCompute/ROCT-Thunk-Interface.git")
                (commit (string-append "rocm-" version))))
        (file-name (git-file-name "roct-thunk-interface" version))
        (sha256 (base32 (assoc-ref %roct-thunk-hashes version)))))

(define (make-roct-thunk version)
    (package
        (name "roct-thunk-interface")
        (version version)
        (source (roct-thunk-origin version))
        (build-system cmake-build-system)
        (arguments (list #:build-type "Release" #:tests? #f))
        (inputs (list libdrm numactl))
        (native-inputs (list `(,gcc "lib") pkg-config))
        (synopsis "ROCT Thunk interface")
        (description "This repository includes the user-mode API interfaces used
to interact with the ROCk driver.")
        (home-page "https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface.git")
        (license license:expat)))

(define-public roct-thunk-5.7 (make-roct-thunk "5.7.1"))
(define-public roct-thunk-5.6 (make-roct-thunk "5.6.1"))
(define-public roct-thunk-5.5 (make-roct-thunk "5.5.1"))
(define-public roct-thunk-5.4 (make-roct-thunk "5.4.4"))
(define-public roct-thunk-5.3 (make-roct-thunk "5.3.3"))


; rocr-runtime
(define %rocr-runtime-hashes
    '(
        ("5.7.1" . "02g53357i15d8laxlhvib7h01kfarlq8hyfm7rm3ii2wgrm23c0g")
        ("5.6.1" . "07wh7s1kgvpw8ydxmr2wvvn05fdqcmcc20qjbmnc3cbbhxviksyr")
        ("5.5.1" . "0zhqlbnkq2w0zqdqiqk4l2mksy618fl0zivkp2h6f5pjfnishpw9")
        ("5.4.4" . "09kpnfn5vpfcjh0amxbk1885hyib9jbisfmh2p9224cx156xfi16")
        ("5.3.3" . "18hf3abq6g7hyxlkfzd61a661j8lxgq42nkarrs2x5491ny3p8fv")
    )
)

(define %rocr-runtime-patches
    '(
        ("5.7.1" . ("amd/patches/rocr-runtime-5.5.patch"))
        ("5.6.1" . ("amd/patches/rocr-runtime-5.5.patch"))
        ("5.5.1" . ("amd/patches/rocr-runtime-5.5.patch"))
        ("5.4.4" . ("amd/patches/rocr-runtime-5.3.3.patch"))
        ("5.3.3" . ("amd/patches/rocr-runtime-5.3.3.patch"))
    )
)

(define (rocr-runtime-origin version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/RadeonOpenCompute/ROCR-Runtime.git")
                (commit (string-append "rocm-" version))))
        (file-name (git-file-name "rocr-runtime" version))
        (sha256 (base32 (assoc-ref %rocr-runtime-hashes version)))
        (patches (map search-patch (assoc-ref %rocr-runtime-patches version)))))

(define (make-rocr-runtime roct-thunk rocm-device-libs lld-rocm clang-rocm)
    (package
        (name "rocr-runtime")
        (version (package-version rocm-device-libs))
        (source (rocr-runtime-origin version))
        (build-system cmake-build-system)
        (arguments
            (list
                #:build-type "Release"
                #:tests? #f ; No tests.
                #:configure-flags
                #~(list
                    (string-append "-DBITCODE_DIR=" #$(this-package-input "rocm-device-libs") "/amdgcn/bitcode/")
                )
                #:phases
                #~(modify-phases %standard-phases
                    (add-after 'unpack 'chdir
                        (lambda _ (chdir "src"))))))
        (inputs (list numactl roct-thunk rocm-device-libs libdrm libffi))
        (native-inputs (list xxd libelf lld-rocm clang-rocm pkg-config))
        (synopsis "HSA Runtime API and runtime for ROCm")
        (description "This repository includes the user-mode API interfaces and 
libraries necessary for host applications to launch compute kernels to 
available HSA ROCm kernel agents. Reference source code for the 
core runtime is also available.")
        (home-page "https://github.com/RadeonOpenCompute/ROCR-Runtime.git")
        (license license:ncsa)))

(define-public rocr-runtime-5.7 (make-rocr-runtime roct-thunk-5.7 rocm-device-libs-5.7 lld-rocm-5.7 clang-rocm-5.7))
(define-public rocr-runtime-5.6 (make-rocr-runtime roct-thunk-5.6 rocm-device-libs-5.6 lld-rocm-5.6 clang-rocm-5.6))
(define-public rocr-runtime-5.5 (make-rocr-runtime roct-thunk-5.5 rocm-device-libs-5.5 lld-rocm-5.5 clang-rocm-5.5))
(define-public rocr-runtime-5.4 (make-rocr-runtime roct-thunk-5.4 rocm-device-libs-5.4 lld-rocm-5.4 clang-rocm-5.4))
(define-public rocr-runtime-5.3 (make-rocr-runtime roct-thunk-5.3 rocm-device-libs-5.3 lld-rocm-5.3 clang-rocm-5.3))

; lld-wrapper
(define-public lld-wrapper-rocm-5.7 (make-lld-wrapper lld-rocm-5.7))
(define-public lld-wrapper-rocm-5.6 (make-lld-wrapper lld-rocm-5.6))
(define-public lld-wrapper-rocm-5.5 (make-lld-wrapper lld-rocm-5.5))
(define-public lld-wrapper-rocm-5.4 (make-lld-wrapper lld-rocm-5.4))
(define-public lld-wrapper-rocm-5.3 (make-lld-wrapper lld-rocm-5.3))


; libomp
(define (make-libomp-rocm llvm-rocm clang-rocm lld-rocm rocm-device-libs rocr-runtime roct-thunk)
    (package
        (inherit libomp-15)
        (version (package-version llvm-rocm))
        (source (llvm-rocm-monorepo version))
        (native-inputs
            (append
                (list `("gcc:lib" ,gcc "lib"))
                (modify-inputs (package-native-inputs libomp-15)
                    (replace "clang" clang-rocm)
                    (replace "llvm"  llvm-rocm)
                    (replace "python"  python-wrapper)
                    (append lld-rocm)
                    (append elfutils))
            )
        )
        (inputs (modify-inputs (package-inputs libomp-15)
            (append libdrm)     ; required for rocm-5.7 onwards
            (append numactl)    ; required for rocm-5.7 onwards
            (append roct-thunk) ; required for rocm-5.7 onwards
            (append libffi-shared)
            (append rocm-device-libs)
            (append rocr-runtime)))
        (arguments
            (substitute-keyword-arguments (package-arguments libomp-15)
                ((#:configure-flags flags)
                 #~(append
                    (list "-DOPENMP_ENABLE_LIBOMPTARGET=1"
                          "-DCMAKE_C_COMPILER=clang"
                          "-DCMAKE_CXX_COMPILER=clang++"
                          "-DCMAKE_BUILD_TYPE=Release"                 ;strictly speaking unnecesary as debug will be stripped
                          "-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld"      ;can be removed if we use lld-as-ld-wrapper 
                          "-DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld"   ;can be removed if we use lld-as-ld-wrapper
                          "-DLIBOMPTARGET_AMDGCN_GFXLIST=gfx906;gfx908;gfx90a;gfx940;gfx1030"
                          (string-append "-DDEVICELIBS_ROOT=" #$(this-package-input "rocm-device-libs"))
                          (string-append "-DCLANG_BINARY_DIR=" #$(this-package-native-input "clang") "/bin")
                          (string-append "-DLLVM_DIR=" #$(this-package-native-input "llvm")))
                    #$flags))
                ((#:phases phases '(@ () %standard-phases))
                    #~(modify-phases #$phases
                        (add-after 'set-paths 'adjust-LD_LIBRARY_PATH
                            (lambda* (#:key inputs #:allow-other-keys)
                                (setenv "LD_LIBRARY_PATH"
                                    (string-append (assoc-ref inputs "llvm") "/lib" ":"
                                                                (assoc-ref inputs "gcc:lib") "/lib"))))))))))

(define-public libomp-rocm-5.7 (make-libomp-rocm llvm-rocm-5.7 clang-rocm-5.7 lld-wrapper-rocm-5.7 rocm-device-libs-5.7 rocr-runtime-5.7 roct-thunk-5.7))
(define-public libomp-rocm-5.6 (make-libomp-rocm llvm-rocm-5.6 clang-rocm-5.6 lld-wrapper-rocm-5.6 rocm-device-libs-5.6 rocr-runtime-5.6 roct-thunk-5.6))
(define-public libomp-rocm-5.5 (make-libomp-rocm llvm-rocm-5.5 clang-rocm-5.5 lld-wrapper-rocm-5.5 rocm-device-libs-5.5 rocr-runtime-5.5 roct-thunk-5.5))
(define-public libomp-rocm-5.4 (make-libomp-rocm llvm-rocm-5.4 clang-rocm-5.4 lld-wrapper-rocm-5.4 rocm-device-libs-5.4 rocr-runtime-5.4 roct-thunk-5.4))
(define-public libomp-rocm-5.3 (make-libomp-rocm llvm-rocm-5.3 clang-rocm-5.3 lld-wrapper-rocm-5.3 rocm-device-libs-5.3 rocr-runtime-5.3 roct-thunk-5.3))



; rocm-toolchain
(define (make-rocm-toolchain clang-rocm libomp-rocm lld-wrapper-rocm rocr-runtime rocm-device-libs)
    (let ((rocm-clang-toolchain (make-clang-toolchain clang-rocm libomp-rocm)))
        (package
            (inherit rocm-clang-toolchain)
            (name "rocm-toolchain")
            (version (list-ref (string-split (package-version rocm-clang-toolchain) #\-) 1)); extract version without the rocm prefix
            (inputs (modify-inputs (package-inputs rocm-clang-toolchain)
                (append lld-wrapper-rocm rocr-runtime rocm-device-libs)))
            (synopsis "Complete ROCm toolchain, based on the Clang toolchain, for C/C++ development")
            (description "This package provides a complete ROCm toolchain for C/C++
development to be installed in user profiles. This includes Clang, as well as
libc (headers and binaries, plus debugging symbols in the @code{debug}
output), Binutils, the ROCm device libraries, and the ROCr runtime."))))

(define-public rocm-toolchain-5.7 (make-rocm-toolchain clang-rocm-5.7 libomp-rocm-5.7 lld-wrapper-rocm-5.7 rocr-runtime-5.7 rocm-device-libs-5.7))
(define-public rocm-toolchain-5.6 (make-rocm-toolchain clang-rocm-5.6 libomp-rocm-5.6 lld-wrapper-rocm-5.6 rocr-runtime-5.6 rocm-device-libs-5.6))
(define-public rocm-toolchain-5.5 (make-rocm-toolchain clang-rocm-5.5 libomp-rocm-5.5 lld-wrapper-rocm-5.5 rocr-runtime-5.5 rocm-device-libs-5.5))
(define-public rocm-toolchain-5.4 (make-rocm-toolchain clang-rocm-5.4 libomp-rocm-5.4 lld-wrapper-rocm-5.4 rocr-runtime-5.4 rocm-device-libs-5.4))
(define-public rocm-toolchain-5.3 (make-rocm-toolchain clang-rocm-5.3 libomp-rocm-5.3 lld-wrapper-rocm-5.3 rocr-runtime-5.3 rocm-device-libs-5.3))
