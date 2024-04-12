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

(define-module (amd packages rocm-origin)
    #:use-module (guix packages)
    #:use-module (guix gexp)
    #:use-module (guix git-download)
    #:use-module (guix download)
    #:use-module (guix utils)

    #:use-module (gnu packages)

    #:export (rocm-origin)
)

(define rocm-hashes
    `(
        ; llvm-project
        (("llvm-project" "5.7.1") . ,(base32 "1bwqrsvl2gdygp8lqz25xifhmrqwmwjhjhdnc51dr7lc72f4ksfk"))
        (("llvm-project" "5.6.1") . ,(base32 "080pmr2f7hmnpgixikwrrj8pb67b2mw5c5s5649ik2rl8dyjnmmi"))
        (("llvm-project" "5.5.1") . ,(base32 "0g4w7grbl3qf96biflamhgf0f1hvzxnd747cc0kjzpqa1bfcfrhl"))
        (("llvm-project" "5.4.4") . ,(base32 "1q3jlnmyrrj5mhyx33xpnfdbi8ikw8r28rnq0fhxc5j307lw4fq4"))
        (("llvm-project" "5.3.3") . ,(base32 "06r4zrgjsaifnjc7lsp18nwkg6xvalfrlxmn0r7ixghnrhvkpai0"))
        ; rocm-device-libs
        (("rocm-device-libs" "5.7.1") . ,(base32 "1xc4g5qb8x5hgnvrpzxqxqbsdnwaff1r12aqb8a84mmj5bznq701"))
        (("rocm-device-libs" "5.6.1") . ,(base32 "1jg96ycy99s9fis8sk1b7qx5p33anw16mqlm07zqbnhry2gqkcbh"))
        (("rocm-device-libs" "5.5.1") . ,(base32 "0apwrwa8av5ylf318blwid4xgz6j6bgdpc4frgzwd8vsjwzwkmm8"))
        (("rocm-device-libs" "5.4.4") . ,(base32 "069nc6yg5scp9r0mj8ckb7a5mg74dsavb2ls6fqi75c65n1ny37j"))
        (("rocm-device-libs" "5.3.3") . ,(base32 "15bcgwy5azmx7ldimhz5mdmbrmi4wzdfwdwmznj3g4793z81x8xc"))
        ; roct-thunk-interface
        (("roct-thunk-interface" "5.7.1") . ,(base32 "075advkplqlj9y3m3bsww4yiz3qxrfmxwhcf0giaa9dzrn9020wc"))
        (("roct-thunk-interface" "5.6.1") . ,(base32 "0v8j4gkbb21gqqmz1b4nmampx5ywva99ipsx8lcjr5ckcg84fn9x"))
        (("roct-thunk-interface" "5.5.1") . ,(base32 "1digw626k4m3kzcyi89kvba8j69xj4agqgi4avqsnkq5yf0vw9cz"))
        (("roct-thunk-interface" "5.4.4") . ,(base32 "0can34ccy2dm31m0wq9hhrxb8ykd6jj8bn3gfrlycmdklahnskhi"))
        (("roct-thunk-interface" "5.3.3") . ,(base32 "1adzhpa38lfsk0xj0m09fm11ird84vc594nspmhwqqmf3q3zrkkh"))
        ; rocr-runtime
        (("rocr-runtime" "5.7.1") . ,(base32 "02g53357i15d8laxlhvib7h01kfarlq8hyfm7rm3ii2wgrm23c0g"))
        (("rocr-runtime" "5.6.1") . ,(base32 "07wh7s1kgvpw8ydxmr2wvvn05fdqcmcc20qjbmnc3cbbhxviksyr"))
        (("rocr-runtime" "5.5.1") . ,(base32 "0zhqlbnkq2w0zqdqiqk4l2mksy618fl0zivkp2h6f5pjfnishpw9"))
        (("rocr-runtime" "5.4.4") . ,(base32 "09kpnfn5vpfcjh0amxbk1885hyib9jbisfmh2p9224cx156xfi16"))
        (("rocr-runtime" "5.3.3") . ,(base32 "18hf3abq6g7hyxlkfzd61a661j8lxgq42nkarrs2x5491ny3p8fv"))
        ; rocm-compilersupport
        (("rocm-compilersupport" "5.7.1") . ,(base32 "0p28jsbwjk19c4i6vwqkwgwpa4qkmqsgpyhhxsx3albnbz8wc7a0"))
        (("rocm-compilersupport" "5.6.1") . ,(base32 "15s2dx0pdvjv3xfccq5prkplcbwps8x9jas5qk93q7kv8wx57p3b"))
        (("rocm-compilersupport" "5.5.1") . ,(base32 "1xh09ljh3i28r3wwx44680jaq0dbyr9mmyad5ail4cmbnd4bwqjc"))
        (("rocm-compilersupport" "5.4.4") . ,(base32 "02vcbw5da8pkn8rxvaw0jdjcd6w2y2883z0b47jrx8lj6w2jpfx8"))
        (("rocm-compilersupport" "5.3.3") . ,(base32 "0s22jplls3sfgwp746qvbzyalhzcsgwz2xxdnzmcr6qnly38q31d"))
        ; hipcc
        (("hipcc" "5.7.1") . ,(base32 "0n5ra5biv2r5yjbzwf88vbfwc6cmswmqxfx8wn58kqambnfgm5cl"))
        (("hipcc" "5.6.1") . ,(base32 "1mrpgpvrya2vb21crar5rskdcvlrannv5mvnqgadw559yax4jm9f"))
        ; hip
        (("hip" "5.7.1") . ,(base32 "0p7w17mv14xrn1dg98mss43haa1k5qz1bnn9ap10l2wrvavy41nl"))
        (("hip" "5.6.1") . ,(base32 "0vkx3ncjz80xdyi37f80lb2mma4ygqs5rvkvidqqfvamc96v75j1"))
        (("hip" "5.5.1") . ,(base32 "0rm143x4c1h73rfcsa2ggyfg62g1y3x5az9n1jsxfbivqlmmxgs5"))
        (("hip" "5.4.4") . ,(base32 "192jg9bbiyrxq9qszhmvg5d1yszhqmh552qpkqhf0idkvdyp5lsn"))
        (("hip" "5.3.3") . ,(base32 "1lfr2niqa646bfm3y14377frcrxyfpbiygn20jfivlnk16pnyr4j"))
        ; hipamd (post rocm-5.5.X)
        (("clr" "5.7.1") . ,(base32 "1300wrbdjpswps8ds850rxy7yifcbwjfszys3x55fl2vy234j1nn"))
        (("clr" "5.6.1") . ,(base32 "1i1zj47x473qh94y27ly14cfhwqdc4qw54j02zl7l82dglvz65sx"))
        ; hipamd (pre rocm-5.6.X)
        (("hipamd" "5.5.1") . ,(base32 "0qqr89zlv3pny6b7b729p3k4z7wywhic2gypzdjqfld514j2r83c"))
        (("hipamd" "5.4.4") . ,(base32 "0lx02yg6adiqxvhrw7pkn0hl91g88fijgxbic65pmv0636bb5jqm"))
        (("hipamd" "5.3.3") . ,(base32 "07j709nf7z7r3q71gjh8xa17aw99n86735xdapxb9l4m7zz57f4b"))
        ; rocclr
        (("rocclr" "5.5.1") . ,(base32 "0r9z85kh64ax8jimihw0kf8h52kfdhz8b7zld7qm3p0ka17isk73"))
        (("rocclr" "5.4.4") . ,(base32 "0hg2s2za462xb8937ngsmgmifz1gg87zax80c7ga7j98py87pcqd"))
        (("rocclr" "5.3.3") . ,(base32 "10agrf2g1iaws97rczbyc9rcls7ds3kdyyg6fj87301zna9gsqkn"))
        ; rocm-opencl-runtime
        (("rocm-opencl-runtime" "5.5.1") . ,(base32 "0cxhi7pk9xsw6iggkw0fdl2vllpn51iyj1ac80zdifhqss3aba75"))
        (("rocm-opencl-runtime" "5.4.4") . ,(base32 "1hpvxbpxxn0l9cigp0j2fkyv8n61bznzikaj3yxvzr99z3yrhpqk"))
        (("rocm-opencl-runtime" "5.3.3") . ,(base32 "1bsdwgbn9gf9an70sc9zmk732s7qjayv527j6dsxgaszjvdhbw22"))
        ; rocm-cmake
        (("rocm-cmake" "5.7.1") . ,(base32 "0dfhqffgmrbcyxyri2qxpyfdyf8b75bprvnq77q2g281kswg6n39"))
        (("rocm-cmake" "5.6.1") . ,(base32 "183s2ksn142r7nl7l56qvyrgvvkdgqfdzmgkfpp4a6g9mjp88ady"))
        (("rocm-cmake" "5.5.1") . ,(base32 "1g89irfx3f1lmz4p2ys663kc524i6airmkc9n7l20l7l6xm446rv"))
        (("rocm-cmake" "5.4.4") . ,(base32 "0rhg2rs1nv66plfvfa389ga8v8g3z40ckbyysnasbpwr52md1ai5"))
        (("rocm-cmake" "5.3.3") . ,(base32 "1dwm7k22p9jwbax46nlsgd86s2s4c43qsa2wv2ldf7bbp94ggs80"))
        ; rocminfo
        (("rocminfo" "5.7.1") . ,(base32 "1a6viq9i7hcjn7xfyswzg7ivb5sp577097fiplzf7znkl3dahcsk"))
        (("rocminfo" "5.6.1") . ,(base32 "150bvyxp9krq8f7jqd1g5b4l85rih4ch322y4sg1hnciqpabn6a6"))
        (("rocminfo" "5.5.1") . ,(base32 "150bvyxp9krq8f7jqd1g5b4l85rih4ch322y4sg1hnciqpabn6a6"))
        (("rocminfo" "5.4.4") . ,(base32 "1i8p1w8f2wqdc2b9sq8j0xkdd1mbasn65bny24qnz00rj2dm61p3"))
        (("rocminfo" "5.3.3") . ,(base32 "1i8p1w8f2wqdc2b9sq8j0xkdd1mbasn65bny24qnz00rj2dm61p3"))
        ; rocm-smi
        (("rocm_smi_lib" "5.7.1") . ,(base32 "0d9cacap0k8k7hmlfbpnrqbrj86pmxk3w1fl8ijglm8a3267i51m"))
        (("rocm_smi_lib" "5.6.1") . ,(base32 "0jxd74y4lgar0jy2y3kqbs872f23cdfj9yrfgjz9hmrp903c9hql"))
        (("rocm_smi_lib" "5.5.1") . ,(base32 "19qxgdc757f4qbkkggkwk8rs3c1jv8d8jgyhsg228s8w6gcr80ga"))
        (("rocm_smi_lib" "5.4.4") . ,(base32 "14f898i9xrbc5nvrpk9zkhjq6hwn0av13gbphq3a6lsd6f49sj4y"))
        (("rocm_smi_lib" "5.3.3") . ,(base32 "0x76gy8kzp4h6x9ssgrbswqpxajxlrps04kvpxh0z1dggn89pcai"))
        ; tensile
        (("tensile" "5.7.1") . ,(base32 "0visjmv63fmk8ywqjfcfvfbsr5784pmv83gsff4xppgrry4cc8qb"))
        (("tensile" "5.6.1") . ,(base32 "1s2fmq5p0yd2s3r92sz8kzrmmgjkqv9pz4rjy25i8xvaips9wl3s"))
        (("tensile" "5.5.1") . ,(base32 "0fs3cz6yaymawnzhm3szy9g3yg4r11gc9zni0k3m7gmycympbsg9"))
        (("tensile" "5.4.4") . ,(base32 "1a4d1sds391s99ymzyigqnd493d8l24hikrc964whzkddbmapb2v"))
        (("tensile" "5.3.3") . ,(base32 "1l3jxp9j4las9hwgsvbqx2alqxh9n0gyqqdjirkgdhs8hw8x23p8"))
        ; roctracer
        (("roctracer" "5.7.1") . ,(base32 "11bd53vylassbg0xcpa9hncvwrv0xcb04z51b12h2iyc1341i91z"))
        (("roctracer" "5.6.1") . ,(base32 "1hsgmgil0k675y5arnhm1338r9b3ikiivfxifghwlisqjw3zy51g"))
        (("roctracer" "5.5.1") . ,(base32 "0gvfawcnc5hr8cxg9c443hqzmjz88rdc9iins2lh5j2gdw8macfw"))
        (("roctracer" "5.4.4") . ,(base32 "1dpc2jmsq2mcilz63fr4vxg99hhzpxdspqavhsg1v57jrhsi9xp6"))
        (("roctracer" "5.3.3") . ,(base32 "0i0qy3mlq0yynrw0s3jh1x9wlpwimjjcn9xavrixf5l00xkljr18"))
        ; rocprim
        (("rocprim" "5.7.1") . ,(base32 "0rawbvyilzb1swj03f03h56i0gs52cg9kbcyz591ipdgqmd0bsgs"))
        (("rocprim" "5.6.1") . ,(base32 "1dms8wm2b4f6h0jwmd76sibmb34g4fh1vdfqs178ncndsmcddgs0"))
        (("rocprim" "5.5.1") . ,(base32 "0dwkshxkbbx4v48mppmkfp4d0gj0y3j9dlgn9f24pq8pqmwc8zld"))
        (("rocprim" "5.4.4") . ,(base32 "1p1q95sw1d66kkh8s3m7nar68x91g147a6mxa85bp5i7pffp5j0s"))
        (("rocprim" "5.3.3") . ,(base32 "0m97rlay6q56gxnn17h79830rp96smvncd6sll8w1cpj8ccfxx4d"))
        ; rocblas
        (("rocblas" "5.7.1") . ,(base32 "1ffwdyn5f237ad2m4k8b2ah15s0g2jfd6hm9qsywnsrby31af0nz"))
        (("rocblas" "5.6.1") . ,(base32 "1vi927lzym8q063xllqlbay8v0yaqy5wvf687gdvc62vp2i22x73"))
        (("rocblas" "5.5.1") . ,(base32 "1x1mp8fb05qrfd5sh6hyas2rfzr462xl9hixrhryi7ph8pi8r2aq"))
        (("rocblas" "5.4.4") . ,(base32 "08qy5rrj6jwwqi1vnn3km92c0hl3pnc9aymifpack27g2p62j5jy"))
        (("rocblas" "5.3.3") . ,(base32 "16iq2rjc4pljdycvflc55p8zc8jvs69mhh98cs4cgf5cbz21d3fg"))
    )
)

(define rocm-patches
    `(
        ; llvm-project
        (("llvm-project" "5.7.1") . ("amd/packages/patches/llvm-rocm-5.6.1.patch"))
        (("llvm-project" "5.6.1") . ("amd/packages/patches/llvm-rocm-5.6.1.patch"))
        (("llvm-project" "5.5.1") . ("amd/packages/patches/llvm-rocm-5.5.1.patch"))
        (("llvm-project" "5.4.4") . ("amd/packages/patches/llvm-rocm-5.4.4.patch"))
        (("llvm-project" "5.3.3") . ("amd/packages/patches/llvm-rocm-5.3.3.patch"))
        ; rocr-runtime
        (("rocr-runtime" "5.7.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.6.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.5.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.4.4") . ("amd/packages/patches/rocr-runtime-5.3.3.patch"))
        (("rocr-runtime" "5.3.3") . ("amd/packages/patches/rocr-runtime-5.3.3.patch"))
        ; hip
        (("hip" "5.7.1") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "5.6.1") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "5.5.1") . ("amd/packages/patches/hip-5.5.1.patch"))
        (("hip" "5.4.4") . ("amd/packages/patches/hip-5.4.4.patch"))
        (("hip" "5.3.3") . ("amd/packages/patches/hip-5.3.3.patch"))
        ; hipcc
        (("hipcc" "5.7.1") . ("amd/packages/patches/hipcc-5.6.1.patch"))
        (("hipcc" "5.6.1") . ("amd/packages/patches/hipcc-5.6.1.patch"))
        ; hipamd (post rocm-5.5.X)
        (("clr" "5.7.1") . ("amd/packages/patches/hipamd-5.6.1.patch"))
        (("clr" "5.6.1") . ("amd/packages/patches/hipamd-5.6.1.patch"))
        ; hipamd (pre rocm-5.6.X)
        (("hipamd" "5.4.4") . ("amd/packages/patches/hipamd-5.4.4.patch"))
        ; tensile
        (("tensile" "5.7.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.6.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.5.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.4.4") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.3.3") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        ; rocblas
        (("rocblas" "5.6.1") . ("amd/packages/patches/rocblas-5.6.1.patch"))
        (("rocblas" "5.5.1") . ("amd/packages/patches/rocblas-5.5.1.patch"))
        (("rocblas" "5.4.4") . ("amd/packages/patches/rocblas-5.4.4.patch"))
        (("rocblas" "5.3.3") . ("amd/packages/patches/rocblas-5.3.3.patch"))
    )
)


(define* (rocm-origin name version #:key (recursive? #f))
    "This procedure returns origin objects for ROCm components."
    (origin
        (method git-fetch)
        (uri (git-reference
                (url (string-append "https://github.com/ROCm/" name))
                (commit (string-append "rocm-" version))
                (recursive? recursive?)))
        (file-name (git-file-name name (string-append "rocm-" version)))
        (sha256 (assoc-ref rocm-hashes (list name version)))
        (patches (map search-patch (or (assoc-ref rocm-patches (list name version)) '())))))
