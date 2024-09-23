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
    (version "1.7.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.maisondelasimulation.fr/pdidev/pdi/")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0rh0nkb9wipb7bgbxrb6vzizl27sszl5l708g3ckcifdd01dxwwb"))
       (snippet #~(begin
                    (use-modules (guix build utils))
                    (delete-file-recursively "vendor")))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                "-DBUILD_BENCHMARKING=OFF")
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "pdi"))))))
    (native-inputs
     (list pkg-config
           ;; needed for the Fortran API support
           gfortran
           python
           zpp
           ;; needed for tests
           benchmark
           openssh
           googletest
           ;; needed for building documentation
           doxygen))
    (native-search-paths
     (list (search-path-specification
            (variable "PDI_PLUGIN_PATH")
            (files
             (list
              (string-append "lib/" name "/plugins_" version))))))
    (inputs (list spdlog
                  libyaml
                  pkg-config
                  paraconf))
    (synopsis "A library allowing loose coupling between components.")
    (description
     "PDI supports loose coupling of simulation codes with data handling
the simulation code is annotated in a library-agnostic way,
libraries are used from the specification tree.")
    (home-page "https://pdi.dev")
    (license license:bsd-3)))

(define-public pdiplugin-mpi
  (package/inherit pdi
    (name "pdiplugin-mpi")
    (inputs
     (modify-inputs (package-inputs pdi)
       (append openmpi)))
    (native-inputs (list gfortran
                         googletest
                         benchmark))
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                ;; force usage of system packages
                                "-DUSE_DEFAULT=SYSTEM"
                                (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/mpi")))
                   (add-before 'check 'mpi-setup
                     #$%openmpi-setup))))
    (synopsis "MPI plugin for PDI")))

(define-public pdiplugin-decl-hdf5
  (package/inherit pdi
    (name "pdiplugin-decl-hdf5")
    (inputs
     (modify-inputs (package-inputs pdi)
       (append hdf5)))
    (native-inputs (list gfortran
                         googletest
                         benchmark))
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                ;; force usage of system packages
                                "-DUSE_DEFAULT=SYSTEM"
                                "-DBUILD_HDF5_PARALLEL=OFF"
                                (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/decl_hdf5")))
                   (add-before 'check 'fix-tests
                     (lambda* _
                       (substitute* "../build/tests/compatibility_tests/CTestTestfile.cmake"
                         (("/bin/bash")
                          (which "bash"))))))))
    (synopsis "Serial verson of the HDF5 plugin for PDI")
    (description "Decl'HDF5 plugin enables one to read and write data from HDF5 files in
a declarative way. Decl'HDF5 does not support the full HDF5 feature
set but offers a simple declarative interface to access a large subset
of it for the PDI library.")))

(define-public pdiplugin-decl-hdf5-parallel
  (package/inherit pdi
    (name "pdiplugin-decl-hdf5-parallel")
    (inputs
     (modify-inputs (package-inputs pdi)
       (append hdf5-parallel-openmpi
               openmpi)))
    (native-inputs (list gfortran
                         googletest
                         benchmark))
    (propagated-inputs (list pdiplugin-mpi))
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                ;; force usage of system packages
                                "-DUSE_DEFAULT=SYSTEM"
                                (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/decl_hdf5")))
                   (add-before 'check 'fix-tests
                     (lambda* _
                       (substitute* "../build/tests/compatibility_tests/CTestTestfile.cmake"
                         (("/bin/bash")
                          (which "bash")))))
                   (add-after 'fix-tests 'mpi-setup
                              #$%openmpi-setup))))
    (synopsis "Parallel verson of the HDF5 plugin for PDI")))

(define-public pdiplugin-set-value
  (package/inherit pdi
    (name "pdiplugin-set-value")
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                ;; force usage of system packages
                                "-DUSE_DEFAULT=SYSTEM"
                                (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/set_value"))))))
    (synopsis "\"set value\" plugin for PDI")))

(define-public pdiplugin-trace
  (package/inherit pdi
    (name "pdiplugin-trace")
    (arguments
     (list
      #:configure-flags #~(list (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:tests? #f ;; no tests in package
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/trace"))))))
    (synopsis "The trace plugin generates a trace of what happens in
PDI \"data store\"")))


(define-public pdiplugin-user-code
  (package/inherit pdi
    (name "pdiplugin-user-code")
    (arguments
     (list
      #:configure-flags #~(list (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/user_code"))))))
    (synopsis "The user-code plugin enables one to call a user-defined function
when a specified event occur or certain data becomes available.")))

(define-public pdiplugin-decl-netcdf
  (package/inherit pdi
    (name "pdiplugin-decl-netcdf")
    (inputs
     (modify-inputs (package-inputs pdi)
       (append netcdf)
       ;; netcdf plugin depends on HDF5 headers to build.
       (append hdf5)))
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON" ;activate tests
                                "-DBUILD_NETCDF_PARALLEL=OFF"
                                (string-append "-DPDI_DIR=" #$pdi "/share/pdi/cmake"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'change-dir
                     (lambda _
                       (chdir "plugins/decl_netcdf"))))))
    (synopsis "Serial version of the NetCDF plugin for PDI")
    (description "Decl'NetCDF plugin allows interaction with the NetCDF software library
and data format.")))
