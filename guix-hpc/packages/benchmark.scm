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
      (description "mpiGraph is a MPI benchmark to generate network bandwidth images.")
      (license (license:fsf-free "https://github.com/LLNL/mpiGraph/blob/main/mpiGraph.c")))))

(define-public osu-micro-benchmarks
  (package
    (name "osu-micro-benchmarks")
    (version "7.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://mvapich.cse.ohio-state.edu/download/mvapich/" name "-"
             version ".tar.gz"))
       (sha256
        (base32 "1z6fywvmcvk5s5k4q6qs5fsab2cnyfkl11xjpw4r96b1z8p0rp8y"))))
    (build-system gnu-build-system)
    (inputs (list openmpi))
    (arguments
     (list
      #:configure-flags #~(list (string-append "CC="
                                               #$(this-package-input "openmpi")
                                               "/bin/mpicc")
                                (string-append "CXX="
                                               #$(this-package-input "openmpi")
                                               "/bin/mpicxx"))))
    (home-page "https://mvapich.cse.ohio-state.edu/benchmarks/")
    (synopsis "Benchmarking suite from the MVAPICH project")
    (description
     "Microbenchmarks suite to evaluate MPI and PGAS (OpenSHMEM, UPC, and
UPC++) libraries for CPUs and GPUs.")
    (license license:bsd-3)))
