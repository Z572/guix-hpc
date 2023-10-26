;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (inria concace)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages emacs)
  ;; #:use-module (nongnu packages emacs) ;; emacs-org-roam-ui
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gdb)  
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rust-apps) ;; for ripgrep
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tex)
  #:use-module (gnu packages texlive)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages wget)
;;  #:use-module (hacky gitlab)
  #:use-module (inria hiepacs)
  #:use-module (inria mpi)
  #:use-module (inria simgrid)
  #:use-module (inria storm)
  #:use-module (inria tadaam)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  )

(define emacs-instead-of-emacs-minimal
  (package-input-rewriting `((,emacs-minimal . ,emacs))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-early-init publicly defined below intead
(define emacs-bedrock-early-init-with-emacs-minimal
  (package
   (name "emacs-bedrock-early-init")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-early-init")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Early init.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Early init.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "961797e55adc26e0203dac7f936820fb41efebc7")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "10nixwa35zzirp0gr65xrpf38mqqk1k9fm6lnx1d2ymns5icl7wi"))))
    (build-system emacs-build-system)
    ;;(propagated-inputs (list (transform-no-emacs-minimal (specification->package "emacs"))))))
    (propagated-inputs (list emacs))))

;; emacs-bedrock-early-init with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-early-init
  (emacs-instead-of-emacs-minimal emacs-bedrock-early-init-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-minimal publicly defined below intead
(define emacs-bedrock-minimal-with-emacs-minimal
  (package
   (name "emacs-bedrock-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-minimal")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "48496430fa09827b97e81bb37d3a3bdaf9cac6d4")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1l8cr00dv10djlrvcazxh4nvlfjr8b64zdvhjr2i7h1nmhbv6qgw"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list bash
	   bzip2
           coreutils
	   emacs-bedrock-early-init
	   emacs-evil
	   emacs-which-key
	   findutils
           gawk
           git
           grep
           gzip
	   man-db
	   man-pages
           sed
           tar
           tree
           which))))

;; emacs-bedrock-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-minimal
  (emacs-instead-of-emacs-minimal emacs-bedrock-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-base publicly defined below intead
(define emacs-bedrock-base-with-emacs-minimal
  (package
   (name "emacs-bedrock-base")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-base")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Base setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Base setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "4e6fa430f48197ed49aa9be3f879fea5242cb601")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"1r2b1i0ry7304kbws96jl0xw0rh6gi02mka5yf570hp2ik7il6lf"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-avy
	   emacs-bedrock-minimal
	   emacs-cape
	   emacs-consult
	   emacs-corfu
	   ;; emacs-corfu-popupinfo: library provided within emacs-corfu package
	   emacs-corfu-terminal
	   emacs-embark
	   ;; emacs-embark-consult: library provided within emacs-embark package
	   ;; emacs-eshell
	   emacs-kind-icon
	   emacs-marginalia
	   emacs-orderless
	   emacs-ripgrep
	   emacs-vertico
	   ;; emacs-vertico-directory: library provided within emacs-vertico package
	   emacs-wgrep
           ripgrep))))

;; emacs-bedrock-base with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-base
  (emacs-instead-of-emacs-minimal emacs-bedrock-base-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-org publicly defined below intead
(define emacs-bedrock-org-with-emacs-minimal
  (package
   (name "emacs-bedrock-org")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-org")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "b67ba69ffabb731d2bc48ef11bb98fa719bf96db")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0z6n024fr96iqzvnq1hzndnpgffcv49mlx6zmgxw8ymlk95f3v2c"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-base
	   emacs-consult-org-roam
	   emacs-org ;; more recent version of org-mode
	   emacs-org-ql ;; for a better speed (to be investigated) 
	   emacs-org-roam
	   ;; emacs-org-roam-ui
	   ))))

;; emacs-bedrock-base with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-org
  (emacs-instead-of-emacs-minimal emacs-bedrock-org-with-emacs-minimal))


;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-dev-minimal publicly defined below intead
(define emacs-bedrock-dev-minimal-with-emacs-minimal
  (package
   (name "emacs-bedrock-dev-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-dev-minimal")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Dev minimal setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Dev minimal setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "181f0a64316bfe9ff9b49deef23a381c73b61599")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0cfj13i18nviiza13ybwg7bhj0r8ny2zq0w0yqssnikxfq52inwl"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-base
	   emacs-json-mode
	   emacs-magit
	   emacs-yaml-mode
	   openssh
	   ))))

;; emacs-bedrock-dev-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-dev-minimal
  (emacs-instead-of-emacs-minimal emacs-bedrock-dev-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-dev publicly defined below instead
(define emacs-bedrock-dev-with-emacs-minimal
  (package
   (name "emacs-bedrock-dev")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-dev")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Dev full setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Dev full setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "05127e1b07415411ff3e94107a07b34f38491991")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"18jra9bpd7ddkbk3pxrln6cd2jg6krca4m575pygzfc7pw9hj5b3"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-dev-minimal
	   ;; emacs-crdt
	   bash
	   ccls ;; c / c++ language server
	   emacs-envrc
	   emacs-rmsbolt
	   gdb
	   python-lsp-server ;; pyton language server
           tree-sitter
	   tree-sitter-bash
	   tree-sitter-bibtex
	   tree-sitter-c ;; see also ccls language server
	   tree-sitter-cpp ;; see also ccls language server
	   tree-sitter-cmake
	   tree-sitter-julia
	   tree-sitter-markdown
	   tree-sitter-org
	   tree-sitter-python ;; see also python-lsp-server language server
	   tree-sitter-scheme
	   tree-sitter-r
	   tree-sitter-rust
	   ))))

;; emacs-bedrock-dev with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-dev
  (emacs-instead-of-emacs-minimal emacs-bedrock-dev-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-dev-parentheses publicly defined below instead
(define emacs-bedrock-dev-parentheses-with-emacs-minimal
  (package
   (name "emacs-bedrock-dev-parentheses")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-dev-parentheses")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Setup for languages with parentheses or alike: lisp, scheme.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs
experience. Setup for languages with parentheses or alike: lisp,
scheme.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "083614ad5884daae5888705532c42b685a08e780")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0ma4ayvc048l1i407lr6bhk0wvv5y5sml2ximrimn3q7bb8d7qh2"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-geiser-guile
	   emacs-paredit))))

;; emacs-bedrock-dev-parentheses with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-dev-parentheses
  (emacs-instead-of-emacs-minimal emacs-bedrock-dev-parentheses-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-write publicly defined below intead
(define emacs-bedrock-write-with-emacs-minimal
  (package
   (name "emacs-bedrock-write")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-write")
   (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Write setup.")
   (description
    "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Write setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "b9bc33db6da1ac1b872740c478a1d9967c43a703")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
               (base32
		"0x6i6pw1zyxr8gbkr701if778yhgzga08hkhf2m2c9kg0ipisn3d"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-bedrock-base
	  emacs-citar
	  emacs-citar-org-roam
	  emacs-jinx))))

;; emacs-bedrock-write with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-write
  (emacs-instead-of-emacs-minimal emacs-bedrock-write-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-full publicly defined below intead
(define emacs-bedrock-full-with-emacs-minimal
  (package
   (name "emacs-bedrock-full")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-full")
   (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Full setup.")
   (description
    "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Full setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "1a536ecc827f1e3cca8c821686c891af0801f437")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
               (base32
		"0h68xpc4mz1gw3vjmp2jq5dcn1nsxkb7ynbk1b7f8dh28ywy38mh"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-bedrock-dev
	  emacs-bedrock-dev-parentheses
	  emacs-bedrock-org
	  emacs-bedrock-write))))

;; emacs-bedrock-full with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-full
  (emacs-instead-of-emacs-minimal emacs-bedrock-full-with-emacs-minimal))

(define-public emacs-bedrock
  (package
   (inherit emacs-bedrock-full)
   (name "emacs-bedrock")))

(define-public emacs-bedrock-as-default
  (package
   (name "emacs-bedrock-as-default")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-default")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Add a default.el starup file.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Add a default.el startup file.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "44865d853840a1c68088152d19c94b11f2ad4c2c")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"1i8yg11cskrmscmjdg301q7j1ypss52nydymmykbaaiygilq2yzy"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock))))

;; site-start.el is already deployed by guix.
;; As a consequence the following package would have no effect.
;; (define-public emacs-bedrock-as-site-start
;;   (package
;;    (name "emacs-bedrock-as-site-start")
;;     (version "1.4.0")
;;     (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-site-start")
;;     (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Add a site-start.el starup file.")
;;     (description
;;      "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Add a site-start.el startup file.")
;;     (license license:cecill-c)
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                     (url home-page)
;;                     (commit "6fa923bd5c6c7785cf62134d49a1ab1075311757")))
;;               (file-name (string-append name "-" version "-checkout"))
;;               (sha256
;;                (base32
;; 		"0xk3jq6l2h1jb8ya8pmsgk5dfx7gwfwzsiczkfj7rkiqvzkin0mp"))))
;;     (build-system emacs-build-system)
;;     (propagated-inputs
;;      (list emacs-bedrock))))

(define-public emacs-ob-compose-latexpicture
  (package
   (name "emacs-ob-compose-latexpicture")
    (version "0.1")
    (home-page "https://gitlab.inria.fr/compose/include/compose-ob-latexpicture")
    (synopsis "Tentative portable (latex and html) usage of vector pictures for org-mode.")
    (description
     "Tentative portable (latex and html) usage of vector pictures for org-mode.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "b2d04e7337ce9c99dce13147c9e0e59d152bcb55")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
	       (base32
                "05mm70xj82ck8bcmcdv3jrkv54l3g5wixg5dpyd7iwxxxx6ysd12"))))
    (build-system emacs-build-system)
    (propagated-inputs (list emacs-org))))

(define-public emacs-org-compose-publish
  (package
   (name "emacs-org-compose-publish")
    (version "0.1")
    (home-page "https://gitlab.inria.fr/compose/include/compose-publish")
    (synopsis "compose-publish emacs org-mode extension")
    (description
     "Compose-publish is an org-mode configuration for publication.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "db96531f0b8477c0f6902e80ce0b5fadfaf96798")
                    (recursive? #t)))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "159rbxq84phdw876a984prrdnbzcl4lqya8k6wch8vh976pk46ny"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list bash
           bzip2
           coreutils
           emacs
           emacs-citeproc-el
           emacs-htmlize
           emacs-org
           emacs-org-contrib
           emacs-org-re-reveal
           emacs-org-ref
           gawk
           git
           ;; gitlab-runner
           grep
           gzip
           imagemagick
           inkscape
           python
           python-pygments
           sed
           tar
           texlive
           tree
           which
           wget
           texlive-biber))))

(define-public laplacian-example
  (package
    (name "laplacian-example")
    (version "1.0.0")
    (home-page "https://gitlab.inria.fr/agullo/laplacian-example")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "83b34c4d95b7987369e2e74e6f69066d45310e3b")
                    ;; We need the submodule in 'cmake_modules/morse'.
                    (recursive? #t)))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1xppa4bf2rlbf3c3s2hwiw5sqnlkn6c4dgngd0v6fd8p81w5q1s3"))))
    (build-system cmake-build-system)
    (arguments
     '(#:configure-flags '("-DLAPLACIAN_USE_MPI=OFF"
                           "-DLAPLACIAN_BUILD_EXAMPLES=ON"
                           )
       #:tests? #f))
    (inputs (list  openmpi
                  openssh
                  openblas))
    (native-inputs (list gfortran pkg-config))
    (synopsis "Example of solving a Laplacian problem in Fortran")
    (description
     "LAPLACIAN is an example of a Laplacian problem. The code is written in Fortran 90.")
    (license license:cecill-c)))
