;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages parallel)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages parallel)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python))

(define-public prrte
  (package
   (name "prrte")
   (version "3.0.6")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/openpmix/prrte/releases/download/v"
                  version "/prrte-" version ".tar.bz2"))
            (sha256
             (base32
              "0wiy0vk37v4db1jgxza8bci0cczcvj34dalzsrlz05dk45zb7dl3"))))
   (build-system gnu-build-system)
   (arguments
    (list #:configure-flags #~(list (string-append "--with-hwloc="
                                                   (assoc-ref %build-inputs "hwloc"))
                                    (string-append "--with-pmix=" #$(this-package-input "openpmix")))))
   (inputs (list libevent
                 `(,hwloc-2 "lib")
                 openpmix))
   (native-inputs (list perl))
   (synopsis "PMIx Reference RunTime Environment (PRRTE)")
   (description
    "The PMIx Reference RunTime Environment is a runtime environment
containing the reference implementation and capable of operating
within a host SMS. The reference RTE therefore provides an easy way of
exploring PMIx capabilities and testing PMIx-based applications
outside of a PMIx-enabled environment.")
   (home-page "https://openpmix.github.io/")
   ;; The provided license is kind of BSD-style but specific.
   (license (license:fsf-free "https://github.com/openpmix/prrte?tab=License-1-ov-file#License-1-ov-file"))))

(define-public openpmix
  (package
   (name "openpmix")
   (version "4.2.8")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/openpmix/openpmix/releases/download/v"
                  version "/pmix-" version ".tar.bz2"))
            (sha256
             (base32
              "1j9xlhqrrmgjdkwakamn78y5gj756adi53hn25zksgr3is3l5d09"))))
   (build-system gnu-build-system)
   (arguments
    (list #:configure-flags #~(list (string-append "--with-hwloc="
                                                   (ungexp (this-package-input "hwloc") "lib")))))
   (inputs (list libevent
                 `(,hwloc-2 "lib")))
   (native-inputs (list perl
                        python))
   (synopsis "PMIx library")
   (description
    "PMIx is an application programming interface standard that provides
libraries and programming models with portable and well-defined access
to commonly needed services in distributed and parallel computing
systems.")
   (home-page "https://pmix.org/")
   ;; The provided license is kind of BSD-style but specific.
   (license (license:fsf-free "https://github.com/openpmix/openpmix?tab=License-1-ov-file#License-1-ov-file"))))

(define-public slurm-openpmix
  (package/inherit slurm
    (name "slurm-openpmix")
    (inputs (modify-inputs (package-inputs slurm)
              (append openpmix)))
    (arguments
     (list #:configure-flags
           #~(list "--enable-pam" "--sysconfdir=/etc/slurm"
                   "--disable-static"
                   (string-append "--with-freeipmi=" #$(this-package-input "freeipmi"))
                   (string-append "--with-hwloc="
                                  (ungexp (this-package-input "hwloc") "lib"))
                   (string-append "--with-json=" #$(this-package-input "json-c"))
                   (string-append "--with-munge=" #$(this-package-input "munge"))
                   ;; Use PMIx bundled with Open MPI (this is required for Open MPI 5.x).
                   (string-append "--with-pmix=" #$(this-package-input "openpmix"))
                   ;; 32-bit support is marked as deprecated and needs to be
                   ;; explicitly enabled.
                   #$@(if (target-64bit?) '() '("--enable-deprecated")))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'patch-plugin-linker-flags
                 (lambda _
                   (substitute* (find-files "src/plugins/" "Makefile.in")
                     (("_la_LDFLAGS = ")
                      "_la_LDFLAGS = ../../../api/libslurm.la "))))
               (add-after 'patch-plugin-linker-flags 'autoconf
                 (lambda _ (invoke "autoconf"))) ;configure.ac was patched
               (add-after 'install 'install-libpmi
                 (lambda _
                   ;; Open MPI expects libpmi to be provided by Slurm so install it.
                   (invoke "make" "install" "-C" "contribs/pmi")

                   ;; Others expect pmi2.
                   (invoke "make" "install" "-C" "contribs/pmi2"))))))))
