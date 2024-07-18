;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages benchmark)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages perl))

(define-public mpigraph
  (let ((version "1")
        (commit "5f6cbd9883f0204cc65ee5205f35518eab704ba7")
        (revision "1"))
    (package
      (name "mpigraph")
      (version version)
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/LLNL/mpiGraph")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0szycpfl3wvdqra9iyjk43vvrljjbflw9c05m3ibx8bvrmwqn0l9"))))
      (build-system gnu-build-system)
      (native-inputs (list openmpi))
      (inputs (list perl))
      (arguments
       (list #:tests? #f                ; No tests in package.
             #:modules '((ice-9 match)
                         (guix build utils)
                         (guix build gnu-build-system))
             #:phases #~(modify-phases %standard-phases
                          (delete 'configure) ; No configure script.
                          (replace 'install
                            (lambda _
                              (let* ((tmpdir (getenv "TMPDIR"))
                                    (source-dir (string-append tmpdir "/source"))
                                    (bin (string-append #$output "/bin"))
                                    (tools (string-append #$output "/share/mpigraph/tools"))
                                    (doc (string-append #$output "/share/doc/mpigraph")))
                                (for-each (lambda (file-dest-pair)
                                            (match file-dest-pair
                                              ((file . dest)
                                               (install-file (string-append source-dir "/" file) dest))))
                                          (list `("mpiGraph" . ,bin)
                                                `("crunch_mpiGraph" . ,tools)
                                                `("hostlist_lite.pm" . ,tools)
                                                `("README.md" . ,doc)))))))))
      (home-page "https://github.com/LLNL/mpiGraph")
      (synopsis "Benchmark to generate network bandwidth images")
      (description "MPI benchmark to generate network bandwidth images.")
      (license (license:fsf-free "https://github.com/LLNL/mpiGraph/blob/main/mpiGraph.c")))))

;; (define-public bench-in-situ
;;   (let ((commit "da55cb6b37a1f9dbc0e7c878f290ee63fe3d3827")
;;         (version "0.1")
;;         (revision "1"))
;;     (package
;;      (name "bench-in-situ")
;;      (version (git-version version revision commit))
;;      (home-page "https://github.com/Maison-de-la-Simulation/bench-in-situ")
;;      (source
;;       (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/Maison-de-la-Simulation/bench-in-situ")
;;              (commit commit)))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "05l194cg24a7j6phqqh2qdnwqhz32j9fi4qaa2xcgkbwb9yw2400"))))
;;      (build-system cmake-build-system)
;;      (inputs (list kokkos
;;                    pdi
;;                    dms))
;;      (arguments
;;       (list
;;        #:phases #~(modify-phases %standard-phases
;;                                  (add-after 'unpack 'fix-kokkos-dep
;;                                             (lambda _
;;                                               (substitute* "CMakeLists.txt"
;;                                                            (("add_subdirectory.*kokkos)")
;;                                                             "find_package(Kokkos REQUIRED)")
;;                                                            (("add_subdirectory.*dms)")
;;                                                             "")))))))
;;      (synopsis
;;       "")
;;      (description
;;       "")
;;      (license license:gpl3))))
