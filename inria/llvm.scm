(define-module (inria llvm)
  #:use-module (guix)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (gnu packages)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages python)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages check)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

; FIXME: deduplicate and use functions from guix's llvm
(define %llvm-monorepo-hashes
  `(("14.0.6" . ,(base32 "14f8nlvnmdkp9a9a79wv67jbmafvabczhah8rwnqrgd5g3hfxxxx"))
    ("15.0.7" . ,(base32 "12sggw15sxq1krh1mfk3c1f07h895jlxbcifpwk3pznh4m1rjfy2"))))

(define (llvm-uri component version)
  ;; LLVM release candidate file names are formatted 'tool-A.B.C-rcN/tool-A.B.CrcN.src.tar.xz'
  ;; so we specify the version as A.B.C-rcN and delete the hyphen when referencing the file name.
  (string-append "https://github.com/llvm/llvm-project/releases/download"
                 "/llvmorg-"
                 version
                 "/"
                 component
                 "-"
                 (string-delete #\- version)
                 ".src.tar.xz"))

(define (llvm-monorepo version)
  (origin
    (method git-fetch)
    (uri (git-reference (url "https://github.com/llvm/llvm-project")
                        (commit (string-append "llvmorg-" version))))
    (file-name (git-file-name "llvm-project" version))
    (sha256 (assoc-ref %llvm-monorepo-hashes version))
; This patch is here to let us build flang "standalone".
; Currently flang's documentation instruct to use an LLVM *build* folder for
; the standalone build, but for other LLVM projects we usually use an
; *installed* version. This patch fixes the detection of MLIR tablegen to let
; us use an installed version of LLVM.
    (patches (search-patches "inria/patches/flang.patch"))))

(define* (mlir-from-llvm llvm
                         #:optional hash
                         (patches '()))
  (package
    (name "mlir")
    (version (package-version llvm))
    (source (if hash
                (origin
                  (method url-fetch)
                  (uri (llvm-uri "mlir" version))
                  (sha256 (base32
                           hash))
                  (patches (map search-patch patches)))
                (llvm-monorepo (package-version llvm))))
    (build-system cmake-build-system)
    (native-inputs (package-native-inputs llvm))
    (inputs (list llvm))
    (arguments
     `(#:build-type "Release"
       ;; These two options let us install mlir-tblgen!
       #:configure-flags '("-DLLVM_BUILD_UTILS=ON"
                           "-DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF")
       #:tests? #f ;Tests require gtest
       #:modules ((srfi srfi-1)
                  (ice-9 match)
                  ,@%cmake-build-system-modules)))
    (home-page "https://mlir.llvm.org/")
    (synopsis "Multi-Level Intermediate Representation library")
    (description "Novel approach to building reusable and extensible compiler
infrastructure. MLIR aims to address software fragmentation, improve compilation
for heterogeneous hardware, significantly reduce the cost of building domain
specific compilers, and aid in connecting existing compilers together.")
    (license (package-license llvm))))

(define-public mlir-15
  (let ((template (mlir-from-llvm llvm-15)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases
           #~(@ (guix build cmake-build-system) %standard-phases))
          #~(modify-phases #$phases
              (add-after 'unpack 'change-directory
                (lambda _
                  (chdir "mlir"))))))))))

(define* (flang-from-llvm llvm clang mlir)
  (package
    (name "flang")
    (version (package-version llvm))
    (source (llvm-monorepo (package-version llvm)))
    (native-inputs (package-native-inputs llvm))
    (inputs (list llvm clang mlir))
    (arguments
     (list ;Don't use '-g' during the build to save space.
           #:build-type "Release"
           ;; Yep, for flang we definitely don't want parallel build :(
           #:parallel-build? #f
           #:tests? #f ;Tests require gtest
           #:configure-flags #~(list (string-append "-DCLANG_DIR="
                                                    #$(this-package-input
                                                       "clang")
                                                    "/lib/cmake/clang"))
           #:modules `((srfi srfi-1)
                       (ice-9 match)
                       ,@%cmake-build-system-modules)))
    (build-system cmake-build-system)
    (home-page "https://flang.llvm.org/")
    (synopsis "Fortran compiler")
    (description "Ground-up implementation of a Fortran front end written in
modern C++. While it is capable of generating executables for a number of
examples, some functionalities are still missing.")
    (license (package-license llvm))))

(define-public flang-15
  (let ((template (flang-from-llvm llvm-15 clang-15 mlir-15)))
    (package
      (inherit template)
      (arguments
       (substitute-keyword-arguments (package-arguments template)
         ((#:phases phases
           #~(@ (guix build cmake-build-system) %standard-phases))
          #~(modify-phases #$phases
              (add-after 'unpack 'change-directory
                (lambda _
                  (chdir "flang"))))))))))
