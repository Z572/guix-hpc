;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2019, 2020, 2021, 2022 Inria

(define-module (inria staging)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages check)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages maths))

;;; Commentary:
;;;
;;; This is the staging area: things that ought to be in Guix proper but more
;;; work is needed before that can happen.
;;;
;;; Code:

(define S specification->package)

(define-public metis-r64
  ;; This variant of Metis uses 64-bit reals (32-bit reals are the default).
  ;; It was initially submitted as <https://issues.guix.gnu.org/47237> but
  ;; deemed too specific.  Perhaps move it to Guix proper eventually, or add
  ;; a "package parameter" interface.
  (package/inherit metis
    (name "metis-r64")
    (synopsis
     "Graph partitioning and fill-reducing matrix ordering (64-bit reals)")
    (arguments
     (substitute-keyword-arguments (package-arguments metis)
       ((#:modules _ '())
        '((system base target)
          (guix build cmake-build-system)
          (guix build utils)))
       ((#:phases phases '%standard-phases)
        `(modify-phases ,phases
           (add-after 'unpack 'set-real-type-width
             (lambda* (#:key build target #:allow-other-keys)
               ;; Enable 64-bit floating point numbers on 64-bit
               ;; architectures.  Leave the default 32-bit width on other
               ;; architectures.
               (let ((word-size
                      (with-target (or target build %host-type)
                                   (lambda ()
                                     (target-word-size)))))
                 (when (= 8 word-size)
                   (display "setting REALTYPEWIDTH to 64...\n")
                   (substitute* "include/metis.h"
                     (("define REALTYPEWIDTH.*$")
                      "define REALTYPEWIDTH 64\n"))))))))))))

(define-public python-brian2
  (package
    (name "python-brian2")
    (version "2.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "Brian2" version))
       (sha256
        (base32
         "1wjrx581xmzrgvc790bk78f38ky65lsiv1n01cmwdn2507s1lwbs"))))
    (build-system python-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                  (replace 'check
                    (lambda* (#:key tests? #:allow-other-keys)
                      (when tests?
                        (invoke "pytest")))))

       ;; FIXME:
       ;; AttributeError: 'Config' object has no attribute 'fail_for_not_implemented'
       #:tests? #f))
    (propagated-inputs
     (list python-cython
           python-jinja2
           python-numpy
           (S "python-pyparsing")
           (S "python-setuptools")
           python-sympy))
    (native-inputs
     (list python-pytest python-pytest-xdist))
    (home-page "http://www.briansimulator.org/")
    (synopsis "Clock-driven simulator for spiking neural networks")
    (description
     "Brian is a simulator for spiking neural networks, written in Python.  It
is designed to be easy to learn and use, highly flexible and easily
extensible.")
    (license license:cecill)))
