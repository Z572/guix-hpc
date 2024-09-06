;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017, 2019, 2020, 2022, 2024 Inria

(define-module (guix-hpc packages io)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fabric-management)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (guix build-system cmake)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages))

(define-public adios2
  (package
    (name "adios2")
    (version "2.10.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ornladios/ADIOS2")
             (commit (string-append "v" version))))
       (sha256
        (base32 "157d68vsww8wcrwpm9dc9lc5rpy922b28vy2rn9dhcfghix0vnzx"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags #~(list "-DADIOS2_USE_MPI=ON"
                                "-DADIOS2_USE_ZeroMQ=ON"
                                "-DADIOS2_USE_HDF5=ON"
                                "-DADIOS2_USE_Python=ON"
                                "-DADIOS2_USE_Fortran=ON"
                                "-DADIOS2_USE_SST=ON"
                                "-DADIOS2_USE_BZip2=ON")))
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
