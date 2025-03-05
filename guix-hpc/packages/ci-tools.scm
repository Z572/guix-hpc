;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2025 Inria

(define-module (guix-hpc packages ci-tools)
  #:use-module (gnu packages check)
  #:use-module (gnu packages machine-learning)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages time)
  #:use-module (gnu packages xml)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public python-cs
  (package
    (name "python-cs")
    (version "3.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ngine-io/cs")
             (commit (string-append "v" version))))
       (sha256
        (base32 "1m0zqg7bqm4pr1v5i9pr2g0fz8rvlnwsh0khjlci23kf87yik607"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools
                         python-wheel
                         python-pytest
                         python-pytest-cov
                         python-contextlib2
                         python-mock))
    (propagated-inputs (list python-pytz python-requests))
    (home-page "https://github.com/ngine-io/cs")
    (synopsis
     "A simple yet powerful CloudStack API client for Python and the command-line.")
    (description
     "This package provides a simple yet powerful @code{CloudStack} API client for
Python and the command-line.")
    (license license:bsd-3)))

(define-public python-multi-key-dict
  (package
    (name "python-multi-key-dict")
    (version "2.0.3")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "multi_key_dict" version))
       (sha256
        (base32 "17lkx4rf4waglwbhc31aak0f28c63zl3gx5k5i1iq2m3gb0xxsyy"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools python-wheel))
    (home-page "https://github.com/formiaczek/multi_key_dict")
    (synopsis "Multi key dictionary implementation")
    (description "Multi key dictionary implementation.")
    (license license:expat)))

(define-public python-jenkins
  (package
    (name "python-jenkins")
    (version "1.8.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "python-jenkins" version))
       (sha256
        (base32 "1jzfnqf0glybz83b58jx2vcvxvdb051jsvgwsvhvig870sxxmrsn"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f)) ; Tests use tox.
    (propagated-inputs (list python-multi-key-dict python-pbr python-requests
                             python-six))
    (native-inputs (list python-setuptools
                         python-wheel))
    (home-page "https://opendev.org/jjb/python-jenkins")
    (synopsis "Python bindings for the remote Jenkins API")
    (description "Python bindings for the remote Jenkins API.")
    (license license:bsd-3)))

(define-public ci-cmdline
  (let ((commit "f007c6108101e8bf8737ed32ed1a186f744fe26f")
        (version "0.1")
        (revision "1"))
    (package
      (name "ci-cmdline")
      (version (git-version version revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://gitlab.inria.fr/inria-ci/ci-cmdline")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "115lmf41rnv09cdcc2j3jdrgy7p1s9ddjbcci0g4ciy5zlbpwp26"))))
      (build-system pyproject-build-system)
      (arguments
       (list #:tests? #f))              ; No tests in package.
      (native-inputs (list python-setuptools python-wheel))
      (propagated-inputs (list python-beautifulsoup4
                               python-cs
                               python-genshi
                               python-inflection
                               python-lxml
                               python-jenkins
                               python-pyyaml
                               python-readchar
                               python-requests
                               python-sshpubkeys
                               python-typing-extensions
                               python-wget
                               python-pysocks))
      (home-page "https://gitlab.inria.fr/inria-ci/ci-cmdline")
      (synopsis "Command-line for ci.inria.fr")
      (description "A command-line for ci.inria.fr.")
      (license license:bsd-2))))
