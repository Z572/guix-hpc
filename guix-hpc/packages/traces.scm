;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2019, 2021, 2024 Inria

(define-module (guix-hpc packages traces)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix utils)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages profiling)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages version-control))

(define S specification->package)

(define-public vite
  (package
    (name "vite")
    (version "1.4")
    (home-page "https://solverstack.gitlabpages.inria.fr/vite/")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.inria.fr/solverstack/vite.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1f1a7p6mpjdw0ps0by1c0plxj2mnzsk59gya176yzk6bmh2khqyg"))))
    (build-system cmake-build-system)
    (arguments
     '(#:configure-flags (list "-DVITE_ENABLE_MT_PARSERS=ON" "-DVITE_ENABLE_OTF2=ON")
       #:phases (modify-phases %standard-phases
                               ;; when SOURCE_DATE_EPOCH is set, CMakeLists.txt
                               ;; uses it as the date to display in the About
                               ;; window, however, this phase sets it to 0.
                               ;; When SOURCE_DATE_EPOCH is not set,
                               ;; CMakeLists.txt will use the date of the Git
                               ;; tag.
                               (delete 'set-SOURCE-DATE-EPOCH))
       #:tests? #f))
    (inputs (list (S "qtbase@5")
                  mesa
                  glew
                  glu
                  glm
                  `(,otf2 "lib")
                  (S "qtcharts@5")
                  (S "qtsvg@5")))
    (native-inputs (list (S "qttools@5")
                   git  ;; used to get Git tag date and include it in about window
                   ))
    (synopsis "Visualize program execution traces")
    (description
     "ViTE is a trace explorer.  It is a tool to visualize execution traces
of parallel programs (OpenMP, MPI, etc.) in Pajé or OTF format for debugging
and profiling parallel or distributed applications.  Such traces can be
obtained using, for example, EZTrace.")
    (license cecill)))
