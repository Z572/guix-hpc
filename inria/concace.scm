;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (inria concace)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages emacs)
  ;; #:use-module (nongnu packages emacs) ;; emacs-org-roam-ui
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rust-apps) ;; for ripgrep
  #:use-module (gnu packages shellutils) ;; for direnv
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

(define-public texlive-bedrock
  (package
    (name "texlive-bedrock")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/compose-styles")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Texlive add-on.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Texlive add-on.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "27a5a0aeca37c8489b1c5dee2b4e8459693b4a63")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "075j1ciywizg0iiv04xnrha8z1apk531zh8vh9npss39s0nxd9f8"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("siam" "share/texmf-dist/tex/latex/siam")
	 ("beamerthemeguix" "share/texmf-dist/tex/latex/beamerthemeguix")
         ("beamerthemeinria" "share/texmf-dist/tex/latex/beamerthemeinria")
	 ("compas" "share/texmf-dist/tex/latex/compas")
	 ("IEEEoverride" "share/texmf-dist/tex/latex/ieeeoverride")
	 ("kbordermatrix" "share/texmf-dist/tex/latex/kbordermatrix")
	 ("RR" "share/texmf-dist/tex/latex/inriarr")
	 ("poster" "share/texmf-dist/tex/latex/inriaposter"))))
    (propagated-inputs (list texlive-rsfs)))) ;; for RR

;; Updated version of the emacs-rmsbolt from guix channel to have tree-sitter (ts) support
;; TODO: update guix channel instead
(define-public emacs-rmsbolt-ts
  ;; There is no release tag. Version is extracted from main file.
  (let ((commit "86c6e12a85db472e6660ef7fef12a4e719ef3c66")
        (revision "0")
        (version "0.1.2"))
    (package
      (name "emacs-rmsbolt")
      (version (git-version version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://gitlab.com/jgkamat/rmsbolt")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1kvl8syz700vl2dbva4k1vdzxd67sjby4w4zsl62njvbvwzvcj0r"))))
      (build-system emacs-build-system)
      (home-page "https://gitlab.com/jgkamat/rmsbolt")
      (synopsis "Emacs viewer for compiler output")
      (description
       "RMSBolt is a package to provide assembly or bytecode output for
a source code input file.")
      (license license:agpl3+))))

(define emacs-instead-of-emacs-minimal
  (package-input-rewriting `((,emacs-minimal . ,emacs))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ob-latex-macros publicly defined below instead
(define emacs-ob-latexmacro-with-emacs-minimal
  (package
   (name "emacs-ob-latexmacro")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-ob-latexmacro")
   (synopsis "Extension of ob-latex for supporting common macro definitions for ox-latex and ox-html backends.")
   (description
    "Extension of ob-latex for supporting common macro definitions for ox-latex and ox-html backends.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "195bf067e5e3fc80864a9d8ca6ab44232074d5cd")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
	      "1iz117n40p6w8ll7jzgqm1zc9mapfgh0hzxqa95lalpvbf02csxh"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-org))))

;; emacs-ob-latexmacro with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-ob-latexmacro
  (emacs-instead-of-emacs-minimal emacs-ob-latexmacro-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-ob-latexpicture publicly defined below instead
(define emacs-ob-latexpicture-with-emacs-minimal
  (package
   (name "emacs-ob-latexpicture")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-ob-latexpicture")
   (synopsis "Extension of ob-latex for supporting vectorial output for both ox-latex (inlined) and ox-html (through svg generation) backends.")
   (description
    "Extension of ob-latex for supporting vectorial output for both ox-latex (inlined) and ox-html (through svg generation) backends. Note it also optionally support macros definition from emacs-ob-latexmacro through :usemacros t header argument.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "6ad7672cfe613b0ee4b0a6b94345cafdc1204f5f")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
	      "1z80l4yvgwi72z4y4ai176klwdfd6nhhi1iqsz2y2zr1zkkvywgh"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-org
	  texlive-biblatex
	  texlive-listings
	  texlive-standalone))))

;; emacs-ob-latexmacro with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-ob-latexpicture
  (emacs-instead-of-emacs-minimal emacs-ob-latexpicture-with-emacs-minimal))

(define-public emacs-lob-ob-latexpicture
  (package
    (inherit emacs-ob-latexpicture)
    (name "emacs-lob-ob-latexpicture")
    (synopsis "Extension of library of babel (lob) for ob-latexpicture")
    (description
     "Extension of library of babel (lob) for ob-latexpicture")
    (build-system copy-build-system)
    (native-search-paths
     (list (search-path-specification
            (variable "EMACSLOBPATH")
            (files (list "share/emacs/site-lob")))))
    (arguments
     '(
       #:install-plan
       '(("lob-ob-latexpicture.org" "share/emacs/site-lob/lob-ob-latexpicture.org"))))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-early-init publicly defined below instead
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
;; Use emacs-bedrock-minimal publicly defined below instead
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
                    (commit "90361bf6255a0ef89bc3fb04d371261dcbc3a5fd")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0iyzk2aw14p8z3gy4kqhb664ly1n3482kvs4ww7fcixm3bnbc8j7"))))
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
	   graphviz
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
;; Use emacs-bedrock-base publicly defined below instead
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
                    (commit "4b6c61108ae96f096142b12cf84c6bf486ac6a37")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"187vgfs9i14h3nh0y8dv4mfvnxrcwdv2shyrx142kswmlhllpp6v"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-avy
	   emacs-bedrock-minimal
	   emacs-cape
	   emacs-consult
	   emacs-consult-xdg-recent-files
	   emacs-corfu
	   ;; emacs-corfu-popupinfo: library provided within emacs-corfu package
	   emacs-corfu-terminal
	   emacs-embark
	   ;; emacs-embark-consult: library provided within emacs-embark package
	   ;; emacs-eshell
	   emacs-kind-icon
	   emacs-marginalia
	   emacs-multi-vterm
	   emacs-orderless
	   emacs-pdf-tools
	   emacs-ripgrep
	   emacs-vertico
	   ;; emacs-vertico-directory: library provided within emacs-vertico package
	   emacs-vterm-toggle
	   emacs-wgrep
           ripgrep))))

;; emacs-bedrock-base with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-base
  (emacs-instead-of-emacs-minimal emacs-bedrock-base-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-org-minimal publicly defined below instead
;; Note that this package is a common minimalist basis for both emacs-bedrock-org and emacs-bedrock-ox
(define emacs-bedrock-org-minimal-with-emacs-minimal
  (package
   (name "emacs-bedrock-org-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-org-minimal")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal org-mode setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal org-mode setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "39a5845274c5ac21ba17dfd1b52080d690890736")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"088vcyj26jl1v8q86l1xbqs2cfacwnj4rk5919dscf4cf9p4gmzv"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-org
	   graphviz))))

;; emacs-bedrock-org-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-org-minimal
  (emacs-instead-of-emacs-minimal emacs-bedrock-org-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-org publicly defined below instead
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
                    (commit "098671ac62b24641e02fa8a4cc32dfd732fb6764")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"1j87k8582qcj5ipf1grj73ps5wm15m7yyg0wkpsripin3z2mds4m"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-base
	   emacs-bedrock-org-minimal
	   emacs-consult-org-roam
	   emacs-org-ql ;; for a better speed (to be investigated)
	   emacs-org-roam
	   ;; emacs-org-roam-ui
	   ))))

;; emacs-bedrock-org with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-org
  (emacs-instead-of-emacs-minimal emacs-bedrock-org-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-dev-minimal publicly defined below instead
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
                    (commit "8bea28393a423fdf370af31f6e43767d87e63123")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0jm1y1ic8pfsrljqs4w08f5q6vkzycw6ladsa5iirxspl0s07w1l"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-base
	   emacs-editorconfig
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
	   direnv ;; not necessary for emacs-envrc (already a dependency of it) but so that we have it in a terminal
	   emacs-envrc
	   emacs-rmsbolt-ts
	   gdb
	   python-lsp-server ;; pyton language server
           tree-sitter
	   tree-sitter-bash
	   tree-sitter-bibtex
	   tree-sitter-c ;; see also ccls language server
	   tree-sitter-cmake
	   tree-sitter-cpp ;; see also ccls language server
	   tree-sitter-css
	   tree-sitter-javascript
	   tree-sitter-json
	   tree-sitter-julia
	   tree-sitter-markdown
	   tree-sitter-org
	   tree-sitter-python ;; see also python-lsp-server language server
	   tree-sitter-scheme
	   tree-sitter-r
	   tree-sitter-rust
	   tree-sitter-typescript
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
;; Use emacs-bedrock-write publicly defined below instead
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
    (list aspell ;; emacs-jinx has enchant as input, which has aspell (and hunspell) as input, but not as propagated input
	  aspell-dict-en
	  aspell-dict-fr
          emacs-bedrock-base
	  emacs-citar
	  emacs-citar-org-roam
	  emacs-jinx))))

;; emacs-bedrock-write with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-write
  (emacs-instead-of-emacs-minimal emacs-bedrock-write-with-emacs-minimal))

(define-public emacs-bedrock-ox-latex-minimal
  (package
    (name "emacs-bedrock-ox-latex-minimal")
    (version "1.4.0")
    (arguments
     `(#:builder (mkdir (assoc-ref %outputs "out"))))
    (source #f)
    (build-system trivial-build-system)
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal dependencies for org-mode latex export (ox-latex).")
    (description "Emacs bedrock starter kit. Stepping stones to a better Emacs
experience. Minimal dependencies for org-mode latex export (ox-latex). Provides both rubber and latexmk build systems." )
    (home-page "dummy")
    (license #f)
    (propagated-inputs
     (list texlive-scheme-basic
           texlive-amsfonts
           texlive-babel
           texlive-babel-french
           texlive-bibtex
           texlive-capt-of
           texlive-carlisle
           texlive-fontaxes
           texlive-hyperref
           texlive-inconsolata
           texlive-jknapltx
	   texlive-latexmk
           texlive-libertine
           texlive-ulem
           texlive-upquote
           texlive-wrapfig
           texlive-xcolor
           texlive-xkeyval
           rubber))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox-beamer-minimal publicly defined below instead
(define emacs-bedrock-ox-beamer-minimal-with-emacs-minimal
  (package
    (name "emacs-bedrock-ox-beamer-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-beamer-minimal")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal org-mode latex beamer (ox-beamer) setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal org-mode latex beamer (ox-beamer) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "fb0a17ae31385cb070057065f0805ba14615b2b4")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"159sf04wsvf9wsdb21fr6jd4xfw3h96adpylrfvkvfb6ppwy4fj9"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-ox-latex-minimal
           texlive-beamer))))

;; emacs-bedrock-ox-beamer-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox-beamer-minimal
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-beamer-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox-base publicly defined below instead
(define emacs-bedrock-ox-base-with-emacs-minimal
  (package
    (name "emacs-bedrock-ox-base")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-base")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Base org export (ox) setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Minimal org-mode latex beamer (ox-beamer) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "955846e1ccdaf02c949a2db0972a091a5b276b5b")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"07g5g11pprid1113nl6qv7hjbgh076d4i6ysl46yx1la1fkc0p9s"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-org-minimal
	   emacs-lob-ob-latexpicture
	   emacs-ob-latexmacro
	   emacs-ob-latexpicture))))

;; emacs-bedrock-ox-base with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox-base
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-base-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox-latex-classes publicly defined below instead
(define emacs-bedrock-ox-latex-classes-with-emacs-minimal
  (package
    (name "emacs-bedrock-ox-latex-classes")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-latex-classes")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Latex classes for org export (ox) setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Latex classes for org export (ox) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "58ecac7d123796f03f3be764f29d98a4520f1e96")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0416f4m9rrvkakvrnlrs9z3n5648rw7zcrqmsvx12h0snb75f1dm"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-org
	   inkscape ;; requested by the svg package for converging svg to pdf when  ZZZ
	   ;; small granularity; consider texlive-collection-publishers for a superset
	   texlive-acmconf
	   texlive-acmart
	   texlive-algorithms ;; for siamart220329 from texlive-bedrock
	   texlive-anonymous-acm
	   texlive-biblatex-apa ;; typically nice in beamer presentations (#+cite_export: biblatex apa)
           ;; texlive-biblatex-apa6 ;; check apa vs apa6 vs apa7 vs apacite
	   texlive-beamerposter ;; for inriaposter in texlive-bedrock
	   texlive-bedrock ;; See above definition (!): guix, inria, siam
	   texlive-booktabs ;; for texlive-acmart
	   texlive-caption ;; for texlive-acmart
	   texlive-cleveref ;; for siamart220329 from texlive-bedrock
	   texlive-cmap ;; for texlive-acmart
	   texlive-cm-super ;; for guix theme in texlive-bedrock
	   texlive-comment ;; for texlive-acmart
	   texlive-environ ;; for texlive-acmart
	   texlive-euler ;; for compas from texlive-bedrock
	   texlive-helvetic ;; for beamerthemeguix from texlive-bedrock
	   texlive-hyperxmp ;; for texlive-acmart
	   texlive-ieeeconf
	   texlive-ieeetran ;; https://ctan.tetaneutral.net/macros/latex/contrib/IEEEtran/IEEEtran_HOWTO.pdf
	   texlive-ifmtarg ;; for texlive-acmart
	   texlive-inriafonts
	   texlive-llncs
	   texlive-llncsconf
	   texlive-microtype ;; for texlive-acmart
	   texlive-ncctools ;; for texlive-acmart (for manyfoot; TODO checkout bigfoot)
	   texlive-ntheorem ;; for siamart220329 from texlive-bedrock
	   texlive-palatino ;; for compas from texlive-bedrock
	   texlive-setspace ;; for texlive-acmart
	   texlive-shadow ;; for compas from texlive-bedrock
	   texlive-textcase ;; for texlive-acmart
	   texlive-type1cm ;; for beamerposter requested by inriaposter in texlive-bedrock
	   texlive-times ;; for texlive-ieeetran
	   texlive-totpages ;; for texlive-acmart
	   ;; TODO SIAM
	   ;;texlive-XXX
	   ))))

;; emacs-bedrock-ox-latex-classes with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox-latex-classes
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-latex-classes-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox-latex publicly defined below instead
(define emacs-bedrock-ox-latex-with-emacs-minimal
  (package
    (name "emacs-bedrock-ox-latex")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-latex")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode latex (ox-latex) setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode latex (ox-latex) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "f8c26a64788b280518e9d7a1d4cf13ac44acaaaf")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0scw1lzli48cw450p9kbxrr7nxln89xlpxaljm3k52mr3hkr3532"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-ox-base
	   emacs-bedrock-ox-latex-classes
	   emacs-bedrock-ox-latex-minimal
	   python          ;; for minted
	   python-pygments ;; for minted
	   texlive-algorithm2e
	   texlive-amsmath
	   texlive-biber
;;	   texlive-biblatex
	   texlive-braket
	   texlive-ifoddpage
	   texlive-koma-script
	   texlive-minted
	   texlive-relsize
	   texlive-tools ;; for xspace (TODO: check if necessary)
	   texlive-transparent
	   texlive-svg
	   texlive-pgf ;; pgd/tikz
	   texlive-trimspaces))))

;; emacs-bedrock-ox-latex with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox-latex
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-latex-with-emacs-minimal))

;; ;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; ;; Use emacs-bedrock-ox-beamer publicly defined below instead
;; (define emacs-bedrock-ox-beamer-with-emacs-minimal
;;   (package
;;     (name "emacs-bedrock-ox-beamer")
;;     (version "1.4.0")
;;     (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-beamer")
;;     (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode latex beamer (ox-beamer) setup.")
;;     (description
;;      "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode latex beamer (ox-beamer) setup.")
;;     (license license:cecill-c)
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                     (url home-page)
;;                     (commit "c1efc3a60b3014fdc58a287735b98ef31cf4cc7a")))
;;               (file-name (string-append name "-" version "-checkout"))
;;               (sha256
;;                (base32
;; 		"0i7ir3dmi053bzczv3fh37yxbmi02cf4hb2wlpddvzwns02ss1zs"))))
;;     (build-system emacs-build-system)
;;     (propagated-inputs
;;      (list emacs-bedrock-ox-beamer-minimal
;;            emacs-bedrock-ox-latex))))

;; ;; emacs-bedrock-ox-beamer with emacs instead of emacs-minimal
;; ;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
;; (define-public emacs-bedrock-ox-beamer
;;   (emacs-instead-of-emacs-minimal emacs-bedrock-ox-beamer--with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox-latex publicly defined below instead
(define emacs-bedrock-ox-html-with-emacs-minimal
  (package
    (name "emacs-bedrock-ox-html")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-html")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode html (ox-html) setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode html (ox-html) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "5d7d15fd9b80cbf2a303c1543e9f57c63f2a6d4b")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0hsx95f1i9aipjvkr125fpyql43fyqz272k3kmzbp2bpi7c1agi9"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-ox-base
	   emacs-citeproc-el
	   emacs-htmlize))))

;; emacs-bedrock-ox-html with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox-html
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-html-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox publicly defined below instead
(define emacs-bedrock-ox-with-emacs-minimal
  (package
   (name "emacs-bedrock-ox")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox")
   (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode export (ox) setup.")
   (description
    "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode export (ox) setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "7a4f0e715679d282f571687f423f87f687cb0c6e")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
	      "0rwl6g8lggrj705pvvpa6jgrrvrj38pcrsp48fgi98da6p27y1ar"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-bedrock-ox-beamer-minimal
	  emacs-bedrock-ox-html
	  emacs-bedrock-ox-latex
	  emacs-org-re-reveal))))

;; emacs-bedrock-ox with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-ox-publish publicly defined below instead
(define emacs-bedrock-ox-publish-with-emacs-minimal
  (package
    (name "emacs-bedrock-ox-publish")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-publish")
    (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode publish (ox-publish) setup.")
    (description
     "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. org-mode publish (ox-publish) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "80c2e58e809fc1654b9911fe72ccc04581eb1b7e")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"1f28bcamcz00scah8q68yzsl3l1xx2wj5yb5cb5xamnlv7myd4fa"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-bedrock-ox))))

;; emacs-bedrock-ox-publish with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-bedrock-ox-publish
  (emacs-instead-of-emacs-minimal emacs-bedrock-ox-publish-with-emacs-minimal))

(define-public emacs-bedrock-ox-publish-as-default
  (package
   (name "emacs-bedrock-ox-publish-as-default")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/compose/include/emacs-bedrock/emacs-bedrock-ox-publish-default")
   (synopsis "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Add a default.el starup file for export-only + publish bedrock setup together with a vanilla emacs IDE.")
   (description
    "Emacs bedrock starter kit. Stepping stones to a better Emacs experience. Add a default.el startup file for export-only + publish bedrock setup together with a vanilla emacs IDE.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "2a4d63920087275d97707ede8272f662895e604c")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
	      "00m1j74jfhk5a7znabpl7qag87j25jry2rkc387lk49kj1x0s8ap"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs
	  emacs-bedrock-ox-publish))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-bedrock-full publicly defined below instead
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
                  (commit "f783ba0e257bd8d2d21b7199d57ebd4c279b1b1a")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
	      "0phy92cdk2m4xmk35m66mdcm1zy07rpghxzn7yqhsxlvq6lmm5lq"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-bedrock-dev
	  emacs-bedrock-dev-parentheses
	  emacs-bedrock-org
	  emacs-bedrock-ox-publish
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
	   nss-certs
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
