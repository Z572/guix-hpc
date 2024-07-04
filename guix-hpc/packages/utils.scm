;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017, 2019, 2020, 2022, 2024 Inria

(define-module (guix-hpc packages utils)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system r)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages check)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cran)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages statistics)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages xml)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages fabric-management)
  ;; To remove when/if python2 packages sympy and mpi4py
  ;; are fixed in official repo
  #:use-module (guix build-system python)
  )

(define-public r-rlist
(package
 (name "r-rlist")
 (version "0.4.6.1")
 (source
  (origin
   (method url-fetch)
   (uri (cran-uri "rlist" version))
   (sha256
    (base32
     "08awy2p7rykc272wvvya4ddszbr7b7s7qv4wr3hs8ylr4jqlh0dv"))))
 (properties `((upstream-name . "rlist")))
 (build-system r-build-system)
 (propagated-inputs
  (list r-data-table r-jsonlite r-xml r-yaml))
 (home-page "https://renkun.me/rlist")
 (synopsis
  "A Toolbox for Non-Tabular Data Manipulation")
 (description
  "This package provides a set of functions for data manipulation with list objects, including mapping, filtering, grouping, sorting, updating, searching, and other useful functions.  Most functions are designed to be pipeline friendly so that data processing with lists can be chained.")
 (license license:expat)))

(define-public sz-compressor
  (package
   (name "sz-compressor")
   (version "2.1.11")
   (home-page "https://github.com/szcompressor/SZ")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256 (base32 "0kzmiigh12aysaq5nnapsh5vrcpvqc7nl21km4hz4xrmp94n2x9c"))))
   (build-system cmake-build-system)
   (arguments
    '(#:build-type "Release"))
   (synopsis "GUIX package for the SZ compressor.")
   (description "GUIX package for the SZ compressor.")
   (license license:gpl3+)))

(define-public sz3-compressor
  (package
   (name "sz3-compressor")
   (version "3.1.8")
   (home-page "https://github.com/szcompressor/SZ3")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256 (base32 "08hjcqmw49wika5crmqi74vi7lpb79krr7rkn54bp5hsh7ycsqx7"))))
   (build-system cmake-build-system)
   (arguments
    '(#:build-type "Release"))
   (native-inputs (list pkg-config))
   (propagated-inputs (list `(,zstd "lib")))
   (synopsis "GUIX package for the SZ3 compressor.")
   (description "GUIX package for the SZ3 compressor.")
   (license license:gpl3+)))

(define-public zfp
  (package
    (name "zfp")
    (version "1.0.1")
    (home-page "https://zfp.io/")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/LLNL/zfp")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1agn3clm7bw5gwr9b0hzhwm54hfc238ymqz1d4h9929gabi41749"))))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"))
    (native-inputs (list python-wrapper))
    (synopsis "A compressed format for multi-dimensional arrays")
    (description
     "zfp is a compressed number format for multi-dimensional arrays. zfp provides compressed-array classes (e.g., for in-memory storage) and high-speed, parallel data compression (e.g., for offline storage). zfp supports both lossy and lossless compression and fine-grained user control over accuracy and storage size.")
    (license license:bsd-3)))

(define-public python-expecttest
  (package
   (name "python-expecttest")
   (version "0.1.3")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "expecttest" version))
     (sha256
      (base32
       "16hlaymwnwz0iqghfh7aj850xf8d0x50kv8kxn51550xh6apc1c3"))))
   (build-system python-build-system)
   (home-page "https://github.com/ezyang/ghstack")
   (synopsis "This library implements expect tests (also known as 'golden'
tests).")
   (description "Expect tests are a method of writing tests where instead of
hard-coding the expected output of a test, you run the test to get the output,
and the test framework automatically populates the expected output.")
   (license license:expat)))

(define-public redox
  (package
    (name "redox")
    (version "0.3") ;no official releases, according to HISTORY.md
    (home-page "https://github.com/mpoquet/redox") ;this fork contains additionnal commits to generate pkg-config files
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "e7904da79d5360ba22fbab64b96be167b6dda5f6")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0mmxrjfidcm5fq233wsgjb9rj81hq78rn52c02vwfmz8ax9bc5yg"))))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"
       #:tests? #f))
    (propagated-inputs (list libev hiredis))
    (synopsis "Modern, asynchronous, and wicked fast C++11 client for Redis")
    (description
     "Redox is a C++ interface to the Redis key-value store that makes it easy
     to write applications that are both elegant and high-performance.
     Communication should be a means to an end, not something we spend a lot of
     time worrying about. Redox takes care of the details so you can move on to
     the interesting part of your project.")
    (license license:asl2.0)))

(define-public cpp-docopt
  (package
    (name "cpp-docopt")
    (version "0.6.3")
    (home-page "https://github.com/docopt/docopt.cpp")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0cz3vv7g5snfbsqcf3q8bmd6kv5qp84gj3avwkn4vl00krw13bl7"))))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"
       #:tests? #f))
    (synopsis "C++11 port of docopt")
    (description
      "docopt helps you:
- define the interface for your command-line app, and
- automatically generate a parser for it.
docopt is based on conventions that have been used for decades in help messages
and man pages for describing a program's interface. An interface description in
docopt is such a help message, but formalized.")
    (license (list license:expat license:boost1.0))))

(define-public sionlib
  (package
    (name "sionlib")
    (version "1.7.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://apps.fz-juelich.de/jsc/sionlib/download.php?version="
             version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1486lvsi9jsi136akk5z18h3rbd3mr671kac28f3nyni7knm6lp8"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:phases #~(modify-phases %standard-phases
                   ;; configure doesn't support "--enable-fast-install"
                   (replace 'configure
                     (lambda* (#:key outputs configure-flags
                               #:allow-other-keys)
                       (let ((out (assoc-ref outputs "out")))
                         (setenv "CONFIG_SHELL"
                                 (which "sh"))
                         (setenv "SHELL"
                                 (which "sh"))
                         (apply invoke "./configure"
                                (string-append "--prefix=" out)
                                configure-flags))))
                   (add-after 'patch-source-shebangs 'patch-realmakefile
                     (lambda _
                       (substitute* "mf/RealMakefile"
                         (("^SHELL *= */bin/sh")
                          (string-append "SHELL = "
                                         #$bash-minimal "/bin/sh")))))
                   (add-before 'check 'mpi-setup
                     #$%openmpi-setup))
      #:configure-flags #~(list "--compiler=gnu" "--disable-fortran" ;FIXME build error with gfortran
                                "--mpi=openmpi")
      #:test-target "test"))
    (inputs (list openmpi))
    (home-page "https://www.fz-juelich.de/jsc/sionlib")
    (synopsis "Scalable I/O library for parallel access to task-local files")
    (description
     "SIONlib is a library for writing and reading data from several
thousands of parallel tasks into/from one or a small number of
physical files.")
    (license (license:non-copyleft "file:///COPYRIGHT"))))

(define-public fti
  (package
    (name "fti")
    (version "1.6")
    (home-page "https://github.com/leobago/fti")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0lmclyby77kb4mph25adh1lfbjd7x9lm1qb53xdhnxmdmqjb8zna"))))
    (build-system cmake-build-system)
    (inputs (list openmpi openssl zlib))
    (arguments
     (list
      #:configure-flags #~(list "-DENABLE_TESTS=ON")
      #:phases #~(modify-phases %standard-phases
                   (add-before 'check 'mpi-setup
                     #$%openmpi-setup))
      ;; FIXME: tests fail because their definition is not found in the build folder
      #:tests? #f))
    (synopsis "Fault Tolerance Interface")
    (description
     "FTI stands for Fault Tolerance Interface and is a library that aims to
give computational scientists the means to perform fast and efficient
multilevel checkpointing in large scale supercomputers.")
    (license license:bsd-3)))

(define-public paraconf
  (package
    (name "paraconf")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/pdidev/paraconf")
             (commit version)))
       (sha256
        (base32 "062jqhx0fpf4sspnz131408272brpqdcimcwmrv8ynykchgma44m"))
       (snippet #~(begin
                    (use-modules (guix build utils))
                    (delete-file-recursively "vendor")))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
				;; don't use vendored dependencies
                                "-DUSE_DEFAULT=SYSTEM")))
    (native-inputs (list pkg-config gfortran))
    (inputs (list libyaml))
    (synopsis
     "Library providing a simple query language to access a Yaml tree")
    (description
     "Paraconf is a library that provides a simple query language to access
a Yaml tree on top of libyaml.")
    (home-page "https://github.com/pdidev/paraconf")
    (license license:bsd-3)))

(define-public zpp
  (package
    (name "zpp")
    (version "1.0.15")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jbigot/zpp")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0jmdqy8884q6sd5aab7zzf2asi40hizfs6ly8y3z35w3a9b8y2s7"))))
    (build-system python-build-system)
    (home-page "https://github.com/jbigot/zpp")
    (synopsis "\"Z\" pre-processor, the last preprocessor you'll ever need")
    (description
     "Zpp transforms bash in a pre-processor for F90 source files.
It offers a set of functions specifically tailored to build clean
Fortran90 interfaces by generating code for all types, kinds, and
array ranks supported by a given compiler.")
    (license (license:non-copyleft "file:///LICENSE.txt"))))

(define-public mdspan
  (package
    (name "mdspan")
    (version "0.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kokkos/mdspan")
             (commit (string-append name "-" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "17zmjid1vjvpmvgd1k023ljk8yygqw18xilx78b7pxg7xws3w0bg"))))
    (build-system cmake-build-system)
    (arguments
     (list #:configure-flags #~(list "-DMDSPAN_ENABLE_TESTS=ON"
                                     "-DMDSPAN_USE_SYSTEM_GTEST=ON")))
    (native-inputs (list googletest))
    (synopsis "Reference implementation of mdspan targeting C++23")
    (description "This package aims to provide a production-quality implementation of
the ISO-C++ proposal P0009, which will add support for non-owning
multi-dimensional array references to the C++ standard library.")
    (home-page "https://github.com/kokkos/mdspan")
    (license license:asl2.0)))

(define-public ginkgo
  (package
    (name "ginkgo")
    (version "1.7.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ginkgo-project/ginkgo")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0mjrwvy1lbys8ymdxh00zw4p3qhpk3f5400yj4864m99fs72f01g"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DGINKGO_BUILD_BENCHMARKS=OFF")))
    (native-inputs (list googletest))
    (synopsis "Numerical linear algebra software package")
    (description "Ginkgo is a high-performance numerical linear algebra library for
many-core systems, with a focus on solution of sparse linear systems.")
    (home-page "https://ginkgo-project.github.io/")
    (license license:bsd-2)))

(define-public adios2
  (package
    (name "adios2")
    (version "2.10.0-rc1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ornladios/ADIOS2")
             (commit (string-append "v" version))))
       (sha256
        (base32 "1z19ifn6s7v5lwz8hahpr77zfp2lbckl2aw1qy590089rz1bqgw4"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags #~(list "-DADIOS2_USE_MPI=ON"
                                "-DADIOS2_USE_ZeroMQ=ON"
                                "-DADIOS2_USE_HDF5=ON"
                                "-DADIOS2_USE_Python=ON"
                                "-DADIOS2_USE_Fortran=ON"
                                "-DADIOS2_USE_SST=ON")))
    (native-inputs (list pkg-config perl gfortran))
    (inputs (list libffi
                  openmpi
                  zeromq
                  hdf5
                  python
                  bzip2
                  libfabric
                  ucx))
    (propagated-inputs (list python-numpy python-mpi4py))
    (synopsis "The Adaptable Input Output System version 2")
    (description
     "ADIOS2 transports data as groups of self-describing variables and
  attributes across different media types (such as files, wide-area-networks, and remote
  direct memory access) using a common application programming interface for all
  transport modes. ADIOS2 can be used on supercomputers, cloud systems, and personal computers.")
    (home-page "https://github.com/ornladios/ADIOS2")
    (license license:asl2.0)))
