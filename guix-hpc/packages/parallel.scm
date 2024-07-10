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
  #:use-module (gnu packages parallel)
  #:use-module (guix-hpc packages mpi))

(define-public slurm-openpmix
  (package/inherit slurm
    (name "slurm-openpmix")
    (inputs (modify-inputs (package-inputs slurm)
              (append openmpi-5)))
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
                   (string-append "--with-pmix=" #$(this-package-input "openmpi-5"))
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
