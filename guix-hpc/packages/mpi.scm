;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2017-2024 Inria

(define-module (guix-hpc packages mpi)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages parallel)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xml)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define %pm2-home-page
  "https://pm2.gitlabpages.inria.fr/")
(define %pm2-git
  "https://gitlab.inria.fr/pm2/pm2.git")
(define %pm2-commit
  "release-2024-07-12")
(define %pm2-hash
  "1f45ip7xjm2lx6hnjfriklgv33vh0f1qsrdkan886z0bsadknww8")
 ; guix hash -rx .
(define %pm2-version
  "2024-07-12")

(define-public puk
  (package
    (name "puk")
    (version %pm2-version)
    (home-page (string-append %pm2-home-page "PadicoTM"))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit %pm2-commit)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 %pm2-hash))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug"
                           "--disable-trace")
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* '("building-tools/common_vars.mk.in"
                                     "building-tools/package-version.sh")
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "Puk") #t))
                  (delete 'check)))) ;no make check in Puk
    (native-inputs (list pkg-config autoconf automake))
    (propagated-inputs (list expat procps))
    (synopsis "PadicoTM micro-kernel")
    (description
     "Puk is the core of PadicoTM. It manages dynamically loadable
modules, software components, and basic data structures (lists, vectors,
hashtables, lock-free queues).")
    (license license:gpl2)))

(define-public pioman
  (package
    (name "pioman")
    (version %pm2-version)
    (home-page (string-append %pm2-home-page "pioman"))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit %pm2-commit)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 %pm2-hash))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug"
                           "--with-pthread")
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* '("building-tools/common_vars.mk.in"
                                     "building-tools/package-version.sh")
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "pioman") #t))
                  (delete 'check)))) ;no make check in pioman
    (native-inputs (list pkg-config autoconf automake))
    (propagated-inputs (list puk
                             `(,hwloc "lib")))
    (synopsis "A Generic I/O Manager")
    (description
     "PIOMan is an I/O event manager of the PM2 software suite. It
ensures communication progression using available cores and hooks in thread
scheduler. It guarantees good reactivity, asynchronous communication progression,
and communication/computation overlap.
PIOMan is closely integrated with the NewMadeleine communication library and
PadicoTM. It works with three flavors of thread scheduling: no thread, pthread,
and Marcel. The pthread flavor may be composed with various runtime systems such
as OpenMP.
PIOMan can be used standalone to bring low level asynchronous progression in a
communication library, or more simply may be used through the NewMadeleine
communication library and its companion MPI implementation called Mad-MPI
supporting MPI_THREAD_MULTIPLE multi-threading level.")
    (license license:gpl2)))

(define-public pukabi
  (package
    (name "pukabi")
    (version %pm2-version)
    (home-page (string-append %pm2-home-page "PadicoTM"))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit %pm2-commit)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 %pm2-hash))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug"
                           "--enable-mem")
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* '("building-tools/common_vars.mk.in"
                                     "building-tools/package-version.sh")
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "PukABI") #t))
                  (delete 'check))))
    (native-inputs (list pkg-config autoconf automake))
    (propagated-inputs (list puk))
    (synopsis "Dynamic ABI manager")
    (description
     "PukABI is a dynamic ABI manager. It intercepts symbols using
LD_PRELOAD to allow for a variety of features: replace a libc function with a
user-supplied function; add hooks for locking with another thread library
than libc pthread; add hooks for memory.")
    (license license:gpl2)))

(define-public padicotm
  (package
    (name "padicotm")
    (version %pm2-version)
    (home-page (string-append %pm2-home-page "PadicoTM"))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit %pm2-commit)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 %pm2-hash))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug"
                           "--with-pioman"

                           ;; 'padico-d' wants to write to $localstatedir/log.
                           "--localstatedir=/var")
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* '("building-tools/common_vars.mk.in"
                                     "building-tools/package-version.sh")
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "PadicoTM") #t))
                  (delete 'check)
                  (add-after 'install 'wrap-padico-launch
                    (lambda* (#:key inputs outputs #:allow-other-keys)
                      ;; Wrap the 'padico-launch' shell script so that it
                      ;; finds all the commands that it needs.
                      (define (input-directory input)
                        (string-append (assoc-ref inputs input) "/bin"))

                      (let* ((path (map input-directory
                                        '("util-linux" ;'setsid'
                                          "inetutils" ;'hostname'
                                          "procps" ;'ps'
                                          "hwloc" ;for 'padico-d'
                                          "which"
                                          "tar"
                                          "gzip"
                                          "coreutils"
                                          "grep"
                                          "sed"
                                          "gawk")))
                             (out (assoc-ref outputs "out"))
                             (bin (string-append out "/bin")))
                        (wrap-program (string-append bin "/padico-launch")
                          `("PATH" ":" prefix
                            ,path)) #t))))))
    (inputs (list util-linux procps inetutils hwloc which))
    (native-inputs (list pkg-config
                         autoconf
                         automake
                         `(,hwloc "lib")
                         rdma-core
                         psm
                         psm2
                         slurm))
    (propagated-inputs (list puk pioman pukabi))
    (synopsis "A High-performance Communication Framework for Grids")
    (description
     "PadicoTM is composed of a core which provides a
high-performance framework for networking and multi-threading, and
services plugged into the core. High-performance communications
and threads are obtained thanks to Marcel and Madeleine, provided
by the PM2 software suite. The PadicoTM core aims at making the
different services running at the same time run in a cooperative
way rather than competitive.")
    (license license:gpl2)))

(define-public padicotm-mini
  (package
    (inherit padicotm)
    (name "padicotm-mini")
    (arguments
     (substitute-keyword-arguments (package-arguments padicotm)
       ((#:configure-flags flags
         '())
        `(cons "--without-pioman"
               (delete "--with-pioman"
                       ,flags)))))
    (propagated-inputs `(,@(delete `("pioman" ,pioman)
                                   (package-propagated-inputs padicotm))))))

;;see comment above nmad*-pukabi packages definition
(define-public padicotm-pukabi
  (package
    (inherit padicotm)
    (name "padicotm-pukabi")
    (arguments
     (substitute-keyword-arguments (package-arguments padicotm)
       ((#:configure-flags flags
         '())
        `(cons "--without-pukabi"
               ,flags))))
    (propagated-inputs `(,@(delete `("pukabi" ,pukabi)
                                   (package-propagated-inputs padicotm))))))

(define-public padicotm-mini-pukabi
  (package
    (inherit padicotm-mini)
    (name "padicotm-mini-pukabi")
    (arguments
     (substitute-keyword-arguments (package-arguments padicotm-mini)
       ((#:configure-flags flags
         '())
        `(cons "--without-pukabi"
               ,flags))))
    (propagated-inputs `(,@(delete `("pukabi" ,pukabi)
                                   (package-propagated-inputs padicotm-mini))))))

(define-public nmad
  (package
    (name "nmad")
    (version %pm2-version)
    (home-page (string-append %pm2-home-page "newmadeleine"))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit %pm2-commit)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 %pm2-hash))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug"
                           "--with-pioman" "--with-pukabi" "--enable-mpi"
                           "--disable-sampling")
       #:phases (modify-phases %standard-phases
                  ;; (add-before 'check 'pre-check
                  ;; (lambda _
                  ;; (setenv "PADICO_VERBOSE" "yes") ; for verbose tests
                  ;; #t))
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* '("building-tools/common_vars.mk.in"
                                     "building-tools/package-version.sh")
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "nmad") #t))
                  (add-after 'install 'set-libexec-dir-mpicc
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (for-each (lambda (file)
                                    (substitute* file
                                      (("^libexec=.*")
                                       (string-append "libexec=" out
                                                      "/libexec\n"))))
                                  (find-files (string-append out "/bin")
                                              "^mpi")) #t)))
                  (add-after 'install 'install-examples-too
                    (lambda _
                      (invoke "make"
                              "-j"
                              (number->string (parallel-job-count))
                              "-C"
                              "examples"
                              "install")))
                  (delete 'check))))
    (native-inputs (list pkg-config autoconf automake gfortran))
    (propagated-inputs (list hwloc padicotm))
    (inputs (list rdma-core psm psm2 slurm))
    (synopsis
     "An Optimizing Communication Library for High-Performance Networks")
    (description
     "NewMadeleine is the fourth incarnation of the Madeleine
communication library. The new architecture aims at enabling the use of a much
wider range of communication flow optimization techniques. Its design is entirely
modular: drivers and optimization strategies are dynamically loadable software
components, allowing experimentations with multiple approaches or on multiple
issues with regard to processing communication flows.
The optimizing scheduler SchedOpt targets applications with irregular, multi-flow
communication schemes such as found in the increasingly common application
conglomerates made of multiple programming environments and coupled pieces of
code, for instance. SchedOpt itself is easily extensible through the concepts of
optimization strategies (what to optimize for, what the optimization goal is)
expressed in terms of tactics (how to optimize to reach the optimization goal).
Tactics themselves are made of basic communication flows operations such as packet
merging or reordering.
The communication library is fully multi-threaded through its close integration
with PIOMan. It manages concurrent communication operations from multiple
libraries and from multiple threads. Its MPI implementation Mad-MPI fully supports
the MPI_THREAD_MULTIPLE multi-threading level.")
    (license license:gpl2)))

(define-public nmad-mini
  (package
    (inherit nmad)
    (name "nmad-mini")
    (arguments
     (substitute-keyword-arguments (package-arguments nmad)
       ((#:configure-flags flags
         '())
        `(cons "--without-pioman"
               (delete "--with-pioman"
                       ,flags)))))
    (propagated-inputs `(("padicotm" ,padicotm-mini)
                         ,@(delete `("padicotm" ,padicotm)
                                   (package-propagated-inputs nmad))))))

;;nmad-pukabi and nmad-mini-pukabi corresponds to old packages that were not using pukabi
;;they should only be used in case something goes wrong with the default ones
;;they are not meant to be maintained
(define-public nmad-pukabi
  (package
    (inherit nmad)
    (name "nmad-pukabi")
    (arguments
     (substitute-keyword-arguments (package-arguments nmad)
       ((#:configure-flags flags
         '())
        `(cons "--without-pukabi"
               (delete "--with-pukabi"
                       ,flags)))))
    (propagated-inputs `(("padicotm" ,padicotm-pukabi)
                         ,@(delete `("padicotm" ,padicotm)
                                   (package-propagated-inputs nmad))))))

(define-public nmad-mini-pukabi
  (package
    (inherit nmad-mini)
    (name "nmad-mini-pukabi")
    (arguments
     (substitute-keyword-arguments (package-arguments nmad-mini)
       ((#:configure-flags flags
         '())
        `(cons "--without-pukabi"
               (delete "--with-pukabi"
                       ,flags)))))
    (propagated-inputs `(("padicotm" ,padicotm-mini-pukabi)
                         ,@(delete `("padicotm" ,padicotm-mini)
                                   (package-propagated-inputs nmad-mini))))))

(define-public mpibenchmark
  (package
    (name "mpibenchmark")
    (version "0.4")
    (home-page (string-append %pm2-home-page "mpibenchmark"))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit "9f08955628deca25e45bb23be21f91e7d0377121")))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 "0pk872qdjvw9jx6rnilxlzyp0ygbgcamh38c5izvbkh9pms00l4h"))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug")
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* '("building-tools/common_vars.mk.in"
                                     "building-tools/package-version.sh"
                                     "mpi_sync_clocks/autogen.sh")
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "mpibenchmark") #t))
                  (delete 'check)))) ;no make check in mpibenchmark
    (native-inputs (list pkg-config autoconf automake))
    (inputs (list `(,hwloc "lib") gnuplot nmad))
    (synopsis "MPI overlap benchmark")
    (description
     "MadMPI benchmark contains the following benchmark series:
- base send/recv benchmark, used for reference (mpi_bench_base);
- communication/computation overlap benchmark (mpi_bench_overlap);
- tag-matching performance with tags of posted receives in order and out of
  order (mpi_bench_reqs);
- multi-threaded communications benchmark (mpi_bench_thread) // preliminary
  version, still incomplete.
Benchmarks are point-to-point, running on two nodes. Collective operations
are not benchmarked yet.")
    (license license:gpl2)))

(define-public mpi_sync_clocks
  (package
    (name "mpi_sync_clocks")
    (version %pm2-version)
    (home-page %pm2-home-page)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url %pm2-git)
             (commit %pm2-commit)))
       (file-name (string-append name "-" version "-checkout"))
       (sha256
        (base32 %pm2-hash))))
    (build-system gnu-build-system)
    (arguments
     '(#:out-of-source? #t
       #:configure-flags '("--enable-optimize" "--disable-debug")
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'fix-hardcoded-paths-chdir
                    (lambda _
                      (substitute* "building-tools/common_vars.mk.in"
                        (("/bin/sh")
                         (which "sh")))
                      (chdir "mpi_sync_clocks") #t))
                  (delete 'check)))) ;no make check in mpi_sync_clocks
    (native-inputs (list pkg-config autoconf automake))
    (inputs (list openmpi)) ;Every packet requiring mpi use openmpi, so use it, it will be simpler to then change with `--with-input=openmpi=nmad`
    (propagated-inputs (list procps))
    (synopsis "Distributed synchronized clocks over MPI")
    (description
     "Small library with routines to synchronize clocks over several
                nodes with MPI.")
    (license license:lgpl2.1)))
