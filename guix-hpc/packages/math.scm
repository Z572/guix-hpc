;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2022, 2023, 2024 Inria

(define-module (guix-hpc packages math)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages autotools)
  ;; Conflicts with guix/build/utils, so use prefix
  #:use-module ((gnu packages base)
                #:prefix base:)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pretty-print)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages popt)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages swig)
  #:use-module (gnu packages xml)
  #:use-module (guix build utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix)
  #:use-module (guix-hpc packages cpp))

(define-public libxc
  (package
    (name "libxc")
    (version "4.3.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.com/libxc/libxc")
             (commit version)))
       (sha256
        (base32 "03vnmh9ygx8rg7nm1wfgkx15yzjxzccgjvjzvai5y00hwmybk5y7"))))
    (build-system cmake-build-system)
    (native-inputs (list python gfortran perl))
    (arguments
     `(#:configure-flags '("-DBUILD_SHARED_LIBS=ON" "-DENABLE_FORTRAN=ON")))
    (synopsis
     "Library of exchange-correlation functionals for density-functional theory.")
    (description
     "Library of exchange-correlation functionals for
density-functional theory. The aim is to provide a portable, well
tested and reliable set of exchange and correlation functionals that
can be used by a variety of programs.")
    (home-page "https://libxc.gitlab.io")
    (license license:mpl2.0)))

(define-public ntpoly
  (package
    (name "ntpoly")
    (version "3.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/william-dawson/NTPoly")
             (commit (string-append "ntpoly-v" version))))
       (sha256
        (base32 "1pjc1hhawxpfg08xxbbbhd5a32rx6cyczilmi9g3wlilfrzxq6xp"))))
    (build-system cmake-build-system)
    (native-inputs (list gfortran
                         swig
                         python
                         ;; tests
                         python-mpi4py
                         python-numpy
                         python-scipy
                         python-pyyaml
                         openssh))

    (inputs (list openmpi lapack))
    (arguments
     `(#:configure-flags (list "-DBUILD_SHARED_LIBS=ON")))
    (synopsis
     "Massively parallel library for computing the functions of sparse matrices")
    (description
     "Massively parallel library for computing the functions of
sparse, Hermitian matrices based on polynomial expansions. For sufficiently
sparse matrices, most of the matrix functions in NTPoly can be computed in linear time.")
    (home-page "https://william-dawson.github.io/NTPoly")
    (license license:expat)))

(define-public freefem
  (package
    (name "freefem")
    (version "4.14")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/FreeFem/FreeFem-sources")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0q1817slryrh8cvqhaj9gf6779wbah398a5ybrqgm4vlxx3zhj1j"))))
    (build-system gnu-build-system)
    (arguments
     (list
      ;; Disable ISA extension optimizations (SSE, etc.) that are based on
      ;; the build machine's /proc/cpuinfo.
      #:configure-flags #~(list "--enable-generic")

      #:phases #~(modify-phases %standard-phases
                   (add-before 'check 'skip-faulty-tests
                     (lambda _
                       (substitute* "examples/3d/Makefile"
                         (("schwarz-nm-3d.edp")
                          ""))
                       (substitute* "examples/3dSurf/Makefile"
                         (("testvtk\\.edp")
                          "")))))))
    (native-inputs (list autoconf
                         automake
                         unzip
                         base:which
                         bison
                         flex
                         gfortran))
    (inputs (list ;petsc-openmpi
                  gsl
                  ipopt
                  nlopt
                  mumps ;FIXME: ./configure fails to use mumps
                  (list mmg "lib")
                  suitesparse-umfpack
                  suitesparse-config
                  suitesparse-amd
                  suitesparse-cholmod
                  hdf5
                  fftw
                  arpack-ng
                  scalapack
                  scotch
                  pt-scotch
                  metis
                  openmpi
                  lapack))
    (properties `((tunable? . #t)))
    (home-page "https://freefem.org/")
    (synopsis "High-level multiphysics finite element library")
    (description
     "FreeFEM is a partial differential equation solver for non-linear
multi-physics systems in 2D and 3D using the finite element method.

Problems involving partial differential equations from several branches of
physics such as fluid-structure interactions require interpolations of data
on several meshes and their manipulation within one program.

FreeFEM includes a fast interpolation algorithm and a language for the
manipulation of data on multiple meshes. It is written in C++ and the FreeFEM
language is a C++ idiom.")
    (license license:lgpl3+)))

(define feelpp-commit
  "4253a032757266c8e0ab6418fcb037e6483915e2")
(define feelpp-version
  (git-version "0.111.0" "1" feelpp-commit))

(define-public feel++
  (package
    (name "feel++")
    (version feelpp-version)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (recursive? #t)
             (url "https://github.com/feelpp/feelpp")
             (commit feelpp-commit)))
       (sha256
        (base32 "1nsxdql1m15rdr6vjrqg1dshcr9acq4y1cvvzrnla6sqkj4bc8zz"))))
    (build-system (build-system-with-c-toolchain cmake-build-system
                                                 `(("clang-toolchain" ,clang-toolchain))))
    (native-inputs (list pkg-config gfortran boost-mpi perl))
    (inputs (list openmpi
                  hdf5-parallel-openmpi
                  petsc-openmpi
                  cln
                  gmp
                  fmi4cpp
                  libzip
                  napp
                  tabulate
                  curl
                  fftw
                  glpk
                  slepc
                  fmt-7
                  glog
                  eigen
                  pugixml
                  gmsh
                  ;; Python deps
                  python
                  python-petsc4py
                  python-mpi4py
                  python-sympy
                  pybind11))
    (arguments
     (list
      #:configure-flags #~(list "-DFEELPP_RESET_ENV_LIBRARY_PATH=OFF"
                                "-DFEELPP_ENABLE_TESTS=OFF"
                                "-DFEELPP_ENABLE_QUICKSTART=ON"
                                "-DFEELPP_ENABLE_TOOLBOXES=OFF"
                                "-DFEELPP_ENABLE_MOR=OFF"
                                "-DFEELPP_ENABLE_QUICKSTART=ON"
                                "-DFEELPP_USE_EXTERNAL_FMT=ON"
                                "-DFEELPP_USE_EXTERNAL_CLN=ON")))
    (home-page "https://docs.feelpp.org")
    (synopsis "Finite Element Embedded Language and Library in C++")
    (description
     "Feel++ is an Open-Source C++ library which allows to solve a large range of
partial differential equations using Galerkin methods, e.g. finite element method, spectral element
method, discontinuous Galerkin methods or reduced basis methods. Feel++ enables parallel computing
in a seamless way and allows to solve large scale systems up to tens of thousands of cores.")
    (license license:lgpl3)))

(define fmi4cpp-commit
  "2aea2f545f82c24f23d12a8b0fcf49e3918374d8")
(define fmi4cpp-version
  (git-version "1.0.0" "1" fmi4cpp-commit))

(define-public fmi4cpp
  (package
    (name "fmi4cpp")
    (version fmi4cpp-version)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/NTNU-IHB/FMI4cpp.git")
             (commit fmi4cpp-commit)))
       (file-name (git-file-name "fmi4cpp" fmi4cpp-version))
       (sha256
        (base32 "1pw5xm917ij5mydmwrbszy714pqdig0s25l9zcl4pw3g5dm3lagv"))))
    (build-system cmake-build-system)
    (inputs (list libzip pugixml))
    (arguments
     (list
      #:tests? #f))
    (home-page "https://github.com/NTNU-IHB/FMI4cpp")
    (synopsis
     "FMI4cpp is a cross-platform FMI 2.0 implementation written in modern C++.")
    (description
     "FMI4cpp is a cross-platform FMI 2.0 implementation written in modern C++.")
    (license license:expat)))
