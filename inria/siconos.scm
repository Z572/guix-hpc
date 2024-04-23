;
(define-module (inria siconos)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix build-system python)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system copy)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages check)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages nettle)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages autogen)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages swig)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages engineering)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages image)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages game-development)
  #:use-module (gnu packages image-processing)
  ;; boost:
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages shells)
  ;; vtk
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages geo)
  #:use-module (gnu packages sqlite)
  ;; swig
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pcre)
  ;; opencascade-oce
  #:use-module (gnu packages tcl)
  ;; python-h5py
  #:use-module (gnu packages pkg-config)
  ;; pythonocc-core (rapidjson)
  #:use-module (gnu packages web))

(define-public fclib-3.0
  (package
    (name "fclib")
    (version "3.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/FrictionalContactLibrary/fclib/")
             (commit "a8ba23a694d5addcdfa29357a4c45933451abdfd")))
       (sha256 (base32
                "1c95yc7w2rynkk2d3mhnzv1bbcjqfpcxsc8qx0nvq78pyxqcaf2g"))))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"           ;Build without '-g' to save space.
                    #:configure-flags
                    '("-DFCLIB_HEADER_ONLY=OFF")
                    #:tests? #f))
    (native-inputs
     `(("gcc" ,gcc)
       ("gnu-make" ,gnu-make)
       ("cmake" ,cmake)))
    (propagated-inputs
     `(("hdf5" ,hdf5)))
    (home-page "https://frictionalcontactlibrary.github.io/")
    (synopsis "A collection of discrete 3D Frictional Contact (FC) problems")
    (description "FCLIB is an open source collection of Frictional
Contact (FC) problems stored in a specific HDF5 format with a light
implementation in C Language of Input/Output functions to read and write those
problems.")
    (license license:asl2.0) ; Apache 2.0
    ))

(define-public fclib fclib-3.0)

(define-public siconos-tutorials-4.4
  (package
    (name "siconos-tutorials")
    (version "4.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/siconos/siconos-tutorials")
             (commit "9144b28e370666b1999b0ad10970fd0510768cd7")))
       (sha256 (base32
                "0jdpwik01vjbw27i3hyazjn1fxjgd91rgy09inz46x6zpalhdnyk"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("." "/share/siconos/siconos-tutorials"))
       #:phases
       (modify-phases %standard-phases
         (delete 'reset-gzip-timestamps))))
    (home-page "https://github.com/siconos/siconos-tutorials")
    (synopsis "Library for nonsmooth numerical simulation - Examples")
    (description
     "Siconos is an open-source scientific software primarily targeted at
modeling and simulating nonsmooth dynamical systems in C++ and in Python:
Mechanical systems (rigid or solid) with unilateral contact and Coulomb
friction and impact (nonsmooth mechanics, contact dynamics, multibody systems
dynamics or granular materials).  Switched Electrical Circuit such as
electrical circuits with ideal and piecewise linear components: power
converter, rectifier, Phase-Locked Loop (PLL) or Analog-to-Digital converter.
Sliding mode control systems.  Biology (Gene regulatory network).

Other applications are found in Systems and Control (hybrid systems,
differential inclusions, optimal control with state constraints),
Optimization (Complementarity systems and Variational inequalities), Fluid
Mechanics, and Computer Graphics.")
    (license license:asl2.0) ; Apache 2.0
    ))

(define-public siconos-tutorials-4.3
  (package
    (inherit siconos-tutorials-4.4)
    (version "4.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/siconos/siconos-tutorials")
             (commit "5fa67fa5fdb59734e38e704143d47ade98b8faef")))
       (sha256 (base32
                "0m7ahrx1l5pb8j0qzym59523375lfbgyacibd24zk343k69vcsg0"))))))

(define-public siconos-tutorials-4.2
  (package
    (inherit siconos-tutorials-4.4)
    (version "4.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/siconos/siconos-tutorials")
             (commit "7e1322d1c51224970967e46408b81a84e81b18a8")))
       (sha256 (base32
                "0451cj8vx42zyrd1injcccw5sl5zz9f9afd54q3ax0h6d52q994x"))))))


(define-public siconos-tutorials-4.5.x
  (package
   (inherit siconos-tutorials-4.4)
   (name "siconos-tutorials-4.5.x")
   (version "4.5.x")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/siconos/siconos-tutorials")
           (commit "0861cb54988bb60738e7ce891ebadaa7dac35b88")))
     (sha256 (base32
              "0dj0b8kscy2h3chxpw330dbnppl43gydhpm7na05hnsp74in8k5s"))))))

(define-public siconos-tutorials siconos-tutorials-4.4)

(define-public siconos-4.3
  (package
    (name "siconos")
    (version "4.3.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/siconos/siconos/archive/"
             version ".tar.gz"))
       (sha256 (base32
                "0lksvbw4m3z938hsi3bs9zdbiq6ijgzdfqan0p7qhdsawhmzzzv2"))
       (patches (search-patches "inria/patches/siconos-cmake-ixx.patch"))))
    (build-system cmake-build-system)
    (arguments
     `(#:imported-modules ((guix build python-build-system)
                           ,@%cmake-build-system-modules)
       #:configure-flags `("-DCMAKE_VERBOSE_MAKEFILE=ON"
                           "-DWITH_BULLET=ON"
                           "-DBULLET_USE_DOUBLE_PRECISION=ON"
                           "-DWITH_OCE=ON"
                           "-DWITH_FCLIB=ON"
                           ,(string-append "-DCMAKE_INSTALL_PREFIX=" (assoc-ref %outputs "out"))
                           "-DCOMPONENTS=externals;numerics;kernel;control;mechanics;io;mechanisms"
                           "-DWITH_SYSTEM_SUITESPARSE=ON")
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'delete-ixx
           ;; some troubles with this file and cmake 3.21.4
           ;; probably related to https://gitlab.kitware.com/cmake/cmake/-/merge_requests/5926
           (lambda _ (delete-file "mechanisms/src/CADMBTB/mymath_FunctionSetRoot.ixx") #t))
         (add-after 'install 'patch-mechanisms
           (lambda*  (#:key outputs #:allow-other-keys)
             (substitute* (string-append (assoc-ref outputs "out")
                                         "/bin/siconos_mechanisms")
               (("/usr/bin/env python") (which "python3")))
             #t))
         ;;  setup.py fails with recents python/numpy
         (add-after 'patch-mechanisms 'install-python-files
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((python-version (@ (guix build python-build-system)
                                       python-version))
                    (out (assoc-ref outputs "out"))
                    (version (python-version (assoc-ref inputs "python")))
                    (pydir (string-append out "/lib/python"
                                          version "/site-packages/")))
               (chdir "./wrap")
               (for-each (lambda (file)
                           (let ((dirinst (string-append pydir "/" (dirname file))))
                             (mkdir-p dirinst)
                             (install-file file dirinst)))
                         (find-files "siconos" "\\.py$"))
               #t))))
       #:tests? #f))                              ;XXX: no "test" target
    (outputs '("out" "debug"))
    (native-inputs
     `(("swig" ,swig)
       ("gcc" ,gcc-7)
       ("gfortran" ,gfortran)
       ("gnu-make" ,gnu-make)
       ("cmake" ,cmake)
       ("python-pytest" ,python-pytest)))
    (inputs
     `(("python" ,python)))
    (propagated-inputs
     `(("boost" ,boost)
       ("bullet" ,bullet-double-precision)
       ("fclib" ,fclib)
       ("gmp" ,gmp)
       ("lapack" ,lapack)
       ("openblas" ,openblas)
       ("opencascade-oce", opencascade-oce)
       ("python-h5py"  ,python-h5py)
       ("python-lxml"  ,python-lxml)
       ("python-numpy" ,python-numpy)
       ("python-packaging" ,python-packaging)
       ("python-scipy" ,python-scipy)
       ("suitesparse" ,suitesparse)))
    (home-page "https://nonsmooth.gricad-pages.univ-grenoble-alpes.fr/siconos/index.html")
    (synopsis "Library for nonsmooth numerical simulation")
    (description
     "Siconos is an open-source scientific software primarily targeted at
modeling and simulating nonsmooth dynamical systems in C++ and in Python:
Mechanical systems (rigid or solid) with unilateral contact and Coulomb
friction and impact (nonsmooth mechanics, contact dynamics, multibody systems
dynamics or granular materials).  Switched Electrical Circuit such as
electrical circuits with ideal and piecewise linear components: power
converter, rectifier, Phase-Locked Loop (PLL) or Analog-to-Digital converter.
Sliding mode control systems.  Biology (Gene regulatory network).

Other applications are found in Systems and Control (hybrid systems,
differential inclusions, optimal control with state constraints),
Optimization (Complementarity systems and Variational inequalities), Fluid
Mechanics, and Computer Graphics.")
    (license license:asl2.0) ; Apache 2.0
    ))

; with mumps and mpi
(define-public siconos-mpi-4.3
  (package
    (inherit siconos-4.3)
    (name "siconos-mpi")
    (synopsis "Library for nonsmooth numerical simulation - with MUMPS solver and MPI")
    (propagated-inputs
     `(("mpi" ,openmpi)
       ("mumps-openmpi" ,mumps-openmpi)
       ("python-mpi4py" ,python-mpi4py)
       ,@(package-propagated-inputs siconos-4.3)))
    (arguments
     (substitute-keyword-arguments (package-arguments siconos)
       ((#:configure-flags flags)
        `("-DWITH_MPI=ON"
          "-DWITH_MUMPS=ON" ,@flags))))))

(define-public siconos-4.2
  (package
   (inherit siconos-4.3)
   (version "4.2.0")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/siconos/siconos/archive/"
           version ".tar.gz"))
     (sha256 (base32
              "1gy15d8yzch0mmgy56mj9h22gbyh2k4m9y59q8p8dxy7aixqhfbv"))
     (patches (search-patches "inria/patches/siconos-4.2-cmake-ixx.patch"))))
   (native-inputs
    `(("gfortran", gfortran-7)
        ,@(alist-delete "gfortran"
                        `(("swig", swig-3.0.12)
                          ,@(alist-delete "swig" (package-native-inputs siconos))))))
   (propagated-inputs
    `(("python-h5py" ,python-h5py-2)
      ,@(alist-delete "python-h5py"
                      `(("boost" ,boost-1.68.0)
                        ,@(alist-delete "boost" (package-propagated-inputs siconos))))))
   (arguments
    (substitute-keyword-arguments (package-arguments siconos)
      ((#:phases phases)
       `(modify-phases ,phases
          (delete 'delete-ixx)
          (add-after 'unpack 'delete-ixx-4.2
           ;; some troubles with this file and cmake 3.21.4
           ;; probably related to https://gitlab.kitware.com/cmake/cmake/-/merge_requests/5926
           (lambda _ (delete-file "mechanics/src/mechanisms/CADMBTB/mymath_FunctionSetRoot.ixx") #t))))
      ((#:configure-flags flags)
       `(cons "-DWITH_OCC=ON"
              (cons "-DWITH_MECHANISMS=ON"
                    (delete "-DCOMPONENTS=externals;numerics;kernel;control;mechanics;io;mechanisms"
                            (delete "-DWITH_OCE=ON" ,flags)))))))))

(define-public siconos-4.4-rc2
  (package
    (inherit siconos-4.3)
    (version "4.4.0.rc2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/siconos/siconos/archive/"
             version ".tar.gz"))
       (sha256 (base32
                "18z8bcl2b4l2iaw9f3hgafxsid8kyn5vdm07fl53whl3jac4xaca"))
       (patches (search-patches "inria/patches/siconos-cmake-ixx.patch"))))))

(define-public siconos-4.4-rc3
  (package
    (inherit siconos-4.4-rc2)
    (version "4.4.0.rc3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/siconos/siconos/archive/"
             version ".tar.gz"))
       (sha256 (base32
                "148fwppjj7rdiqrgapbm9rg4k60d8xm9q4fc3757fp236nv8bxip"))
       (patches (search-patches "inria/patches/siconos-cmake-ixx.patch"))))))

(define-public siconos-mpi-4.4-rc2
  (package
    (inherit siconos-mpi-4.3)
    (version "4.4.0.rc2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/siconos/siconos/archive/"
             version ".tar.gz"))
       (sha256 (base32
                "18z8bcl2b4l2iaw9f3hgafxsid8kyn5vdm07fl53whl3jac4xaca"))))))


(define-public siconos-mpi-4.4-rc3
  (package
    (inherit siconos-mpi-4.4-rc2)
    (version "4.4.0.rc3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/siconos/siconos/archive/"
             version ".tar.gz"))
       (sha256 (base32
                "148fwppjj7rdiqrgapbm9rg4k60d8xm9q4fc3757fp236nv8bxip"))))))

(define-public siconos-4.5.x
  (package
   (inherit siconos-4.4-rc3)
   (version "4.5.x")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/siconos/siconos/")
           (commit "bee4d6bd5ec744c4467c52ca8c824fb948cdbff7")))
     (sha256 (base32
              "0yb8nqmjhhn2za2qw4709lmd016038xg0mmkwz2nvnlar6pgfhk3"))))
   (native-inputs
    `(("python-wheel", python-wheel)
      ("python-pip", python-pip)
      ("cc" ,gcc) ,@(alist-delete "gcc" (package-native-inputs siconos-4.4-rc3))))
   (propagated-inputs
    `(("vtk", vtk)
      ("python-pyhull", python-pyhull)
      ,@(package-propagated-inputs siconos-4.4-rc3)))
   (arguments
    (substitute-keyword-arguments
     (package-arguments siconos-4.4-rc3)
     ((#:configure-flags flags)
      `(cons "-DFCLIB_ROOT=1"
             (cons (string-append "-DISOLATED_INSTALL=" (assoc-ref %outputs "out"))
                   (cons "-DCOMPONENTS=externals;numerics;kernel;control;mechanics;io"
                         (delete "-DCOMPONENTS=externals;numerics;kernel;control;mechanics;io;mechanisms"
                                 ,flags)))))
     ((#:phases phases)
      `(modify-phases
        ,phases
        (delete 'patch-mechanisms)
        (add-after 'check 'set-SOURCE-DATE-EPOCH
           (lambda _
             (setenv "SOURCE_DATE_EPOCH" "315532800")
             #t))
        (add-after 'unpack 'some-quick-patches
                   (lambda _
                     (substitute* "externals/numeric_bindings/boost/numeric/bindings/blas/detail/cblas.h"
                                  (("#ifdef HAS_OpenBLAS") "#ifdef REMOVED_HAS_OpenBLAS"))
                     (substitute* "cmake/SiconosSetup.cmake"
                                  (("FATAL_ERROR") "WARNING"))
                     (substitute* "cmake/fclib_setup.cmake"
                                  (("find_package\\(FCLIB 3.0.0 CONFIG REQUIRED\\)")
                                   "find_package(FCLIB 3.0.0 CONFIG REQUIRED)
    set(ConfigPackageLocation lib/cmake/siconos-${SICONOS_VERSION})"))
                     #t))))))))

(define-public siconos siconos-4.4-rc3)

(define-public siconos-mpi siconos-mpi-4.4-rc3)

(define-public siconos-bullet-single-precision
  (package
    (inherit siconos)
    (name "siconos-bullet-single-precision")
    (propagated-inputs
     `(("bullet" ,bullet-single-precision)
       ,@(package-propagated-inputs siconos)))
    (arguments
     (substitute-keyword-arguments (package-arguments siconos)
       ((#:configure-flags flags)
        `(cons "-DBULLET_USE_DOUBLE_PRECISION=OFF"
               (delete "-DBULLET_USE_DOUBLE_PRECISION=ON" ,flags)))))))


;;;;;;; needed packages
(define-public lmgc90
  (package
   (name "lmgc90")
   (version "2019.rc1")
   (source
    (origin
     (method url-fetch)
     (uri "https://seafile.lmgc.univ-montp2.fr/f/7ea37ca5a7ec469f9373/?dl=1")
     (sha256
      (base32
       "111g568404svzkq6ldnr2xxf7am2rmfaxvv11mwwxi5w5i1i6c8n"))))
   (build-system cmake-build-system)
   (native-inputs
    `(("fortran" ,gfortran)
      ("gcc" ,gcc)
      ("swig" ,swig)
      ("git" ,git)
      ("patchelf" ,patchelf)))
   (inputs
    `(("blas" ,openblas)
      ("python" ,python)
      ("gmsh" ,gmsh)
      ("mumps" ,mumps)
      ("siconos" ,siconos)
      ("numpy" ,python-numpy)))
   (arguments
     `(#:modules ((guix build cmake-build-system)
                  (guix build utils)
                  (ice-9 match)
                  (ice-9 popen)
                  (srfi srfi-1))
       #:imported-modules (,@%cmake-build-system-modules)
       #:build-type
       "Release"           ;Build without '-g' to save space.
       #:configure-flags
       '("-DWITH_SICONOS_NUMERICS=1")
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'fix-rpath
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (libdir (string-append out "/lib")))
               (install-file (string-append "lib/python"
                                            ,(version-major+minor
                                              (package-version python)) "/site-packages/pylmgc90/chipy/_lmgc90.so") libdir)))))))
   (home-page "https://git-xen.lmgc.univ-montp2.fr/lmgc90/lmgc90_user/wikis/home")
   (synopsis "LMGC90 is a free and open source software dedicated to
multiple physics simulation of discrete material and structures.")
   (description " The LMGC90 is a multipurpose software developed in
Montpellier, capable of modeling a collection of deformable or
undeformable particles of various shapes (spherical, polyhedral, or
non-convex) interacting trough simple interaction (friction,
cohesion...) or complex multiphysics coupling (fluid, thermal...)
")
   (license license:cecill)))


(define-public bullet-single-precision
  (package
    (inherit bullet)
    (name "bullet-single-precision")
    (arguments
     (substitute-keyword-arguments (package-arguments bullet)
       ((#:configure-flags flags)
        `(cons "-DUSE_DOUBLE_PRECISION=OFF"
               (delete "-DUSE_DOUBLE_PRECISION=ON" ,flags)))))))

(define-public bullet-double-precision
  (package
    (inherit bullet)
    (name "bullet-double-precision")
    (arguments
     (substitute-keyword-arguments (package-arguments bullet)
       ((#:configure-flags flags)
        `(cons "-DUSE_DOUBLE_PRECISION=ON"
               (delete "-DUSE_DOUBLE_PRECISION=OFF" ,flags)))))))


(define-public python-pyhull
  (package
    (name "python-pyhull")
    (version "2015.2.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "pyhull" version))
       (sha256
        (base32
         "091sph52c4yk1jlm5w8xidxpzbia9r7s42bnb23q4m4b56ihmzyj"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-numpy" ,python-numpy)))
    (home-page
     "https://github.com/materialsvirtuallab/pyhull")
    (synopsis
     "A Python wrapper to Qhull (http://www.qhull.org/) for the computation of the convex hull, Delaunay triangulation and Voronoi diagram")
    (description
     "A Python wrapper to Qhull (http://www.qhull.org/) for the computation of the convex hull, Delaunay triangulation and Voronoi diagram")
    (license license:expat)))


(define-public boost-1.68.0
  (package
    (name "boost")
    (version "1.68.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "mirror://sourceforge/boost/boost/" version "/boost_"
                    (string-map (lambda (x) (if (eq? x #\.) #\_ x)) version)
                    ".tar.bz2"))
              (sha256
               (base32
                "1dyqsr9yb01y0nnjdq9b8q5s2kvhxbayk34832k5cpzn7jy30qbz"))
              (patches (search-patches "inria/patches/boost-fix-icu-build.patch"))))
    (build-system gnu-build-system)
    (inputs `(("icu4c" ,icu4c)
              ("zlib" ,zlib)))
    (native-inputs
     `(("perl" ,perl)
       ("python" ,python-2)
       ("tcsh" ,tcsh)))
    (arguments
     `(#:tests? #f
       #:make-flags
       (list "threading=multi" "link=shared"

             ;; Set the RUNPATH to $libdir so that the libs find each other.
             (string-append "linkflags=-Wl,-rpath="
                            (assoc-ref %outputs "out") "/lib"))
       #:phases
       (modify-phases %standard-phases
         (delete 'bootstrap)
         (replace 'configure
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((icu (assoc-ref inputs "icu4c"))
                   (out (assoc-ref outputs "out")))
               (substitute* '("libs/config/configure"
                              "libs/spirit/classic/phoenix/test/runtest.sh"
                              "tools/build/src/engine/execunix.c"
                              "tools/build/src/engine/Jambase"
                              "tools/build/src/engine/jambase.c")
                 (("/bin/sh") (which "sh")))

               (setenv "SHELL" (which "sh"))
               (setenv "CONFIG_SHELL" (which "sh"))

               (invoke "./bootstrap.sh"
                       (string-append "--prefix=" out)
                       ;; Auto-detection looks for ICU only in traditional
                       ;; install locations.
                       (string-append "--with-icu=" icu)
                       "--with-toolset=gcc"))))
         (replace 'build
           (lambda* (#:key make-flags #:allow-other-keys)
             (apply invoke "./b2"
                    (format #f "-j~a" (parallel-job-count))
                    make-flags)))
         (replace 'install
           (lambda* (#:key make-flags #:allow-other-keys)
             (apply invoke "./b2" "install" make-flags)))
         (add-after 'install 'provide-libboost_python
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               ;; Boost can build support for both Python 2 and Python 3 since
               ;; version 1.67.0, and suffixes each library with the Python
               ;; version.  Many consumers only check for libboost_python
               ;; however, so we provide it here as suggested in
               ;; <https://github.com/boostorg/python/issues/203>.
               (with-directory-excursion (string-append out "/lib")
                 (symlink "libboost_python27.so" "libboost_python.so"))
               #t))))))

    (home-page "https://www.boost.org")
    (synopsis "Peer-reviewed portable C++ source libraries")
    (description
     "A collection of libraries intended to be widely useful, and usable
across a broad spectrum of applications.")
    (license (license:x11-style "https://www.boost.org/LICENSE_1_0.txt"
                                "Some components have other similar licences."))))


; vtk with python support
(define-public python-vtk-8-2.0
  (package
    (name "python-vtk")
    (version "8.2.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://vtk.org/files/release/"
                                  (version-major+minor version)
                                  "/VTK-" version ".tar.gz"))
              (sha256
               (base32
                "1fspgp8k0myr6p2a6wkc21ldcswb4bvmb484m12mxgk1a9vxrhrl"))
              (patches
               (search-patches "inria/patches/vtk-8.2.0-fix-freetypetools-build-failure.patch"
                                "inria/patches/0001-Compatibility-for-Python-3.8.patch"))))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"           ;Build without '-g' to save space.
       ;; -DVTK_USE_SYSTEM_NETCDF:BOOL=TRUE requires netcdf_cxx
       #:configure-flags '("-DVTK_USE_SYSTEM_EXPAT:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_FREETYPE:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_HDF5:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_JPEG:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_JSONCPP:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_LIBXML2:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_OGGTHEORA:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_PNG:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_TIFF:BOOL=TRUE"
                           "-DVTK_USE_SYSTEM_ZLIB:BOOL=TRUE"
                           "-DVTK_WRAP_PYTHON=ON"
                           "-DVTK_PYTHON_VERSION:STRING=3"
	                   "-DPython_ADDITIONAL_VERSIONS=3.8")
       #:tests? #f))                              ;XXX: no "test" target
    (inputs
     `(("libXt" ,libxt)
       ("xorgproto" ,xorgproto)
       ("libX11" ,libx11)
       ("libxml2" ,libxml2)
       ("mesa" ,mesa)
       ("glu" ,glu)
       ("expat" ,expat)
       ("freetype" ,freetype)
       ("hdf5" ,hdf5)
       ("jpeg" ,libjpeg-turbo)
       ("jsoncpp" ,jsoncpp)
       ("libogg" ,libogg)
       ("libtheora" ,libtheora)
       ("png" ,libpng)
       ("python" ,python)
       ("tiff" ,libtiff)
       ("zlib" ,zlib)))
    (home-page "https://vtk.org/")
    (synopsis "Libraries for 3D computer graphics")
    (description
     "The Visualization Toolkit (VTK) is a C++ library for 3D computer graphics,
image processing and visualization.  It supports a wide variety of
visualization algorithms including: scalar, vector, tensor, texture, and
volumetric methods; and advanced modeling techniques such as: implicit
modeling, polygon reduction, mesh smoothing, cutting, contouring, and Delaunay
triangulation.  VTK has an extensive information visualization framework, has
a suite of 3D interaction widgets, supports parallel processing, and
integrates with various databases on GUI toolkits such as Qt and Tk.")
    (license license:bsd-3)))

(define-public swig-3.0.12
  (package
    (name "swig")
    (version "3.0.12")
    (source (origin
             (method url-fetch)
             (uri (string-append "mirror://sourceforge/" name "/" name "/"
                                 name "-" version "/"
                                 name "-" version ".tar.gz"))
             (patches (search-patches "inria/patches/swig-guile-gc.patch"))
             (sha256
              (base32
               "0kf99ygrjs5616gsqhz1l7bib3a12izmxi7g48bwblbymr3z9ybw"))))
    (build-system gnu-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'set-env
           ;; Required since Perl 5.26.0's removal of the current
           ;; working directory from @INC.
           ;; TODO Try removing this for later versions of SWIG.
           (lambda _ (setenv "PERL_USE_UNSAFE_INC" "1") #t))
         (add-before 'configure 'workaround-gcc-bug
           (lambda _
             ;; XXX: Don't add the -isystem flag, or GCCs #include_next
             ;; won't be able to find <stdlib.h>.
             (substitute* "configure"
               (("-isystem ") "-I"))
             #t)))))
    (native-inputs `(("boost" ,boost)
                     ("pcre" ,pcre "bin")))       ;for 'pcre-config'
    (inputs `(;; Provide these to run the corresponding tests.
              ("guile" ,guile-2.0)
              ("perl" ,perl)))
              ;; FIXME: reactivate input python as soon as the test failures
              ;;   fatal error: Python.h: No such file or directory
              ;;   # include <Python.h>
              ;; are fixed.
              ;; The python part probably never worked and does not seem to
              ;; be needed for currently dependent packages.
;;               ("python" ,python-wrapper)))
    (home-page "http://swig.org/")
    (synopsis
     "Interface compiler that connects C/C++ code to higher-level languages")
    (description
     "SWIG is an interface compiler that connects programs written in C and
C++ with languages such as Perl, Python, Ruby, Scheme, and Tcl.  It works by
taking the declarations found in C/C++ header files and using them to generate
the wrapper code that scripting languages need to access the underlying C/C++
code.  In addition, SWIG provides a variety of customization features that let
you tailor the wrapping process to suit your application.")

    ;; See http://www.swig.org/Release/LICENSE for details.
    (license license:gpl3+)))

; from guix 1.0.2
(define-public opencascade-oce
  (package
    (name "opencascade-oce")
    (version "0.17.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/tpaviot/oce")
              (commit (string-append "OCE-" version))))
        (file-name (git-file-name name version))
        (patches (search-patches "inria/patches/opencascade-oce-glibc-2.26.patch"))
        (sha256
          (base32 "0rg5wzkvfmzfl6v2amyryb8dnjad0nn9kyr607wy2gch6rciah69"))))
    (build-system cmake-build-system)
    (arguments
     '(#:configure-flags
        (list "-DOCE_TESTING:BOOL=ON"
              "-DOCE_USE_TCL_TEST_FRAMEWORK:BOOL=ON"
              "-DOCE_DRAW:BOOL=ON"
              (string-append "-DOCE_INSTALL_PREFIX:PATH="
                        (assoc-ref %outputs "out"))
              "-UCMAKE_INSTALL_RPATH")))
    (inputs
      `(("freetype" ,freetype)
        ("glu" ,glu)
        ("libxmu" ,libxmu)
        ("mesa" ,mesa)
        ("tcl" ,tcl)
        ("tk" ,tk)))
    (native-inputs
      `(("python" ,python-wrapper)))
    (home-page "https://github.com/tpaviot/oce")
    (synopsis "Libraries for 3D modeling and numerical simulation")
    (description
     "Open CASCADE is a set of libraries for the development of applications
dealing with 3D CAD data or requiring industrial 3D capabilities.  It includes
C++ class libraries providing services for 3D surface and solid modeling, CAD
data exchange, and visualization.  It is used for development of specialized
software dealing with 3D models in design (CAD), manufacturing (CAM),
numerical simulation (CAE), measurement equipment (CMM), and quality
control (CAQ) domains.

This is the ``Community Edition'' (OCE) of Open CASCADE, which gathers
patches, improvements, and experiments contributed by users over the official
Open CASCADE library.")
    (license (list license:lgpl2.1; OCE libraries, with an exception for the
                                  ; use of header files; see
                                  ; OCCT_LGPL_EXCEPTION.txt
                   license:public-domain; files
                                  ; src/Standard/Standard_StdAllocator.hxx and
                                  ; src/NCollection/NCollection_StdAllocator.hxx
                   license:expat; file src/OpenGl/OpenGl_glext.h
                   license:bsd-3)))); test framework gtest

(define-public pythonocc
  (package
    (name "pythonocc")
    (version "0.17.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/tpaviot/pythonocc-core/archive/" version ".tar.gz"))
       (sha256
        (base32
         "0fk617nlfh3c79wladgdl7jvbjs1dfqwncjalc456qlkb8ix8xci"))
       (patches
        (search-patches
         "inria/patches/pythonocc-install.patch"))))
    (native-inputs
     `(("cmake" ,cmake)
       ("make" ,gnu-make)
       ("swig" ,swig)
       ("gcc" ,gcc)))
    (inputs
     `(("python" ,python)
       ("freetype" ,freetype)
       ("mesa" ,mesa)
       ("glu" ,glu)
       ("opencascade-oce" ,opencascade-oce)))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"           ;Build without '-g' to save space.
                    #:configure-flags
                    '()
                    #:tests? #f))
    (home-page "http://www.pythonocc.org/")
    (synopsis "3D CAD for python")
    (description
     "pythonOCC is a 3D CAD/PLM development library for the Python
programming language. It provides 3D hybrid modeling, data
exchange (support for the STEP/IGES file format), GUI management
support (wxPython, PyQt, python-xlib), parametric modeling, and
advanced meshing features. pythonOCC is built upon the OpenCASCADE 3D
modeling kernel and the salomegeom and salomesmesh packages. Some high
level packages (for parametric modeling, topology, data exchange,
webservices, etc.) extend the builtin features of those libraries to
enable highly dynamic and modular programming of any CAD application.")
    (license license:lgpl3)))

;; needed for siconos@4.2
(define-public python-h5py-2
  (package
    (name "python-h5py")
    (version "2.10.0")
    (source
     (origin
      (method url-fetch)
      (uri (pypi-uri "h5py" version))
      (sha256
       (base32
        "0baipzv8n93m0dq0riyi8rfhzrjrfrfh8zqhszzp1j2xjac2fhc4"))))
    (build-system python-build-system)
    (arguments
     `(#:tests? #f ; no test target
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-hdf5-paths
          (lambda* (#:key inputs #:allow-other-keys)
            (let ((prefix (assoc-ref inputs "hdf5")))
              (substitute* "setup_build.py"
                (("\\['/opt/local/lib', '/usr/local/lib'\\]")
                 (string-append "['" prefix "/lib" "']"))
                (("'/opt/local/include', '/usr/local/include'")
                 (string-append "'" prefix "/include" "'")))
              (substitute* "setup_configure.py"
                (("\\['/usr/local/lib', '/opt/local/lib'\\]")
                 (string-append "['" prefix "/lib" "']")))
              #t))))))
    (propagated-inputs
     `(("python-six" ,python-six)
       ("python-numpy" ,python-numpy)))
    (inputs
     `(("hdf5" ,hdf5-1.10)))
    (native-inputs
     `(("python-cython" ,python-cython)
       ("python-pkgconfig" ,python-pkgconfig)
       ("pkg-config" ,pkg-config)))
    (home-page "https://www.h5py.org/")
    (synopsis "Read and write HDF5 files from Python")
    (description
     "The h5py package provides both a high- and low-level interface to the
HDF5 library from Python.  The low-level interface is intended to be a
complete wrapping of the HDF5 API, while the high-level component supports
access to HDF5 files, datasets and groups using established Python and NumPy
concepts.")
    (license license:bsd-3)))


(define-public pythonocc-core
  (package
    (name "pythonocc-core")
    (version "7.6.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/tpaviot/pythonocc-core/archive/refs/tags/" version ".tar.gz"))
       (sha256
        (base32
         "0j5q341wdr21wy0s1vpzl59w6yhnr1y1zaql6gy7w0k2nb9xmcc4"))))
    (native-inputs
     `(("cmake" ,cmake)
       ("make" ,gnu-make)
       ("swig" ,swig)
       ("gcc" ,gcc)))
    (inputs
     `(("python" ,python)
       ("rapidjson" ,rapidjson)
       ("fontconfig" ,fontconfig)
       ("freetype" ,freetype)
       ("mesa" ,mesa)
       ("glu" ,glu)
       ("opencascade-occt" ,opencascade-occt)))
    (build-system cmake-build-system)
    (arguments
     '(#:build-type "Release"           ;Build without '-g' to save space.
                    #:configure-flags
                    `(,(string-append "-DPYTHONOCC_INSTALL_DIRECTORY="
                                      (assoc-ref %outputs "out")))
                    #:tests? #f))
    (home-page "http://www.pythonocc.org/")
    (synopsis "3D CAD for python")
    (description
     "pythonOCC is a 3D CAD/PLM development library for the Python
programming language. It provides 3D hybrid modeling, data
exchange (support for the STEP/IGES file format), GUI management
support (wxPython, PyQt, python-xlib), parametric modeling, and
advanced meshing features. pythonOCC is built upon the OpenCASCADE 3D
modeling kernel and the salomegeom and salomesmesh packages. Some high
level packages (for parametric modeling, topology, data exchange,
webservices, etc.) extend the builtin features of those libraries to
enable highly dynamic and modular programming of any CAD application.")
    (license license:lgpl3)))


