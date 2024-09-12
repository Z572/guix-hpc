;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages gysela)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages benchmark)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages check)
  #:use-module (gnu packages code)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages tls)
  #:use-module (guix-hpc packages cpp)
  #:use-module (guix-hpc packages pdi)
  #:use-module (guix-hpc packages utils))

(define-public gyselalibxx
  (let ((commit "a3be632c27742dea183bd20b59484f0599b87d39")
        (version "0.1")
        (revision "2"))
    (package
      (name "gyselalibxx")
      (version (git-version version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/gyselax/gyselalibxx")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "179dm3sldkqxg0zq3lp140q3kdk0wpiiy2fqsrqjzwdkgrpyi0vq"))))
      (build-system cmake-build-system)
      (inputs (list eigen
                    fftw
                    fftwf
                    ginkgo
                    googletest
                    hdf5
                    kokkos
                    libyaml
                    mdspan
                    openmpi
                    openblas
                    paraconf))
      (propagated-inputs (list pdi ;needed to set up PDI_PLUGIN_PATH
                               pdiplugin-decl-hdf5-parallel
                               pdiplugin-set-value
                               pdiplugin-mpi))
      (native-inputs (list pkg-config
                           python
                           python-matplotlib
                           python-xarray
                           python-numpy
                           python-pyyaml
                           python-dask
                           python-h5py))
      (arguments
       (list
        #:configure-flags #~(list
                             "-DGYSELALIBXX_DEPENDENCY_POLICIES=INSTALLED")
        #:phases #~(modify-phases %standard-phases
                     (add-before 'check 'mpi-setup
                       #$%openmpi-setup)
                     (add-after 'unpack 'fix-kokkos-dep
                       (lambda _
                         (substitute* "CMakeLists.txt"
                           (("add_subdirectory.*kokkos.*")
                            "find_package(Kokkos REQUIRED)")))))))
      (synopsis
       "Collection of C++ components for writing gyrokinetic semi-lagrangian codes")
      (description
       "Gyselalib++ is a collection of C++ components for writing gyrokinetic
semi-lagrangian codes and similar as well as a collection of such
codes.")
      (home-page "https://gyselax.github.io/")
      (license license:bsd-2))))
