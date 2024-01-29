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
  #:use-module (gnu packages mpi)
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
  #:use-module (inria solverstack)
  #:use-module (inria mpi)
  #:use-module (inria simgrid)
  #:use-module (inria storm)
  #:use-module (inria tadaam)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  )

(define-public texlive-elementaryx
  (package
    (name "texlive-elementaryx")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/compose/include/compose-styles")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Texlive add-on.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Texlive add-on.")
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
;; Use emacs-ob-latex-macros publicly defined below instead
(define emacs-ob-latexmacro-with-emacs-minimal
  (package
   (name "emacs-ob-latexmacro")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-ob-latexmacro")
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
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-ob-latexpicture")
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
;; Use emacs-elementaryx-early-init publicly defined below instead
(define emacs-elementaryx-early-init-with-emacs-minimal
  (package
    (name "emacs-elementaryx-early-init")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-early-init")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Early init.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Early init.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "f6121c699eb5df9f03b909271fd1c60593762f19")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0yd80sm4m756zlsyj54m1p3q31ghv1xwxvn0sqj4wwby933m8xki"))))
    (build-system emacs-build-system)
    ;;(propagated-inputs (list (transform-no-emacs-minimal (specification->package "emacs"))))))
    (propagated-inputs (list emacs))))

;; emacs-elementaryx-early-init with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-early-init
  (emacs-instead-of-emacs-minimal emacs-elementaryx-early-init-with-emacs-minimal))

(define-public elementaryx-core
  (package
   (name "elementaryx-core")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-minimal")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Core packages for non interactive usage.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix. Core packages for non interactive usage.")
   (arguments
    `(#:builder (mkdir (assoc-ref %outputs "out"))))
   (source #f)
   (build-system trivial-build-system)
   (license #f)
   (propagated-inputs
    (list bash
          bzip2
          coreutils
          findutils
          gawk
          git
          graphviz
          grep
          gzip
	  nss-certs
          sed
          tar
          tree
          which))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-minimal publicly defined below instead
(define emacs-elementaryx-minimal-with-emacs-minimal
  (package
   (name "emacs-elementaryx-minimal")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-minimal")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "143c04e9b51ee298e0f4bf93d77b0c99b24e2493")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1mdp7lyy3b75y8fs46iwqjgmaisfsapmnwlz7hrg6k25nnw2nsw0"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list bash-completion
          elementaryx-core
          emacs-elementaryx-early-init
          emacs-evil
          emacs-which-key
          man-db
          man-pages))))

;; emacs-elementaryx-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-minimal
  (emacs-instead-of-emacs-minimal emacs-elementaryx-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-base publicly defined below instead
(define emacs-elementaryx-base-with-emacs-minimal
  (package
   (name "emacs-elementaryx-base")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-base")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Base setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Base setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "0029f2289c33deb63f83aa2d6c7154a2096272e9")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "19xyxjkw08wmcgy2yjn5111qvbn7v6ss1p78qazl4i0z75hxpzlv"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-avy
           emacs-elementaryx-minimal
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

;; emacs-elementaryx-base with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-base
  (emacs-instead-of-emacs-minimal emacs-elementaryx-base-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-org-minimal publicly defined below instead
;; Note that this package is a common minimalist basis for both emacs-elementaryx-org and emacs-elementaryx-ox
(define emacs-elementaryx-org-minimal-with-emacs-minimal
  (package
   (name "emacs-elementaryx-org-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-org-minimal")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal org-mode setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal org-mode setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "4ae2d27cef6ac0ee60c07d8c20e630a1c74483fc")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1rn6ypb7f7f1pz6r9a35amgjmvvm6m34khsmf85hkrg8hg757mc5"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-org
           graphviz))))

;; emacs-elementaryx-org-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-org-minimal
  (emacs-instead-of-emacs-minimal emacs-elementaryx-org-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-org publicly defined below instead
(define emacs-elementaryx-org-with-emacs-minimal
  (package
   (name "emacs-elementaryx-org")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-org")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. org-mode setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. org-mode setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "1492c2d57513a6603ad892e4739aad00052f3f66")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "14yi7gdavlyf6w4nm2ghqaqdkcl9ny7s9cfrrhmwn54s48lcfxgy"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-base
           emacs-elementaryx-org-minimal
           emacs-consult-org-roam
           emacs-org-ql ;; for a better speed (to be investigated)
           emacs-org-roam
           ;; emacs-org-roam-ui
           ))))

;; emacs-elementaryx-org with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-org
  (emacs-instead-of-emacs-minimal emacs-elementaryx-org-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-dev-minimal publicly defined below instead
(define emacs-elementaryx-dev-minimal-with-emacs-minimal
  (package
   (name "emacs-elementaryx-dev-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-dev-minimal")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev minimal setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev minimal setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "644bacef2bd29222d6c53f376ee370d91318b366")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "07mb73xgalv618k4ja4d3wbnb889mj4hrnsx1byc9y58sfrphjdq"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-base
           emacs-editorconfig
           emacs-json-mode
           emacs-magit
           emacs-yaml-mode
           openssh
           ))))

;; emacs-elementaryx-dev-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-dev-minimal
  (emacs-instead-of-emacs-minimal emacs-elementaryx-dev-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-dev publicly defined below instead
(define emacs-elementaryx-dev-with-emacs-minimal
  (package
   (name "emacs-elementaryx-dev")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-dev")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev full setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev full setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "bcea7304efa02d9243ce9347d69cced8fc9f1d81")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "00ali1vj2006kfm0q20jfncdx3xwr1f2463axd5x79xhf70wvfjy"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-dev-minimal
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

;; emacs-elementaryx-dev with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-dev
  (emacs-instead-of-emacs-minimal emacs-elementaryx-dev-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-dev-parentheses publicly defined below instead
(define emacs-elementaryx-dev-parentheses-with-emacs-minimal
  (package
   (name "emacs-elementaryx-dev-parentheses")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-dev-parentheses")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup for languages with parentheses or alike: lisp, scheme.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup for languages with parentheses or alike: lisp,
scheme.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "77918117de2f4a7de8fd72fa86c5371f5239092b")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0z0fhkrbjxfbkpl7f9fdb68qzax9liypml9c7b9vzxr9gcvcqj0h"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-geiser-guile
           emacs-paredit))))

;; emacs-elementaryx-dev-parentheses with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-dev-parentheses
  (emacs-instead-of-emacs-minimal emacs-elementaryx-dev-parentheses-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-write publicly defined below instead
(define emacs-elementaryx-write-with-emacs-minimal
  (package
   (name "emacs-elementaryx-write")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-write")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Write setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix Write setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "038765987d9175c5337088ff8d6a8c853823ad82")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
               (base32
                "1zpxli3nlfrg3612653vprwrqphzs08vppcn36air6y8qqnl5wjn"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list aspell ;; emacs-jinx has enchant as input, which has aspell (and hunspell) as input, but not as propagated input
          aspell-dict-en
          aspell-dict-fr
          emacs-elementaryx-base
          emacs-citar
          emacs-citar-org-roam
          emacs-jinx))))

;; emacs-elementaryx-write with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-write
  (emacs-instead-of-emacs-minimal emacs-elementaryx-write-with-emacs-minimal))

(define-public emacs-elementaryx-ox-latex-minimal
  (package
   (name "emacs-elementaryx-ox-latex-minimal")
   (version "1.4.0")
   (arguments
    `(#:builder (mkdir (assoc-ref %outputs "out"))))
   (source #f)
   (build-system trivial-build-system)
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal dependencies for org-mode latex export (ox-latex).")
   (description "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal dependencies for org-mode latex export (ox-latex). Provides both rubber and latexmk build systems." )
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
;; Use emacs-elementaryx-ox-beamer-minimal publicly defined below instead
(define emacs-elementaryx-ox-beamer-minimal-with-emacs-minimal
  (package
    (name "emacs-elementaryx-ox-beamer-minimal")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-beamer-minimal")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal org-mode latex beamer (ox-beamer) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal org-mode latex beamer (ox-beamer) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "7bd8db55fbe034aa0c3d96ee0557863b21a576b6")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "17b4a66mhppvmyr9plb0gy2xzc5v5aas7zpzbga7ab7db8g6pdfp"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox-latex-minimal
           texlive-beamer))))

;; emacs-elementaryx-ox-beamer-minimal with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox-beamer-minimal
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-beamer-minimal-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-ox-base publicly defined below instead
(define emacs-elementaryx-ox-base-with-emacs-minimal
  (package
    (name "emacs-elementaryx-ox-base")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-base")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Base org export (ox) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal org-mode latex beamer (ox-beamer) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "138c3ac29c6dd941f4cc4c31a796a7dbe6db39d2")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "026w4c2c1369b86snlq1ky2kydl2p6b36wq2i19w9znbprdb11sm"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list elementaryx-core
	   emacs-elementaryx-org-minimal
           emacs-lob-ob-latexpicture
           emacs-ob-latexmacro
           emacs-ob-latexpicture))))

;; emacs-elementaryx-ox-base with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox-base
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-base-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-ox-latex-classes publicly defined below instead
(define emacs-elementaryx-ox-latex-classes-with-emacs-minimal
  (package
    (name "emacs-elementaryx-ox-latex-classes")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-latex-classes")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Latex classes for org export (ox) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Latex classes for org export (ox) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "600a252561470394ef29f6de125cc3faf7f1e53c")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0d5a65whb98lkdcf16g4l54i2qrnrsgnb1ild4s9dij9dlq2c09d"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-org
           inkscape ;; requested by the svg package for converging svg to pdf when  ZZZ
           ;; small granularity; consider texlive-collection-publishers for a superset
           texlive-acmconf
           texlive-acmart
           texlive-algorithms ;; for siamart220329 from texlive-elementaryx
           texlive-anonymous-acm
           texlive-biblatex-apa ;; typically nice in beamer presentations (#+cite_export: biblatex apa)
           ;; texlive-biblatex-apa6 ;; check apa vs apa6 vs apa7 vs apacite
           texlive-beamerposter ;; for inriaposter in texlive-elementaryx
           texlive-elementaryx ;; See above definition (!): guix, inria, siam
           texlive-booktabs ;; for texlive-acmart
           texlive-caption ;; for texlive-acmart
           texlive-cleveref ;; for siamart220329 from texlive-elementaryx
           texlive-cmap ;; for texlive-acmart
           texlive-cm-super ;; for guix theme in texlive-elementaryx
           texlive-comment ;; for texlive-acmart
           texlive-environ ;; for texlive-acmart
           texlive-euler ;; for compas from texlive-elementaryx
           texlive-helvetic ;; for beamerthemeguix from texlive-elementaryx
           texlive-hyperxmp ;; for texlive-acmart
           texlive-ieeeconf
           texlive-ieeetran ;; https://ctan.tetaneutral.net/macros/latex/contrib/IEEEtran/IEEEtran_HOWTO.pdf
           texlive-ifmtarg ;; for texlive-acmart
           texlive-inriafonts
           texlive-llncs
           texlive-llncsconf
           texlive-microtype ;; for texlive-acmart
           texlive-ncctools ;; for texlive-acmart (for manyfoot; TODO checkout bigfoot)
           texlive-ntheorem ;; for siamart220329 from texlive-elementaryx
           texlive-palatino ;; for compas from texlive-elementaryx
           texlive-setspace ;; for texlive-acmart
           texlive-shadow ;; for compas from texlive-elementaryx
           texlive-textcase ;; for texlive-acmart
           texlive-type1cm ;; for beamerposter requested by inriaposter in texlive-elementaryx
           texlive-times ;; for texlive-ieeetran
           texlive-totpages ;; for texlive-acmart
           ;; TODO SIAM
           ;;texlive-XXX
           ))))

;; emacs-elementaryx-ox-latex-classes with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox-latex-classes
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-latex-classes-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-ox-latex publicly defined below instead
(define emacs-elementaryx-ox-latex-with-emacs-minimal
  (package
    (name "emacs-elementaryx-ox-latex")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-latex")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode latex (ox-latex) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode latex (ox-latex) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "8bc0166b90077dcc714d61fe3c79ce63f907f1f8")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "19cjm93bsh8mghb29s5v1zhs9nn8wfb7iicncr1mgs7sjx5a1mm1"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox-base
           emacs-elementaryx-ox-latex-classes
           emacs-elementaryx-ox-latex-minimal
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

;; emacs-elementaryx-ox-latex with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox-latex
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-latex-with-emacs-minimal))

;; ;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; ;; Use emacs-elementaryx-ox-beamer publicly defined below instead
;; (define emacs-elementaryx-ox-beamer-with-emacs-minimal
;;   (package
;;     (name "emacs-elementaryx-ox-beamer")
;;     (version "1.4.0")
;;     (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-beamer")
;;     (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode latex beamer (ox-beamer) setup.")
;;     (description
;;      "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode latex beamer (ox-beamer) setup.")
;;     (license license:cecill-c)
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                     (url home-page)
;;                     (commit "c1efc3a60b3014fdc58a287735b98ef31cf4cc7a")))
;;               (file-name (string-append name "-" version "-checkout"))
;;               (sha256
;;                (base32
;;              "0i7ir3dmi053bzczv3fh37yxbmi02cf4hb2wlpddvzwns02ss1zs"))))
;;     (build-system emacs-build-system)
;;     (propagated-inputs
;;      (list emacs-elementaryx-ox-beamer-minimal
;;            emacs-elementaryx-ox-latex))))

;; ;; emacs-elementaryx-ox-beamer with emacs instead of emacs-minimal
;; ;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
;; (define-public emacs-elementaryx-ox-beamer
;;   (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-beamer--with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-ox-latex publicly defined below instead
(define emacs-elementaryx-ox-html-with-emacs-minimal
  (package
    (name "emacs-elementaryx-ox-html")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-html")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode html (ox-html) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode html (ox-html) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "a0a2892039759e83977b1bd9cb95323692287325")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0j0cdpx18j4q2x02inzbkw09h9b0xb22dpskc7shcz5fw17lznd7"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox-base
           emacs-citeproc-el
           emacs-htmlize))))

;; emacs-elementaryx-ox-html with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox-html
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-html-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-ox publicly defined below instead
(define emacs-elementaryx-ox-with-emacs-minimal
  (package
   (name "emacs-elementaryx-ox")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode export (ox) setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode export (ox) setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "ed014f91ca8617e351304110fabcfd88c6332537")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1xy97zid5jsd40jyw7wf7919qfdf30sxy3myccargh4lnkg1fc7b"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-elementaryx-ox-beamer-minimal
          emacs-elementaryx-ox-html
          emacs-elementaryx-ox-latex
          emacs-org-re-reveal))))

;; emacs-elementaryx-ox with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-with-emacs-minimal))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-ox-publish publicly defined below instead
(define emacs-elementaryx-ox-publish-with-emacs-minimal
  (package
    (name "emacs-elementaryx-ox-publish")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-publish")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode publish (ox-publish) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode publish (ox-publish) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "de23a7b4f4ac29252a23b03c215c080693b9352e")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1cb6lv3bw1zkwb3y6a5j5l441clm7219arjr8xc4w8pvnrwwjgh0"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox))))

;; emacs-elementaryx-ox-publish with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-ox-publish
  (emacs-instead-of-emacs-minimal emacs-elementaryx-ox-publish-with-emacs-minimal))

(define-public emacs-elementaryx-ox-publish-as-default
  (package
   (name "emacs-elementaryx-ox-publish-as-default")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-publish-default")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el startup file for export-only + publish elementaryx setup together with a vanilla emacs IDE.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el startup file for export-only + publish elementaryx setup together with a vanilla emacs IDE.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "b5b8225bdec1c7bdbb79b2d0b1b45a114f6eb08e")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "0k7cz6xinq1p4qsh9f47v6spzhsz4naahq60xf1c3hcjsrkkgxc1"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs
          emacs-elementaryx-ox-publish))))

;; This package is not meant to be used as it depends on emacs and thus implicitly emacs-minimal
;; Use emacs-elementaryx-full publicly defined below instead
(define emacs-elementaryx-full-with-emacs-minimal
  (package
   (name "emacs-elementaryx-full")
   (version "1.4.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-full")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Full setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix Full setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "2103c795a75e7b3c0d613713934c19b0974abfd4")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1rxvvxsbya7dzn0cpjxkmb8mnkh7gyg9gqd579bg8szacvibh6bh"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-elementaryx-dev
          emacs-elementaryx-dev-parentheses
          emacs-elementaryx-org
          emacs-elementaryx-ox-publish
          emacs-elementaryx-write))))

;; emacs-elementaryx-full with emacs instead of emacs-minimal
;; See motivation here: https://guix.gnu.org/manual/en/html_node/Application-Setup.html#Emacs-Packages-1
(define-public emacs-elementaryx-full
  (emacs-instead-of-emacs-minimal emacs-elementaryx-full-with-emacs-minimal))

(define-public emacs-elementaryx
  (package
   (inherit emacs-elementaryx-full)
   (name "emacs-elementaryx")))

(define-public emacs-elementaryx-as-default
  (package
   (name "emacs-elementaryx-as-default")
    (version "1.4.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-default")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el starup file.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el startup file.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "69ef643114f36ba4297f131d169a92736d2c6740")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0mc3w4bzdgxj6cz9lz3g6d4jnfpflahj49x8c34qi9wq4srah42h"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx))))

;; site-start.el is already deployed by guix.
;; As a consequence the following package would have no effect.
;; (define-public emacs-elementaryx-as-site-start
;;   (package
;;    (name "emacs-elementaryx-as-site-start")
;;     (version "1.4.0")
;;     (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-site-start")
;;     (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Add a site-start.el starup file.")
;;     (description
;;      "ElementaryX: Elementary Emacs configuration coupled with Guix Add a site-start.el startup file.")
;;     (license license:cecill-c)
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                     (url home-page)
;;                     (commit "6fa923bd5c6c7785cf62134d49a1ab1075311757")))
;;               (file-name (string-append name "-" version "-checkout"))
;;               (sha256
;;                (base32
;;              "0xk3jq6l2h1jb8ya8pmsgk5dfx7gwfwzsiczkfj7rkiqvzkin0mp"))))
;;     (build-system emacs-build-system)
;;     (propagated-inputs
;;      (list emacs-elementaryx))))

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
