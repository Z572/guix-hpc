;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017, 2019, 2021-2023 Inria

(define-module (inria bioversiton)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi))

(define-public disseq
  (let ((commit "350e58d35d64de0827620bf1d8f207ee1d1df220")
        (revision "1"))
    (package
      (name "disseq")
      (version (git-version "0.0" revision commit))
      (home-page "https://gitlab.inria.fr/biodiversiton/disseq")
      (source (origin
                (method git-fetch)
                (uri (git-reference (url home-page) (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1x1vynzkqz3m98px1rp2iqcdm1wqxkwp142jsp3myzk80il4m52q"))))
      (build-system cmake-build-system)
      (arguments
       '(#:configure-flags `("-DBUILD_SHARED_LIBS=OFF"
                             "-DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON")
         #:phases (modify-phases %standard-phases
                    (add-after 'unpack 'chdir
                      (lambda _
                        (chdir "src"))))
         #:tests? #f))

      (inputs (list openmpi hdf5-parallel-openmpi))

      (synopsis "Compute pairwise distances between reads as edit distances")
      (description
       "This package has been developed for computing exact distances,
without heuristics, between all pairs of reads of a NGS sample. This is a
first step for supervised or unsupervised clustering of reads in an
environmental sample.")
      (license license:gpl3+))))
