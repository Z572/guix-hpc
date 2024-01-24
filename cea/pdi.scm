;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (cea pdi)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages benchmark)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages check)
  #:use-module (gnu packages code)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages serialization))

(define-public pdi
  (package
    (name "pdi")
    (version "1.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.maisondelasimulation.fr/pdidev/pdi/")
             (commit version)))
       (sha256
        (base32 "0d68nlz92abcy9x642i8svbsv4121gq1qm48h6jgp1hmrbqz7mhh"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                ;; force usage of system packages
                                ;; TODO: package the remaining vendored dependencies?
                                "-DUSE_Astyle=SYSTEM"
                                "-DUSE_benchmark=SYSTEM"
                                "-DUSE_Doxygen=SYSTEM"
                                "-DUSE_GTest=SYSTEM"
                                "-DUSE_HDF5=SYSTEM"
                                "-DUSE_pybind11=SYSTEM"
                                "-DUSE_paraconf=SYSTEM"
                                "-DUSE_spdlog=SYSTEM"
                                "-DUSE_yaml=SYSTEM")
      #:phases #~(modify-phases %standard-phases
                   (add-before 'check 'fix-tests
                     (lambda* _
                       (substitute* "../build/DECL_HDF5_PLUGIN/src/DECL_HDF5_PLUGIN_pkg-build/tests/compatibility_tests/CTestTestfile.cmake"
                         (("/bin/bash")
                          (which "bash")))))
                   (add-after 'fix-tests 'mpi-setup
                     #$%openmpi-setup))))
    (inputs (list gfortran
                  python
                  openmpi
                  ;; the following packages are provided by PDI but
                  ;; we use the version present in Guix
                  astyle
                  spdlog
                  benchmark
                  doxygen
                  googletest
                  hdf5-parallel-openmpi
                  pybind11
                  libyaml
                  pkg-config
                  paraconf))
    (native-inputs (list openssh)) ;for tests
    (synopsis "A library allowing loose coupling between components.")
    (description
     "PDI supports loose coupling of simulation codes with data handling
the simulation code is annotated in a library-agnostic way,
libraries are used from the specification tree.")
    (home-page "https://pdi.dev")
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
        (base32 "062jqhx0fpf4sspnz131408272brpqdcimcwmrv8ynykchgma44m"))))
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
