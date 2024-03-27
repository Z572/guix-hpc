;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017, 2019, 2020, 2023, 2024 Inria

(define-module (inria eztrace)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix packages) ; for guix style
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix-hpc packages utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages profiling)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages serialization))

(define-public eztrace
  (package
    (name "eztrace")
    (version "2.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.com/eztrace/eztrace")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1h0pgppgsvhjfpcc4p2dsn8dhp5c09pl8fhs4khwpj1cwq5rp2gz"))
              ;; (modules '((guix build utils)))

              ;; Remove bundled libraries.
              ;; FIXME: There's few more under extlib/.
              ;; FIXME: The bundled litl is different from the latest
              ;; release (0.1.8), so we have to use it.
              ;; (snippet '(delete-file-recursively "extlib/litl"))
              ))
    (build-system cmake-build-system)
    (arguments
     (list #:out-of-source? #f                    ;test scripts expect it
           #:configure-flags #~'("-DEZTRACE_ENABLE_OMPT=OFF" ;TODO: add ompt
                                 "-DEZTRACE_ENABLE_MPI=ON"
                                 "-DEZTRACE_ENABLE_OPENMP=ON")

           ;; XXX: The test suite requires ompt support, which is currently missing.
           #:tests? #f

           #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'patch-more-shebangs
                          (lambda _
                            (patch-shebang "test/run")))
                        (delete 'check)
                        (add-after 'install 'post-install
                          (lambda _
                            ;; 'make test' expects 'eztrace' to be in $PATH,
                            ;; so install run 'make install' first.
                            (setenv "PATH"
                                    (string-append #$output "/bin:"
                                                   (getenv "PATH")))))
                        (add-after 'post-install 'check
                          (assoc-ref %standard-phases 'check)))))
    (inputs (list otf2
                  gfortran
                  perl
                  opari2                          ;for OpenMP support

                  ;; XXX: The dependencies below are needed for pptrace, but
                  ;; that code now fails to build due to '-gdwarf-5' being
                  ;; unrecognized by GCC 11.

                  ;; libiberty ;for bfd
                  ;; zlib ;for bfd

                  ;; ;; Pptrace needs 'bfd_get_section', which is no longer
                  ;; ;; available in Binutils 2.34.
                  ;; binutils-2.33

                  openmpi))
    (propagated-inputs (list grep coreutils)) ;eztrace is executing 'grep "$(basename ...)$" ...  |grep " r-xp "|tr '-' ' '|cut  -d' ' -f1,5)' with a popen() call
    (synopsis "Collect program execution traces")
    (description
     "EZTrace is a tool that aims at generating automatically execution trace
from high performance computing (HPC) programs.  It generates execution trace
files that can be interpreted by visualization tools such as
@uref{https://solverstack.gitlabpages.inria.fr/vite/, ViTE}.")
    (license license:cecill-c)                    ;FIXME: really CECILL-B
    (home-page "https://eztrace.gitlab.io/eztrace/")))

(define-public eztrace-1
  ;; Version 1.1 provides a tracing API not found in 2.x, used by PasTiX.
  (package
    (inherit eztrace)
    (name "eztrace")
    (version "1.1-13")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.com/eztrace/eztrace")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "17jyhyab79qs4zcpwxvqii34fik0c9d2ziamc65p75cgjry541n7"))

              ;; Remove bundled libraries.
              ;; FIXME: There's few more under extlib/.
              ;; FIXME: The bundled litl is different from the latest
              ;; release (0.1.8), so we have to use it.
              ;; (snippet '(delete-file-recursively "extlib/litl"))
              ))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags
           #~(list "LDFLAGS=-liberty"             ;for bfd
                   "--disable-pptrace"            ;depends on Binutils 2.33
                   (string-append "--with-mpi="
                                  #$(this-package-input "openmpi")))

           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'make-source-writable
                 (lambda _
                   ;; Make sure 'autoreconf' can write 'configure' files.
                   (for-each make-file-writable
                             (find-files "." "^configure$"))))
               (add-before 'bootstrap 'patch-build-tool-shebangs
                 (lambda _
                   ;; These scripts are executed from 'autoreconf'.
                   (for-each patch-shebang
                             (find-files "." "\\.sh$")))))

           ;; FIXME: There are test failures in bundled libraries.
           #:tests? #f))
    (native-inputs (list autoconf-2.71 automake libtool))
    (inputs (list gfortran
                  libiberty                       ;for bfd
                  zlib                            ;for bfd
                  openmpi))))

(define-public litl
  (package
    (name "litl")
    (home-page "https://github.com/trahay/LiTL")
    (version "0.1.9")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    ;; this commit is a little bit after litl-0.1.9, but it
                    ;; fixes some issues
                    (commit "05ed9f59f00a9af0a08894d7e972465239d26e6d")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0qwymk8f8qhaq7z1vxwafwph828lfxdvsmsp7c3inpxxy6ig6qn9"))))
    (build-system gnu-build-system)
    (arguments
     ;; Tests expect to be run sequentially: 'test_litl_write' creates a file
     ;; that 'test_litl_read' reads.
     '(#:parallel-tests? #f))
    (synopsis "Collect events during the execution of a program")
    (description
     "This project aims at providing an alternative solution to the already
existing FxT library, which is used to record events during the execution of
scientific applications, that would deliver nearly the same performance and
would solve the scalability issues such as scalability and the number of
threads.")
    (native-inputs (list autoconf automake libtool))
    (license license:bsd-2)))

(define-public fxt
  (package
    (name "fxt")
    (version "0.3.14")
    (source (origin
              (uri (string-append "mirror://savannah/fkt/fxt-"
                                  version ".tar.gz"))
              (method url-fetch)
              (sha256
               (base32
                "1wpbmax4jzc454ilz9vay0a63ilxsav910rvqizg5naw2y9qsz9i"))))
    (build-system gnu-build-system)
    (native-inputs
     (list perl help2man))
    (home-page "https://savannah.nongnu.org/projects/fkt")
    (synopsis "Efficient recording of program execution traces")
    (description
     "FxT is a fast tracing engine that can be used either in user land, in
kernel land, or both.  It can record developer-specified events in compact
\"traces\", with minimal run-time overhead.")
    (license license:gpl2+)))

(define-public fxt+static
  (package
    (inherit fxt)
    (name "fxt-static")
    (arguments
     '(#:configure-flags '("CFLAGS=-fPIC"
                           "--enable-static=yes"
                           "--enable-shared=no")))))

(define-public pallas
  (package
    (name "pallas")
    (version "0.0.1") ;keep a minimal version as long as there is no first official release
    (home-page "https://gitlab.inria.fr/pallas/pallas")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit "779337f90045d368e144f2bf060d40ce52bec51f")))
       (sha256
        (base32 "164k6fidj10b7krnlpdi9crynac5a3q7faxc6bqzkk7d1nimafm0"))))
    (build-system cmake-build-system)
    (native-inputs (list pkg-config perl))
    (propagated-inputs (list sz-compressor jsoncpp `(,zstd "lib") zfp hdf5))
    (synopsis "Interface to write and read trace data")
    (description
     "OTF2-compatible interface to write and read trace data from HPC applications.")
    (license license:bsd-3)))

(define-public eztrace+pallas
  (package
    (inherit eztrace)
    (name "eztrace-pallas")
    (inputs (modify-inputs (package-inputs eztrace)
              (replace "otf2" pallas)))))
