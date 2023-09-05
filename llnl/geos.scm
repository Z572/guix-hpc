;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (llnl geos)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh))

(define-public camp
  (package
    (name "camp")
    (version "0.4.0")
    (home-page "https://github.com/LLNL/camp")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url home-page)
                                  (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1allmiszvl4dy5z7vzbf4zrvnw2i92fd7hwl3vlch3w6hl6dfg96"))))
    (build-system copy-build-system)
    (arguments '(#:install-plan '(("." "camp_dir"))))
    (synopsis "CAMP Concepts And Meta-Programming library")
    (description
     "CAMP collects a variety of macros and metaprogramming facilities for C++
projects. It's in the direction of projects like metal (a major influence)
but with a focus on wide compiler compatibility across HPC-oriented systems.")
    (license license:bsd-3)))

(define-public blt
  (let ((commit "5a792c1775e7a7628d84dcde31652a689f1df7b5")
        (revision "20230605"))
    (package
      (name "blt")
      (version (git-version "0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/LLNL/blt")
                      (commit commit)))
                (sha256
                 (base32
                  "110xb9ssm5vpq09q83qraqjdg40z58qid2nq67sr8lfk95rf49ym"))))
      (build-system copy-build-system)
      (arguments
       '(#:install-plan '(("." "blt_dir"))))
      (home-page "https://llnl-blt.readthedocs.io/en/develop/")
      (synopsis "CMake macros and tools assembled to simplify HPC software development")
      (description
       "BLT is a streamlined CMake-based foundation for Building, Linking and
Testing large-scale high performance computing (HPC) application.")
      (license license:bsd-3))))

(define-public hdf5-geos
  (package
    (inherit hdf5)
    (name "hdf5-geos")
    (version "1.12.2")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/"
                    "hdf5-" version "/src/hdf5-" version ".tar.gz"))
              (sha256
               (base32
                "050gj5ij9vp8y3001v316mvx26i8871350p1r8nm1rvcsl1sz29a"))
              (patches (list (local-file "hdf5-config-date.patch")))))
    (build-system gnu-build-system)
    (inputs '())
    (native-inputs (list perl))
    (propagated-inputs (list openmpi openssh-sans-x zlib))
    (arguments
     `(#:tests? #f                                ;XXX: hmm?
       #:configure-flags '("--enable-build-mode=production"
                           "--enable-shared=yes" "--enable-parallel")
       #:make-flags (list "CFLAGS=-fPIC -O2 -g" "CXXFLAGS=-fPIC -O2 -g")))))

(define-public conduit
  (package
    (name "conduit")
    (version "0.8.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url "https://github.com/LLNL/conduit")
                                  (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0pls45gcaz781q1v1xypzxnwpwb8sg9fffl6m081dlsv3gca7dx4"))))
    (build-system cmake-build-system)
    (inputs (list hdf5-geos blt))
    (arguments
     (list #:configure-flags #~`("-DENABLE_DOCS=OFF" "-DENABLE_EXAMPLES=OFF"
                                 "-DENABLE_FORTRAN=OFF"
                                 "-DBLT_CXX_STD:STRING=c++17"
                                 "-DENABLE_TESTS=OFF"
                                 "-DENABLE_MPI=ON"
                                 ,(string-append "-DBLT_SOURCE_DIR="
                                                 #$(this-package-input "blt")
                                                 "/blt_dir")
                                 "-DBLT_CXX_STD:STRING=c++11"
                                 "-DBUILD_SHARED_LIBS=ON"
                                 "-DENABLE_OPENMP=ON"
                                 ,(string-append "-DHDF5_DIR="
                                                 #$(this-package-input "hdf5-geos")))
           #:tests? #f                            ;XXX: no "test" target
           #:phases #~(modify-phases %standard-phases
                        (add-before 'configure 'change-directory
                          (lambda _
                            (chdir "src")))
                        (add-after 'unpack 'unpack-etc
                          (lambda* (#:key inputs outputs #:allow-other-keys)
                            ;; Configuration samples are not installed by default.
                            (let* ((output (assoc-ref outputs "out"))
                                   (etcdir (string-append output "/etc")))
                              (for-each (lambda (l)
                                          (install-file l etcdir))
                                        (find-files "etc" "\\.cfg$"))))))))

    (home-page "https://software.llnl.gov/conduit/")
    (synopsis "Simplified data exchange for HPC simulation")
    (description
     "Conduit is a project from Lawrence Livermore National Laboratory that
provides an intuitive model for describing hierarchical scientific data in
C++, C, Fortran, and Python.  It is used for data coupling between packages
in-core, serialization, and I/O tasks.")
    (license license:bsd-3)))

(define-public silo
  (package
    (name "silo")
    (version "4.11")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/LLNL/Silo/releases/download/v"
                    version "/silo-" version "-bsd.tar.gz"))
              (patches (list (local-file "silo-fix-build.patch")))
              (sha256
               (base32
                "1v649dpx2i5j1k381ryy5s2n9k7x9kybbv44036cv3ylg6h8a2kd"))))
    (build-system gnu-build-system)
    (native-inputs (list which))
    (inputs (list hdf5-geos blt openmpi))
    (arguments
     (list #:configure-flags #~`("LIBS=-ldl" "--disable-silex"
                                 "--disable-fortran"
                                 "--enable-optimization"
                                 "--enable-shared=yes"
                                 "--enable-static=no"
                                 ,(string-append "--with-hdf5="
                                                 #$(this-package-input "hdf5-geos")
                                                 "/include,"
                                                 #$(this-package-input "hdf5-geos")
                                                 "/lib"))
           #:tests? #f))                          ;XXX: tests fail to build
    (home-page "https://llnl.github.io/Silo")
    (synopsis "Mesh and field I/O library and scientific database")
    (description
     "Silo is a library for reading and writing a wide variety of scientific data
to binary, disk files.  The files Silo produces and the data within them can
be easily shared and exchanged between wholly independently developed
applications running on disparate computing platforms.")
    (license license:bsd-3)))

(define-public raja
  (package
    (name "raja")
    (version "2022.03.0")
    (home-page "https://github.com/LLNL/RAJA")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "06mzzx29hgjq0pikj1zzvxwn27yxvjwvg8x1si0j6zm8lkmg1v3w"))))
    (build-system cmake-build-system)
    (synopsis "RAJA is a library of C++ abstractions")
    (arguments
     (list #:configure-flags
           #~`("-DENABLE_OPENMP=ON" ,(string-append "-DBLT_SOURCE_DIR="
                                                    #$(this-package-input "blt")
                                                    "/blt_dir")
               "-DENABLE_TESTS:BOOL=ON"
               "-DBUILD_SHARED_LIBS=ON"
               "-DENABLE_EXAMPLES:BOOL=OFF"
               ,(string-append "-DEXTERNAL_CAMP_SOURCE_DIR="
                               #$(this-package-input "camp")
                               "/camp_dir"))))
    (inputs (list blt python camp))
    (description
     "RAJA offers portable, parallel loop execution by providing building blocks
that extend the generally-accepted parallel for idiom.  RAJA relies on
standard C++14 features.")
    (license license:bsd-3)))

(define-public chai 
  (package
	(name "chai")
	(version "2022.03.0")
	(source
	  (origin
		(method url-fetch)
		(uri "https://github.com/LLNL/CHAI/releases/download/v2022.03.0/chai-2022.03.0.tar.gz")
		(sha256
		  (base32 "13y88x2rpvsfzq458zcw8ll4xnlzi2gn54512wzp440z41clvqlc"))))
	(build-system cmake-build-system)
	(synopsis  "CHAI is a library that handles automatic data migration to different memory spaces behind an array-style interface")
	(arguments
	  (list #:configure-flags #~`("-DENABLE_OPENMP=ON"
							     ,(string-append "-DBLT_SOURCE_DIR=" #$(this-package-input "blt") "/blt_dir")
							     "-DENABLE_TESTS:BOOL=ON"
							     "-DBUILD_SHARED_LIBS=ON"
							     "-DENABLE_EXAMPLES:BOOL=OFF"
							     "-DENABLE_BENCHMARKS=OFF"
							     "-DENABLE_DOXYGEN=OFF"
							     "-DENABLE_DOCS=OFF"
							     "-DENABLE_SPHINX=OFF"
							     "-DCHAI_ENABLE_RAJA_PLUGIN=ON"
							     "-DUMPIRE_ENABLE_C=ON"
							     ) 
		#:tests? #f))
	(inputs (list blt python raja))
	(description "CHAI is a C++ libary providing an array object that can be used transparently in multiple memory spaces. Data is automatically migrated based on copy-construction, allowing for correct data access regardless of location. CHAI can be used standalone, but is best when paired with the RAJA library, which has built-in CHAI integration that takes care of everything")
	(license license:bsd-3)
	(home-page "https://github.com/LLNL/CHAI")))

(define-public adiak
  (package
    (name "adiak")
    (version "0.2.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url "https://github.com/LLNL/adiak")
                                  (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1n0bzibjf1l9pgc5gff5cjsdpgbrnd1wz01ib1jkd672l3zh7w7g"))))
    (build-system cmake-build-system)
    (inputs (list openmpi blt))
    (arguments
     (list #:configure-flags
           #~`("-DWITH_MPI=ON"
               ,(string-append "-DBLT_SOURCE_DIR="
                               #$(this-package-input "blt")
                               "/blt_dir")
               "-DBUILD_SHARED_LIBS=ON"
               "-DENABLE_TESTS=ON")))
    (home-page "https://software.llnl.gov/adiak/")
    (synopsis "Collect metadata from HPC application runs")
    (description
     "Adiak is a library for recording meta-data about HPC simulations.  An HPC
application code may, for example, record what user invoked it, the version
of the code being run, a computed time history showing density changes, or
how long the application spent performing file IO.  Adiak represents this
metadata as Name/Value pairs.  Names are arbitrary strings, with some
standardization, and the values are represented by a flexible dynamic type
system")
    (license license:bsd-3)))
