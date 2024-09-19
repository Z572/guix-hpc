(define-module (guix-hpc packages python-science)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages check)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages machine-learning)
  #:use-module (gnu packages statistics)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject)
  #:use-module (guix licenses))

(define-public python-pyamg
  (package
    (name "python-pyamg")
    (version "4.0.0")
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "pyamg" version))
              (sha256 (base32 "12m32pqymb9w94kqgijrfj2fvj4r2nbg51llfm77fabfv3zkisrw"))))
    (build-system python-build-system)
    (arguments `(#:phases (modify-phases %standard-phases
                            (add-before 'build 'set-home
                              (lambda _
                                ;; The build process expects HOME to be set
                                ;; to a writable directory.
                                (setenv "HOME" (getcwd))
                                #t)))))

    ;; Things only needed for tests.
    (native-inputs (list python-pytest))
    (inputs (list pybind11 python-numpy python-scipy))
    (synopsis "PyAMG library for python.")
    (description "PyAMG is a library of Algebraic Multigrid (AMG) solvers with a convenient Python interface.")
    (home-page "https://github.com/pyamg/pyamg")
    (license gpl3+)))

(define-public python-ttpy
  ;; This commit contains a fix for
  ;; <https://github.com/oseledets/ttpy/issues/80> among other things.
  (let ((commit "22dff3d2cf52b4b23aae40119f1eec39675db9ef")
        (revision "0"))
    (package
      (name "python-ttpy")
      (version (git-version "1.2.0" revision commit))
      (home-page "https://github.com/oseledets/ttpy")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url home-page)
                      (commit commit)
                      (recursive? #t)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "07kl2099rqnd32z2nkmgn1z0chrxwz1x0p5qy5hpmn4gyss4qbgq"))))
      (build-system python-build-system)
      (arguments
       (list #:phases
             #~(modify-phases %standard-phases
                 (add-before 'build 'patch-before-build
                   (lambda* (#:key inputs #:allow-other-keys)
                     ;; Indicate we want to use "CPU = i8-gnu"
                     (rename-file "tt/tt-fort/Makefile.cpu.default"
                                  "tt/tt-fort/Makefile.cpu")
                     ;; Removing lapack dependency
                     (substitute* "tt/__init__.py"
                       (("liblapack.so")
                        (search-input-file inputs
                                           "lib/libopenblas.so"))))))
             #:tests? #f))
      ;; WARNING: the 'python-ttpy' package must be built with a numpy version lower than 1.23.2.
      (native-inputs (list python-pytest python-cython gfortran))
      (inputs (list gmp mpfr openblas))
      (propagated-inputs (list python-numpy python-scipy python-six))
      (synopsis "Python implementation of the Tensor Train (TT) toolbox")
      (description
       "Python implementation of the Tensor Train (TT) toolbox.  It contains several
important packages for working with the TT-format in Python.  It is able to
do TT-interpolation, solve linear systems, eigenproblems, solve dynamical
problems.  Several computational routines are done in Fortran (which can be
used separately), and are wrapped with the @command{f2py} tool.")
      (license expat))))

(define-public python-easydict
  (package
    (name "python-easydict")
    (version "1.9")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "easydict" version))
        (sha256
          (base32
            "0fw82sjzki95rl5f6nscz9bvp1fri3rv2b83vzsg16f20ymhsgrz"))))
    (build-system python-build-system)
    (home-page
      "https://github.com/makinacorpus/easydict")
    (synopsis
      "Access dict values as attributes (works recursively).")
    (description
      "Access dict values as attributes (works recursively).")
    (license #f)))

;; Not working yet
;; ERROR: No matching distribution found for dill>=0.3.2 (python-dill is currently)
;; while the current guix version is at 0.3.1.1
(define-public python-latexify-py
  (package
   (name "python-latexify-py")
   (version "0.0.7")
   (source (origin
            (method url-fetch)
            (uri (pypi-uri "latexify-py" version))
            (sha256
             (base32
              "08c1iwsibrvham5r7q1lrgw142msfa90ds1f2in4ffb089jn479k"))))
   (build-system python-build-system)
   (propagated-inputs (list python-dill))
   (home-page "https://github.com/google/latexify_py")
   (synopsis "Generates LaTeX source from Python functions.")
   (description "Generates LaTeX source from Python functions.")
   (license #f)))

(define-public python-pillow6
  (package
   (inherit python-pillow)
   (name "python-pillow")
   (version "6.1.0")
   (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "Pillow" version))
       (sha256
        (base32
         "1pnrsz0f0n0c819v1pdr8j6rm8xvhc9f3kh1fv9xpdp9n5ygf108"))))
   (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-ldconfig
           (lambda _
             (substitute* "setup.py"
               (("\\['/sbin/ldconfig', '-p'\\]") "['true']"))))
         (replace 'check
           (lambda* (#:key outputs inputs tests? #:allow-other-keys)
             (when tests?
               (setenv "HOME" (getcwd))
               ;; Make installed package available for running the tests.
               (add-installed-pythonpath inputs outputs)
               (invoke "python" "selftest.py" "--installed")))))))))

(define-public python-torch-vision
  (package
    (name "python-torch-vision")
    (version "0.2.2")
    (source
      (origin
        (method git-fetch)
        (uri
         (git-reference
          (url "https://github.com/pytorch/vision")
          (commit (string-append "v" version))))
        (sha256
          (base32 "0wmpvb67a3778syxk7wav1rajf0ad71f85vmwbvrxw2nc2agxsd9"))))
    (build-system python-build-system)
    (arguments
     ;; The 'check' phase is producing a 'not a test' error! 
     '(#:tests? #f))
    (inputs
     (list python-pytorch python-pillow6 python-scipy))
    (home-page "https://github.com/pytorch/vision")
    (synopsis "image and video datasets and models for torch deep learning")
    (description "image and video datasets and models for torch deep learning")
    (license bsd-3)))

(define-public python-torch-diffeq
  (package
    (name "python-torch-diffeq")
    (version "0.2.2")
    (source
      (origin
        (method git-fetch)
        (uri
         (git-reference
          (url "https://github.com/rtqichen/torchdiffeq")
          (commit "97e93deddcb18f67330f0b9caa75808f38b94c89")))
        (sha256
          (base32 "04gmc13jf0wnbdvslgvzzbnnmzl1f7q44b73xbpaa7s7s4ijprxd"))))
    (build-system python-build-system)
    (arguments
     ;; Looks like the tests require network connection.
     '(#:tests? #f))
    (inputs
     (list python-pytorch python-pillow6 python-scipy))
    (home-page
      "https://github.com/rtqichen/torchdiffeq")
    (synopsis
      "Differentiable ODE solvers with full GPU support and O(1)-memory
backpropagation.")
    (description
      "This library provides ordinary differential equation (ODE) solvers
implemented in PyTorch. Backpropagation through ODE solutions is supported using
the adjoint method for constant memory cost. For usage of ODE solvers in deep
learning applications.

As the solvers are implemented in PyTorch, algorithms in this repository are
fully supported to run on the GPU.")
    (license expat)))

(define-public python-pyevtk
  (package
    (name "python-pyevtk")
    (version "1.6.0")
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "pyevtk" version))
              (sha256
               (base32
                "1x55zpnxwlfwss9jmzz7lbqlzr779zd525c6b215q01sda3yfsqz"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-numpy))
    (native-inputs (list python-pytest python-pytest-cov))
    (home-page "https://github.com/pyscience-projects/pyevtk")
    (synopsis "Export data as binary VTK files")
    (description "Export data as binary VTK files")
    (license bsd-2)))

(define-public python-iterative-stats
  (package
    (name "python-iterative-stats")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url
              "https://github.com/IterativeStatistics/BasicIterativeStatistics")
             (commit (string-append "v" version))))
       (sha256
        (base32 "1hjqi4zrvrcidjryq65nf1046pw04ya3w1xmsapldjbqmxd259n2"))))
    (build-system pyproject-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'change-pyyaml-requirement
                 (lambda _
                   (substitute* "pyproject.toml"
                     (("pyyaml = \"6.0\"")
                      "pyyaml = \">=6.0\"")))))))
    (native-inputs (list python-poetry-core python-pytest python-openturns))
    (propagated-inputs (list python-numpy python-pyyaml))
    (home-page
     "https://github.com/IterativeStatistics/BasicIterativeStatistics")
    (synopsis "Iterative Statistics Python Library")
    (description
     "Implements iterative statistics operators for mean, variance, high-order
 moments, extrema, covariance, threshold, quantile (experimental) and Sobol'
 indices")
    (license bsd-3)))
