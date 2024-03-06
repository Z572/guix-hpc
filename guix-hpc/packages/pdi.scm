;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages pdi)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix-hpc packages utils)
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
       (file-name (git-file-name name version))
       (sha256
        (base32 "0d68nlz92abcy9x642i8svbsv4121gq1qm48h6jgp1hmrbqz7mhh"))
       (snippet #~(begin
                    (use-modules (guix build utils))
                    (delete-file-recursively "vendor")))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                ;; force usage of system packages
                                "-DUSE_DEFAULT=SYSTEM"
                                ;; these are not honoured by USE_DEFAULT
                                "-DUSE_GTest=SYSTEM"
                                "-DUSE_benchmark=SYSTEM"
                                "-DUSE_Zpp=SYSTEM")
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
                  fti
                  googletest
                  hdf5-parallel-openmpi
                  pybind11
                  libyaml
                  pkg-config
                  paraconf
                  sionlib
                  zpp))
    (native-inputs (list openssh))      ;for tests
    (synopsis "A library allowing loose coupling between components.")
    (description
     "PDI supports loose coupling of simulation codes with data handling
the simulation code is annotated in a library-agnostic way,
libraries are used from the specification tree.")
    (home-page "https://pdi.dev")
    (license license:bsd-3)))
