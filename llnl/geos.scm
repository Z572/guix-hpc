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
  #:use-module (gnu packages profiling)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh))

(define-public camp
  (package
    (name "camp")
    (version "0.4.0")
    (home-page "https://github.com/LLNL/camp")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1allmiszvl4dy5z7vzbf4zrvnw2i92fd7hwl3vlch3w6hl6dfg96"))))
    (build-system cmake-build-system)
    (arguments
     (list #:configure-flags #~`("-DENABLE_DOCS=OFF" "-DENABLE_CUDA:BOOL=OFF"
                                 "-DENABLE_TESTS=ON"
                                 "-DBLT_CXX_STD:STRING=c++17"
                                 "-DCMAKE_CXX_FLAGS:STRING=-std=c++17"
                                 "-DENABLE_MPI=ON"
                                 ,(string-append "-DBLT_SOURCE_DIR="
                                                 #$(this-package-input "blt")
                                                 "/blt_dir")
                                 "-DBUILD_SHARED_LIBS=ON"
                                 "-DENABLE_OPENMP=ON")))
    (propagated-inputs (list openmpi openssh-sans-x blt))
    (synopsis "CAMP Concepts And Meta-Programming library")
    (description
     "CAMP collects a variety of macros and metaprogramming
     facilities for C++ projects.  It's in the direction
     of projects like metal (a major influence) but with
     a focus on wide compiler compatibility across HPC-oriented systems.")
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
                (file-name (git-file-name name version))
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

(define-public umpire
  (let ((commit "1e5ef604de88e81bb3b6fc4a5d914be833529da5")
        (revision "0"))
    (package
      (name "umpire")
      (version (git-version "023.06.0" revision commit))
      (home-page "https://github.com/LLNL/Umpire/")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url home-page)
                      (commit commit)))
                (file-name (git-file-name name commit))
                (sha256
                 (base32
                  "13syi8x1fwn70yjjb8qhmi5pc9wplpaj9w4i8p270n0q4xfg7bsh"))))
      (build-system copy-build-system)
      (arguments
       '(#:install-plan '(("." "umpire_dir"))))
      (synopsis "LLNL debugging library")
      (description
       "Umpire is a resource management library that allows the
discovery, provision, and management of memory on machines with multiple memory devices like NUMA and GPUs.")
      (license license:bsd-3))))


(define-public raja
  (package
    (name "raja")
    (version "2023.06.1")
    (home-page "https://github.com/LLNL/RAJA")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "13ik310kjvdpn474mxdgzp5vdbkz80jj482x9hvyvckc5phz8xdk"))))
    (build-system cmake-build-system)
    (synopsis "RAJA is a library of C++ abstractions")
    (arguments
     (list #:configure-flags
           #~`("-DENABLE_OPENMP=ON" 
               ,(string-append "-DBLT_SOURCE_DIR="
                   #$(this-package-input "blt")
                   "/blt_dir")
              ,(string-append "-Dcamp_DIR=" #$(this-package-input "camp"))
              "-DENABLE_TESTS:BOOL=ON"
               "-DBUILD_SHARED_LIBS=ON"
               "-DENABLE_EXAMPLES:BOOL=OFF"
               )))
    (inputs (list blt python camp))
    (description
     "RAJA offers portable, parallel loop execution by providing building blocks
that extend the generally-accepted parallel for idiom.  RAJA relies on
standard C++14 features.")
    (license license:bsd-3)))

(define-public chai
  (package
    (name "chai")
    (version "2023.06.0")
    (home-page "https://github.com/LLNL/CHAI")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "16qjnx1bvddiyhp1g0f17hral88361f7mjm365iy144dv0ar50yw"))))
    (build-system cmake-build-system)
    (synopsis
     "CHAI is a library that handles automatic data
migration to different memory spaces behind an array-style interface")
    (arguments
     (list #:configure-flags #~`("-DENABLE_OPENMP=ON" 
                                 ,(string-append
                                     "-DBLT_SOURCE_DIR="
                                     #$(this-package-input
                                        "blt") "/blt_dir")
                                 ,(string-append "-Dcamp_DIR=" #$(this-package-input "camp"))
                                 "-DENABLE_TESTS:BOOL=ON"
                                 "-DBUILD_SHARED_LIBS=ON"
                                 "-DENABLE_EXAMPLES:BOOL=OFF"
                                 "-DENABLE_BENCHMARKS=OFF"
                                 "-DENABLE_DOXYGEN=OFF"
                                 "-DENABLE_DOCS=OFF"
                                 "-DENABLE_SPHINX=OFF"
                                 "-DCHAI_ENABLE_RAJA_PLUGIN=ON"
                                 ,(string-append "-DRAJA_DIR=" #$(this-package-input "raja") "/lib/cmake/raja")
                                 "-DUMPIRE_ENABLE_C=ON")
     #:phases
              #~(modify-phases %standard-phases
                (add-after 'unpack 'copy-umpire-sources
                   (lambda _
                     (begin
                       (rmdir "src/tpl/umpire")
                       (copy-recursively (string-append #$(this-package-input
                                          "umpire") "/umpire_dir") "src/tpl/umpire"))))) 


           ))
    (inputs (list blt python raja camp umpire))
    (description
     "CHAI is a C++ libary providing an array object that
can be used transparently in multiple memory spaces.  Data is
automatically migrated based on copy-construction,
allowing for correct data access regardless of location.  CHAI
can be used standalone, but is best when paired with the RAJA
library, which has built-in CHAI integration that takes care of everything")
    (license license:bsd-3)))

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

(define-public caliper
  (package
    (name "caliper")
    (version "2.8.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference (url "https://github.com/LLNL/Caliper")
                                  (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1nbiy1zn6kh9hyjjk2xp2ff7i1ag9nn0ib790mc3lgkpr40zra1q"))))
    (build-system cmake-build-system)
    (inputs (list openmpi blt adiak papi python))
    (arguments
     (list #:configure-flags
           #~`("-DWITH_MPI=ON"
               "-DWITH_ADIAK=ON"
               "-DWITH_PAPI=ON"
               ,(string-append "-Dadiak_DIR="
                               #$(this-package-input "adiak")
                               "/lib/cmake/adiak/")
               "-DBUILD_SHARED_LIBS=ON")
           #:tests? #f))
    (home-page "https://software.llnl.gov/caliper/")
    (synopsis "Performance instrumentation and profiling library")
    (description
     "Caliper is a program instrumentation and performance measurement framework.
It is a performance-analysis toolbox in a library, allowing one to bake
performance analysis capabilities directly into applications and activate
them at runtime.  Caliper is primarily aimed at HPC applications, but works
for any C/C++/Fortran program.")
    (license license:bsd-3)))


(define-public pvtpackage
  (let ((revision "0")
        (commit "a92dd22bf4e2ddd16d3253613ca40a8fb769827a"))
    (package
      (name "pvtpackage")
      (version (git-version "0.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/GEOS-DEV/PVTPackage")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0w4wziqm5dm1680bm6kf629lzn43kzqrvfnx5ipr53f9rla1fxhd"))))
      (build-system copy-build-system)
      (arguments
       '(#:install-plan '(("." "pvtpackage"))))
      (home-page "https://github.com/GEOS-DEV/PVTPackage")
      (synopsis "No synopsis on the website")
      (description
       "No description on the website")
      (license license:bsd-3))))

(define-public lvarray
  (let ((revision "0")
        (commit "145bb1c530a68afa7d446e21c7a90b9c6a987d1f"))
    (package
      (name "lvarray")
      (version (git-version "0.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/GEOS-DEV/LvArray")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1snvwvcz5rxzazjfhkbc636anfdxnc1q0hhqd101r5ris9ld56yw"))))
      (build-system copy-build-system)
      (arguments
       '(#:install-plan '(("." "lvarray"))
          #:phases  (modify-phases %standard-phases
                           (add-after 'unpack 'suppress-cxx20-warnings
                           (lambda _ (substitute* "src/python/pythonHelpers.hpp"
                    ((".*Pragma.*GCC.*diagnostic.*20.*extensions.*") "")))))))
      (home-page "https://github.com/GEOS-DEV/LvArray")
      (synopsis "Collection of array classes for high-performance simulation software")
      (description
       "LvArray is a collection of container classes designed for performance
       portability in that they are usable on the host and device and provide
       performance similar to direct pointer manipulation")
      (license license:bsd-3))))

(define-public python-mpi4py-geos
  (package
    (inherit python-mpi4py)
    (name "python-mpi4py-geos")
    (version "3.1.1")
    (source (origin
       (method url-fetch)
       (uri (pypi-uri "mpi4py" version))
       (sha256
        (base32 "0p4zdgyw6kf1hjw8421wv1jvk1mmck3dxb96hm6b4fxrlf3qa7z1"))))))

(define-public python-h5py-geos
  (package
    (name "python-h5py-geos")
    (version "3.9.0")
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "h5py" version))
              (sha256
               (base32
                "05zqjmgaw19d6x8jcbbgci3cqlvzhjf27bbzpp36gqy145jxn176"))))
    (build-system python-build-system)
    (arguments (list
                 #:phases #~(modify-phases %standard-phases
                           (add-before 'build 'hdf5-fix-parallel
                            (lambda _ (begin
                                (setenv "HDF5_MPI" "ON")
                                (setenv "HDF5_DIR"
                                #$(this-package-input "hdf5-geos"))))))
                 #:tests? #f)) ; because page buffering is disabled for parallel
    (native-inputs (list python-cython))
    (propagated-inputs (list python-numpy
                             hdf5-geos
                             openmpi
                             python-mpi4py-geos))
    (home-page "https://docs.h5py.org/en/stable/index.html")
    (synopsis "Read and write HDF5 files from Python")
    (description "Read and write HDF5 files from Python")
    (license license:bsd-3)))

(define-public hdf5-interface
  (let ((commit "5136554439e791dc5e948f2a74ede31c4c697ef5"))
    (package
      (name "hdf5-interface")
      (version commit)
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/GEOS-DEV/hdf5_interface")
                      (commit commit)))
                (sha256
                 (base32
                  "1qvjjw2rmd2n85zcgny4gz4ya9psnsmns2cypsscfqs3s4rvb0s0"))))
      (build-system copy-build-system)
      (arguments
       '(#:install-plan '(("." "hdf5_interface"))))
      (home-page "https://github.com/GEOS-DEV/hdf5_interface")
      (synopsis "No synopsis on the website")
      (description "No description on the website")
      (license license:bsd-3))))


(define-public pugixml-geos
  (package
    (name "pugixml-geos")
    (version "1.13")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "https://github.com/zeux/pugixml/releases/download/v"
                           version "/pugixml-" version ".tar.gz"))
      (sha256
       (base32 "1gmb29m1hy7npv0r3ns1dc14cr0ky5dyamzs81b4hcf19s8v7h20"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags '("-DBUILD_SHARED_LIBS=ON"
                            "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
       #:tests? #f))                    ; no tests
    (native-inputs
     (list pkg-config))
    (home-page "https://pugixml.org")
    (synopsis "Light-weight, simple and fast XML parser for C++ with XPath support")
    (description "Pugixml is a C++ XML processing library, which consists of a DOM-like
interface with rich traversal/modification capabilities, a fast XML parser
which constructs the DOM tree from an XML file/buffer, and an XPath 1.0
implementation for complex data-driven tree queries.  Full Unicode support is
also available, with Unicode interface variants and conversions between
different Unicode encodings which happen automatically during
parsing/saving.")
    (license license:expat)))

(define-public vtk-geos
  (package/inherit vtk
    (name "vtk-geos")
    (version "9.1.0")
    (source (origin
       (method url-fetch)
       (uri (string-append "https://vtk.org/files/release/"
                                  (version-major+minor version)
                                  "/VTK-" version ".tar.gz"))
       (sha256
        (base32 "15nflmf3xx07v1m138v1048hgnkimnlyls3v221q1sziz3s45vcg"))
        (patch-flags '("-p0"))
        (patches (list  (local-file "vtk-geos-cmake-fix.patch")
                        (local-file "vtk-geos-disable_traits.patch")
                        (local-file "vtk-geos-duplicate-points-fix.patch")
                        (local-file "vtk-geos-vtkXMLReader-fpe.patch")))))
    (inputs (list hdf5-geos
                  libtheora
                  openmpi
                  python
                  zlib))
   (arguments
    (substitute-keyword-arguments (package-arguments vtk)
                  ((#:configure-flags flags '())
                   #~(list "-DVTK_MODULE_ENABLE_VTK_IOParallelXML=YES"
                           "-DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2=YES"
                           "-DVTK_GROUP_ENABLE_Imaging=DONT_WANT"
                           "-DVTK_GROUP_ENABLE_MPI=DONT_WANT"
                           "-DVTK_GROUP_ENABLE_Qt=DONT_WANT"
                           "-DVTK_GROUP_ENABLE_Rendering=DONT_WANT"
                           "-DVTK_GROUP_ENABLE_StandAlone=DONT_WANT"
                           "-DVTK_GROUP_ENABLE_Views=DONT_WANT"
                           "-DVTK_GROUP_ENABLE_Web=DONT_WANT"
                           "-DVTK_BUILD_ALL_MODULES=OFF"
                           "-DVTK_WRAP_PYTHON=ON"
                           "-DVTK_WRAP_JAVA=OFF"
                           "-DVTK_USE_MPI=ON"
                           "-DVTK_MODULE_ENABLE_VTK_vtkm=DONT_WANT"
                           "-DVTK_MODULE_ENABLE_VTK_IOXML=YES"
                           "-DVTK_MODULE_ENABLE_VTK_IOLegacy=YES"
                           "-DVTK_BUILD_TESTING=OFF"
                           "-DVTK_LEGACY_REMOVE=ON"))
                  ((#:tests? #f #f) #f)
                  ((#:validate-runpath? #f #f) #f)))))

(define-public segyio
  (package
    (name "segyio")
    (version "1.9.10")
    (home-page "https://github.com/equinor/segyio")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (patch-flags '("-p1"))
              (patches (list (local-file "segyio.patch"))) ;to suppress test.about.example
              (sha256
               (base32
                "06h7qd1jr73qwwc2m7ddjjbsvzibs10dpd34gvwd85k2l68m1l53"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags '("-DBUILD_SHARED_LIBS=ON"
                           "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
       #:validate-runpath? #f ;Kontuz !
       ))
    (inputs (list python-numpy python python-scikit-build python-pytest-runner))
    (native-inputs (list python-setuptools-scm python-pytest))
    (synopsis "Fast Python library for SEGY file")
    (description
     "Segyio is a small LGPL licensed C library for easy interaction with SEG-Y and Seismic Unix formatted seismic data, with language bindings for Python and Matlab")
    (license license:expat)))
