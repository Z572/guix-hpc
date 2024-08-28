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

(define npb-classes
  '("S" ;Small for quick test purposes
    "W" ;Workstation size
    "A"
    "B"
    "C" ;standard test problems
    ;; ~4X size increase going from one class to the next
    "D"
    "E"
    "F"))

(define npb-names
  '("is" ;Integer Sort, random memory access
    "ep" ;Embarrassingly Parallel
    "cg" ;Conjugate Gradient, irregular memory access and communication
    "mg" ;Multi-Grid on a sequence of meshes, long- and short-distance communication, memory intensive
    "ft" ;discrete 3D fast Fourier Transform, all-to-all communication
    "bt" ;Block Tri-diagonal solver
    "sp" ;Scalar Penta-diagonal solver
    ;; Lower-Upper Gauss-Seidel solver
    "lu"))

(define npb-suite
  (cartesian-product (lambda (name class)
                       ;; Class F is not available for IS
                       (match `(,name ,class)
                         (("is" "F")
                          '())
                         (_ (string-append name "\t" class)))) npb-names
                     npb-classes))

(define-public npb-openmp
  (package
    (name "npb-openmp")
    (version "3.4.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://www.nas.nasa.gov/assets/npb/NPB" version
                           ".tar.gz"))
       (sha256
        (base32 "1svaz2q1s8451hksvavp70kwacinl4al8xcwlzxjdf3sx3bh6z59"))))
    (build-system gnu-build-system)
    (native-inputs (list gfortran))
    (arguments
     (list
      #:make-flags #~(list "suite")
      #:tests? #f
      #:phases #~(modify-phases %standard-phases
                   (delete 'install) ;NPB builds directly into the install dir
                   
                   (add-after 'unpack 'chdir
                     (lambda _
                       (let* ((version' (string-take #$(package-version
                                                        this-package) 3))
                              (subdir (string-append "NPB" version' "-OMP")))
                         (chdir (pk 'subdir subdir)))))

                   (replace 'configure
                     (lambda _
                       (let* ((lines `(("FC" "gfortran")
                                       ("F77" "gfortran")
                                       ("FLINK" "gfortran")
                                       ;; ("F_LIB" "") ;Not needed
                                       ;; ("F_INC" "") ;Not needed
                                       ("FFLAGS" "-O3 -fopenmp")
                                       ("FLINKFLAGS" "-O3 -fopenmp")
                                       ("CC" "gcc")
                                       ("CLINK" "gcc")
                                       ("C_LIB" "-lm")
                                       ;; ("C_INC" "") ;Not needed
                                       ("CFLAGS" "-O3 -fopenmp")
                                       ("CLINKFLAGS" "-O3 -fopenmp")
                                       ("UCC" "gcc")
                                       ("BINDIR" ,(string-append #$output
                                                                 "/bin"))
                                       ;; ("RAND" "randi8") ;Not needed
                                       ("WTIME" "wtime.c"))))
                         (call-with-output-file "config/make.def"
                           (lambda (port)
                             (for-each (lambda (x)
                                         (display (string-append (list-ref x 0)
                                                                 " = "
                                                                 (list-ref x 1)
                                                                 "\n") port))
                                       lines))))

                       (call-with-output-file "config/suite.def"
                         (lambda (port)
                           (for-each (lambda (line)
                                       (display line port)
                                       (display "\n" port))
                                     '#$npb-suite)))

                       (mkdir-p (string-append #$output "/bin")))))))

    (home-page "https://www.nas.nasa.gov/software/npb.html")
    (synopsis "Small set of programs designed to help evaluate the performance
of parallel supercomputers, MPI variant")
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

(define-public npb-mpi
  (package/inherit npb-openmp
    (name "npb-mpi")
    (inputs (list openmpi))
    (arguments (substitute-keyword-arguments (package-arguments npb-openmp)
                 ((#:phases _)
                  #~(modify-phases %standard-phases
                      (delete 'install) ;NPB builds directly into the install dir
                      
                      (add-after 'unpack 'chdir
                        (lambda _
                          (let* ((version' (string-take #$(package-version
                                                           this-package) 3))
                                 (subdir (string-append "NPB" version' "-MPI")))
                            (chdir (pk 'subdir subdir)))))

                      (replace 'configure
                        (lambda _
                          (let* ((lines `(("MPIFC" "mpif90")
                                          ("MPIF77" "mpif77")
                                          ("FLINK" "mpif77")
                                          ;; ("FMPI_LIB" "") ;Not needed
                                          ;; ("FMPI_INC" "") ;Not needed
                                          ;; GCC10 enforces rank matching, disable it as the software is very old
                                          ("FFLAGS"
                                           "-O3 -fallow-argument-mismatch")
                                          ("FLINKFLAGS" "-O3")
                                          ("MPICC" "mpicc")
                                          ("CLINK" "mpicc")
                                          ;; ("CMPI_LIB" "") ;Not needed
                                          ;; ("CMPI_INC" "") ;Not needed
                                          ("CFLAGS" "-O3")
                                          ("CLINKFLAGS" "-O3")
                                          ("CC" "gcc")
                                          ;; ("RAND" "randi8") ;Not needed
                                          ("BINDIR" ,(string-append #$output
                                                                    "/bin")))))
                            (call-with-output-file "config/make.def"
                              (lambda (port)
                                (for-each (lambda (x)
                                            (display (string-append (list-ref
                                                                     x 0)
                                                                    " = "
                                                                    (list-ref
                                                                     x 1) "\n")
                                                     port)) lines))))

                          (call-with-output-file "config/suite.def"
                            (lambda (port)
                              (for-each (lambda (line)
                                          (display line port)
                                          (display "\n" port))
                                        '#$npb-suite)))

                          (mkdir-p (string-append #$output "/bin"))))))))
    (synopsis "Small set of programs designed to help evaluate the performance
of parallel supercomputers, MPI variant")))

