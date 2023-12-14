;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (inria medinria)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (gnu packages image-processing)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (gnu packages)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages check)
  #:use-module (gnu packages python)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages image)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages tbb)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages image-processing)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages bioinformatics)
  #:use-module (inria dtk))

(define-public vtk-8
  (package
    (inherit vtk)
    (name "vtk")
    (version "8.1.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Kitware/VTK.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (patches (search-patches "inria/patches/qpainterpath.patch"))
       (sha256
        (base32 "0rj106p41rkn06dw9xp901qaaxkbqn3braqybypad4q07sqmxm0k"))))
    (arguments
     (list
      #:build-type "Release" ;Build without '-g' to save space.
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'add-header
                     (lambda _
                       (install-file "IO/Legacy/vtkLegacyReaderVersion.h"
                                     (string-append #$output
                                                    "/include/vtk-8.1")))))
      #:configure-flags #~'("-DBUILD_TESTING:BOOL=FALSE"
                            "-DVTK_FORBID_DOWNLOADS=OFF"
                            "-DBUILD_TESTING=OFF"
                            "-DBUILD_SHARED_LIBS=ON"
                            "-DBUILD_EXAMPLES=OFF"
                            "-DCMAKE_C_FLAGS:STRING= -w"
                            "-DCMAKE_CXX_FLAGS:STRING= -w"
                            "-DCOMPILER_HAS_HIDDEN_VISIBILITY:INTERNAL=1"
                            "-DVTK_WRAP_PYTHON=OFF"
                            "-DBUILD_DOCUMENTATION=OFF"
                            "-DVTK_RENDERING_BACKEND=OpenGL2"
                            "-DVTK_Group_Qt:BOOL=ON"
                            "-DVTK_Group_StandAlone:BOOL=ON"
                            "-DVTK_Group_Rendering:BOOL=ON"
                            "-DVTK_USE_X:BOOL=ON"
                            "-DModule_vtkGUISupportQtOpenGL:BOOL=ON"
                            "-DModule_vtkRenderingExternal:BOOL=OFF"
                            "-DVTK_QT_VERSION=5"
                            "-DModule_vtkRenderingOSPRay:BOOL=OFF"
                            "-DVTK_USE_OGGTHEORA_ENCODER:BOOL=ON")

      #:tests? #f)) ;XXX: test data not included
    (inputs (modify-inputs (package-inputs vtk)
              (append qtbase-5 qttools-5 qtx11extras)))))

(define-public insight-toolkit-5.1.1
  (package
    (inherit insight-toolkit)
    (version "5.1.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/InsightSoftwareConsortium/ITK/"
             "releases/download/v"
             version
             "/InsightToolkit-"
             version
             ".tar.gz"))
       (patches (search-patches "inria/patches/itkgdcmlimits.patch"))
       (sha256
        (base32 "13mmxm6m3xzqz32bbd7zh933ff5y3fr3b2l752vn2hq580wadqir"))))
    (arguments
     (list
      #:configure-flags #~'("-DITK_BUILD_DEFAULT_MODULES=ON"
                            "-DBUILD_SHARED_LIBS=ON"
                            "-DModule_ITKIOPhilipsREC=ON"
                            "-DModule_ITKReview=ON" "-DModule_ITKVtkGlue=ON"
                            "-DITK_LEGACY_REMOVE=ON")

      #:tests? #f))
    (inputs (modify-inputs (package-inputs insight-toolkit)
              (append vtk-8)))))

(define-public dcmtk-medinria-config
  (package
    (inherit dcmtk)
    (name "dcmtk-medinria")
    (arguments
     (list
      #:configure-flags #~'("-DBUILD_SHARED_LIBS:BOOL=ON"
                            "  -DDCMTK_WITH_ICU:BOOL=ON "
                            "  -DDCMTK_ENABLE_STL:BOOL=ON"
                            "  -DDCMTK_ENABLE_BUILTIN_DICTIONARY:BOOL=ON"
                            "  -DDCMTK_ENABLE_PRIVATE_TAGS:BOOL=ON")))))

(define-public ttk
  (package
    (name "ttk")
    (version "4.0")
    (synopsis "TTK")
    (description "TTK")
    (home-page "https://github.com/medInria/TTK")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1qlr2y0s9aplaacf19gdvlr1097l2maw7mivccykl9nb4c6yhvaz"))))
    (inputs (list vtk-8
                  insight-toolkit-5.1.1
                  hdf5-1.8
                  zlib
                  libdrm
                  mesa))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:build-type "Debug"
      #:configure-flags #~'("-DBUILD_SHARED_LIBS=ON" "-DTTK_USE_ACML=OFF"
                            "-DTTK_USE_GMM=OFF" "-DTTK_USE_MIPS=OFF"
                            "-DTTK_USE_MKL=OFF" "-DTTK_USE_VTKINRIA3D=OFF")))
    (license gpl3)))

(define-public qtdcm
  (package
    (name "qtdcm")
    (version "4.0")
    (synopsis "QtDcm")
    (description "QtDcm")
    (home-page "https://github.com/medInria/qtdcm")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dagl5p50ycy13yk11iykbpsmwgcxvkxqkg67sv20d53zfmz3lrd"))))
    (inputs (list insight-toolkit-5.1.1
                  dcmtk-medinria-config
                  qtbase-5
                  qttools-5
                  qtx11extras
                  zlib))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:build-type "Release"
      #:configure-flags #~'("-DDCMTK_FIND_PACKAGE_USE_CONFIG_ONLY=ON")))
    (license gpl3)))

(define-public rpi
  (package
    (name "rpi")
    (version "4.0")
    (synopsis "RPI")
    (description "RPI")
    (home-page "https://github.com/medInria/RPI")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))

       (sha256
        (base32 "1wfd0i693nw95vycdpnghz2d7ypj4qrn7vcs8f70vjzq6qjyjlpg"))))
    (inputs (list insight-toolkit-5.1.1 libdrm mesa))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:build-type "Release"
      #:configure-flags #~'("-DBUILD_ConvertLinearToDF=OFF"
                            "-DBUILD_ConvertLinearToSVF=OFF"
                            "-DBUILD_FuseTransformations=OFF"
                            "-DBUILD_ResampleImage=OFF"
                            "-DBUILD_RegistrationAddOn=OFF"
                            "-DCMAKE_CXX_STANDARD=17")))
    (license gpl3)))

(define-public medinria
  (package
    (name "medinria")
    (version "de16bedcf10f5712606cd4a6745800e21b38374e")
    (synopsis
     "medInria is a multi-platform medical image processing and visualization software.")
    (description
     "medInria is a multi-platform medical image processing and visualization software. It is free and open-source. Through an intuitive user interface, medInria offers from standard to cutting-edge processing functionalities for your medical images such as 2D/3D/4D image visualization, image registration, diffusion MR processing and tractography.")
    (home-page "https://med.inria.fr/")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/medInria/medInria-public")
             (commit version)))
       (patches (search-patches
                 "inria/patches/medinria-fix-qtdcm-include.patch"))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dzzpnja30di39213pv8yqs5hnm5s8x9mpqqzx8nclbncd67l8bn"))))
    (inputs (list dtk
                  dcmtk-medinria-config
                  qtdcm
                  insight-toolkit-5.1.1
                  vtk-8
                  qtbase-5
                  qttools-5
                  qtx11extras
                  qtdeclarative-5
                  qtsvg-5
                  rpi
                  ttk
                  boost))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:build-type "Release"
      #:phases #~(modify-phases %standard-phases
                   (add-before 'configure 'change-directory
                     (lambda _
                       (chdir "src"))))
      #:configure-flags #~(list "-DACTIVATE_WALL_OPTION:BOOL=OFF"
                           "-DBUILD_SHARED_LIBS:BOOL=ON"
                           "-DBUILD_ALL_PLUGINS:BOOL=OFF"
                           "-DBUILD_COMPOSITEDATASET_PLUGIN:BOOL=OFF"
                           "-DBUILD_EXAMPLE_PLUGINS:BOOL=OFF"
                           "-DUSE_DTKIMAGING:BOOL=OFF"
                           "-DUSE_OSPRay:BOOL=OFF"
                           "-DCMAKE_CXX_STANDARD=17"
                           "-DCMAKE_C_FLAGS= -Wall"
                           "-DCMAKE_C_FLAGS_RELEASE= -O3 -DNDEBUG"
                           "-DCMAKE_CXX_FLAGS_RELEASE= -O3 -DNDEBUG"
                           "-DCMAKE_CXX_FLAGS:STRING= -Wall -Wno-unknown-pragmas -fpermissive")))
    (license gpl3)))

