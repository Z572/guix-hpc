;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (inria flowvr)
  #:use-module (guix)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages swig))

(define-public flowvr-ex
  (package
    (name "flowvr-ex")
    (version "2.3.2")
    (home-page "https://gitlab.inria.fr/flowvr/flowvr-ex")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0bih8d045kmjfn6mkx4fj8x8w8adjrx94z595vrqffh2fcbgq9h6"))))
    (build-system cmake-build-system)
    (inputs (list `(,hwloc "lib") openmpi python swig))
    (native-inputs (list openssh))
    (arguments
     (list
      #:configure-flags #~(list "-DBUILD_TESTING=ON")
      ;; FIXME: some .so are not found in the build tree?
      #:validate-runpath? #f))
    (synopsis "In Situ Processing and Analytics Framework")
    (description
     "FlowVR is a middleware library that eases development and execution of
high performance interactive applications requiring to harness the
power of computing nodes distributed in a cluster or grid.")
    ;; Different parts of the code use different licenses.
    (license (list license:lgpl2.1+ license:gpl2+))))
