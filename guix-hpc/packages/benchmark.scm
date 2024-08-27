;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages benchmark)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages gcc)
  #:use-module ((guix import utils)
                #:prefix utils:)
  #:use-module (ice-9 match))

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
       (list
        #:tests? #f ;No tests in package.
        #:modules '((ice-9 match)
                    (guix build utils)
                    (guix build gnu-build-system))
        #:phases #~(modify-phases %standard-phases
                     (delete 'configure) ;No configure script.
                     (replace 'install
                       (lambda _
                         (let* ((tmpdir (getenv "TMPDIR"))
                                (source-dir (string-append tmpdir "/source"))
                                (bin (string-append #$output "/bin"))
                                (tools (string-append #$output
                                                      "/share/mpigraph/tools"))
                                (doc (string-append #$output
                                                    "/share/doc/mpigraph")))
                           (for-each (lambda (file-dest-pair)
                                       (match file-dest-pair
                                         ((file . dest) (install-file (string-append
                                                                       source-dir
                                                                       "/"
                                                                       file)
                                                                      dest))))
                                     (list `("mpiGraph" unquote bin)
                                           `("crunch_mpiGraph" unquote tools)
                                           `("hostlist_lite.pm" unquote tools)
                                           `("README.md" unquote doc)))))))))
      (home-page "https://github.com/LLNL/mpiGraph")
      (synopsis "Benchmark to generate network bandwidth images")
      (description
       "mpiGraph is a MPI benchmark to generate network bandwidth images.")
      (license (license:fsf-free
                "https://github.com/LLNL/mpiGraph/blob/main/mpiGraph.c")))))

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

(define (flat-map f lst)
  "Maps f into the list and flattens the result"
  (utils:flatten (map f lst)))

(define (cartesian-product f a b)
  "Given procedure that takes to arguments, applies it for each combination and
returns the list of results"
  (flat-map (lambda (x)
              (map (lambda (y)
                     (f x y)) b)) a))

;; Based on:
;; https://github.com/spack/spack/blob/develop/var/spack/repos/builtin/packages/npb/package.py

(define npb-classes
  '("S" "W"
    "A"
    "B"
    "C"
    "D"
    "E"
    "F"))

(define npb-names
  '("is" "ep"
    "cg"
    "mg"
    "ft"
    "bt"
    "sp"
    "lu"))

(define npb-suite
  (cartesian-product (lambda (name class)
                       ;; Filter available classes
                       (match `(,name ,class)
                         (("is" "F")
                          '())
                         (_ (string-append name "\t" class)))) npb-names
                     npb-classes))

(define-public npb-mpi
  (package
    (name "npb-mpi")
    (version "3.4.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://www.nas.nasa.gov/assets/npb/NPB" version
                           ".tar.gz"))
       (sha256
        (base32 "10c8l8c31cnsnsj17d3b2cr7khc6xb9md4c6x8lsi13fv9kk997k"))))
    (build-system gnu-build-system)
    (native-inputs (list gfortran))
    (inputs (list openmpi))
    (arguments
     (list
      #:make-flags #~(list "suite")
      #:phases #~(modify-phases %standard-phases
                   (delete 'check) ;NPB doesn't have tests
                   (delete 'install) ;NPB builds directly into the install dir
                   
                   (add-after 'unpack 'chdir
                     (lambda* _
                       (let* ((version' (string-take #$version 3))
                              (subdir (string-append "NPB" version' "-MPI")))
                         (chdir (pk 'subdir subdir)))))

                   (replace 'configure
                     (lambda* _
                       (let* ((port (open-file "config/make.def" "a"))
                              (lines `(("MPIFC" "mpif90")
                                       ("MPIF77" "mpif77")
                                       ("FLINK" "mpif77")
                                       ;; ("FMPI_LIB" "") ;; Not needed
                                       ;; ("FMPI_INC" "") ;; Not needed
                                       ("FFLAGS" "-O3")
                                       ("FLINKFLAGS" "-O3")
                                       ("MPICC" "mpicc")
                                       ("CLINK" "mpicc")
                                       ;; ("CMPI_LIB" "") ;; Not needed
                                       ;; ("CMPI_INC" "") ;; Not needed
                                       ("CFLAGS" "-O3")
                                       ("CLINKFLAGS" "-O3")
                                       ("CC" "gcc")
                                       ("BINDIR" ,(string-append #$output
                                                                 "/bin")))))
                         ;; ("RAND" "randi8")))) ;; Not needed
                         (for-each (lambda* (x)
                                     (display (string-append (list-ref x 0)
                                                             " = "
                                                             (list-ref x 1)
                                                             "\n") port))
                                   lines)
                         (close-port port))

                       (let* ((port (open-file "config/suite.def" "a")))
                         (for-each (lambda (line)
                                     (display line port)
                                     (display "\n" port))
                                   '#$npb-suite)

                         (close-port port))

                       (mkdir-p (string-append #$output "/bin")))))))

    (home-page "https://www.nas.nasa.gov/software/npb.html")
    (synopsis "Small set of programs designed to help evaluate the
performance of parallel supercomputers, MPI variant")
    (description
     "The benchmarks are derived from computational fluid dynamics (CFD)
applications and consist of five kernels and three pseudo-applications in the original
\"pencil-and-paper\" specification (NPB 1). The benchmark suite has been extended
to include new benchmarks for unstructured adaptive meshes, parallel I/O, multi-zone
applications, and computational grids. Problem sizes in NPB are predefined and indicated
as different classes.")
    ;; License is not in the source, but declared in this comment
    ;; https://github.com/LLNL/NPB/commit/35cd0e4a895da7dea0316fac34b4da9ab5d7cba5
    (license license:expat)))

