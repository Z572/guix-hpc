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
