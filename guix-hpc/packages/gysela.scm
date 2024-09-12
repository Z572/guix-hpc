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
  #:use-module (guix build-system copy)
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

(define-public libkoliop
  (package
    (name "libkoliop")
    (version "0.0.18")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.com/cines/code.gysela/libkoliop")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0pyb6msknq2g1k6q6f58an5illqkhpxyz6zlw01w91sqqzy4z6li"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan
           #~'(("." "src"))))
    (home-page "https://gitlab.com/cines/code.gysela/libkoliop")
    (synopsis "KOkkos based colLIsion OPerator (KoLiOp) for Gysela")
    (description "A KOkkos based colLIsion OPerator (KoLiOp) for Gysela that computes
the evolution of the distribution function due to collisions.")
    (license license:expat)))

(define-public gyselalibxx
  ;; Commit from 04-09-2024.
  (let ((commit "806f94c601c7bcf604174506f212ec0be374b348")
        (version "0.1")
        (revision "3"))
    (package
      (name "gyselalibxx")
      (version (git-version version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/gyselax/gyselalibxx")
               (commit commit)
               (recursive? #t)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "153cv3x9k5fx0vf7cq0df6qvz11g8kd5flq5wv2j0v1dhrb62d46"))
         ;; Remove nearly everything from the vendored dependencies.
         ;; We keep only koliop which is statically linked.
         (snippet #~(begin
                      (use-modules (guix build utils))
                      (for-each (lambda (dir)
                                  (delete-file-recursively (string-append "vendor/" dir)))
                                (list "benchmark"
                                      "googletest"
                                      "kokkos"
                                      "kokkos-kernels"
                                      ;; For now, use vendored kokkos-tools as the
                                      ;; upstream repo is not properly versioned.
                                        ;"kokkos-tools"
                                      "mdspan"
                                      "eigen"
                                      "ddc"))
                      ;; While here, fix dependency solver of koliop.
                      ;; This could be done in a phase but we do it here
                      ;; so when koliop is properly packaged, all the snippet
                      ;; can be removed.
                      (substitute* "vendor/koliop/dependencies/kokkos/seeker.cmake"
                        (("VERSION          \"4.1.0...<5.0.0\"")
                         "VERSION \"\""))))))
      (build-system cmake-build-system)
      (inputs (list ddc
                    eigen
                    fftw
                    fftwf
                    ginkgo
                    googletest
                    hdf5
                    kokkos
                    ;; For now we need to use a fork of kokkos-kernels.
                    ;; Changes are to be upstreamed.
                    (@@ (guix-hpc packages cpp) kokkos-kernels-for-ddc-and-gyselalibxx)
                    libyaml
                    mdspan
                    openmpi
                    openblas
                    paraconf))
      (propagated-inputs (list pdi   ;needed to set up PDI_PLUGIN_PATH
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
                           (("add_subdirectory\\(\"vendor/kokkos/\" \"kokkos\"\\)")
                            "find_package(Kokkos REQUIRED)")
                           (("add_subdirectory\\(\"vendor/kokkos-kernels/\" \"kokkos-kernels\"\\)")
                            "find_package(KokkosKernels REQUIRED)")
                           (("add_subdirectory\\(\"vendor/ddc/\" \"ddc\"\\)")
                            "find_package(DDC REQUIRED)")
                           ;; koliop should be able to find Kokkos by itself.
                           ((".*koliop_ENABLE_Kokkos.*")
                            "")))))))
      (synopsis
       "Collection of C++ components for writing gyrokinetic semi-lagrangian codes")
      (description
       "Gyselalib++ is a collection of C++ components for writing gyrokinetic
semi-lagrangian codes and similar as well as a collection of such
codes.")
      (home-page "https://gyselax.github.io/")
      (license license:bsd-2))))
