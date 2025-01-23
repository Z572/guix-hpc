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
  #:use-module (gnu packages)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages gcc)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1))

(define-public gpcnet
  (package
    (name "gpcnet")
    (version "1.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/netbench/GPCNET")
             ;; Version 1.3 is not tagged in the Git repository but it
             ;; is mentioned in the source diff corresponding to this
             ;; commit.
             (commit "476e0c342e91f59ff54cc5b431ac84c99afff0be")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0bnfr8z24mm4h3xmdqvj2g33nrxdjwjlhwqm76yilramlnikci4w"))))
    (build-system gnu-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               ;; No configure script.
               (delete 'configure)
               ;; No install rule in the Makefile.
               (replace 'install
                 (lambda _
                   (let ((bin (string-append #$output "/bin")))
                     (install-file "network_test" bin)
                     (install-file "network_load_test" bin)))))
           #:make-flags
           #~(list (string-append "CC=" #$(this-package-input "openmpi") "/bin/mpicc")
                   ;; There is no configured default target in the
                   ;; Makefile: in order to build everything, the all
                   ;; target must be specified.
                   "all")
           ;; No tests in package.
           #:tests? #f))
    (inputs (list openmpi))
    (home-page "https://github.com/netbench/GPCNET")
    (synopsis "Global Performance and Congestion Network Test")
    (description "GPCNeT is a benchmark suite that includes simulated network
congestion.  It allows to benchmark network performance in
closer-to-real-conditions in HPC networks.")
    (license license:asl2.0)))

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
        #:tests? #f                     ;No tests in package.
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

(define (cartesian-product proc a b)
  "Given procedure that takes to arguments, applies it for each combination and
returns the list of results"
  (append-map (lambda (x)
                (map (lambda (y)
                       (proc x y)) b)) a))

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
                       (match `(,name ,class)
                         ;; Class F is not available for IS
                         (("is" "F")
                          (string-append "# skipping: " name " " class))
                         (_ (string-append name " " class)))) npb-names
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
                       (let* ((version' #$(version-major+minor (package-version
                                                                this-package)))
                              (subdir (string-append "NPB" version' "-OMP")))
                         (chdir (pk 'subdir subdir)))))

                   (replace 'configure
                     (lambda _
                       (let* ((lines `(("FC" "gfortran")
                                       ("F77" "gfortran")
                                       ("FLINK" "gfortran")
                                       ("FFLAGS" "-O3 -fopenmp")
                                       ("FLINKFLAGS" "-O3 -fopenmp")
                                       ("CC" "gcc")
                                       ("CLINK" "gcc")
                                       ("C_LIB" "-lm")
                                       ("CFLAGS" "-O3 -fopenmp")
                                       ("CLINKFLAGS" "-O3 -fopenmp")
                                       ("UCC" "gcc")
                                       ("BINDIR" ,(string-append #$output
                                                                 "/bin"))
                                       ("RAND" "randi8")
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
    (synopsis "NAS Parallel Benchmarks (NPB), OpenMP variant")
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

(define-public npb-openmpi
  (package/inherit npb-openmp
    (name "npb-openmpi")
    (inputs (list openmpi))
    (arguments (substitute-keyword-arguments (package-arguments npb-openmp)
                 ((#:phases phases)
                  #~(modify-phases #$phases
                      (replace 'chdir
                        (lambda _
                          (let* ((version' #$(version-major+minor (package-version
                                                                   this-package)))
                                 (subdir (string-append "NPB" version' "-MPI")))
                            (chdir (pk 'subdir subdir)))))

                      (replace 'configure
                        (lambda _
                          (let* ((lines `(("MPIFC" "mpif90")
                                          ("MPIF77" "mpif77")
                                          ("FLINK" "mpif77")
                                          ("FFLAGS"
                                           ;; GCC10 enforces rank matching, disable it as the software is very old
                                           "-O3 -fallow-argument-mismatch")
                                          ("FLINKFLAGS" "-O3")
                                          ("MPICC" "mpicc")
                                          ("CLINK" "mpicc")
                                          ("CFLAGS" "-O3")
                                          ("CLINKFLAGS" "-O3")
                                          ("CC" "gcc")
                                          ("BINDIR" ,(string-append #$output
                                                                    "/bin"))
                                          ("RAND" "randi8"))))
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
    (synopsis "NAS Parallel Benchmarks (NPB), MPI variant")))

(define-public netlib-hpl
  (package
    (name "netlib-hpl")
    (version "2.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://netlib.org/benchmark/hpl/hpl-" version
                           ".tar.gz"))
       (sha256
        (base32 "0c18c7fzlqxifz1bf3izil0bczv3a7nsv0dn6winy3ik49yw3i9j"))
       (patches (search-patches
                 "guix-hpc/packages/patches/hpl-use-default-hpl-dat.patch"))))
    (build-system gnu-build-system)
    (inputs (list openblas openmpi))
    (arguments
     (list #:configure-flags #~(list "CFLAGS=-DHPL_DETAILED_TIMING -DHPL_CALL_CBLAS")
           #:make-flags #~(list "arch=x86_64")
           #:phases #~ (modify-phases %standard-phases
                         (add-after 'unpack 'set-hpl-dat-path
                           (lambda _
                             (substitute* "testing/ptest/HPL_pdinfo.c"
                               (("@@GUIX_HPL_DAT@@")
                                (string-append #$output
                                               "/share/"
                                               #$(package-name this-package)
                                               "-"
                                               #$(package-version this-package)
                                               "/examples")))))
                         (add-after 'install 'install-hpl-dat
                           (lambda _
                             (install-file "testing/ptest/HPL.dat"
                                           (string-append #$output
                                                          "/share/"
                                                          #$(package-name this-package)
                                                          "-"
                                                          #$(package-version this-package)
                                                          "/examples")))))))
    (home-page "https://netlib.org/benchmark/hpl/")
    (synopsis "High-Performance Linpack Benchmark for Distributed-Memory Computers")
    (description "HPL is a software package that solves a (random) dense linear system
in double precision (64 bits) arithmetic on distributed-memory
computers.  It can thus be regarded as a portable as well as freely
available implementation of the High Performance Computing Linpack
Benchmark.")
    (license (license:non-copyleft "https://netlib.org/benchmark/hpl/copyright.html"))))
