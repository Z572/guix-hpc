;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2019, 2020, 2023 Inria

(define-module (guix-hpc packages memphis)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages xml))

(define-public bitpit
  (package
    (name "bitpit")
    (version "1.8.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/optimad/bitpit")
                    (commit (string-append "bitpit-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "16iz6bb1wkly970vlin82bs6295j4qy2vwq098zqa0sh5ggiwxv4"))))
    (inputs
     (list libxml2 openblas))
    (propagated-inputs
     (list openmpi petsc-openmpi))
    (native-inputs
     (list pkg-config gfortran openssh))
    (build-system cmake-build-system)
    (arguments
     (list #:configure-flags
           #~`("-DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON"
               "-DBUILD_SHARED_LIBS=ON" "-DENABLE_MPI=ON"
               ,(string-append "-DPETSC_DIR="
                               #$(this-package-input "petsc-openmpi")))
           #:tests? #f))
    (home-page "http://optimad.github.io/bitpit/")
    (synopsis
     "C++ parallel library for structured and unstructured mesh handling.")
    (description
     "C++ parallel library for structured and unstructured mesh handling.")
    (license license:lgpl3)))
