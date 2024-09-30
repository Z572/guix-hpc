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
  #:use-module (gnu packages crates-io) ;; for rust-lsp-server (from rust-analyzer)
  #:use-module (gnu packages emacs)
  ;; #:use-module (nongnu packages emacs) ;; emacs-org-roam-ui
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages freedesktop) ;; for xdg-utils
  #:use-module (gnu packages fontutils) ;; for fontconfig, e.g. used by emacs-all-the-icons
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages less)
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
  #:use-module (gnu packages statistics) ;; for emacs-ess
  #:use-module (gnu packages terminals) ;; for fzf
  #:use-module (gnu packages tex)
  #:use-module (gnu packages texlive)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages xdisorg) ;; for xclip
  ;;  #:use-module (hacky gitlab)
  #:use-module (guix-hpc packages solverstack)
  #:use-module (inria mpi)
  #:use-module (inria simgrid)
  #:use-module (inria storm)
  #:use-module (inria tadaam)
  #:use-module (guix utils)
  #:use-module (guix-hpc packages lsp) ;; for fortls in guix-hpc
  #:use-module (srfi srfi-1)
  )

(define-public texlive-elementaryx
  (package
    (name "texlive-elementaryx")
    (version "2.0.0")
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


;; The 2.0.1 is the last release but dates back to 2016 (8 years old)
;; TODO: remove it and use emacs-spaceline 2.0.2 or 2.1 or 3 as soon as it is released and integrated in guix
(define-public emacs-spaceline-2024
  (package
   (inherit emacs-spaceline)
   (home-page "https://github.com/TheBB/spaceline/")
   (name "emacs-spaceline-2024")
   (version "2.0.1-2024")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "086420d16e526c79b67fc1edec4c2ae1e699f372")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1qld1rsvi9a2kq8w128sp0gv7dppp7cxmgrlyg5zdvvp9av3d90i"))))))

;; Better compatibility support with context-menu-mode (right-click)
;; TODO: remove it and use emacs-treemacs-extra 3.2 as soon as it is released and integrated in guix
(define-public emacs-treemacs-extra-2024
  (package
   (inherit emacs-treemacs-extra)
   (home-page "https://github.com/Alexander-Miller/treemacs")
   (name "emacs-treemacs-extra-2024")
   (version "3.1-2024")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "8c6df39f01a4d47fda2cc943645fa067f771b748")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "12jfivx5gqayv8n2q08f7inwqmxck51q0r9nxgb1m1kzi5vdisqp"))))))

;; (define emacs-instead-of-emacs-minimal
;;   ;; (package-input-rewriting `((,emacs-minimal . ,emacs))))
;;   ;; Try to do nothing (before deciding completely purging it):
;;   (package-input-rewriting `((,emacs-minimal . ,emacs-minimal))))

(define-public emacs-ob-latexmacro
  (package
   (name "emacs-ob-latexmacro")
   (version "v0.1")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-ob-latexmacro")
   (synopsis "Extension of ob-latex for supporting common macro definitions for ox-latex and ox-html backends.")
   (description
    "Extension of ob-latex for supporting common macro definitions for ox-latex and ox-html backends.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "17fb90b6beef2712530314973a554964ccba8f7f")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "08s09gv2b3pz82nfih83j7flns4w7i25icyhh3jwyjysklrf61az"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-org))))

(define-public emacs-ob-latexpicture
  (package
   (name "emacs-ob-latexpicture")
   (version "v0.1")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-ob-latexpicture")
   (synopsis "Extension of ob-latex for supporting vectorial output for both ox-latex (inlined) and ox-html (through svg generation) backends.")
   (description
    "Extension of ob-latex for supporting vectorial output for both ox-latex (inlined) and ox-html (through svg generation) backends. Note it also optionally support macros definition from emacs-ob-latexmacro through :usemacros t header argument.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "698393f30be6f5c8d01bed9913fc8d428f9aaf93")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1m8q80k5kz8mdnz78x77qbvv847rjagldms9hx9j47pxn2y55lkq"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-org
          texlive-biblatex
          texlive-listings
	  texlive-preview
          texlive-standalone))))

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

;; ;; Contrary to emacs-treemacs-extra, we do not embed projectile,
;; ;; persp-mode, perspective and mu as propagated inputs
;; (define-public emacs-treemacs-extra-light
;;   (package
;;     (inherit emacs-treemacs-extra)
;;     (name "emacs-treemacs-extra-light")
;;     (propagated-inputs
;;      (modify-inputs (package-propagated-inputs emacs-treemacs)
;;        (append emacs-all-the-icons
;;                emacs-evil
;;                emacs-magit
;;                ;; emacs-projectile
;;                ;; emacs-persp-mode
;;                ;; emacs-perspective
;;                ;; mu
;; 	       )))))

(define-public emacs-elementaryx-early-init
  (package
    (name "emacs-elementaryx-early-init")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-early-init")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Early init.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Early init.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0s4fdkrzjha4w7g9byi9j1qsygi48rq0qqcznpqw4majhbhvija6"))))
    (build-system emacs-build-system)
    ;;(propagated-inputs (list (transform-no-emacs-minimal (specification->package "emacs"))))))
    (propagated-inputs (list emacs))))

(define-public elementaryx-core
  (package
   (name "elementaryx-core")
   (version "2.0.0")
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

(define-public emacs-elementaryx-minimal
  (package
   (name "emacs-elementaryx-minimal")
   (version "2.1.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-minimal")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.1.0")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "0g2ksxs3kz0nzz8h653x3zpd6vsz072d3s0qagj3p4z0sq2ki4p2"))))
   (build-system emacs-build-system)
   (propagated-inputs
    ;; TODO move to a higher level package: bash-completion, bat, diffutils, fzf, less, lesspipe, and maybe man-db and man-pages, as well as fonts (fontconfig and fonts themselves)
    (list bash-completion
	  bat ;; enhanced cat: supports syntax highlighting; possible to couple nicely it with fzf
	  diffutils ;; provides diff; used by diff-hl-flydiff-mode
          elementaryx-core
          emacs-elementaryx-early-init
          emacs-evil
          emacs-which-key
	  emacs-xclip
	  ;; TODO: considering adding fonts (WIP: needs further testing and refining)
	  ; fontconfig
	  ; font-dejavu font-liberation font-fira-code font-fira-mono font-hack font-adobe-source-code-pro font-gnu-freefont font-gnu-unifont
	  fzf ;; fuzzy search
	  less
	  lesspipe ;; extends less if LESSOPEN environment variable is setup
          man-db
          man-pages
	  xclip ;; for emacs-xclip; NB: alternative could be xsel; NB: on Wayland shall be wl-clipboard
	  xdg-utils ;; for xdg-open
	  ))))

(define-public emacs-elementaryx-base
  (package
   (name "emacs-elementaryx-base")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-base")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Base setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Base setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0ayr6g5iz7wb5krasfvfbrmy13zh282r1ckpr3zplws1c6zgv5af"))))
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
	   ;;  emacs-dirvish TODO
	   emacs-embark
	   emacs-expand-region
	   emacs-guix
	   ;; emacs-embark-consult: library provided within emacs-embark package
	   ;; emacs-eshell
	   emacs-kind-icon
	   emacs-marginalia
	   emacs-move-text
	   emacs-multi-vterm
	   emacs-multiple-cursors
	   emacs-orderless
	   emacs-pdf-tools
	   emacs-ripgrep
	   emacs-undo-fu
	   emacs-vertico
	   ;; emacs-vertico-directory: library provided within emacs-vertico package
	   emacs-vterm-toggle
	   emacs-wgrep
	   inetutils ;; for `hostname`, requested by liquidprompt
	   liquidprompt ;; for nice PS1 prompt
	   ripgrep))))

(define-public emacs-elementaryx-treemacs
  (package
   (name "emacs-elementaryx-treemacs")
   (version "2.0.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-treemacs")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for treemacs.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for treemacs.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.0.0")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1ymzsdn76h3bpjklv3mawg3cbvl1ynvawfjlkybiv6k4iql1qs26"))))
   (build-system emacs-build-system)
   (propagated-inputs
    ;; (list emacs-treemacs-extra-light)
    (list emacs-cfrs emacs-treemacs-extra-2024))))

;; This package can be used out of the elementaryx suite, e.g.: `guix shell emacs emacs-elementaryx-all-the-icons`
(define-public emacs-elementaryx-all-the-icons
  (package
    (name "emacs-elementaryx-all-the-icons")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-all-the-icons")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for all-the-icons.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for all-the-icons, a utility package to collect various Icon Fonts and
propertize them within Emacs. See also emacs-elementaryx-nerd-icons
alternative.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"06wk492ay5jk47hw4awcsy1gw6id5zq6sr3gkyw9mgc5fj4dl1sh"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-doom-themes
	   emacs-all-the-icons
	   emacs-all-the-icons-completion
	   emacs-all-the-icons-dired
	   emacs-all-the-icons-ibuffer
	   emacs-spaceline-2024
	   emacs-diminish
	   ;; emacs-spaceline-all-the-icons
	   fontconfig
	   ;; Note that emacs-treemacs-extra in emacs-elementaryx-treemacs includes support for all the icons
	   ))))

;; This package can be used out of the elementaryx suite, e.g.: `guix shell emacs emacs-elementaryx-nerd-icons`
(define-public emacs-elementaryx-nerd-icons
  (package
    (name "emacs-elementaryx-nerd-icons")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-nerd-icons")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for nerd-icons.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for nerd-icons. See also emacs-elementaryx-all-the-icons alternative.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"1237hv8cpli7k6yj4fbkq2aasvr8jg5yflfv334nsqq6k2di6yby"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-nerd-icons
	   ;; emacs-nerd-icons-completion
	   ;; + emacs-nerd-icons-corfu
	   ;; emacs-nerd-icons-dired
	   ;; emacs-nerd-icons-ibuffer
	   emacs-doom-themes
	   emacs-doom-modeline
	   ;; Note: out-of-the-box emacs-treemacs nerd support?
	   fontconfig
	   ))))

;; Note that this package is a common minimalist basis for both emacs-elementaryx-org and emacs-elementaryx-ox
(define-public emacs-elementaryx-org-minimal
  (package
   (name "emacs-elementaryx-org-minimal")
   (version "2.0.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-org-minimal")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal org-mode setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix. Minimal org-mode setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.0.0")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
	      "1rn6ypb7f7f1pz6r9a35amgjmvvm6m34khsmf85hkrg8hg757mc5"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-org
          graphviz))))

(define-public emacs-elementaryx-org
  (package
   (name "emacs-elementaryx-org")
    (version "2.1.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-org")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. org-mode setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. org-mode setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.1.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0wf4hyw2gha52jkvaf09bpvxbsh3f4bp1295v7adi4r322rllxph"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-base
           emacs-elementaryx-org-minimal
           emacs-consult-org-roam
	   emacs-ob-async ;; allow async org-babel src execution with :async header arg beyond vanilla :session and ipython
           emacs-org-ql ;; for a better speed (to be investigated)
           emacs-org-roam
           ;; emacs-org-roam-ui
           ))))

(define-public emacs-elementaryx-dev-minimal
  (package
   (name "emacs-elementaryx-dev-minimal")
    (version "2.1.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-dev-minimal")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev minimal setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev minimal setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.1.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "144pghk1aly9nmg1hv2jmldz27ncvx6wg0mnnadg3mf12px4dhql"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list ;; emacs-consult-eglot ;; Wait for https://issues.guix.gnu.org/70211 to be resolved:
           emacs-diff-hl ;; for highlighting differences of current buffer with VC (alternative: emacs-git-gutter)
	   emacs-elementaryx-base
           emacs-editorconfig
	   ;; emacs-git-gutter ;; for highlighting differences of current buffer with VC (alternative: emacs-diff-hl)
           emacs-json-mode
           emacs-magit
           emacs-yaml-mode
	   ;; TODO: investigate: emacs-consult-eglot https://stable.melpa.org/#/consult-eglot
           openssh
           ))))

(define-public emacs-elementaryx-dev
  (package
   (name "emacs-elementaryx-dev")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-dev")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev full setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Dev full setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1axfp6ms9k2ivmykijlhjhdhawmxqxxx978ir6xcf1v7nchk95n1"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-dev-minimal
           ;; emacs-crdt
           bash
           ccls ;; c / c++ language server
           direnv ;; not necessary for emacs-envrc (already a dependency of it) but so that we have it in a terminal
           emacs-envrc
           ;; emacs-ess ;; Waiting for its stalibilization: `guix build --check --no-grafts emacs-ess` seems to possibly fail.
           emacs-rmsbolt-ts
	   fortls ;; fortran language server
           gdb
           python-lsp-server ;; pyton language server
	   r-languageserver ;; r language server; TODO: enable emacs-ess otherwise there is no r mode
	   ;; rust-lsp-server-0.5 ;; rust language server
	   texlive-digestif ;; language server (and code analyzer) for: LaTeX, plain TeX, ConTeXt and Texinfo
           tree-sitter
           tree-sitter-bash
           tree-sitter-bibtex
           tree-sitter-c
           tree-sitter-cmake
           tree-sitter-cpp
           tree-sitter-css
	   tree-sitter-dockerfile
	   tree-sitter-haskell
	   tree-sitter-html
           tree-sitter-java
           tree-sitter-javascript
           tree-sitter-json
           tree-sitter-julia
	   tree-sitter-lua
           ;; tree-sitter-markdown ;; it seems that there is not emacs ts mode yet: https://www.reddit.com/r/emacs/comments/1bqichi/did_anyone_manage_to_setup_markdowntsmode/
	   ;; tree-sitter-markdown-gfm ;; probably the same as above (github flavored markddown)
	   ;; therefore we use standard markdown mode instead:
	   emacs-markdown-mode
	   tree-sitter-ocaml ;; TODO: not sure how to use it
           tree-sitter-org
	   tree-sitter-php
           tree-sitter-python ;; see also python-lsp-server language server
           tree-sitter-r ;; TODO: not sure how to use it with ess
           tree-sitter-rust
           tree-sitter-scheme ;; TODO: not sure how to use it with guile et al.
           tree-sitter-typescript
	   ;; tree-sitter-yaml ;; https://issues.guix.gnu.org/66836
           ))))

(define-public emacs-elementaryx-dev-parentheses
  (package
   (name "emacs-elementaryx-dev-parentheses")
    (version "2.0.0")
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
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1c0zdbhcgckw2bvd252gqypbmxi31qrk7filrvhs0vssc14ziw6v"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-geiser-guile
           emacs-paredit))))

(define-public emacs-elementaryx-write
  (package
   (name "emacs-elementaryx-write")
   (version "2.0.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-write")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Write setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix Write setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.0.0")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
               (base32
                "07am7vbylk4zrf2dnh6w7y4640dpm4cx2592qrjz715c38ng6288"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list aspell ;; emacs-jinx has enchant as input, which has aspell (and hunspell) as input, but not as propagated input
          aspell-dict-en
          aspell-dict-fr
	  bibtool
	  emacs-biblio
          emacs-elementaryx-base
          emacs-citar
          emacs-citar-org-roam
          emacs-jinx))))

(define-public emacs-elementaryx-ox-latex-minimal
  (package
   (name "emacs-elementaryx-ox-latex-minimal")
   (version "2.0.0")
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

(define-public emacs-elementaryx-ox-beamer-minimal
  (package
    (name "emacs-elementaryx-ox-beamer-minimal")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-beamer-minimal")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal org-mode latex beamer (ox-beamer) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal org-mode latex beamer (ox-beamer) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "17b4a66mhppvmyr9plb0gy2xzc5v5aas7zpzbga7ab7db8g6pdfp"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox-latex-minimal
           texlive-beamer))))

(define-public emacs-elementaryx-ox-base
  (package
    (name "emacs-elementaryx-ox-base")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-base")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Base org export (ox) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Minimal org-mode latex beamer (ox-beamer) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1qmnrs1p6nj9rxg4xncabiriqjp4mz9v6jv3km0gvh9b07x8p9jm"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list elementaryx-core
	   emacs-elementaryx-org-minimal
           emacs-lob-ob-latexpicture
           emacs-ob-latexmacro
           emacs-ob-latexpicture))))

(define-public emacs-elementaryx-ox-latex-classes
  (package
    (name "emacs-elementaryx-ox-latex-classes")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-latex-classes")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Latex classes for org export (ox) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Latex classes for org export (ox) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
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

(define-public emacs-elementaryx-ox-latex
  (package
    (name "emacs-elementaryx-ox-latex")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-latex")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode latex (ox-latex) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode latex (ox-latex) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "1zaryz6z0ylz8hc7hpyyix49pacj0mcz6s8c80s07f4nyjg70i1m"))))
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

;; (define-public emacs-elementaryx-ox-beamer
;;   (package
;;     (name "emacs-elementaryx-ox-beamer")
;;     (version "2.0.0")
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

(define-public emacs-elementaryx-ox-html
  (package
    (name "emacs-elementaryx-ox-html")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-html")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode html (ox-html) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode html (ox-html) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "00frnyqszmy7djh24dgnm306ljmxxgh8g2fp75rj0wjlxa51wdxg"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox-base
           emacs-citeproc-el
           emacs-htmlize))))

(define-public emacs-elementaryx-ox
  (package
   (name "emacs-elementaryx-ox")
   (version "2.0.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode export (ox) setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode export (ox) setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.0.0")))
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

(define-public emacs-elementaryx-ox-publish
  (package
    (name "emacs-elementaryx-ox-publish")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-publish")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode publish (ox-publish) setup.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix org-mode publish (ox-publish) setup.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "104qxzdblxzg1fy8sgzkxd56732ywaifdzjzkcy9r659swxjzsib"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx-ox))))

(define-public emacs-elementaryx-ox-publish-as-default
  (package
   (name "emacs-elementaryx-ox-publish-as-default")
   (version "2.0.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-ox-publish-default")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el startup file for export-only + publish elementaryx setup together with a vanilla emacs IDE.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el startup file for export-only + publish elementaryx setup together with a vanilla emacs IDE.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.0.0")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "0k7cz6xinq1p4qsh9f47v6spzhsz4naahq60xf1c3hcjsrkkgxc1"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs
          emacs-elementaryx-ox-publish))))

(define-public emacs-elementaryx-full
  (package
   (name "emacs-elementaryx-full")
   (version "2.0.0")
   (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-full")
   (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Full setup.")
   (description
    "ElementaryX: Elementary Emacs configuration coupled with Guix Full setup.")
   (license license:cecill-c)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url home-page)
                  (commit "v2.0.0")))
            (file-name (string-append name "-" version "-checkout"))
            (sha256
             (base32
              "1fs433hfbfnhqi76x60hrm04rn6fn53df4q7lhy516np3y8vhk3j"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-elementaryx-dev
          emacs-elementaryx-dev-parentheses
          emacs-elementaryx-org
          emacs-elementaryx-ox-publish
          emacs-elementaryx-write
	  emacs-elementaryx-treemacs
	  emacs-elementaryx-all-the-icons
	  ;; emacs-elementaryx-nerd-icons ;; Waiting for nerd icons integration https://issues.guix.gnu.org/67983
	  ))))

(define-public emacs-elementaryx
  (package
   (inherit emacs-elementaryx-full)
   (name "emacs-elementaryx")
   (arguments
    `(#:phases
      (modify-phases %standard-phases
		     (add-after 'install 'install-scripts
				(lambda* (#:key outputs #:allow-other-keys)
				  (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
				    ;; Ensure the 'bin' directory exists
				    (mkdir-p bin)
				    ;; Create a script called 'elementaryx-emacs'
				    (call-with-output-file (string-append bin "/elementaryx-emacs")
				      (lambda (port)
					(format port "#!/usr/bin/env bash\n")
					(format port "emacs $([ -n \"$SSH_CONNECTION\" ] && echo \"-nw\") --eval \"(progn (use-package elementaryx-full))\" --init-dir=$XDG_CONFIG_HOME/emacs-elementaryx/ \"$@\"\n")))
				    ;; Make the 'elementaryx-escode' script executable
				    (chmod (string-append bin "/elementaryx-emacs") #o755)
				    #t))))))))

(define-public emacs-elementaryx-as-default
  (package
   (name "emacs-elementaryx-as-default")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-default")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el starup file.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix Add a default.el startup file.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
                "0mc3w4bzdgxj6cz9lz3g6d4jnfpflahj49x8c34qi9wq4srah42h"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-elementaryx))))

(define-public elementaryx-escode
  (package
    (name "elementaryx-escode")
    (version "2.1.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-escode")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for ESCode, the Elementaryx fake true Studio Code.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for ESCode, the Elementaryx fake true Studio Code.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.1.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"00pv2ry22ivis132sr649za53i8anw7p5x81pxi8a7gmqd3z71ka"))))
    (build-system emacs-build-system)
    ;; We also define an elementaryx-escode executable wrapper call for easy call
    (arguments
     `(#:phases
       (modify-phases %standard-phases
		      (add-after 'install 'install-scripts
				 (lambda* (#:key outputs #:allow-other-keys)
				   (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
				     ;; Ensure the 'bin' directory exists
				     (mkdir-p bin)
				     ;; Create a script called 'elementaryx-escode'
				     (call-with-output-file (string-append bin "/elementaryx-escode")
				       (lambda (port)
					 (format port "#!/usr/bin/env bash\n")
					 (format port "emacs $([ -n \"$SSH_CONNECTION\" ] && echo \"-nw\") --eval \"(use-package elementaryx-escode)\" --init-dir=$XDG_CONFIG_HOME/escode/ \"$@\"\n")))
					 ;; (format port "emacs $([ -n \"$SSH_CONNECTION\" ] && echo \"-nw\") --eval \"(progn (use-package elementaryx-full) (use-package elementaryx-escode))\" --init-dir=$XDG_CONFIG_HOME/escode/ \"$@\"\n")))
				     ;; Make the 'elementaryx-escode' script executable
				     (chmod (string-append bin "/elementaryx-escode") #o755)
				     ;; ;; Create a script called 'elementaryx-escode-nested-guix' ; TODO: how to escape $@ in bash -c ''?
				     ;; (call-with-output-file (string-append bin "/elementaryx-escode-nested-guix")
				     ;;   (lambda (port)
				     ;; 	 (format port "#!/usr/bin/env bash\n")
				     ;; 	 (format port "bash -c 'GUIX_PROFILE=\"/guix\" ; . \"$GUIX_PROFILE/etc/profile\" ; emacs $([ -n \"$SSH_CONNECTION\" ] && echo \"-nw\") --eval \"(progn (use-package elementaryx-full) (use-package elementaryx-escode))\" --init-dir=\\$XDG_CONFIG_HOME/escode/ \"$@\"'\n")))
				     ;; ;; Make the 'elementaryx-escode-nested-guix' script executable
				     ;; (chmod (string-append bin "/elementaryx-escode-nested-guix") #o755)
				     #t))))))
    (propagated-inputs
     (list emacs-centaur-tabs
	   emacs-dashboard
	   emacs-elementaryx-full
	   emacs-highlight-indentation ;; possible alternative: emacs-highlight-indent-guides
	   emacs-hydra
	   emacs-minimap
	   emacs-vscode-dark-plus ;; ;; TODO emacs-vscode-icons; with nerd-icons?
	   fontconfig
	   font-google-noto ;; TODO: investigate other fonts: font-dejavu font-liberation font-fira-code font-fira-mono font-hack font-adobe-source-code-pro
	   ))))

(define-public elementaryx-vym
  (package
    (name "elementaryx-vym")
    (version "2.0.0")
    (home-page "https://gitlab.inria.fr/elementaryx/emacs-elementaryx-evil")
    (synopsis "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for Vym, the fake true VY iMprovised.")
    (description
     "ElementaryX: Elementary Emacs configuration coupled with Guix. Setup
for Vym, the fake true VY iMprovised. Version of Elementaryx with
vim-like keybindings. Based on evil and related packages such as
evil-collection.")
    (license license:cecill-c)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit "v2.0.0")))
              (file-name (string-append name "-" version "-checkout"))
              (sha256
               (base32
		"0rsxyr17qz53dzqgwlwkfrhq8sx7v1s9riwhvhbgs1pwh6fivwia"))))
    (build-system emacs-build-system)
    ;; We also define an elementaryx-vym executable wrapper call for easy call
    (arguments
     `(#:phases
       (modify-phases %standard-phases
		      (add-after 'install 'install-scripts
				 (lambda* (#:key outputs #:allow-other-keys)
				   (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
				     ;; Ensure the 'bin' directory exists
				     (mkdir-p bin)
				     ;; Create a script called 'elementaryx-escode'
				     (call-with-output-file (string-append bin "/elementaryx-vym")
				       (lambda (port)
					 (format port "#!/usr/bin/env bash\n")
					 (format port "emacs $([ -n \"$SSH_CONNECTION\" ] && echo \"-nw\") --eval \"(progn (use-package elementaryx-full) (use-package elementaryx-evil))\" --init-dir=$XDG_CONFIG_HOME/vym/ \"$@\"\n")))
				     ;; Make the 'elementaryx-escode' script executable
				     (chmod (string-append bin "/elementaryx-vym") #o755)
				     #t))))))
    (propagated-inputs
     (list emacs-elementaryx-full
           emacs-evil
	   emacs-evil-collection
	   emacs-evil-tex
	   emacs-evil-org
	   emacs-evil-quickscope
	   ))))



;; site-start.el is already deployed by guix.
;; As a consequence the following package would have no effect.
;; (define-public emacs-elementaryx-as-site-start
;;   (package
;;    (name "emacs-elementaryx-as-site-start")
;;     (version "2.0.0")
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
	   ;; git-annex
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
