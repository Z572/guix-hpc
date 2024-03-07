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
  #:use-module (guix-hpc packages python-science)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages python)
  #:use-module (guix licenses))

(define commit
  "d8de4d5724cbe35e67734a95002acd6fb5d7af71")

(define version
  "1.0.0")

(define revision
  "2")

(define melissa-source
  (origin
    (method git-fetch)
    (uri (git-reference (url "https://gitlab.inria.fr/melissa/melissa.git")
                        (commit commit)))
    (sha256 (base32 "1ndylxb8c7xb9pajli8z6xmjfv3rdlcnpdwmja21wy1m9k9vj3mm"))))

(define melissa-version
  (git-version version revision commit))

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
                                          "/bin/heatc"))))
                                    (find-files "." "\\.json$"))))))
                  (add-after 'copy-resources 'change-dir
                    (lambda _
                      (chdir "./examples/heat-pde/executables"))))))
    (home-page melissa-homepage)
    (synopsis "Instrumented heat-pde use case for Melissa")
    (description
     "This package is a demonstration of a core use-case of Melissa:
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
    (propagated-inputs (list python-mpi4py
                             python-pyzmq
                             python-numpy
                             python-jsonschema
                             python-rapidjson
                             python-scipy
                             python-cloudpickle
                             python-iterative-stats
                             python-plotext))
    (arguments
     '(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (delete 'sanity-check))))
    (home-page melissa-homepage)
    (synopsis "Melissa Python server and launcher")
    (description
     "This is the front-end Python script in charge of orchestrating the
execution a Melissa based study. It automatically handles large-scale scheduler
interactions in OpenMPI and with common cluster schedulers (e.g. slurm or OAR).")
    (license melissa-license)))
