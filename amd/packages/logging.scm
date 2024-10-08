;;; Copyright © 2024 Advanced Micro Devices, Inc.
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (amd packages logging)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages logging))

;; This package is needed only for the rocprofiler-register library.
;; Don't export its symbol publicly for now (consider upstreaming instead!)
(define-public glog-0.7
  (package
    (inherit glog)
    (name "glog")
    (version "0.7.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/google/glog.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1zh482ga8mndsw277h9wrq4i5xffji0li3v0xha1i6j1llzicz7s"))))
    (arguments
     (list
      ;; Tests pass but package fails to install.
      ;; Fails in phase 'install-license-files'. Disabling for now.
      #:tests? #f))
    (properties `((hidden? . #t) ,@(package-properties glog)))))
