;;; This module extends GNU Guix and is licensed under the same terms, those
;;; of the GNU GPL version 3 or (at your option) any later version.
;;;
;;; Copyright © 2023 Inria

(define-module (inria medinria)
  #:use-module (guix)
  #:use-module (guix git-download)
  #:use-module (gnu packages image-processing)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (gnu packages)
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
  #:use-module (gnu packages image-processing))

(define-public vtk-8
  (package
    (inherit vtk)
    (name "vtk")
    (version "8.1.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/Kitware/VTK.git")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (patches
               (search-patches "inria/patches/removeprobe.patch"
                               "inria/patches/qpainterpath.patch"))
              (sha256
               (base32
                "0rj106p41rkn06dw9xp901qaaxkbqn3braqybypad4q07sqmxm0k"))))
    (arguments
     (list #:build-type "Release"          ;Build without '-g' to save space.
           #:configure-flags
           #~'( "-DBUILD_TESTING:BOOL=FALSE"
                "-DVTK_FORBID_DOWNLOADS=OFF"
                "-DBUILD_TESTING=OFF"
                "-DBUILD_SHARED_LIBS=ON"
                "-DBUILD_EXAMPLES=OFF"
                "-DCMAKE_C_FLAGS:STRING= -w"
                "-DCMAKE_CXX_FLAGS:STRING= -w"
                "-DVTK_WRAP_PYTHON=OFF"
                "-DBUILD_DOCUMENTATION=OFF"
                "-DVTK_RENDERING_BACKEND=OpenGL2"
                "-DVTK_Group_Qt=ON"
                "-DModule_vtkGUISupportQtOpenGL=ON"
                "-DModule_vtkRenderingExternal:BOOL=OFF"
                "-DVTK_QT_VERSION=5"
                "-DModule_vtkRenderingOSPRay:BOOL=OFF"
                "-DModule_vtkRenderingQt:INTERNAL=OFF"
                "-DModule_vtkRenderingQt-ADVANCED:INTERNAL=1"
                "-DModule_vtkRenderingQt-ADVANCED=OFF"
                "-DVTK_USE_OGGTHEORA_ENCODER:BOOL=ON")

           #:tests? #f))                         ;XXX: test data not included
    (inputs (modify-inputs (package-inputs vtk)
              (append qtbase-5
                      qttools-5
                      qtx11extras)))))

(define-public insight-toolkit-without-test
  (package
    (inherit insight-toolkit)
    (arguments
     (list #:configure-flags #~'("-DITK_USE_GPU=ON"
                                 "-DITK_USE_SYSTEM_LIBRARIES=ON"
                                 "-DITK_USE_SYSTEM_GOOGLETEST=OFF"
                                 "-DITK_BUILD_SHARED=ON"
                                 "-DBUILD_EXAMPLES:BOOL=OFF"
                                 "-DBUILD_TESTING:BOOL=OFF"
                                 "-DModule_ITKIOPhilipsREC:BOOL=ON"
                                 "-DModule_ITKReview:BOOL=ON"
                                 "-DModule_ITKVtkGlue:BOOL=ON"
                                 "-DITK_LEGACY_REMOVE:BOOL=ON"
                                 "-DCMAKE_CXX_STANDARD=17")
           #:tests? #f))
    (inputs (modify-inputs (package-inputs insight-toolkit)
              (append vtk-8)))))
