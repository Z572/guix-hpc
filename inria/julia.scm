(define-module (inria julia)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module ((guix search-paths)
                #:select ($SSL_CERT_FILE))
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages julia)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libunwind)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages multiprecision) ;mpfr
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages web)
  #:use-module (gnu packages wget)
  #:use-module (ice-9 match))

(define-public pcre2-julia
  (package
    (inherit pcre2)
    (name "pcre2")
    (version "10.42")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/PCRE2Project/pcre2"
                           "/releases/download/pcre2-"
                           version
                           "/pcre2-"
                           version
                           ".tar.bz2"))
       (sha256
        (base32 "0h78np8h3dxlmvqvpnj558x67267n08n9zsqncmlqapans6csdld"))))))

(define-public llvm-14-julia
  (package
    (inherit llvm-14)
    (source
      (origin
        (method git-fetch)
        (uri (git-reference (url "https://github.com/JuliaLang/llvm-project")
                            (commit "julia-14.0.6-3")))
        (file-name (git-file-name "llvm-project-julia" "14.0.6-3"))
        (sha256
          (base32
            "16ynl9g4paksvglk6asfxdr15gy21bzvsjdkqb1msbcnkz2x610x"))))
    (arguments
     (substitute-keyword-arguments (package-arguments llvm-14)
       ((#:configure-flags flags
         ''())
        ; FIXME: I think we should basically duplicate
        ; https://github.com/JuliaLang/julia/blob/master/deps/llvm.mk
        #~(cons* "-DLLVM_BUILD_LLVM_DYLIB=ON"
                 "-DLLVM_LINK_LLVM_DYLIB=ON"
                 "-DLLVM_SHLIB_SYMBOL_VERSION:STRING=JL_LLVM_14.0"
                 "-DLLVM_VERSION_SUFFIX:STRING=jl" ;Perhaps not needed.
                 #$(string-append "-DLLVM_TARGETS_TO_BUILD=NVPTX;AMDGPU;"
                                  (system->llvm-target))
                 (delete "-DBUILD_SHARED_LIBS:BOOL=TRUE"
                         #$flags)))
       ((#:build-type _)
        "Release")))
    (properties `((hidden? . #t) ,@(package-properties llvm-14)))))

(define libunwind-julia
  ;; The Julia projects requires their patched version.
  ;; Get from https://github.com/JuliaLang/julia/tree/master/deps/patches
  (package
    (inherit libunwind)
    (name "libunwind-julia")
    (version "1.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://savannah/libunwind/libunwind-" version
                           ".tar.gz"))
       (sha256
        (base32 "05qhzcg1xag3l5m3c805np6k342gc0f3g087b7g16jidv59pccwh"))
       (patches (list (julia-patch "libunwind-prefer-extbl"
                       "0pf3lsq6zxlmqn86lk4fcj1xwdan9gbxyabrwgxcb59p8jjwsl8r")
                      (julia-patch "libunwind-static-arm"
                       "1jk3bmiw61ypcchqkk1fyg5wh8wpggk574wxyfyaic870zh3lhgq")
                      (julia-patch "libunwind-cfa-rsp"
                       "0qs5b1h5lsr5qakkv6sddgy5ghlxpjrn2jiqcvg7bkczy24klr6j")))))
    (arguments
     (substitute-keyword-arguments (package-arguments libunwind)
       ;; Skip tests on this older and patched version of libunwind.
       ((#:tests? _ #t)
        #f)))
    (home-page "https://github.com/JuliaLang/julia/tree/master/deps/")))

(define (julia-patch-url version name)
  (string-append "https://raw.githubusercontent.com/JuliaLang/julia/v" version
                 "/deps/patches/" name ".patch"))

(define-public julia
  (package
    (name "julia")
    (version "1.9.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/JuliaLang/julia/releases/download/v" version
             "/julia-" version ".tar.gz"))
       (sha256
        (base32 "0788hbcr1v89crv2j3insy89lxs0zwjbxk9q73jpj4g7j26bszcd"))
       (patches (search-patches "julia-SOURCE_DATE_EPOCH-mtime.patch"
                                "inria/patches/julia.patch"))))
    (build-system gnu-build-system)
    (arguments
     `(#:test-target "test"
       #:modules ((ice-9 match)
                  (guix build gnu-build-system)
                  (guix build utils))

       ;; The test suite takes many times longer than building and
       ;; can easily fail on smaller machines when they run out of memory.
       ;; FIXME: they work, but let's speed up the build process atm
       #:tests? #f
       ;; #:tests? ,(not (or (%current-target-system)
       ;; (target-aarch64?)))
       
       ;; Do not strip binaries to keep support for full backtraces.
       ;; See https://github.com/JuliaLang/julia/issues/17831
       #:strip-binaries? #f

       ;; The DSOs use $ORIGIN to refer to each other, but (guix build
       ;; gremlin) doesn't support it yet, so skip this phase.
       #:validate-runpath? #f

       #:phases (modify-phases %standard-phases
                  (delete 'configure)
                  (add-after 'unpack 'prepare-deps
                    (lambda* (#:key inputs #:allow-other-keys)
                      ;; needed by libwhich
                      (setenv "LD_LIBRARY_PATH"
                              (string-join (map (lambda (pkg)
                                                  (string-append (assoc-ref
                                                                  inputs pkg)
                                                                 "/lib"))
                                                '("curl" "dsfmt"
                                                  "gmp"
                                                  "lapack"
                                                  "libssh2"
                                                  "libnghttp2"
                                                  "libgit2"
                                                  "libblastrampoline"
                                                  "mbedtls-apache"
                                                  "mpfr"
                                                  "openblas"
                                                  "openlibm"
                                                  "pcre2"
                                                  "suitesparse"
                                                  "gfortran:lib")) ":"))))
                  (add-before 'check 'set-home
                    ;; Some tests require a home directory to be set.
                    (lambda _
                      (setenv "HOME" "/tmp")))
                  (add-before 'build 'fix-include-and-link-paths
                    (lambda* (#:key inputs #:allow-other-keys)
                      ;; The REPL must be linked with libuv.
                      (substitute* "cli/Makefile"
                        (("JLDFLAGS \\+= ")
                         (string-append "JLDFLAGS += "
                                        (assoc-ref inputs "libuv")
                                        "/lib/libuv.so ")))))
                  (add-before 'build 'fix-nested-dlopen
                    (lambda* (#:key inputs #:allow-other-keys)
                      (substitute* "Make.inc"
                        ;; See the patch comment for the explanation, *must* be updated
                        ;; when updating julia.
                        (("GUIX_LIBUTF8PROC")
                         (string-append (assoc-ref inputs "utf8proc")
                                        "/lib/libutf8proc.a")))
                      (substitute* "Makefile"
                        ;; See the patch comment for the explanation, *must* be updated
                        ;; when updating julia.
                        (("GUIX_LIBCHOLMOD")
                         (string-append (assoc-ref inputs "suitesparse")
                                        "/lib/libcholmod.so"))
                        (("GUIX_LIBSPQR")
                         (string-append (assoc-ref inputs "suitesparse")
                                        "/lib/libspqr.so"))
                        (("GUIX_LIBSC")
                         (string-append (assoc-ref inputs "suitesparse")
                                        "/lib/libsuitesparseconfig.so"))
                        (("GUIX_LIBUMFPACK")
                         (string-append (assoc-ref inputs "suitesparse")
                                        "/lib/libumfpack.so")))))
                  (add-before 'build 'replace-default-shell
                    (lambda* (#:key inputs #:allow-other-keys)
                      (substitute* "base/client.jl"
                        (("/bin/sh")
                         (search-input-file inputs "/bin/sh")))))
                  (add-before 'build 'shared-objects-paths
                    (lambda* (#:key inputs #:allow-other-keys)
                      (let ((jlpath (lambda (pkgname)
                                      (string-append "stdlib/" pkgname
                                                     "_jll/src/" pkgname
                                                     "_jll.jl")))
                            (jlbasepath (lambda (pkgname)
                                          (string-append "base/" pkgname ".jl")))
                            (tolib (lambda (pkg libname)
                                     (string-append (assoc-ref inputs pkg)
                                                    "/lib/" libname ".so")))
                            (toquotedlib (lambda (pkg libname)
                                           (string-append "\""
                                                          (assoc-ref inputs
                                                                     pkg)
                                                          "/lib/" libname
                                                          ".so\"")))
                            (from (lambda (libname)
                                    (string-append "const " libname
                                                   " = .*\\.so")))
                            (to (lambda* (pkg libname
                                              #:optional libname_jl)
                                  (string-append "const "
                                                 (or libname_jl libname)
                                                 " = \""
                                                 (assoc-ref inputs pkg)
                                                 "/lib/"
                                                 libname
                                                 ".so"))))
                        (substitute* "src/jitlayers.cpp"
                          (("libatomic.so")
                           (string-append (assoc-ref inputs "gfortran:lib")
                                          "/lib/libatomic.so")))
                        (substitute* (jlbasepath "linking")
                          (("\"lld\"")
                           (string-append "\""
                                          (assoc-ref inputs "lld")
                                          "/bin/lld\"")))
                        (substitute* (jlpath "LLD")
                          (("\"lld\"")
                           (string-append "\""
                                          (assoc-ref inputs "lld")
                                          "/bin/lld\"")))
                        (substitute* (jlbasepath "pcre")
                          (("libpcre2-8")
                           (tolib "pcre2" "libpcre2-8")))
                        (substitute* (jlbasepath "gmp")
                          (("libgmp.so.10")
                           (tolib "gmp" "libgmp")))
                        (substitute* (jlbasepath "mpfr")
                          (("libmpfr.so.6")
                           (tolib "mpfr" "libmpfr")))
                        (substitute* (jlbasepath "irrationals")
                          ((":libmpfr")
                           (toquotedlib "mpfr" "libmpfr")))
                        (substitute* "stdlib/Random/src/generation.jl"
                          ((":libmpfr")
                           (toquotedlib "mpfr" "libmpfr")))
                        (substitute* "stdlib/Printf/src/Printf.jl"
                          (("\"libmpfr\"")
                           (toquotedlib "mpfr" "libmpfr")))
                        (substitute* "stdlib/Random/src/DSFMT.jl"
                          ((":libdSFMT")
                           (toquotedlib "dsfmt" "libdSFMT")))
                        (for-each (lambda (file)
                                    (substitute* file
                                      ((":libgit2")
                                       (toquotedlib "libgit2" "libgit2"))))
                                  (find-files "stdlib/LibGit2/" "\\.jl$"))
                        (substitute* (jlpath "CompilerSupportLibraries")
                          (((from "libgomp"))
                           (to "gfortran:lib" "libgomp"))
                          (((from "libgfortran"))
                           (string-append "const libgfortran = string(\""
                                          (search-input-file inputs
                                           "/lib/libgfortran.so"))))
                        (substitute* (jlpath "dSFMT")
                          (((from "libdSFMT"))
                           (to "dsfmt" "libdSFMT")))
                        (substitute* (jlpath "GMP")
                          (((from "libgmp"))
                           (to "gmp" "libgmp"))
                          (((from "libgmpxx"))
                           (to "gmp" "libgmpxx")))
                        (substitute* (jlpath "libLLVM")
                          (((from "libLLVM"))
                           (to "llvm" "libLLVM")))
                        (substitute* (jlbasepath "binaryplatforms")
                          (("libLLVM-14jl")
                           (tolib "llvm" "libLLVM-14jl")))
                        (substitute* (jlpath "LibCURL")
                          (((from "libcurl"))
                           (to "curl" "libcurl")))
                        (substitute* (jlpath "LibGit2")
                          (((from "libgit2"))
                           (to "libgit2" "libgit2")))
                        (substitute* (jlpath "LibSSH2")
                          (((from "libssh2"))
                           (to "libssh2" "libssh2")))
                        (substitute* (jlpath "LibUV")
                          (((from "libuv"))
                           (to "libuv" "libuv")))
                        (substitute* (jlpath "LibUnwind")
                          (((from "libunwind"))
                           (to "libunwind" "libunwind")))
                        (substitute* (jlpath "MPFR")
                          (((from "libmpfr"))
                           (to "mpfr" "libmpfr")))
                        (substitute* (jlpath "MbedTLS")
                          (((from "libmbedcrypto"))
                           (to "mbedtls-apache" "libmbedcrypto"))
                          (((from "libmbedtls"))
                           (to "mbedtls-apache" "libmbedtls"))
                          (((from "libmbedx509"))
                           (to "mbedtls-apache" "libmbedx509")))
                        (substitute* (jlpath "nghttp2")
                          (((from "libnghttp2"))
                           (to "libnghttp2" "libnghttp2")))
                        (substitute* (jlpath "OpenBLAS")
                          (("libgfortran.so")
                           (tolib "gfortran:lib" "libgfortran"))
                          (((from "libopenblas"))
                           ,@(if (target-x86-64?)
                                 `((to "openblas" "libopenblas64_"
                                       "libopenblas"))
                                 `((to "openblas" "libopenblas")))))
                        (substitute* (jlpath "OpenLibm")
                          (((from "libopenlibm"))
                           (to "openlibm" "libopenlibm")))
                        (substitute* (jlpath "PCRE2")
                          (((from "libpcre2_8"))
                           (to "pcre2" "libpcre2-8" "libpcre2_8")))
                        (substitute* (jlpath "SuiteSparse")
                          (((from "libamd"))
                           (to "suitesparse" "libamd"))
                          (((from "libbtf"))
                           (to "suitesparse" "libbtf"))
                          (((from "libcamd"))
                           (to "suitesparse" "libcamd"))
                          (((from "libccolamd"))
                           (to "suitesparse" "libccolamd"))
                          (((from "libcholmod"))
                           (to "suitesparse" "libcholmod"))
                          (((from "libcolamd"))
                           (to "suitesparse" "libcolamd"))
                          (((from "libklu"))
                           (to "suitesparse" "libklu"))
                          (((from "libldl"))
                           (to "suitesparse" "libldl"))
                          (((from "librbio"))
                           (to "suitesparse" "librbio"))
                          (((from "libspqr"))
                           (to "suitesparse" "libspqr"))
                          (((from "libsuitesparse"))
                           (to "suitesparse" "libsuitesparse"))
                          (((from "libsuitesparseconfig"))
                           (to "suitesparse" "libsuitesparseconfig"))
                          (((from "libumfpack"))
                           (to "suitesparse" "libumfpack")))
                        (substitute* (jlpath "Zlib")
                          (((from "libz"))
                           (to "zlib" "libz")))
                        (substitute* (jlpath "libblastrampoline")
                          (("libblastrampoline\\.so")
                           (search-input-file inputs
                                              "/lib/libblastrampoline.so"))))))
                  (add-before 'build 'use-ssl-cert-file
                    (lambda _
                      ;; We must adapt MozillaCACerts to use SSL_CERT_FILE.
                      (substitute* "stdlib/MozillaCACerts_jll/src/MozillaCACerts_jll.jl"
                        (("global cacert = .*")
                         (string-append
                          "global cacert = get(ENV, \"SSL_CERT_FILE\","
                          ;; our fallback location.
                          "\"/etc/ssl/certs/ca-certificates.crt\")\n")))))
                  (add-after 'unpack 'enable-parallel-tests
                    (lambda* (#:key parallel-tests? #:allow-other-keys)
                      (when parallel-tests?
                        (setenv "JULIA_TEST_USE_MULTIPLE_WORKERS" "true"))))
                  (add-after 'unpack 'adjust-test-suite
                    (lambda* (#:key inputs #:allow-other-keys)
                      (substitute* "test/spawn.jl"
                        (("shcmd = `sh`")
                         (string-append "shcmd = `"
                                        (which "sh") "`")))))
                  (add-before 'check 'disable-broken-tests
                    (lambda* (#:key inputs #:allow-other-keys)
                      ;; disabling REPL tests because they require a stdin
                      ;; There are some read-only precompile issues in the 1.6 series.
                      ;; https://github.com/JuliaLang/julia/pull/41614
                      ;; https://github.com/JuliaLang/julia/issues/41156
                      (substitute* "test/choosetests.jl"
                        (("\"cmdlineargs\",")
                         "")
                        (("\"precompile\",")
                         ""))
                      ;; Distributed test with remote execution
                      (substitute* "usr/share/julia/stdlib/v1.9/Distributed/test/distributed_exec.jl"
                        (("using Test,")
                         "exit()\n"))
                      ;; Dates/io tests fail on master when networking is unavailable
                      ;; https://github.com/JuliaLang/julia/issues/34655
                      (substitute* "stdlib/Dates/test/io.jl"
                        (("using Dates")
                         "import Dates
using Dates: @dateformat_str, Date, DateTime, DateFormat, Time"))
                      ;; julia embeds a certificate, we are not doing that
                      (substitute* "stdlib/MozillaCACerts_jll/test/runtests.jl"
                        (("@test isfile\\(MozillaCACerts_jll.cacert\\)")
                         "@test_broken isfile(MozillaCACerts_jll.cacert)"))
                      ;; since certificate is not present some tests are failing in network option
                      (substitute* "usr/share/julia/stdlib/v1.9/NetworkOptions/test/runtests.jl"
                        (("@test isfile\\(bundled_ca_roots\\(\\)\\)")
                         "@test_broken isfile(bundled_ca_roots())")
                        (("@test ispath\\(ca_roots_path\\(\\)\\)")
                         "@test_broken ispath(ca_roots_path())")
                        (("@test ca_roots_path\\(\\) \\!= bundled_ca_roots\\(\\)")
                         "@test_broken ca_roots_path() != bundled_ca_roots()"))
                      ;; WARNING: failed to select UTF-8 encoding, using ASCII
                      ;; Using 'setlocale' doesn't affect the test failures.
                      ;; (setlocale LC_ALL "en_US.utf8")
                      ;; (setenv "LC_ALL" "en_US.utf8")
                      (substitute* "test/cmdlineargs.jl"
                        (("test v\\[3")
                         "test_broken v[3")
                        (("test isempty\\(v\\[3")
                         "test_broken isempty(v[3"))
                      ;; These test(s) randomly fails because they depend on CPU.
                      (substitute* "test/math.jl"
                        ;; @test_broken cannot be used because if the test randomly
                        ;; passes, then it also raises an error.
                        (("@test isinf\\(log1p\\(-one\\(T\\)\\)\\)")
                         " "))

                      ;; These are new test failures for 1.8:
                      ;; This test passes on some architectures and fails on others.
                      (substitute* "stdlib/LinearAlgebra/test/lu.jl"
                        (("@test String")
                         "@test_skip String"))

                      (substitute* "usr/share/julia/stdlib/v1.9/Statistics/test/runtests.jl"
                        (("@test cov\\(A")
                         "@test_skip cov(A")
                        (("@test isfinite")
                         "@test_skip isfinite"))
                      ;; LoadError: SuiteSparse threads test failed with nthreads == 4
                      (substitute* "usr/share/julia/stdlib/v1.9/SuiteSparse/test/runtests.jl"
                        (("Base\\.USE_GPL_LIBS")
                         "false"))
                      ;; Got exception outside of a @test
                      ;; LinearAlgebra.LAPACKException(16)
                      ;; eliminate all the test bits.
                      (substitute* "stdlib/LinearAlgebra/test/schur.jl"
                        (("f = schur\\(A, B\\)")
                         "f = schur(A, A)")
                        (("@test f\\.Q\\*f\\.S\\*f\\.Z'.*")
                         "\n")
                        (("@test f\\.Q\\*f\\.T\\*f\\.Z'.*")
                         "\n"))))
                  ;; Doesn't this just mean they weren't linked correctly?
                  (add-after 'install 'symlink-missing-libraries
                    (lambda* (#:key inputs outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (link (lambda (pkgname pred)
                                     (map (lambda (file)
                                            (unless (file-exists? (string-append
                                                                   out
                                                                   "/lib/julia/"
                                                                   (basename
                                                                    file)))
                                              (symlink file
                                                       (string-append out
                                                        "/lib/julia/"
                                                        (basename file)))))
                                          (find-files (string-append (assoc-ref
                                                                      inputs
                                                                      pkgname)
                                                                     "/lib")
                                                      pred)))))
                        (link "libunwind" "libunwind\\.so")
                        (link "llvm" "libLLVM-14jl\\.so")
                        (link "gmp" "libgmp\\.so.10")
                        (link "mpfr" "libmpfr\\.so.6")
                        (link "zlib" "libz\\.so"))))
                  (add-after 'install 'make-wrapper
                    (lambda* (#:key inputs outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (bin (string-append out "/bin"))
                             (program "julia"))
                        (with-directory-excursion bin
                          (wrap-program program
                            `("JULIA_LOAD_PATH" ":" prefix
                              ("" "$JULIA_LOAD_PATH"))
                            `("JULIA_DEPOT_PATH" ":" prefix
                              ("" "$JULIA_DEPOT_PATH"))))))))
       #:make-flags (list (string-append "prefix="
                                         (assoc-ref %outputs "out"))

                          ;; Passing the MARCH or JULIA_CPU_TARGET flag is necessary to build
                          ;; binary substitutes for the supported architectures.  See also
                          ;; https://docs.julialang.org/en/v1/devdocs/sysimg/#Specifying-multiple-system-image-targets
                          ,(match (or (%current-target-system)
                                      (%current-system))
                             ("x86_64-linux"
                              ;; These are the flags that upstream uses for their binaries.
                              "JULIA_CPU_TARGET=generic;generic,-cx16,clone_all;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)")
                             ("i686-linux" "MARCH=pentium4")
                             ("armhf-linux" "JULIA_CPU_TARGET=armv7-a,neon")
                             ("powerpc64le-linux" "JULIA_CPU_TARGET=pwr8")
                             ;; Prevent errors when querying this package on unsupported
                             ;; platforms, e.g. when running "guix package --search="
                             ;; and also of targeting the builder's architecture.
                             (_ "JULIA_CPU_TARGET=generic"))

                          "CONFIG_SHELL=bash -x" ;needed to build bundled libraries
                          (string-append "CC="
                                         ,(cc-for-target))

                          ,@(if (target-x86-64?)
                                `("USE_BLAS64=1" "LIBBLAS=-lopenblas64_"
                                  "LIBBLASNAME=libopenblas64_")
                                `("USE_BLAS64=0" "LIBBLAS=-lopenblas"
                                  "LIBBLASNAME=libopenblas"))

                          (string-append "UTF8PROC_INC="
                                         (assoc-ref %build-inputs "utf8proc")
                                         "/include")
                          ;; Make.inc expects a static library for libuv.
                          (string-append "LIBUV="
                                         (assoc-ref %build-inputs "libuv")
                                         "/lib/libuv.a")
                          (string-append "LIBUV_INC="
                                         (assoc-ref %build-inputs "libuv")
                                         "/include"))))
    (inputs `(("coreutils" ,coreutils)
               ;for bindings to "mkdir" and the like
              ("curl" ,curl-ssh)
              ("gfortran" ,gfortran)
              ;; required for libgcc_s.so
              ("gfortran:lib" ,gfortran "lib")
              ("gmp" ,gmp)
              ("lapack" ,lapack)
              ("libblastrampoline" ,libblastrampoline)
              ("libgit2" ,libgit2)
              ("libnghttp2" ,nghttp2 "lib")
              ("libssh2" ,libssh2)
              ("libunwind" ,libunwind-julia)
              ("libuv" ,libuv-julia)
              ("llvm" ,llvm-14-julia)
              ("lld" ,lld-14)
              ("mbedtls-apache" ,mbedtls-apache)
              ("mpfr" ,mpfr)
              ,@(if (target-x86-64?)
                    `(("openblas" ,openblas-ilp64))
                    `(("openblas" ,openblas)))
              ("openlibm" ,openlibm)
              ("p7zip" ,p7zip)
              ("pcre2" ,pcre2-julia)
              ("suitesparse" ,suitesparse)
              ("utf8proc" ,utf8proc-2.7.0)
              ("wget" ,wget)
              ("which" ,which)
              ("zlib" ,zlib)
              ;; Find dependencies versions here:
              ;; https://raw.githubusercontent.com/JuliaLang/julia/v1.6.0/deps/Versions.make
              ("dsfmt" ,dsfmt)
              ("libwhich" ,libwhich)))
    (native-inputs `(("openssl" ,openssl)
                     ("perl" ,perl)
                     ("patchelf" ,patchelf)
                     ("pkg-config" ,pkg-config)
                     ("python" ,python)))
    (native-search-paths
     (list (search-path-specification
            (variable "JULIA_LOAD_PATH")
            (files (list "share/julia/loadpath/")))
           (search-path-specification
            (variable "JULIA_DEPOT_PATH")
            (files (list "share/julia/"))) $SSL_CERT_FILE))
    ;; Julia only officially supports some of our platforms:
    ;; https://julialang.org/downloads/#supported_platforms
    (supported-systems '("i686-linux" "x86_64-linux" "aarch64-linux"))
    (home-page "https://julialang.org/")
    (synopsis "High-performance dynamic language for technical computing")
    (description
     "Julia is a high-level, high-performance dynamic programming language for
technical computing, with syntax that is familiar to users of other technical
computing environments.  It provides a sophisticated compiler, distributed
parallel execution, numerical accuracy, and an extensive mathematical function
library.")
    (license license:expat)))
