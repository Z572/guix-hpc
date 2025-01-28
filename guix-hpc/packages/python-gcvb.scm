;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2019, 2020, 2021, 2022, 2024, 2025 Inria

(define-module (guix-hpc packages python-gcvb)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages)
  #:use-module (gnu packages graph)
  #:use-module (gnu packages check)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages xml)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1))
  
(define-public python-percy
  (package
   (name "python-percy")
   (version "2.0.2")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "percy" version))
     (sha256
      (base32 "07821yabrqjyg0z45xlm4vz4hgm4gs7p7mqa3hi5ryh1qhnn2f32"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Tests need internet connection to work.
    '(#:tests? #f))
   (propagated-inputs (list python-requests))
   (native-inputs (list python-setuptools python-wheel))
   (home-page "https://github.com/percy/python-percy-client")
   (synopsis
    "Python client library for visual regression testing with Percy.")
   (description
    "Python client library for visual regression testing with Percy
(https://percy.io).")
   (license license:expat)))

(define-public python-dash-dangerously-set-inner-html
  (package
   (name "python-dash-dangerously-set-inner-html")
   (version "0.0.2")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_dangerously_set_inner_html" version))
     (sha256
      (base32 "0r7akwk9nxw9lpxyxg0b72zwlmd0msvi13rcwb9c87w5al3rkznp"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Cyclic dependency on `python-dash'.
    '(#:phases (modify-phases %standard-phases (delete 'sanity-check))
               #:tests? #f))
   (native-inputs (list python-setuptools python-wheel))
   (home-page "")
   (synopsis "A dash component for specifying raw HTML")
   (description
    "This package provides a dash component for specifying raw HTML.")
   (license license:expat)))

(define-public python-dash-flow-example
  (package
   (name "python-dash-flow-example")
   (version "0.0.5")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_flow_example" version))
     (sha256
      (base32 "0w5l1w4q2i2k2xi6xv8q6j186jqvz1ffswnbvsdglxh306ld56my"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Cyclic dependency on `python-dash'.
    '(#:phases (modify-phases %standard-phases (delete 'sanity-check))
               #:tests? #f))
   (native-inputs (list python-setuptools python-wheel))
   (home-page "")
   (synopsis "Example of a Dash library that uses Flow Types")
   (description "Example of a Dash library that uses Flow Types.")
   (license license:expat)))

(define-public python-dash-table
  (package
   (name "python-dash-table")
   (version "5.0.0")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_table" version))
     (sha256
      (base32 "023kpk2p1h8qychallzi1gmafdrlb5kz39lrxkfz53jc7mllsqhq"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Cyclic dependency on `python-dash'.
    '(#:phases (modify-phases %standard-phases (delete 'sanity-check))
               #:tests? #f))
   (native-inputs (list python-setuptools python-wheel))
   (home-page "")
   (synopsis "Dash table")
   (description "Dash table.")
   (license license:expat)))

(define-public python-dash-html-components
  (package
   (name "python-dash-html-components")
   (version "2.0.0")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_html_components" version))
     (sha256
      (base32 "0l3fy8ax02dwrslxf7vsx6mxm9d47l5qx6chcfd620hg100sc0w7"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Cyclic dependency on `python-dash'.
    '(#:phases (modify-phases %standard-phases (delete 'sanity-check))
               #:tests? #f))
   (native-inputs (list python-setuptools python-wheel))
   (home-page "https://github.com/plotly/dash-html-components")
   (synopsis "Vanilla HTML components for Dash")
   (description "Vanilla HTML components for Dash.")
   (license license:expat)))

(define-public python-dash-core-components
  (package
   (name "python-dash-core-components")
   (version "2.0.0")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_core_components" version))
     (sha256
      (base32 "1vpzcc5nwg4af6rhp9izwi6g2zgfq8b8lfd1jlpmaplpmxs3hwy6"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Cyclic dependency on `python-dash'.
    '(#:phases (modify-phases %standard-phases (delete 'sanity-check))
               #:tests? #f))
   (native-inputs (list python-setuptools python-wheel))
   (home-page "")
   (synopsis "Core component suite for Dash")
   (description "Core component suite for Dash.")
   (license license:expat)))

(define-public python-dash-renderer
  (package
   (name "python-dash-renderer")
   (version "1.9.1")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_renderer" version))
     (sha256
      (base32 "0zlf2p9cyi9ifsw95ziy9ys94795h80x2fkj8a7fd02q2hyrx9kk"))))
   (build-system pyproject-build-system)
   (native-inputs (list python-setuptools python-wheel))
   (home-page "")
   (synopsis "Front-end component renderer for Dash")
   (description "Front-end component renderer for Dash.")
   (license license:expat)))

(define-public python-dash-testing-stub
  (package
   (name "python-dash-testing-stub")
   (version "0.0.2")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash-testing-stub" version))
     (sha256
      (base32 "0mx3f4qi5wmgczc7zr4qvy7l8693czaw26vqgnix67g4kzdgg60a"))))
   (build-system pyproject-build-system)
   (native-inputs (list python-setuptools python-wheel))
   (home-page "https://plotly.com/dash")
   (synopsis
    "Package for optional loading of pytest dash plugin.")
   (description
    "Package installed with dash[testing] for optional loading of pytest dash
plugin.")
   (license license:expat)))

;; `python-dash' requires an older version of `python-werkzeug', so we take the
;; latest version available it accepts which is `3.0.6'.
(define-public python-werkzeug-3.0
  (package
   (inherit python-werkzeug)
   (version "3.0.6")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "werkzeug" version))
     (sha256
      (base32 "138znip28x2lhfq3lsx76vhg4zjzxndsgjrl393p1ji8vva5kpd8"))))))

;; `python-dash' requires an older version of `python-flask', so we take the
;; latest version available it accepts which is `3.0.3'.
(define-public python-flask-3.0
  (package
   (inherit python-flask)
   (version "3.0.3")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "flask" version))
     (sha256
      (base32 "0hk8yw721km9v75lbi0jhmdif1js2afxk918g5rs4gl2yc57pcnf"))))))

(define-public python-dash
  (package
   (name "python-dash")
   (version "2.18.2")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash" version))
     (sha256
      (base32
       "1j4n8asdn92zz80s88qdyd9bwg2ipidw4cxf5v78iznhfd7l1s10"))))
   (build-system pyproject-build-system)
   (arguments
    ;; There are no tests to run.
    '(#:tests? #f))
   (propagated-inputs
    (list python-dash-core-components
          python-dash-html-components
          python-dash-table
          python-flask-3.0
          python-importlib-metadata
          python-nest-asyncio
          python-plotly
          python-requests
          python-retrying
          python-setuptools
          python-typing-extensions
          python-werkzeug-3.0))
   (native-inputs
    (list python-beautifulsoup4
          python-coloredlogs
          python-cryptography
          python-dash-testing-stub
          python-fire
          python-lxml
          python-multiprocess
          python-percy
          python-psutil
          python-pytest
          python-pyyaml
          python-requests
          python-selenium
          python-setuptools
          python-waitress
          python-wheel))
   (home-page "https://plotly.com/dash")
   (synopsis
    "A Python framework for building reactive web-apps. Developed by Plotly.")
   (description
    "This package provides a Python framework for building reactive web-apps.
Developed by Plotly.")
   (license license:expat)))

(define-public python-dash-bootstrap-components
  (package
   (name "python-dash-bootstrap-components")
   (version "1.7.1")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_bootstrap_components" version))
     (sha256
      (base32 "10m0jmb5889gj8m5ph326lvdbw1n8b6h1r06dhfq72fwsr087m1h"))))
   (build-system pyproject-build-system)
   (arguments
    ;; There is no test system to run.
    '(#:tests? #f))
   (propagated-inputs (list python-dash))
   (native-inputs (list python-hatchling))
   (home-page "")
   (synopsis "Bootstrap themed components for use in Plotly Dash")
   (description "Bootstrap themed components for use in Plotly Dash.")
   (license #f)))

(define-public python-dash-defer-js-import
  (package
   (name "python-dash-defer-js-import")
   (version "0.0.2")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "dash_defer_js_import" version))
     (sha256
      (base32 "0jhyvwhp1i0dnivzhvwmsqwi9zbc2d4hgpymshxfsdb5sj9yygs0"))))
   (build-system pyproject-build-system)
   (arguments
    ;; Tests are broken.
    '(#:tests? #f))
   (native-inputs (list python-setuptools python-wheel))
   (propagated-inputs (list python-dash))
   (home-page "")
   (synopsis "Deferring loading of JS files until after React loads")
   (description "Deferring loading of JS files until after React loads.")
   (license license:expat)))

(define-public python-gcvb
  (let ((release "1.0.0")
        (commit "9266eff392343ee22f6bd440d843ebf2bc8227aa")
        (revision "25"))
    (package
     (name "python-gcvb")
     (version (git-version release revision commit))
     (source
      (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/jm-cc/gcvb")
         (commit commit)))
       (sha256
        (base32
         "10ahn5c71gcml37kr4vn43ciihawgq740fn5ay6rs4zpwnsp1py8"))))
     (build-system python-build-system)
     (propagated-inputs
      (list
       python-pyyaml-5
       python-dash-bootstrap-components
       python-dash-defer-js-import))
     (home-page "https://github.com/jm-cc/gcvb")
     (synopsis
      "Non-regression, validation and benchmarking of simulation codes")
     (description
      "gcvb (generate compute validate benchmark) is a Python 3 module aiming at
facilitating non-regression, validation and benchmarking of simulation codes.
gcvb is not a complete tool of continuous integration (CI). It is rather a
component of the testing part of a CI workflow. It can compare the different
metrics of your computation with references that can be a file, depends of the
'configuration' or are absolute.")
     (license license:expat))))

(define-public python-gcvb-minimal
  (package
   (inherit python-gcvb)
   (name "python-gcvb-minimal")
   (arguments
    ;; Even if the package can live without `python-dash-bootstrap-components'
    ;; and `python-dash-defer-js-import', the tests can't.
    '(#:tests? #f))
   (propagated-inputs
    (modify-inputs
     (package-propagated-inputs python-gcvb)
     (delete "python-dash-bootstrap-components" "python-dash-defer-js-import")))
   (description
      "gcvb (generate compute validate benchmark) is a Python 3 module aiming at
facilitating non-regression, validation and benchmarking of simulation codes.
gcvb is not a complete tool of continuous integration (CI). It is rather a
component of the testing part of a CI workflow. It can compare the different
metrics of your computation with references that can be a file, depends of the
'configuration' or are absolute. This is a minimal version without the dashboard
functionality.")))

(define-public python-gcvb-mfelsoci
  (let ((release "1.0.0")
        (commit "75594c9445a0a18fa8c6b399d412e7c2cd1077b2")
        (revision "40"))
    (package
     (name "python-gcvb-mfelsoci")
     (version (git-version release revision commit))
     (source
      (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/felsocim/gcvb")
         (commit commit)))
       (sha256
        (base32
         "03m43icdbv0wv2c0n2vmg9i1la4wwzbx61v1qk4c6x37y1hw2hf0"))))
     (build-system python-build-system)
     (arguments
      ;; There are no tests to run.
      '(#:tests? #f))
     (propagated-inputs
      (list python-pyyaml-5 python-dash-bootstrap-components))
     (home-page "https://github.com/felsocim/gcvb")
     (synopsis
      "Non-regression, validation and benchmarking of simulation codes (fork)")
     (description
      "gcvb (generate compute validate benchmark) is a Python 3 module aiming at
facilitating non-regression, validation and benchmarking of simulation codes.
gcvb is not a complete tool of continuous integration (CI). It is rather a
component of the testing part of a CI workflow. It can compare the different
metrics of your computation with references that can be a file, depends of the
'configuration' or are absolute. This is the fork of Marek Felšöci.")
     (license license:expat))))

(define-public python-gcvb-minimal-mfelsoci
  (package
   (inherit python-gcvb-mfelsoci)
   (name "python-gcvb-minimal-mfelsoci")
   (propagated-inputs
    (modify-inputs
     (package-propagated-inputs python-gcvb-mfelsoci)
     (delete "python-dash-bootstrap-components")))
   (description
      "gcvb (generate compute validate benchmark) is a Python 3 module aiming at
facilitating non-regression, validation and benchmarking of simulation codes.
gcvb is not a complete tool of continuous integration (CI). It is rather a
component of the testing part of a CI workflow. It can compare the different
metrics of your computation with references that can be a file, depends of the
'configuration' or are absolute. This is a minimal version without the dashboard
functionality. This is the fork of Marek Felšöci.")))

