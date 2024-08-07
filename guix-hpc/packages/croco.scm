;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2024 Inria

(define-module (guix-hpc packages croco)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages python))

(define-public croco
  (package
    (name "croco")
    (version "2.0.0")
    (source
      (origin
        (uri (git-reference (url "https://gitlab.inria.fr/croco-ocean/croco")
                            (commit (string-append "v" version))))
        (method git-fetch)
        (sha256
          (base32 "0wwanr3h4k6rwkvyndx2m9fbsczk0sipck146dpz0asdcvlk4wbb"))))
    (build-system gnu-build-system)
    (native-inputs
      (list
        python))
    (inputs 
      (list
        gfortran
        netcdf
        netcdf-fortran))
    (arguments
      `(#:phases (modify-phases %standard-phases
                  (add-after 'unpack 'chdir
                    (lambda* _
                      (chdir "OCEAN")))
                  (delete 'check)
                  (delete 'install)
                  (replace 'configure
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out")))
                        (substitute* "jobcomp"
                          (("SOURCE=(.*)$")
                           "SOURCE=\"$(realpath .)\"\n")
                          (("RUNDIR=(.*)$")
                           (string-append "RUNDIR=" out "/opt/croco\n"))))))
                  (replace 'build
                    (lambda* (#:key outputs #:allow-other-keys)
                      (invoke "./jobcomp"))))))
    (home-page "https://www.croco-ocean.org")
    (synopsis "TODO")
    (description "TODO")
    (license license:expat))) ;; TODO
    
