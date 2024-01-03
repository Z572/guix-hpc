;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (inria melissa)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-science)
  #:use-module (utils python-science)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages python)
  #:use-module (guix licenses))

(define commit
  "090b0b61df0ca2f0ae0453bea75749cd3d5f9198")

(define version
  "1.0.0")
; according to the version number in the source code

(define revision
  "1")

(define melissa-source
  (origin
    (method git-fetch)
    (uri (git-reference (url "https://gitlab.inria.fr/melissa/melissa.git")
                        (commit commit)))
    (sha256 (base32 "1zv36r8gbb92v9s6vvzgdvv8ryli6a51b0i3g61k1rr6l3bvh6g3"))))

(define melissa-version
  (string-append version "-" commit))

(define melissa-license
  bsd-3)

(define melissa-homepage
  "https://gitlab.inria.fr/melissa/melissa")

(define-public melissa-api
  (package
    (name "melissa-api")
    (version melissa-version)
    (source
     melissa-source)
    (build-system cmake-build-system)
    (inputs (list openmpi zeromq gcc-toolchain gfortran-toolchain pkg-config))
    (arguments
     '(#:tests? #f))
    (home-page melissa-homepage)
    (synopsis "Melissa API for client instrumentation")
    (description
     "Melissa is a file-avoiding, adaptive, fault-tolerant and elastic
      framework, to run large-scale sensitivity analysis or deep-surrogate
      training on supercomputers.
      This package builds the API used when instrumenting the clients.")
    (license melissa-license)))

(define-public heat-pde
  (package
    (name "heat-pde")
    (version melissa-version)
    (source
     melissa-source)
    (build-system cmake-build-system)
    (inputs (list melissa-api
                  openmpi
                  gcc-toolchain
                  gfortran-toolchain
                  python
                  pkg-config))
    (arguments
     '(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (add-after 'unpack 'copy-resources
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (resources (string-append out
                                         "/share/heat-pde/resources")))
                        (copy-recursively "./examples/heat-pde/heat-pde-sa"
                                          resources)
                        (with-directory-excursion resources
                          (for-each (lambda (f)
                                      (substitute* f
                                        (("executable_command(.*)heatc")
                                         (string-append
                                          "executable_command\": \"" out
                                          "/bin/heatc"))
                                        (("output_dir\": \"")
                                         (string-append
                                                        "output_dir\": \"/tmp/"))))
                                    (find-files "." "\\.json$"))))))
                  (add-after 'copy-resources 'change-dir
                    (lambda _
                      (chdir "./examples/heat-pde/executables"))))))
    (home-page melissa-homepage)
    (synopsis "Instrumented heat-pde use case for Melissa")
    (description "This package is a demonstration of a core use-case of Melissa:
a sensitivity analysis which yields iteratively computed statistics based on
parallel clients and server. Each individual client is simply a data-generator based
on a heat diffusion equation characterized by a parallelized solver.")
    (license melissa-license)))

(define-public py-melissa-core
  (package
    (name "py-melissa-core")
    (version melissa-version)
    (source
     melissa-source)
    (build-system python-build-system)
    (inputs (list python
                  python-mpi4py
                  python-pyzmq
                  python-numpy
                  python-jsonschema
                  python-rapidjson
                  python-scipy
                  python-cloudpickle
                  python-iterative-statistics))
    (arguments
     '(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (delete 'sanity-check))))
    (home-page melissa-homepage)
    (synopsis "Melissa Python server and launcher")
    (description "This is the front-end Python script in charge of orchestrating the
execution a Melissa based study. It automatically handles large-scale scheduler
interactions in OpenMPI and with common cluster schedulers (e.g. slurm or OAR).")
    (license melissa-license)))
