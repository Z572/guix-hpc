;;; Copyright © 2023 Advanced Micro Devices, Inc.
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

(define-module (amd rocm-tools)
    #:use-module (guix packages)
    #:use-module (guix build-system cmake)
    #:use-module (guix git-download)
    #:use-module (guix licenses)

    #:use-module (gnu packages base)
    #:use-module (gnu packages linux)
    #:use-module (gnu packages python)

    #:use-module (amd rocm-base)
)


; rocminfo
(define %rocminfo-hashes
    `(
        ("5.7.1" . ,(base32 "1a6viq9i7hcjn7xfyswzg7ivb5sp577097fiplzf7znkl3dahcsk"))
        ("5.6.1" . ,(base32 "150bvyxp9krq8f7jqd1g5b4l85rih4ch322y4sg1hnciqpabn6a6"))
        ("5.5.1" . ,(base32 "150bvyxp9krq8f7jqd1g5b4l85rih4ch322y4sg1hnciqpabn6a6"))
        ("5.4.4" . ,(base32 "1i8p1w8f2wqdc2b9sq8j0xkdd1mbasn65bny24qnz00rj2dm61p3"))
        ("5.3.3" . ,(base32 "1i8p1w8f2wqdc2b9sq8j0xkdd1mbasn65bny24qnz00rj2dm61p3"))
    )
)

(define (rocminfo-origin version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/RadeonOpenCompute/rocminfo.git")
                (commit (string-append "rocm-" version))))
        (file-name (git-file-name "rocminfo" version))
        (sha256 (assoc-ref %rocminfo-hashes version))))

(define (make-rocminfo rocr-runtime)
    (package
        (name "rocminfo")
        (version (package-version rocr-runtime))
        (source (rocminfo-origin version))
        (build-system cmake-build-system)
        (arguments `(#:build-type "Release" #:tests? #f))
        (inputs (list rocr-runtime python))
        (propagated-inputs (list grep kmod))
        (synopsis "ROCm application for reporting system info")
        (description "List @acronym{HSA,Heterogeneous System Architecture} Agents available to ROCm and show their properties.")
        (home-page "https://github.com/RadeonOpenCompute/rocminfo")
        (license ncsa)))

(define-public rocminfo-5.7 (make-rocminfo rocr-runtime-5.7))
(define-public rocminfo-5.6 (make-rocminfo rocr-runtime-5.6))
(define-public rocminfo-5.5 (make-rocminfo rocr-runtime-5.5))
(define-public rocminfo-5.4 (make-rocminfo rocr-runtime-5.4))
(define-public rocminfo-5.3 (make-rocminfo rocr-runtime-5.3))


; rocm-smi
(define %rocmsmi-hashes
    `(
        ("5.7.1" . ,(base32 "0d9cacap0k8k7hmlfbpnrqbrj86pmxk3w1fl8ijglm8a3267i51m"))
        ("5.6.1" . ,(base32 "0jxd74y4lgar0jy2y3kqbs872f23cdfj9yrfgjz9hmrp903c9hql"))
        ("5.5.1" . ,(base32 "19qxgdc757f4qbkkggkwk8rs3c1jv8d8jgyhsg228s8w6gcr80ga"))
        ("5.4.4" . ,(base32 "14f898i9xrbc5nvrpk9zkhjq6hwn0av13gbphq3a6lsd6f49sj4y"))
        ("5.3.3" . ,(base32 "0x76gy8kzp4h6x9ssgrbswqpxajxlrps04kvpxh0z1dggn89pcai"))
    )
)

(define (rocmsmi-origin version)
    (origin
        (method git-fetch)
        (uri (git-reference
                (url "https://github.com/RadeonOpenCompute/rocm_smi_lib.git")
                (commit (string-append "rocm-" version))))
        (file-name (git-file-name "rocm-smi" version))
        (sha256 (assoc-ref %rocmsmi-hashes version))))

(define (make-rocm-smi version)
    (package
        (name "rocm-smi")
        (version version)
        (source (rocmsmi-origin version))
        (build-system cmake-build-system)
        (arguments `(#:build-type "Release" #:tests? #f)) ; No tests.
        (inputs (list python))
        (propagated-inputs (list grep coreutils))
        (synopsis "The ROCm System Management Interface (ROCm SMI) Library")
        (description "The ROCm System Management Interface Library, or ROCm SMI library, 
is part of the Radeon Open Compute ROCm software stack. It is a C library for Linux that 
provides a user space interface for applications to monitor and control GPU applications.")
        (home-page "https://github.com/RadeonOpenCompute/rocm_smi_lib.git")
        (license ncsa)))

(define-public rocm-smi-5.7 (make-rocm-smi "5.7.1"))
(define-public rocm-smi-5.6 (make-rocm-smi "5.6.1"))
(define-public rocm-smi-5.5 (make-rocm-smi "5.5.1"))
(define-public rocm-smi-5.4 (make-rocm-smi "5.4.4"))
(define-public rocm-smi-5.3 (make-rocm-smi "5.3.3"))
