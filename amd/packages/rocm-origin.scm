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
        ; hipify
        (("hipify" "5.7.1") . ,(base32 "1llc51ah7dphvv9s46i7l8ay3q51dzxx7fvvs6ym16066makc94l"))
        (("hipify" "5.6.1") . ,(base32 "1kf1wdrgf5zxzkdf6fjyglav2rffcd7ph2n4737z6521hcix25p0"))
        (("hipify" "5.5.1") . ,(base32 "0rpqd8gy38fk176midzhg72gi7f606nm8j3d7hmp3fdimil0w60c"))
        (("hipify" "5.4.4") . ,(base32 "1lkbrrjab3afl1ajjj3d8ds7fllnq9xvhvbal7i4335hbhiyv88i"))
        (("hipify" "5.3.3") . ,(base32 "1mfsp0af86k4wdz5nhi8q4p4ri38s38sl5rsxx5k4vrr9awh7cma"))
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
        ; rocdbg-api
        (("rocdbgapi" "5.7.1") . ,(base32 "0p1zmsy552j780j5ppqihajy3ixbv15diyjwr8f5immsqj0yzid8"))
        (("rocdbgapi" "5.6.1") . ,(base32 "197w632d5grd1h2swl83p05sijhnxsjw8x03bmk366qh6rlbwily"))
        (("rocdbgapi" "5.5.1") . ,(base32 "078slwyf275ichp2prq742148q9crwbrckqy6fkp9q91pyxvcnbq"))
        (("rocdbgapi" "5.4.4") . ,(base32 "0448w46dx2d1v9kky75x3lx1pvvy9kw5ygbvzvwz8478kkl5m09a"))
        (("rocdbgapi" "5.3.3") . ,(base32 "09yq1yr8ipi0rlr0rajjmbkvyfcf8l4kvk14ds13zvcj88pxn6x0"))
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
        ; hipcub
        (("hipcub" "5.7.1") . ,(base32 "0mchafa6mcycwbp1v1an5w7pqk2yjsn1mcxl89vhs2bffc1l806a"))
        (("hipcub" "5.6.1") . ,(base32 "1hapl8vx11aacyxj5ijix820xrp04i8kcpgzdxwlxr5rpr7basw6"))
        (("hipcub" "5.5.1") . ,(base32 "07f11891y5bzpp3wdxwz9vhysmhw6mrlcg9s0zi4i2jlv5dvkjfk"))
        (("hipcub" "5.4.4") . ,(base32 "0ahcyl1iw8mwvrzrpih318cqlp0gg2xnhww6f98gyf8hwr473qdd"))
        (("hipcub" "5.3.3") . ,(base32 "0j47hpbzs79gs3kjjrlq3kq508lf7m9vm1fd118cdmh3nclijqzw"))
        ; rocblas
        (("rocblas" "5.7.1") . ,(base32 "1ffwdyn5f237ad2m4k8b2ah15s0g2jfd6hm9qsywnsrby31af0nz"))
        (("rocblas" "5.6.1") . ,(base32 "1vi927lzym8q063xllqlbay8v0yaqy5wvf687gdvc62vp2i22x73"))
        (("rocblas" "5.5.1") . ,(base32 "1x1mp8fb05qrfd5sh6hyas2rfzr462xl9hixrhryi7ph8pi8r2aq"))
        (("rocblas" "5.4.4") . ,(base32 "08qy5rrj6jwwqi1vnn3km92c0hl3pnc9aymifpack27g2p62j5jy"))
        (("rocblas" "5.3.3") . ,(base32 "16iq2rjc4pljdycvflc55p8zc8jvs69mhh98cs4cgf5cbz21d3fg"))
        ; rocsolver
        (("rocsolver" "5.7.1") . ,(base32 "1gls5k6m3xzzivps2l69qcrb9b4kvmwm3ak44zgjk930ifds66db"))
        (("rocsolver" "5.6.1") . ,(base32 "10552l66fa3lk9wa7zxdi6gfqxzhvgjdcgk0slvnz3kgviv2h93y"))
        (("rocsolver" "5.5.1") . ,(base32 "0945zyxszfv0gcksmbmrjncdkfhpsxckf3zqpk8rjj35kl9fakqq"))
        (("rocsolver" "5.4.4") . ,(base32 "0f25yqi0g9rj65q8wgldbkkj7hs4dgs4x0sdlh2ycglms01iqxah"))
        (("rocsolver" "5.3.3") . ,(base32 "036r99q8xak2k3sr1x0201lw4sp53122h0jrsa9fh57463drrxsz"))
        ; hipblas
        (("hipblas" "5.7.1") . ,(base32 "1s0vpyxwjv2618x4mda87rbl753sz9zif24q1c2clxinvxj89dk9"))
        (("hipblas" "5.6.1") . ,(base32 "01yll5sma9rwhss9g6rqmy77qmcc0kx1bwyrjgcy4whrfgb0k7if"))
        (("hipblas" "5.5.1") . ,(base32 "05jl7gz2w3cqspm8ybvk29rw55270f7h74alddi1dpabzjydzi8j"))
        (("hipblas" "5.4.4") . ,(base32 "0ja8b74jlcr2d64hbas3km0q4zh1cxnrapv5rp6gg28sqnml49lr"))
        (("hipblas" "5.3.3") . ,(base32 "134kh32mvwmyw6adz9yjcbrqfxpyb10fxqdf15vyk8lqvj205cyq"))
        ; rocthrust
        (("rocthrust" "5.7.1") . ,(base32 "01zmy4gsd02w6gsah91458kbyl7kcvw3ffw2f09kl89v1xq0gdzr"))
        (("rocthrust" "5.6.1") . ,(base32 "1b8dy3xjqvgagbkanwkikifhjq8r9gdc6jqyb6wy9d8mpzgp00l6"))
        (("rocthrust" "5.5.1") . ,(base32 "0fizjydc1lz4q5wfm88vgl5qcz6x6w7m9w5djdp5082wpfci2ack"))
        (("rocthrust" "5.4.4") . ,(base32 "10rnzj08j2x3jj8297nh61982px26rx3rqd427zd3pydkmgqyg95"))
        (("rocthrust" "5.3.3") . ,(base32 "1k29k29g8ihixh9w11hw2w7qks36alww0qs7pfc07l4bcmwwxq2q"))
        ; rocsparse
        (("rocsparse" "5.7.1") . ,(base32 "17qp4qhhlp30z57r43irqj734zk7pq0lq5s3ms6lc98rm1pbsjnz"))
        (("rocsparse" "5.6.1") . ,(base32 "1bkkay93pz9lbim01f65p2yj8hn7pv3rb8yvk3y1a89crgc2rmif"))
        (("rocsparse" "5.5.1") . ,(base32 "12dlw2n3905pbk9h07k1glxkqviabp707y8grdmm6p8g04syvw85"))
        (("rocsparse" "5.4.4") . ,(base32 "0d0kis94jqdvn2pzfkd1qbs4hchx6djqy04jdzd57biqjzkw6ccg"))
        (("rocsparse" "5.3.3") . ,(base32 "1gg9jfdm24xq9nmvh4lpa1dgg63b7n2cw910yh69x9f83ahbsknp"))
        ; hipsparse
        (("hipsparse" "5.7.1") . ,(base32 "0fibcy7vycj75wirh4ivy4fhivfqcdlq02s4z3pqyc0rx9la065p"))
        (("hipsparse" "5.6.1") . ,(base32 "18g1zq4272zjck245w8dhwc5qka9yca4aclmgwvn8zj5xiynj1hr"))
        (("hipsparse" "5.5.1") . ,(base32 "1iq1rpd7m2d82q93knywbn53fz85fn47mm4l4c51m5jfdr7pw0nx"))
        (("hipsparse" "5.4.4") . ,(base32 "13b7k5q1dxzixaa1hi7b79d1xgcq314dksm3snkqi6w8z8rfcs15"))
        (("hipsparse" "5.3.3") . ,(base32 "11qgk9q081qb3fyz97n2b4d769hr7z8pll7d0598dvvvmf2j45ry"))
        ; rocrand
        (("rocrand" "5.7.1") . ,(base32 "0rj8yvyaqwp3498vmmd658r2f63xrvh0x1467a47yh2raqg65fjn"))
        (("rocrand" "5.6.1") . ,(base32 "0kdv4fbn2acb0da0vcycbp0kxd6r4vibayjnxkn1pbiyjljkxydi"))
        (("rocrand" "5.5.1") . ,(base32 "194983n94r74dfxyp97bf41zshf4rwlnxv4b0i174sycacpwn2b1"))
        (("rocrand" "5.4.4") . ,(base32 "1szy7q68mhmih8yk9z9hm92fmxb5p9hga58lbmjqgvmy6m2lkbf4"))
        (("rocrand" "5.3.3") . ,(base32 "16i1bisrq5r0imjrjafgfvghj9483wps14mamsh1fmx1z6l0n13b"))
        ; rocalution
        (("rocalution" "5.7.1") . ,(base32 "1vk6p6jn5ddpwg6lifjk4wjhb2nrhaamj2wgkaj8y2vcwqbajhgr"))
        (("rocalution" "5.6.1") . ,(base32 "1lny73aj2bcbhzvgdyzzzynybpgf19pjdfbw2zv5wqq5csd6y2gi"))
        (("rocalution" "5.5.1") . ,(base32 "145lkam1qzijca6lspjdyayvkkmcxy4sgf1vh49902w7f7d46pqq"))
        (("rocalution" "5.4.4") . ,(base32 "150wzr6dg8a4jfkgppj2y1ljd3fc86xrmv713w75hzv830svby1d"))
        (("rocalution" "5.3.3") . ,(base32 "0s57xlibid5hgsqj5iln7qx6wx3vqlwg2frvb9dzjp01vr669vs4"))
        ; rccl
        (("rccl" "5.7.1") . ,(base32 "1vvy5s0cmphvh7hr0qn0nz2snl2f9pk3rrcaka41j613z6xjhncw"))
        (("rccl" "5.6.1") . ,(base32 "1m1gbpvvjk35dzg8szn6r8liksq08rgvvmql6zfp9s03g0f1nv0f"))
        (("rccl" "5.5.1") . ,(base32 "1lbm7d7msgkxc9nhcpw6mc2qqr7qz3qxh4vf4wrqgabchnh8zl2y"))
        (("rccl" "5.4.4") . ,(base32 "1kis9q27ynrrjdzzrikmwb9bq71n49fwa9i7am0938yc4dmg6145"))
        (("rccl" "5.3.3") . ,(base32 "1ja27khabg0qxyr5q6lwlqv0csi92q8zlg2vhkcd08187wc5f562"))
        ; rocfft
        (("rocfft" "5.7.1") . ,(base32 "1q6yfjvl62jhrl83a5mcj6l4n26ak08mlh9vaf6kyk8yg39s550r"))
        (("rocfft" "5.6.1") . ,(base32 "1m2ckbi718hjgxvmcdywv6rahcd337zrjb11bxlxy1m9iay5gnj6"))
        (("rocfft" "5.5.1") . ,(base32 "1jxjrqlk87bvw3z4z99bl3x538axrny491ik4hvbkc9a98csn0h6"))
        (("rocfft" "5.4.4") . ,(base32 "1sbcqgvbwi1sakxnb4c5sba9jmy03hxykhbhf1cmx13n809rziqn"))
        (("rocfft" "5.3.3") . ,(base32 "18y0d2g87gz5fmfin321cy307md6xgf2lzw2l7jq5yayykaqbgcd"))
        ; hipfft
        (("hipfft" "5.7.1") . ,(base32 "1azzv72q7l1ksfcvj3rzm2spb2v414l4s4iqyyqwlzaidxjyxlln"))
        (("hipfft" "5.6.1") . ,(base32 "0wi1y5ygw0dah1f6w9h8s433k4ig9cmwa2gacrhpdmkj8md5fg3m"))
        (("hipfft" "5.5.1") . ,(base32 "0mmzqql3m9bxw7x2ypp6623l9b86v3qw3c7acf8a283a2fycfwf1"))
        (("hipfft" "5.4.4") . ,(base32 "07nl39ychv22v4wkcdwnbpwsi34zj0cypcymwppiw0x9118irjsz"))
        (("hipfft" "5.3.3") . ,(base32 "15czgdfgx316i5iyk1hvv7dxr0rkn51cxp3iysfbmcwfi6rmn16v"))
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
