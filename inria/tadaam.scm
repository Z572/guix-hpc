;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017-2024 Inria
;;; Copyright © 2015, 2016, 2017, 2018, 2019, 2020, 2021 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2014-2022 Eric Bavier <bavier@posteo.net>
;;; Copyright © 2021 Franck Pérignon <franck.perignon@univ-grenoble-alpes.fr>
;;; Copyright © 2016 Leo Famulari <leo@famulari.name>
;;; Copyright © 2016-2022 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2021 Paul A. Patience <paul@apatience.com>
;;; Copyright © 2017, 2018, 2019, 2020, 2021 Paul Garlick <pgarlick@tourbillion-technology.com>
;;; Copyright © 2017–2021 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2020 Vincent Legoll <vincent.legoll@gmail.com>

(define-module (inria tadaam)
  #:use-module (guix)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages linux))


(define-public topomatch
  (package
    (name "topomatch")
    (version "1.1")
    (home-page "https://gitlab.inria.fr/ejeannot/topomatch")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "V" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1n0nfs1kmlq9bf1lvijf04vryslpv8cq99gn96rpmw8sjx7jbj14"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config
                         autoconf
                         automake
                         libtool
                         `(,hwloc "lib")
                         perl))
    (propagated-inputs (list scotch-6))
    (synopsis "Process mapping algorithms and tools for general topologies")
    (description
     "TopoMatch leverages on the Scotch library to handle any type of topologies and not only trees.
Its main features are:
- Handling any type of topologies (tgt Scotch format or hwloc format).
- Handle large communication patterns (up to hundreds of thousands of processes and processing units) .
- Manage binding constraints: you can specify a subset of the node onto which you want to do the mapping.
- Manage oversubscribing: you can specify that more than one processes can be mapped onto a each processing unit.
- Deal with logical numbering. Physical core numbering can be used with XML/HWLOC topologies.
- Provide exhaustive search for small cases.
- Adaptive algorithmic that provide a good trade-off between quality and speed.
- Crucial sections of the code are multithreaded.
- Optimize I/O to read large input files.
- Portable on Unix-like systems (Linux, OS-X, etc.).
- Many useful options (level of verbosity, topology optimization, partitioning, etc.).")
    (license license:bsd-3)))

(define-public scotch-6
  ;; Copied from Guix commit 4c1dff9abeb383ca58dbfcbc27e1bd464d2ad2ea.
  (package
    (inherit scotch)
    (version "6.1.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://www.labri.fr/perso/pelegrin/scotch/distrib/scotch_"
                    version ".tar.gz"))
              (sha256
               (base32
                "04dkz24a2g20wq703fnyi4440ac4mwycy9gwrrllljj7zxcjy19r"))
              (patches (search-patches
                        "inria/patches/scotch-build-parallelism.patch"
                        "inria/patches/scotch-integer-declarations.patch"))))
    (build-system gnu-build-system)
    (inputs
     (list zlib))
    (native-inputs
     (list flex bison gfortran))
    (outputs '("out" "metis"))
    (arguments
     `(#:make-flags (list (string-append "prefix=" %output))
       #:phases
       (modify-phases %standard-phases
         (add-after
             'unpack 'chdir-to-src
           (lambda _ (chdir "src") #t))
         (replace
             'configure
           (lambda _
             (call-with-output-file "Makefile.inc"
               (lambda (port)
                 (format port "
EXE =
LIB = .a
OBJ = .o
MAKE = make
AR = ar
ARFLAGS = -ruv
CAT = cat
CCS = gcc
CCP = mpicc
CCD = gcc
FC = gfortran
CPPFLAGS =~{ -D~a~}
CFLAGS = -O2 -g -fPIC $(CPPFLAGS)
LDFLAGS = -lz -lm -lrt -lpthread
CP = cp
LEX = flex -Pscotchyy -olex.yy.c
LN = ln
MKDIR = mkdir
MV = mv
RANLIB = ranlib
YACC = bison -pscotchyy -y -b y
"
                         '("COMMON_FILE_COMPRESS_GZ"
                           "COMMON_PTHREAD"
                           "COMMON_RANDOM_FIXED_SEED"
                           "INTSIZE64"            ;use 'int64_t'
                           ;; Prevents symbol clashes with libesmumps
                           "SCOTCH_RENAME"
                           ;; XXX: Causes invalid frees in superlu-dist tests
                           ;; "SCOTCH_PTHREAD"
                           ;; "SCOTCH_PTHREAD_NUMBER=2"
                           "restrict=__restrict"))))
             #t))
         (add-after 'build 'build-esmumps
           (lambda _
             (invoke "make"
                     (format #f "-j~a" (parallel-job-count))
                     "esmumps")))
         (add-before 'install 'make-install-dirs
           (lambda* (#:key outputs #:allow-other-keys)
             (mkdir (assoc-ref outputs "out"))))
         (add-after 'install 'install-metis
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "metis")))
               (mkdir out)
               ;; metis files are not installed with 'make install'
               (for-each (lambda (f)
                           (install-file f (string-append out "/include")))
                         (find-files "../include/" ".*metis\\.h"))
               (for-each (lambda (f)
                           (install-file f (string-append out "/lib")))
                         (find-files "../lib/" ".*metis\\..*"))
               #t))))))))

(define-public pt-scotch-6
  (package
    (inherit scotch-6)
    (name "pt-scotch")
    (propagated-inputs
     (list openmpi))                             ;headers include MPI headers
    (arguments
     (substitute-keyword-arguments (package-arguments scotch-6)
       ((#:phases scotch-phases)
        `(modify-phases ,scotch-phases
           (replace
            'build
            (lambda _
              (invoke "make" (format #f "-j~a" (parallel-job-count))
                      "ptscotch" "ptesmumps")

              ;; Install the serial metis compatibility library
              (invoke "make" "-C" "libscotchmetis" "install")))
           (add-before 'check 'mpi-setup
	     ,%openmpi-setup)
           (replace 'check
             (lambda _
               (invoke "make" "ptcheck")))))))
    (synopsis "Programs and libraries for graph algorithms (with MPI)")))
