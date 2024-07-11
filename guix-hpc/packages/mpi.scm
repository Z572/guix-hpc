;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages mpi)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages python)
  #:use-module (guix-hpc packages parallel))

(define-public openmpi-5
  (package/inherit openmpi
    (name "openmpi-5")
    (version "5.0.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://www.open-mpi.org/software/ompi/v"
                           (version-major+minor version)
                           "/downloads/openmpi-" version ".tar.bz2"))
       (sha256
        (base32 "02x9xmpggw77mdpikjjx83j6i4v3gkqbncda73lk5axk0vr841cr"))))
    (inputs (modify-inputs (package-inputs openmpi)
              ;; As of Open MPI 5.0.X, PMIx is used to communicate
              ;; with SLURM, so SLURM'S PMI is no longer needed.
              (delete "slurm")
              (append openpmix)
              (append prrte)))
    (native-inputs (modify-inputs (package-native-inputs openmpi)
                     (append python)))
    (arguments
     (list
      #:configure-flags #~`("--enable-mpi-ext=affinity" ;cr doesn't work
                            "--with-sge"

                            #$@(if (package? (this-package-input "valgrind"))
                                   #~("--enable-memchecker"
                                      "--with-valgrind")
                                   #~("--without-valgrind"))

                            "--with-hwloc=external"
                            "--with-libevent"

                            ;; Open MPI no longer uses the ORTE
                            ;; environment - it has been replaced by
                            ;; PRRTE.
                            "--enable-prrte-prefix-by-default"

                            ;; InfiniBand support
                            "--enable-openib-control-hdr-padding"
                            "--enable-openib-dynamic-sl"
                            "--enable-openib-udcm"
                            "--enable-openib-rdmacm"
                            "--enable-openib-rdmacm-ibaddr"

                            ;; Enable support for SLURM's 'Process Management
                            ;; Interface for Exascale' (PMIx) Vused e.g. by
                            ;; Slurm for the management communication and
                            ;; coordination of MPI processes.
                            ,(string-append "--with-pmix=" #$(this-package-input "openpmix"))
                            ,(string-append "--with-prrte=" #$(this-package-input "prrte")))
      #:phases #~(modify-phases %standard-phases
                   ;; opensm is needed for InfiniBand support.
                   (add-after 'unpack 'find-opensm-headers
                     (lambda* (#:key inputs #:allow-other-keys)
                       (setenv "C_INCLUDE_PATH"
                               (search-input-directory inputs
                                                       "/include/infiniband"))
                       (setenv "CPLUS_INCLUDE_PATH"
                               (search-input-directory inputs
                                                       "/include/infiniband"))))
                   (add-before 'build 'remove-absolute
                     (lambda _
                       ;; Remove compiler absolute file names (OPAL_FC_ABSOLUTE
                       ;; etc.) to reduce the closure size.  See
                       ;; <https://lists.gnu.org/archive/html/guix-devel/2017-07/msg00388.html>
                       ;; and
                       ;; <https://www.mail-archive.com/users@lists.open-mpi.org//msg31397.html>.
                       (substitute* '("oshmem/tools/oshmem_info/param.c"
                                      "ompi/tools/ompi_info/param.c")
                         (("_ABSOLUTE") ""))))
                   (add-after 'install 'remove-logs ;reproducibility
                     (lambda* (#:key outputs #:allow-other-keys)
                       (let ((out (assoc-ref outputs "out")))
                         (for-each delete-file (find-files out "config.log"))))))))))
