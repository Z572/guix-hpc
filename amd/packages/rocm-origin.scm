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

  #:export (rocm-origin))

(define rocm-hashes
    `(
        ; clr
        (("clr" "6.2.0") . ,(base32 "16hhacrp45gvmv85nbfh6zamzyjl5hvkb1wjnl01sxnabrc35yl4"))
        (("clr" "6.1.2") . ,(base32 "0q9nkxk5ll4mncr2m8d7bwkbl6ac3w74pzylak9yryhsgiqsk5ks"))
        (("clr" "6.1.1") . ,(base32 "0wwb9sh12139qgsh8b9rbcx0aki1aipj6an0skvvpclf8fxampfr"))
        (("clr" "6.0.2") . ,(base32 "0rl09h366qh2ggpg3m2d721drhcqwbrnajyh34ljgn4ny3p41jk4"))
        (("clr" "6.0.0") . ,(base32 "1vi6qk8vhb0mf4rd6idchkpgr5jgz4646daprj2vdqlyp5krv205"))
        (("clr" "5.7.1") . ,(base32 "1300wrbdjpswps8ds850rxy7yifcbwjfszys3x55fl2vy234j1nn"))
        (("clr" "5.6.1") . ,(base32 "1i1zj47x473qh94y27ly14cfhwqdc4qw54j02zl7l82dglvz65sx"))
        ; hip
        (("hip" "6.2.0") . ,(base32 "0iw69byvnphlixm79169mqv4kkcbx4a45jwhgf6mw3s563i8vhc4"))
        (("hip" "6.1.2") . ,(base32 "0nwyxl8i6ql12sf6rsj3zyk0cf1j00x7a7mpjnca9gllvq3lf03p"))
        (("hip" "6.1.1") . ,(base32 "0v8cn9wmxg3r1pc2l1v09vjkvr4fsk5kp57iwdgb5d5pcwwmagzr"))
        (("hip" "6.0.2") . ,(base32 "0d7v06sfwhx16xlkrriqpwnci89z0nkka999balb5q0i5l3vfnz7"))
        (("hip" "6.0.0") . ,(base32 "048qj2gsi871hdsl24shzbpqx1j31gkxfla0ky1ws27fvcy8505d"))
        (("hip" "5.7.1") . ,(base32 "0p7w17mv14xrn1dg98mss43haa1k5qz1bnn9ap10l2wrvavy41nl"))
        (("hip" "5.6.1") . ,(base32 "0vkx3ncjz80xdyi37f80lb2mma4ygqs5rvkvidqqfvamc96v75j1"))
        (("hip" "5.5.1") . ,(base32 "0rm143x4c1h73rfcsa2ggyfg62g1y3x5az9n1jsxfbivqlmmxgs5"))
        (("hip" "5.4.4") . ,(base32 "192jg9bbiyrxq9qszhmvg5d1yszhqmh552qpkqhf0idkvdyp5lsn"))
        (("hip" "5.3.3") . ,(base32 "1lfr2niqa646bfm3y14377frcrxyfpbiygn20jfivlnk16pnyr4j"))
        ; hipamd
        (("hipamd" "5.5.1") . ,(base32 "0qqr89zlv3pny6b7b729p3k4z7wywhic2gypzdjqfld514j2r83c"))
        (("hipamd" "5.4.4") . ,(base32 "0lx02yg6adiqxvhrw7pkn0hl91g88fijgxbic65pmv0636bb5jqm"))
        (("hipamd" "5.3.3") . ,(base32 "07j709nf7z7r3q71gjh8xa17aw99n86735xdapxb9l4m7zz57f4b"))
        ; hipblas
        (("hipblas" "6.2.0") . ,(base32 "1jax43ax9blfg4mjnjrrvpsvw8ravrcabwj193hhx3ir26msc7d2"))
        (("hipblas" "6.1.2") . ,(base32 "1nkw3fzr9sfppsc4wkr5mlgdh442b8hi0pnsw6p2py8ircdfk9j9"))
        (("hipblas" "6.1.1") . ,(base32 "1nkw3fzr9sfppsc4wkr5mlgdh442b8hi0pnsw6p2py8ircdfk9j9"))
        (("hipblas" "6.0.2") . ,(base32 "1h5i5j17a4y6laq9am2ak3yll7zymq7jf2nmpz4527i6qgdfibhn"))
        (("hipblas" "6.0.0") . ,(base32 "1h5i5j17a4y6laq9am2ak3yll7zymq7jf2nmpz4527i6qgdfibhn"))
        (("hipblas" "5.7.1") . ,(base32 "1s0vpyxwjv2618x4mda87rbl753sz9zif24q1c2clxinvxj89dk9"))
        (("hipblas" "5.6.1") . ,(base32 "01yll5sma9rwhss9g6rqmy77qmcc0kx1bwyrjgcy4whrfgb0k7if"))
        (("hipblas" "5.5.1") . ,(base32 "05jl7gz2w3cqspm8ybvk29rw55270f7h74alddi1dpabzjydzi8j"))
        (("hipblas" "5.4.4") . ,(base32 "0ja8b74jlcr2d64hbas3km0q4zh1cxnrapv5rp6gg28sqnml49lr"))
        (("hipblas" "5.3.3") . ,(base32 "134kh32mvwmyw6adz9yjcbrqfxpyb10fxqdf15vyk8lqvj205cyq"))
        ; hipcc
        (("hipcc" "6.0.2") . ,(base32 "0vmhrap7pfxq8qhr898i3py0pid6fzdbbgrlvbj16c2jwhvm1d7w"))
        (("hipcc" "6.0.0") . ,(base32 "0vmhrap7pfxq8qhr898i3py0pid6fzdbbgrlvbj16c2jwhvm1d7w"))
        (("hipcc" "5.7.1") . ,(base32 "0n5ra5biv2r5yjbzwf88vbfwc6cmswmqxfx8wn58kqambnfgm5cl"))
        (("hipcc" "5.6.1") . ,(base32 "1mrpgpvrya2vb21crar5rskdcvlrannv5mvnqgadw559yax4jm9f"))
        ; hipcub
        (("hipcub" "6.2.0") . ,(base32 "0khhfwwmj1ch0js0vbv1xjslqaz6sl837m16f1462l92pkvc08gf"))
        (("hipcub" "6.1.2") . ,(base32 "0xa79218gkikf82x7iz0bdfdhm782pm2mqfv99lh5c5ak6jf76bw"))
        (("hipcub" "6.1.1") . ,(base32 "0xa79218gkikf82x7iz0bdfdhm782pm2mqfv99lh5c5ak6jf76bw"))
        (("hipcub" "6.0.2") . ,(base32 "1dr28aya74s3iimyrhzbfwdnkpq280zb5ds1rhxbyj897n1da37i"))
        (("hipcub" "6.0.0") . ,(base32 "1dr28aya74s3iimyrhzbfwdnkpq280zb5ds1rhxbyj897n1da37i"))
        (("hipcub" "5.7.1") . ,(base32 "0mchafa6mcycwbp1v1an5w7pqk2yjsn1mcxl89vhs2bffc1l806a"))
        (("hipcub" "5.6.1") . ,(base32 "1hapl8vx11aacyxj5ijix820xrp04i8kcpgzdxwlxr5rpr7basw6"))
        (("hipcub" "5.5.1") . ,(base32 "07f11891y5bzpp3wdxwz9vhysmhw6mrlcg9s0zi4i2jlv5dvkjfk"))
        (("hipcub" "5.4.4") . ,(base32 "0ahcyl1iw8mwvrzrpih318cqlp0gg2xnhww6f98gyf8hwr473qdd"))
        (("hipcub" "5.3.3") . ,(base32 "0j47hpbzs79gs3kjjrlq3kq508lf7m9vm1fd118cdmh3nclijqzw"))
        ; hipfft
        (("hipfft" "6.2.0") . ,(base32 "02brbxq6l1i5swzswizlm5x5xwj2gsfcj7ibbzdf2a70y258ix2j"))
        (("hipfft" "6.1.2") . ,(base32 "05iblr9ap7gpqg5n72pdlbddmm4sa78p72sy769ks7nfj1ig82c2"))
        (("hipfft" "6.1.1") . ,(base32 "05iblr9ap7gpqg5n72pdlbddmm4sa78p72sy769ks7nfj1ig82c2"))
        (("hipfft" "6.0.2") . ,(base32 "0bd0ldhy0g3mqpzh28wc8mwb0mwjsq1la453k78mwxl9pi1csf0f"))
        (("hipfft" "6.0.0") . ,(base32 "00ib238is7s04iazjb2cwd05dpsqjy5gdfm5wmiyf6gy7zs6i8gz"))
        (("hipfft" "5.7.1") . ,(base32 "1azzv72q7l1ksfcvj3rzm2spb2v414l4s4iqyyqwlzaidxjyxlln"))
        (("hipfft" "5.6.1") . ,(base32 "0wi1y5ygw0dah1f6w9h8s433k4ig9cmwa2gacrhpdmkj8md5fg3m"))
        (("hipfft" "5.5.1") . ,(base32 "0mmzqql3m9bxw7x2ypp6623l9b86v3qw3c7acf8a283a2fycfwf1"))
        (("hipfft" "5.4.4") . ,(base32 "07nl39ychv22v4wkcdwnbpwsi34zj0cypcymwppiw0x9118irjsz"))
        (("hipfft" "5.3.3") . ,(base32 "15czgdfgx316i5iyk1hvv7dxr0rkn51cxp3iysfbmcwfi6rmn16v"))
        ; hipify
        (("hipify" "6.2.0") . ,(base32 "1mn63fvvx16g4is0s0ln0cgakmiq94jw6kwr7agnii9qb6nllqgk"))
        (("hipify" "6.1.2") . ,(base32 "1isdc5qv21f0x052m1n7f2xfqi3vbp88f5622hh2rklmfb40cjxh"))
        (("hipify" "6.1.1") . ,(base32 "1q963b2cfbk29qf47pcd4jbbm5wab1h0j0kindjalm8w1wsps6q1"))
        (("hipify" "6.0.2") . ,(base32 "03lhfc8flgp7ajdprg5a6x7l54vzwk6ws4i02zxh8lz1yfn9dp4w"))
        (("hipify" "6.0.0") . ,(base32 "1hhfj0a19nmvxqyw0p2cgyr6af4acn487bp8i2j6kwzj46vhk855"))
        (("hipify" "5.7.1") . ,(base32 "1llc51ah7dphvv9s46i7l8ay3q51dzxx7fvvs6ym16066makc94l"))
        (("hipify" "5.6.1") . ,(base32 "1kf1wdrgf5zxzkdf6fjyglav2rffcd7ph2n4737z6521hcix25p0"))
        (("hipify" "5.5.1") . ,(base32 "0rpqd8gy38fk176midzhg72gi7f606nm8j3d7hmp3fdimil0w60c"))
        (("hipify" "5.4.4") . ,(base32 "1lkbrrjab3afl1ajjj3d8ds7fllnq9xvhvbal7i4335hbhiyv88i"))
        (("hipify" "5.3.3") . ,(base32 "1mfsp0af86k4wdz5nhi8q4p4ri38s38sl5rsxx5k4vrr9awh7cma"))
        ; hiprand
        (("hiprand" "6.2.0") . ,(base32 "0z5ny7f1si8ma823cx30jsrqpm1hv1hfhfgcfbm5arn98r7ic79l"))
        (("hiprand" "6.1.2") . ,(base32 "172947v56za1hrlwa84xz0sq9wdcmmj97dhl072wp1ckqb340j2f"))
        (("hiprand" "6.0.2") . ,(base32 "122wxlpbb267c2byckmznk0fdlqmarw88w2iklj93r0p2lxg6qdq"))
        (("hiprand" "5.7.1") . ,(base32 "1gw40nn49nwq90mffkpy3fpyjv7z50ah7b90qhz84nw4x5zlc9c3"))
        (("hiprand" "5.6.1") . ,(base32 "126gc74l4lq2x90hznlp783iqylw7a546nbfckwj88ydiwk0sz3r"))
        (("hiprand" "5.5.1") . ,(base32 "126gc74l4lq2x90hznlp783iqylw7a546nbfckwj88ydiwk0sz3r"))
        (("hiprand" "5.4.4") . ,(base32 "0v9ns6l403ab505qyiva5zp95yjg1bzn976w81kdwgprncw494y3"))
        (("hiprand" "5.3.3") . ,(base32 "0ms4df3sqqm9rl50ackcgl0fkjfb9dsbghar6f0zzcp4fmaacn7f"))
        ; hipsolver
        (("hipsolver" "6.2.0") . ,(base32 "1372d34ck89z5swjwmaan87ibzfwqgc71figh2f43x4ny35afv9g"))
        (("hipsolver" "6.1.2") . ,(base32 "084fajg3npxsj6nb1ll1mbdrjq8jkgz4ggdp6lkp8fjjlfq289ip"))
        (("hipsolver" "6.1.1") . ,(base32 "084fajg3npxsj6nb1ll1mbdrjq8jkgz4ggdp6lkp8fjjlfq289ip"))
        (("hipsolver" "6.0.2") . ,(base32 "0kap6269qg7bszxqksj9rp9wxy2imbmn9hhid4k3jx8kzqxdmiw8"))
        (("hipsolver" "6.0.0") . ,(base32 "0kap6269qg7bszxqksj9rp9wxy2imbmn9hhid4k3jx8kzqxdmiw8"))
        (("hipsolver" "5.7.1") . ,(base32 "01xs958pxhr7ahjgqrjh93y0q6k1sdqcih7yxp7ppgbj7wza9gp5"))
        (("hipsolver" "5.6.1") . ,(base32 "1a9qsljwzs07yl5w1yvp0y9i4iqhrb9mi99qllzrdcfq0pwh1dsm"))
        (("hipsolver" "5.5.1") . ,(base32 "0krm0l6y8vim26h8m9vjin873knp0ynnmcrjmlbmjyjc4qyqw4xl"))
        (("hipsolver" "5.4.4") . ,(base32 "1ai1mp29np3jc87ic23h17vsdvxjadcsblzipwnv4b20lhm61n57"))
        (("hipsolver" "5.3.3") . ,(base32 "0sr9vyvi63lr5vbiq2s2h8l2xg9hyfvz8zrz61ls2hgi83f4hf40"))
        ; hipsparse
        (("hipsparse" "6.2.0") . ,(base32 "0i0z29w3988id7xvayc62z8k1nwmxfkkyyxnwgj3rrln2qshi2gh"))
        (("hipsparse" "6.1.2") . ,(base32 "1zx2656mwb2r0dxfvr5q7ya61skh8miky5n42v40jncmzmjn7a3f"))
        (("hipsparse" "6.1.1") . ,(base32 "1zx2656mwb2r0dxfvr5q7ya61skh8miky5n42v40jncmzmjn7a3f"))
        (("hipsparse" "6.0.2") . ,(base32 "1mkqdk0hjflqmzw52y59crdnc2l74kjjcdwkrsgfiy3yh785nbky"))
        (("hipsparse" "6.0.0") . ,(base32 "1mkqdk0hjflqmzw52y59crdnc2l74kjjcdwkrsgfiy3yh785nbky"))
        (("hipsparse" "5.7.1") . ,(base32 "0fibcy7vycj75wirh4ivy4fhivfqcdlq02s4z3pqyc0rx9la065p"))
        (("hipsparse" "5.6.1") . ,(base32 "18g1zq4272zjck245w8dhwc5qka9yca4aclmgwvn8zj5xiynj1hr"))
        (("hipsparse" "5.5.1") . ,(base32 "1iq1rpd7m2d82q93knywbn53fz85fn47mm4l4c51m5jfdr7pw0nx"))
        (("hipsparse" "5.4.4") . ,(base32 "13b7k5q1dxzixaa1hi7b79d1xgcq314dksm3snkqi6w8z8rfcs15"))
        (("hipsparse" "5.3.3") . ,(base32 "11qgk9q081qb3fyz97n2b4d769hr7z8pll7d0598dvvvmf2j45ry"))
        ; llvm-project
        (("llvm-project" "6.2.0") . ,(base32 "03smwbqrrkmdc22j4bi7c6vq5mxmmlv96xnqnmd4fbm89r59sh6c"))
        (("llvm-project" "6.1.2") . ,(base32 "1f1v00x7sqhlmdgj8frw5gynh6yiim44ks4b7779r2simrxvg5zs"))
        (("llvm-project" "6.1.1") . ,(base32 "0fklnsk7j51201hbkz0hlmrq70h19wvddak8ignm0mf0292fhnlb"))
        (("llvm-project" "6.0.2") . ,(base32 "18kzj29bv9l92krkl585q68a6y4b062ssm91m6926d0cpjb5lv5q"))
        (("llvm-project" "6.0.0") . ,(base32 "1giww1s7iarbvckwn9gaylcwq02nz2mjbnrvlnjqhqqx1p57q5jd"))
        (("llvm-project" "5.7.1") . ,(base32 "1bwqrsvl2gdygp8lqz25xifhmrqwmwjhjhdnc51dr7lc72f4ksfk"))
        (("llvm-project" "5.6.1") . ,(base32 "080pmr2f7hmnpgixikwrrj8pb67b2mw5c5s5649ik2rl8dyjnmmi"))
        (("llvm-project" "5.5.1") . ,(base32 "0g4w7grbl3qf96biflamhgf0f1hvzxnd747cc0kjzpqa1bfcfrhl"))
        (("llvm-project" "5.4.4") . ,(base32 "1q3jlnmyrrj5mhyx33xpnfdbi8ikw8r28rnq0fhxc5j307lw4fq4"))
        (("llvm-project" "5.3.3") . ,(base32 "06r4zrgjsaifnjc7lsp18nwkg6xvalfrlxmn0r7ixghnrhvkpai0"))
        ; rccl
        (("rccl" "6.2.0") . ,(base32 "0v0fz03s56k21jfy870fgis33mc5cyg3h5r7d85ixcrlk86pczd6"))
        (("rccl" "6.1.2") . ,(base32 "1cr7fngr9g3rghrn840kdfqcnw1c822gd79igbx78l9vf4x60yql"))
        (("rccl" "6.1.1") . ,(base32 "1v0papfm4scr4fliss33mqvc792yjx3q9gd50ccsbkqnkqh266a6"))
        (("rccl" "6.0.2") . ,(base32 "0kf0gfazqy1z1rn7y8r7qzgi4y0nx8w70hdw03giw446pkisaa9v"))
        (("rccl" "6.0.0") . ,(base32 "0kf0gfazqy1z1rn7y8r7qzgi4y0nx8w70hdw03giw446pkisaa9v"))
        (("rccl" "5.7.1") . ,(base32 "1vvy5s0cmphvh7hr0qn0nz2snl2f9pk3rrcaka41j613z6xjhncw"))
        (("rccl" "5.6.1") . ,(base32 "1m1gbpvvjk35dzg8szn6r8liksq08rgvvmql6zfp9s03g0f1nv0f"))
        (("rccl" "5.5.1") . ,(base32 "1lbm7d7msgkxc9nhcpw6mc2qqr7qz3qxh4vf4wrqgabchnh8zl2y"))
        (("rccl" "5.4.4") . ,(base32 "1kis9q27ynrrjdzzrikmwb9bq71n49fwa9i7am0938yc4dmg6145"))
        (("rccl" "5.3.3") . ,(base32 "1ja27khabg0qxyr5q6lwlqv0csi92q8zlg2vhkcd08187wc5f562"))
        ; rocalution
        (("rocalution" "6.2.0") . ,(base32 "1gm7hvvxch2l6ygbnnk5adbzjzz7sbz65755a68sg6ayvnscv049"))
        (("rocalution" "6.1.2") . ,(base32 "00y0ar97mmiqdzrrbq6sicpbmb0sprjaf5xyijpw8dbwr4al3rvp"))
        (("rocalution" "6.1.1") . ,(base32 "00y0ar97mmiqdzrrbq6sicpbmb0sprjaf5xyijpw8dbwr4al3rvp"))
        (("rocalution" "6.0.2") . ,(base32 "1dxm1h35nr1a2rda7lgr56lkd080qwpbmcc2y8ia7ad6il47xcws"))
        (("rocalution" "6.0.0") . ,(base32 "1dxm1h35nr1a2rda7lgr56lkd080qwpbmcc2y8ia7ad6il47xcws"))
        (("rocalution" "5.7.1") . ,(base32 "1vk6p6jn5ddpwg6lifjk4wjhb2nrhaamj2wgkaj8y2vcwqbajhgr"))
        (("rocalution" "5.6.1") . ,(base32 "1lny73aj2bcbhzvgdyzzzynybpgf19pjdfbw2zv5wqq5csd6y2gi"))
        (("rocalution" "5.5.1") . ,(base32 "145lkam1qzijca6lspjdyayvkkmcxy4sgf1vh49902w7f7d46pqq"))
        (("rocalution" "5.4.4") . ,(base32 "150wzr6dg8a4jfkgppj2y1ljd3fc86xrmv713w75hzv830svby1d"))
        (("rocalution" "5.3.3") . ,(base32 "0s57xlibid5hgsqj5iln7qx6wx3vqlwg2frvb9dzjp01vr669vs4"))
        ; rocblas
        (("rocblas" "6.2.0") . ,(base32 "0d72x1wych786gx1d1c8148cnjvrdhbc0l3dkk3jmyqp6xbwrbw9"))
        (("rocblas" "6.1.2") . ,(base32 "1q1igpd837k94vx6qp6g5cpigpxc88f1x93g2v8h156368gscpsh"))
        (("rocblas" "6.1.1") . ,(base32 "0rfvp6awg3j25ra75870xpyl36qiqsib3yv1lrvjp8j3kvv71y9z"))
        (("rocblas" "6.0.2") . ,(base32 "0jbi9sx0bgdwqmix3m3aikjnch1s7qbdylfcqx6kfvf11gz1vbqv"))
        (("rocblas" "6.0.0") . ,(base32 "0jbi9sx0bgdwqmix3m3aikjnch1s7qbdylfcqx6kfvf11gz1vbqv"))
        (("rocblas" "5.7.1") . ,(base32 "1ffwdyn5f237ad2m4k8b2ah15s0g2jfd6hm9qsywnsrby31af0nz"))
        (("rocblas" "5.6.1") . ,(base32 "1vi927lzym8q063xllqlbay8v0yaqy5wvf687gdvc62vp2i22x73"))
        (("rocblas" "5.5.1") . ,(base32 "1x1mp8fb05qrfd5sh6hyas2rfzr462xl9hixrhryi7ph8pi8r2aq"))
        (("rocblas" "5.4.4") . ,(base32 "08qy5rrj6jwwqi1vnn3km92c0hl3pnc9aymifpack27g2p62j5jy"))
        (("rocblas" "5.3.3") . ,(base32 "16iq2rjc4pljdycvflc55p8zc8jvs69mhh98cs4cgf5cbz21d3fg"))
        ; rocclr
        (("rocclr" "5.5.1") . ,(base32 "0r9z85kh64ax8jimihw0kf8h52kfdhz8b7zld7qm3p0ka17isk73"))
        (("rocclr" "5.4.4") . ,(base32 "0hg2s2za462xb8937ngsmgmifz1gg87zax80c7ga7j98py87pcqd"))
        (("rocclr" "5.3.3") . ,(base32 "10agrf2g1iaws97rczbyc9rcls7ds3kdyyg6fj87301zna9gsqkn"))
        ; rocdbgapi
        (("rocdbgapi" "6.2.0") . ,(base32 "0jshnchp11rmraa34qaw5xmgjl959lmlqk6gliyspqxinackknls"))
        (("rocdbgapi" "6.1.2") . ,(base32 "1n6hdkv9agws5yzj79bff1j32b43caz6h5v1nb4cjjxqxb4hl04k"))
        (("rocdbgapi" "6.1.1") . ,(base32 "1n6hdkv9agws5yzj79bff1j32b43caz6h5v1nb4cjjxqxb4hl04k"))
        (("rocdbgapi" "6.0.2") . ,(base32 "1i2jwydnvr0fbbjaac620fy2zkqy0ji7c7d4f9ig9dsidi75lb7q"))
        (("rocdbgapi" "6.0.0") . ,(base32 "1i2jwydnvr0fbbjaac620fy2zkqy0ji7c7d4f9ig9dsidi75lb7q"))
        (("rocdbgapi" "5.7.1") . ,(base32 "0p1zmsy552j780j5ppqihajy3ixbv15diyjwr8f5immsqj0yzid8"))
        (("rocdbgapi" "5.6.1") . ,(base32 "197w632d5grd1h2swl83p05sijhnxsjw8x03bmk366qh6rlbwily"))
        (("rocdbgapi" "5.5.1") . ,(base32 "078slwyf275ichp2prq742148q9crwbrckqy6fkp9q91pyxvcnbq"))
        (("rocdbgapi" "5.4.4") . ,(base32 "0448w46dx2d1v9kky75x3lx1pvvy9kw5ygbvzvwz8478kkl5m09a"))
        (("rocdbgapi" "5.3.3") . ,(base32 "09yq1yr8ipi0rlr0rajjmbkvyfcf8l4kvk14ds13zvcj88pxn6x0"))
        ; rocfft
        (("rocfft" "6.2.0") . ,(base32 "0sc8xrn4rr9bzd8lsd0lhh38sa90rxc1d06ckn91nca96gci96f1"))
        (("rocfft" "6.1.2") . ,(base32 "0gsj3lcgppjvppqrldiqgzxsdp0d7vv8rhjg71jww0k76x2lvzf2"))
        (("rocfft" "6.1.1") . ,(base32 "0gsj3lcgppjvppqrldiqgzxsdp0d7vv8rhjg71jww0k76x2lvzf2"))
        (("rocfft" "6.0.2") . ,(base32 "0xvw2q031ggbhdjr8m9yfh79hk7hdrc9ikd9aqy1sy86bv5yqs78"))
        (("rocfft" "6.0.0") . ,(base32 "032jxp8vgm7qvlp74bbqm0c9lgxl6wirrrnrbqvb72mj6ypn25x3"))
        (("rocfft" "5.7.1") . ,(base32 "1q6yfjvl62jhrl83a5mcj6l4n26ak08mlh9vaf6kyk8yg39s550r"))
        (("rocfft" "5.6.1") . ,(base32 "1m2ckbi718hjgxvmcdywv6rahcd337zrjb11bxlxy1m9iay5gnj6"))
        (("rocfft" "5.5.1") . ,(base32 "1jxjrqlk87bvw3z4z99bl3x538axrny491ik4hvbkc9a98csn0h6"))
        (("rocfft" "5.4.4") . ,(base32 "1sbcqgvbwi1sakxnb4c5sba9jmy03hxykhbhf1cmx13n809rziqn"))
        (("rocfft" "5.3.3") . ,(base32 "18y0d2g87gz5fmfin321cy307md6xgf2lzw2l7jq5yayykaqbgcd"))
        ; rocgdb
        (("rocgdb" "6.2.0") . ,(base32 "07c0pcbg5kifs0h1gyxsxkk81rs55k8xlgbf8zc48pw0fmwq18ym"))
        (("rocgdb" "6.1.2") . ,(base32 "1chrxshq0355xaz60wcl5mqnwvffn57yl08cmb7cxns1jl2vixz3"))
        (("rocgdb" "6.1.1") . ,(base32 "1chrxshq0355xaz60wcl5mqnwvffn57yl08cmb7cxns1jl2vixz3"))
        (("rocgdb" "6.0.2") . ,(base32 "1bhwgbqs13ll82m17g31c452mchbz76qx224f7hd38qzr29zzrax"))
        (("rocgdb" "6.0.0") . ,(base32 "1bhwgbqs13ll82m17g31c452mchbz76qx224f7hd38qzr29zzrax"))
        (("rocgdb" "5.7.1") . ,(base32 "04gvap8bkrmgrkg005jy766jnlp50ri9sm99xb7xwmgbyjzgnm2f"))
        (("rocgdb" "5.6.1") . ,(base32 "1jbqw11hs0hgh01qpp31xf70m4xz882njsdb4z9lr9a9wl1zqqqd"))
        (("rocgdb" "5.5.1") . ,(base32 "1vfc1l7naq3pbxdn33vh54wkdivfbdxx1q7df45y49pbhpcba2gs"))
        (("rocgdb" "5.4.4") . ,(base32 "12xq1k9q6c1vi7kdmvn2zcv9yiwm9gpp162g4amnzpr7zaylzr0c"))
        (("rocgdb" "5.3.3") . ,(base32 "02717hip34jqhm35fb1s9jc0nzahsapr2abjfmrahvqqkz46pwwk"))
        ; rocm-cmake
        (("rocm-cmake" "6.2.0") . ,(base32 "05dm7dgg4r5gqbz8sj360nnm348mqxr0fbj3gc0x32l8mw81szf5"))
        (("rocm-cmake" "6.1.2") . ,(base32 "0rn9sgj7bgxhajy8b28afzvikfpz0wxsnbk2p25xc9bf1qzzw513"))
        (("rocm-cmake" "6.1.1") . ,(base32 "0rn9sgj7bgxhajy8b28afzvikfpz0wxsnbk2p25xc9bf1qzzw513"))
        (("rocm-cmake" "6.0.2") . ,(base32 "14vsqcxllgj7cd51z78fvb6wjzzqimr7xbafaw1rlhwf897xca59"))
        (("rocm-cmake" "6.0.0") . ,(base32 "14vsqcxllgj7cd51z78fvb6wjzzqimr7xbafaw1rlhwf897xca59"))
        (("rocm-cmake" "5.7.1") . ,(base32 "0dfhqffgmrbcyxyri2qxpyfdyf8b75bprvnq77q2g281kswg6n39"))
        (("rocm-cmake" "5.6.1") . ,(base32 "183s2ksn142r7nl7l56qvyrgvvkdgqfdzmgkfpp4a6g9mjp88ady"))
        (("rocm-cmake" "5.5.1") . ,(base32 "1g89irfx3f1lmz4p2ys663kc524i6airmkc9n7l20l7l6xm446rv"))
        (("rocm-cmake" "5.4.4") . ,(base32 "0rhg2rs1nv66plfvfa389ga8v8g3z40ckbyysnasbpwr52md1ai5"))
        (("rocm-cmake" "5.3.3") . ,(base32 "1dwm7k22p9jwbax46nlsgd86s2s4c43qsa2wv2ldf7bbp94ggs80"))
        ; rocm-compilersupport
        (("rocm-compilersupport" "6.0.2") . ,(base32 "0qknmf3qzi4m05lxnyw9wl094vl2nk6lr3isjx6g541yz59qsyzl"))
        (("rocm-compilersupport" "6.0.0") . ,(base32 "1xl83g1am8fczd47y24icxr659bqmd82skyz3zsqr8nh44458pj9"))
        (("rocm-compilersupport" "5.7.1") . ,(base32 "0p28jsbwjk19c4i6vwqkwgwpa4qkmqsgpyhhxsx3albnbz8wc7a0"))
        (("rocm-compilersupport" "5.6.1") . ,(base32 "15s2dx0pdvjv3xfccq5prkplcbwps8x9jas5qk93q7kv8wx57p3b"))
        (("rocm-compilersupport" "5.5.1") . ,(base32 "1xh09ljh3i28r3wwx44680jaq0dbyr9mmyad5ail4cmbnd4bwqjc"))
        (("rocm-compilersupport" "5.4.4") . ,(base32 "02vcbw5da8pkn8rxvaw0jdjcd6w2y2883z0b47jrx8lj6w2jpfx8"))
        (("rocm-compilersupport" "5.3.3") . ,(base32 "0s22jplls3sfgwp746qvbzyalhzcsgwz2xxdnzmcr6qnly38q31d"))
        ; rocm-device-libs
        (("rocm-device-libs" "6.0.2") . ,(base32 "1d3c2fbcab9pkah9c3yc6gy7bq6i7516p7l19pb47p0956hvnwgd"))
        (("rocm-device-libs" "6.0.0") . ,(base32 "1d3c2fbcab9pkah9c3yc6gy7bq6i7516p7l19pb47p0956hvnwgd"))
        (("rocm-device-libs" "5.7.1") . ,(base32 "1xc4g5qb8x5hgnvrpzxqxqbsdnwaff1r12aqb8a84mmj5bznq701"))
        (("rocm-device-libs" "5.6.1") . ,(base32 "1jg96ycy99s9fis8sk1b7qx5p33anw16mqlm07zqbnhry2gqkcbh"))
        (("rocm-device-libs" "5.5.1") . ,(base32 "0apwrwa8av5ylf318blwid4xgz6j6bgdpc4frgzwd8vsjwzwkmm8"))
        (("rocm-device-libs" "5.4.4") . ,(base32 "069nc6yg5scp9r0mj8ckb7a5mg74dsavb2ls6fqi75c65n1ny37j"))
        (("rocm-device-libs" "5.3.3") . ,(base32 "15bcgwy5azmx7ldimhz5mdmbrmi4wzdfwdwmznj3g4793z81x8xc"))
        ; rocm-opencl-runtime
        (("rocm-opencl-runtime" "5.5.1") . ,(base32 "0cxhi7pk9xsw6iggkw0fdl2vllpn51iyj1ac80zdifhqss3aba75"))
        (("rocm-opencl-runtime" "5.4.4") . ,(base32 "1hpvxbpxxn0l9cigp0j2fkyv8n61bznzikaj3yxvzr99z3yrhpqk"))
        (("rocm-opencl-runtime" "5.3.3") . ,(base32 "1bsdwgbn9gf9an70sc9zmk732s7qjayv527j6dsxgaszjvdhbw22"))
        ; rocm_bandwidth_test
        (("rocm_bandwidth_test" "6.2.0") . ,(base32 "0swrjgr9rns5rfhf42dpjp5srndfcvi0p5jc4lsjymna5pz8d3dk"))
        (("rocm_bandwidth_test" "6.1.2") . ,(base32 "0b5jrf87wa5dqmipdc4wmr63g31hhgn5ikcl6qgbb51w2gq0vvya"))
        (("rocm_bandwidth_test" "6.1.1") . ,(base32 "0b5jrf87wa5dqmipdc4wmr63g31hhgn5ikcl6qgbb51w2gq0vvya"))
        (("rocm_bandwidth_test" "6.0.2") . ,(base32 "1p9ldrk43imwl8bz5c4pxaxwwmipgqg7k3xzkph2jq7ji455v4zz"))
        (("rocm_bandwidth_test" "6.0.0") . ,(base32 "1p9ldrk43imwl8bz5c4pxaxwwmipgqg7k3xzkph2jq7ji455v4zz"))
        (("rocm_bandwidth_test" "5.7.1") . ,(base32 "1p9ldrk43imwl8bz5c4pxaxwwmipgqg7k3xzkph2jq7ji455v4zz"))
        (("rocm_bandwidth_test" "5.6.1") . ,(base32 "0ca6r8xijw3a3hrlgkqqsf3iqyia6sdmidgmjl12f5vypxzp5kmm"))
        (("rocm_bandwidth_test" "5.5.1") . ,(base32 "0ca6r8xijw3a3hrlgkqqsf3iqyia6sdmidgmjl12f5vypxzp5kmm"))
        (("rocm_bandwidth_test" "5.4.4") . ,(base32 "0ca6r8xijw3a3hrlgkqqsf3iqyia6sdmidgmjl12f5vypxzp5kmm"))
        (("rocm_bandwidth_test" "5.3.3") . ,(base32 "0j5vih77942aai79fr4yfya9a8v17g61w3567f6wxa705s62wqgs"))
        ; rocm_smi_lib
        (("rocm_smi_lib" "6.2.0") . ,(base32 "04abxvma78dvk3nvh9ap6kvyb0n1w2h9d7bzyv1qk243x9h8c8qs"))
        (("rocm_smi_lib" "6.1.2") . ,(base32 "0f73k2da53hwylwf9basmd8wla8wjcdsvrggh2ccv4z9lpy319wf"))
        (("rocm_smi_lib" "6.1.1") . ,(base32 "1cr0my0nhj3k3zd837931gcdvpsa9wyvx7i1fk7rhylvapyfgx4s"))
        (("rocm_smi_lib" "6.0.2") . ,(base32 "1w0v29288v4lph8lzjmkjmc3fzygwfsn81h9fcr63mggjj37cbkx"))
        (("rocm_smi_lib" "6.0.0") . ,(base32 "14srslb19lwf25apqcyjyjlj6yda6mj830w5s5gcgb3lq49v7iaz"))
        (("rocm_smi_lib" "5.7.1") . ,(base32 "0d9cacap0k8k7hmlfbpnrqbrj86pmxk3w1fl8ijglm8a3267i51m"))
        (("rocm_smi_lib" "5.6.1") . ,(base32 "0jxd74y4lgar0jy2y3kqbs872f23cdfj9yrfgjz9hmrp903c9hql"))
        (("rocm_smi_lib" "5.5.1") . ,(base32 "19qxgdc757f4qbkkggkwk8rs3c1jv8d8jgyhsg228s8w6gcr80ga"))
        (("rocm_smi_lib" "5.4.4") . ,(base32 "14f898i9xrbc5nvrpk9zkhjq6hwn0av13gbphq3a6lsd6f49sj4y"))
        (("rocm_smi_lib" "5.3.3") . ,(base32 "0x76gy8kzp4h6x9ssgrbswqpxajxlrps04kvpxh0z1dggn89pcai"))
        ; rocminfo
        (("rocminfo" "6.2.0") . ,(base32 "0x0l87741bar4gscj3p0kdjbp7f88kvqh2w96lliwwzdv95fmgsa"))
        (("rocminfo" "6.1.2") . ,(base32 "0b8s8ppxm1vx9wlv2x552p03fhy5wscwzpbswggi8zgsscl4l2wn"))
        (("rocminfo" "6.1.1") . ,(base32 "0b8s8ppxm1vx9wlv2x552p03fhy5wscwzpbswggi8zgsscl4l2wn"))
        (("rocminfo" "6.0.2") . ,(base32 "1jrhddmn5s25vcf3bi6nd6bvl4i47g3bf7qy0adv2shw4h5iwi4k"))
        (("rocminfo" "6.0.0") . ,(base32 "1jrhddmn5s25vcf3bi6nd6bvl4i47g3bf7qy0adv2shw4h5iwi4k"))
        (("rocminfo" "5.7.1") . ,(base32 "1a6viq9i7hcjn7xfyswzg7ivb5sp577097fiplzf7znkl3dahcsk"))
        (("rocminfo" "5.6.1") . ,(base32 "150bvyxp9krq8f7jqd1g5b4l85rih4ch322y4sg1hnciqpabn6a6"))
        (("rocminfo" "5.5.1") . ,(base32 "150bvyxp9krq8f7jqd1g5b4l85rih4ch322y4sg1hnciqpabn6a6"))
        (("rocminfo" "5.4.4") . ,(base32 "1i8p1w8f2wqdc2b9sq8j0xkdd1mbasn65bny24qnz00rj2dm61p3"))
        (("rocminfo" "5.3.3") . ,(base32 "1i8p1w8f2wqdc2b9sq8j0xkdd1mbasn65bny24qnz00rj2dm61p3"))
        ; rocprim
        (("rocprim" "6.2.0") . ,(base32 "01ligmg6pwkb0dnj4iq6z3m860hzral01bcayw1nizfrl9kldqdh"))
        (("rocprim" "6.1.2") . ,(base32 "0sj4r3jh1gvrjp5hjmbdpnd5545fl1qc7ginlpf1f52g18zq2rxq"))
        (("rocprim" "6.1.1") . ,(base32 "0sj4r3jh1gvrjp5hjmbdpnd5545fl1qc7ginlpf1f52g18zq2rxq"))
        (("rocprim" "6.0.2") . ,(base32 "1qrimz28pifqyp70w5jlqynq0cp1gg2fbp2spf09wgcimbdylswx"))
        (("rocprim" "6.0.0") . ,(base32 "1qrimz28pifqyp70w5jlqynq0cp1gg2fbp2spf09wgcimbdylswx"))
        (("rocprim" "5.7.1") . ,(base32 "0rawbvyilzb1swj03f03h56i0gs52cg9kbcyz591ipdgqmd0bsgs"))
        (("rocprim" "5.6.1") . ,(base32 "1dms8wm2b4f6h0jwmd76sibmb34g4fh1vdfqs178ncndsmcddgs0"))
        (("rocprim" "5.5.1") . ,(base32 "0dwkshxkbbx4v48mppmkfp4d0gj0y3j9dlgn9f24pq8pqmwc8zld"))
        (("rocprim" "5.4.4") . ,(base32 "1p1q95sw1d66kkh8s3m7nar68x91g147a6mxa85bp5i7pffp5j0s"))
        (("rocprim" "5.3.3") . ,(base32 "0m97rlay6q56gxnn17h79830rp96smvncd6sll8w1cpj8ccfxx4d"))
        ; rocprofiler
        (("rocprofiler" "6.2.0") . ,(base32 "19k4q2z2fxspsmmmndx42wihx2ayi2hlypr0j1fskxc1l2smlwx1"))
        (("rocprofiler" "6.1.2") . ,(base32 "0hl9xqjfnjf7hl6rr5j6wrlhqhryng7gx7cik1ixdxhqkalmfrmc"))
        (("rocprofiler" "6.1.1") . ,(base32 "0hl9xqjfnjf7hl6rr5j6wrlhqhryng7gx7cik1ixdxhqkalmfrmc"))
        (("rocprofiler" "6.0.2") . ,(base32 "0n8ah8m1kgdringn3q48kmqr973iabny6f5mfmlhc72w1vv30f6b"))
        (("rocprofiler" "6.0.0") . ,(base32 "0n8ah8m1kgdringn3q48kmqr973iabny6f5mfmlhc72w1vv30f6b"))
        (("rocprofiler" "5.7.1") . ,(base32 "0rjz7nkw17c1vc7sm72qbcsmjjn3m5byvxaz5h1p1vxyvh5zpkyn"))
        (("rocprofiler" "5.6.1") . ,(base32 "04n22m17aliy004xi2h4zp5li3zqndckz2h40x6ff0nzzwm0jp22"))
        (("rocprofiler" "5.5.1") . ,(base32 "0m44i160gacrmjdjm2skmhalsx4vnc4y10vij35rqxx38wjrs3bi"))
        (("rocprofiler" "5.4.4") . ,(base32 "1a8999dvqln5aq2fxhr4ygl7v7lxdjvmzy96g69wadqcrbxgz40a"))
        (("rocprofiler" "5.3.3") . ,(base32 "099b58w4bya4xkszpaimrgfawh9mc5j71lx9mc056khqfkr7pdvv"))
        ; rocprofiler-register
        (("rocprofiler-register" "6.2.0") . ,(base32 "02cxwx3v71x2sdaffhfy5vnyq5fg9lr6n4995fryy2w4szw7qvzq"))
        (("rocprofiler-register" "6.1.2") . ,(base32 "0q31813yw3vrbwmd0k5rf4ik1v2vcywld0qf59b62m2jkli56ghg"))
        (("rocprofiler-register" "6.1.1") . ,(base32 "0q31813yw3vrbwmd0k5rf4ik1v2vcywld0qf59b62m2jkli56ghg"))
        ; rocprofiler-sdk
        (("rocprofiler-sdk" "6.2.0") . ,(base32 "1xlcdz9z51knpr1nm2q8jik02mvahi3pnprl8ch404n4nvaq5i25"))
        ; rocr-runtime
        (("rocr-runtime" "6.2.0") . ,(base32 "0164gdlygyhvpik3bdf9ykrb3q70vvwgjlnvvh7wfr4k4lin4b0m"))
        (("rocr-runtime" "6.1.2") . ,(base32 "0g6m7by4ww72zkpq2mhjrsr8lsfg5indgvr90d1p8kfsl873021p"))
        (("rocr-runtime" "6.1.1") . ,(base32 "1yh25avclnxwhx5mljf97ymhazny46vvmm78yv3n7wgsqlpvylsk"))
        (("rocr-runtime" "6.0.2") . ,(base32 "00hjznlrxxkkp1s8vq4id7vac6bynvz0f67ngs7d88q7kvvhdly4"))
        (("rocr-runtime" "6.0.0") . ,(base32 "00hjznlrxxkkp1s8vq4id7vac6bynvz0f67ngs7d88q7kvvhdly4"))
        (("rocr-runtime" "5.7.1") . ,(base32 "02g53357i15d8laxlhvib7h01kfarlq8hyfm7rm3ii2wgrm23c0g"))
        (("rocr-runtime" "5.6.1") . ,(base32 "07wh7s1kgvpw8ydxmr2wvvn05fdqcmcc20qjbmnc3cbbhxviksyr"))
        (("rocr-runtime" "5.5.1") . ,(base32 "0zhqlbnkq2w0zqdqiqk4l2mksy618fl0zivkp2h6f5pjfnishpw9"))
        (("rocr-runtime" "5.4.4") . ,(base32 "09kpnfn5vpfcjh0amxbk1885hyib9jbisfmh2p9224cx156xfi16"))
        (("rocr-runtime" "5.3.3") . ,(base32 "18hf3abq6g7hyxlkfzd61a661j8lxgq42nkarrs2x5491ny3p8fv"))
        ; rocrand
        (("rocrand" "6.2.0") . ,(base32 "09f5ymw3983wkcc9sbra184wgpjccb7xmp7bp6dxhyn39nk3c9nz"))
        (("rocrand" "6.1.2") . ,(base32 "0q2fc8pr3my4v58dxgdi63a39dclgi4403vzp3z0hpjs6l8pnm0f"))
        (("rocrand" "6.1.1") . ,(base32 "0q2fc8pr3my4v58dxgdi63a39dclgi4403vzp3z0hpjs6l8pnm0f"))
        (("rocrand" "6.0.2") . ,(base32 "0rcs7wjz27hxhxdr5bs69yfg0b16l93llviw8771vkpywdh1q684"))
        (("rocrand" "6.0.0") . ,(base32 "1x7nwsrs1fd8b2vrdq80bd415qvlrp8zrwl235af1g87jl0kia8y"))
        (("rocrand" "5.7.1") . ,(base32 "1dc5nj36wkyndkir4b89pvi3v3dwh28v4ici7iln6hg46bzd63nq"))
        (("rocrand" "5.6.1") . ,(base32 "0w1z54q8fz3pv8lqw1jax2svd4z43iw4cwbsq937hibxklcf3f5l"))
        (("rocrand" "5.5.1") . ,(base32 "0nc4c5mdjs3s7ihycjynr9b48vgcv9smx023cszibjklwd7ix93r"))
        (("rocrand" "5.4.4") . ,(base32 "0mxrbn38qwk63l40dr9s7f1jz77b5d0a854p0anlz1pqddzh791w"))
        (("rocrand" "5.3.3") . ,(base32 "0dmsqvfdzlicgc3qgln8clvj7xxl8cn6alwc9sckpxlplfw2nszs"))
        ; rocsolver
        (("rocsolver" "6.2.0") . ,(base32 "0zdf412kyrr7ibsrfn71dakl75k84snq0jpy5phrfbx5xxqs6lg3"))
        (("rocsolver" "6.1.2") . ,(base32 "1h23k9r6ghdb6l0v7yscyfss076jq0gm17wz24nqylxp3h5g85z6"))
        (("rocsolver" "6.1.1") . ,(base32 "1h23k9r6ghdb6l0v7yscyfss076jq0gm17wz24nqylxp3h5g85z6"))
        (("rocsolver" "6.0.2") . ,(base32 "0yh12fmd23a6i664vr3wvb3isljls2y2dqj0p18h054j02km02dn"))
        (("rocsolver" "6.0.0") . ,(base32 "0yh12fmd23a6i664vr3wvb3isljls2y2dqj0p18h054j02km02dn"))
        (("rocsolver" "5.7.1") . ,(base32 "1gls5k6m3xzzivps2l69qcrb9b4kvmwm3ak44zgjk930ifds66db"))
        (("rocsolver" "5.6.1") . ,(base32 "10552l66fa3lk9wa7zxdi6gfqxzhvgjdcgk0slvnz3kgviv2h93y"))
        (("rocsolver" "5.5.1") . ,(base32 "0945zyxszfv0gcksmbmrjncdkfhpsxckf3zqpk8rjj35kl9fakqq"))
        (("rocsolver" "5.4.4") . ,(base32 "0f25yqi0g9rj65q8wgldbkkj7hs4dgs4x0sdlh2ycglms01iqxah"))
        (("rocsolver" "5.3.3") . ,(base32 "036r99q8xak2k3sr1x0201lw4sp53122h0jrsa9fh57463drrxsz"))
        ; rocsparse
        (("rocsparse" "6.2.0") . ,(base32 "1s1lz30kjpg8zd0n88ifd0h9dgv7qvhflf5g34ijms1pwcvj1ldr"))
        (("rocsparse" "6.1.2") . ,(base32 "0j8ncvfr1gqgxdsbcsxqg1br8m2v4whb8kkw5qh4mqs3szppy4ys"))
        (("rocsparse" "6.1.1") . ,(base32 "0j8ncvfr1gqgxdsbcsxqg1br8m2v4whb8kkw5qh4mqs3szppy4ys"))
        (("rocsparse" "6.0.2") . ,(base32 "0x0096xkyk1qlsk9xy8wnkq6whmax5sy08z30lisvdhkg482fdlx"))
        (("rocsparse" "6.0.0") . ,(base32 "1q2j6i8zna4vvrcrwy2kcnyj7r5p8hjn9pl28rhrhgn8vh3dpdp5"))
        (("rocsparse" "5.7.1") . ,(base32 "17qp4qhhlp30z57r43irqj734zk7pq0lq5s3ms6lc98rm1pbsjnz"))
        (("rocsparse" "5.6.1") . ,(base32 "1bkkay93pz9lbim01f65p2yj8hn7pv3rb8yvk3y1a89crgc2rmif"))
        (("rocsparse" "5.5.1") . ,(base32 "12dlw2n3905pbk9h07k1glxkqviabp707y8grdmm6p8g04syvw85"))
        (("rocsparse" "5.4.4") . ,(base32 "0d0kis94jqdvn2pzfkd1qbs4hchx6djqy04jdzd57biqjzkw6ccg"))
        (("rocsparse" "5.3.3") . ,(base32 "1gg9jfdm24xq9nmvh4lpa1dgg63b7n2cw910yh69x9f83ahbsknp"))
        ; roct-thunk-interface
        (("roct-thunk-interface" "6.2.0") . ,(base32 "0zahlp61lkwcs27lgb0rbvxaxgpfkaz1f715j075whmzvsfp9kj1"))
        (("roct-thunk-interface" "6.1.2") . ,(base32 "0nzz1nj6hahi5m21jsjx0ryzndqnvsgd4v0i4qp7s7isgra40s40"))
        (("roct-thunk-interface" "6.1.1") . ,(base32 "0nzz1nj6hahi5m21jsjx0ryzndqnvsgd4v0i4qp7s7isgra40s40"))
        (("roct-thunk-interface" "6.0.2") . ,(base32 "068yk5ll5c62m8crf2d482pqly4y3jg7x4l5gdv2rfa31zw2590p"))
        (("roct-thunk-interface" "6.0.0") . ,(base32 "068yk5ll5c62m8crf2d482pqly4y3jg7x4l5gdv2rfa31zw2590p"))
        (("roct-thunk-interface" "5.7.1") . ,(base32 "075advkplqlj9y3m3bsww4yiz3qxrfmxwhcf0giaa9dzrn9020wc"))
        (("roct-thunk-interface" "5.6.1") . ,(base32 "0v8j4gkbb21gqqmz1b4nmampx5ywva99ipsx8lcjr5ckcg84fn9x"))
        (("roct-thunk-interface" "5.5.1") . ,(base32 "1digw626k4m3kzcyi89kvba8j69xj4agqgi4avqsnkq5yf0vw9cz"))
        (("roct-thunk-interface" "5.4.4") . ,(base32 "0can34ccy2dm31m0wq9hhrxb8ykd6jj8bn3gfrlycmdklahnskhi"))
        (("roct-thunk-interface" "5.3.3") . ,(base32 "1adzhpa38lfsk0xj0m09fm11ird84vc594nspmhwqqmf3q3zrkkh"))
        ; rocthrust
        (("rocthrust" "6.2.0") . ,(base32 "11wjgl5b130g4cr2gipfgjgiqh6rczwysqpcpn12x2iv2r3hsfq5"))
        (("rocthrust" "6.1.2") . ,(base32 "09irjpbwh2ggfjwcipgxqwpbnq00h2dzgcrykp365pddmmxjfkqd"))
        (("rocthrust" "6.1.1") . ,(base32 "09irjpbwh2ggfjwcipgxqwpbnq00h2dzgcrykp365pddmmxjfkqd"))
        (("rocthrust" "6.0.2") . ,(base32 "16m4j29aj0wkjwzynw3ry0xmjk1pjv35yhnlqwdkas4xqz2wakk6"))
        (("rocthrust" "6.0.0") . ,(base32 "16m4j29aj0wkjwzynw3ry0xmjk1pjv35yhnlqwdkas4xqz2wakk6"))
        (("rocthrust" "5.7.1") . ,(base32 "01zmy4gsd02w6gsah91458kbyl7kcvw3ffw2f09kl89v1xq0gdzr"))
        (("rocthrust" "5.6.1") . ,(base32 "1b8dy3xjqvgagbkanwkikifhjq8r9gdc6jqyb6wy9d8mpzgp00l6"))
        (("rocthrust" "5.5.1") . ,(base32 "0fizjydc1lz4q5wfm88vgl5qcz6x6w7m9w5djdp5082wpfci2ack"))
        (("rocthrust" "5.4.4") . ,(base32 "10rnzj08j2x3jj8297nh61982px26rx3rqd427zd3pydkmgqyg95"))
        (("rocthrust" "5.3.3") . ,(base32 "1k29k29g8ihixh9w11hw2w7qks36alww0qs7pfc07l4bcmwwxq2q"))
        ; roctracer
        (("roctracer" "6.2.0") . ,(base32 "0ggkazbn8hfxgijqiy7k565y7zlgljnk0jpmb2dmzmy3l665kam6"))
        (("roctracer" "6.1.2") . ,(base32 "1sh22vhx7para0ymqgskfl5hslbinxaccillals54pf9dplwvbvb"))
        (("roctracer" "6.1.1") . ,(base32 "1sh22vhx7para0ymqgskfl5hslbinxaccillals54pf9dplwvbvb"))
        (("roctracer" "6.0.2") . ,(base32 "1sh22vhx7para0ymqgskfl5hslbinxaccillals54pf9dplwvbvb"))
        (("roctracer" "6.0.0") . ,(base32 "1sh22vhx7para0ymqgskfl5hslbinxaccillals54pf9dplwvbvb"))
        (("roctracer" "5.7.1") . ,(base32 "11bd53vylassbg0xcpa9hncvwrv0xcb04z51b12h2iyc1341i91z"))
        (("roctracer" "5.6.1") . ,(base32 "1hsgmgil0k675y5arnhm1338r9b3ikiivfxifghwlisqjw3zy51g"))
        (("roctracer" "5.5.1") . ,(base32 "0gvfawcnc5hr8cxg9c443hqzmjz88rdc9iins2lh5j2gdw8macfw"))
        (("roctracer" "5.4.4") . ,(base32 "1dpc2jmsq2mcilz63fr4vxg99hhzpxdspqavhsg1v57jrhsi9xp6"))
        (("roctracer" "5.3.3") . ,(base32 "0i0qy3mlq0yynrw0s3jh1x9wlpwimjjcn9xavrixf5l00xkljr18"))
        ; tensile
        (("tensile" "6.2.0") . ,(base32 "0jxbhpnxmg27908x8yn33r1ljbbxinng5j7v868s4pci9gbdkxxl"))
        (("tensile" "6.1.2") . ,(base32 "1b5m6cjgmvcmahkj6mgzzxxg47fmnn74j9jj6dr1kfgxlaj78qmz"))
        (("tensile" "6.1.1") . ,(base32 "1b5m6cjgmvcmahkj6mgzzxxg47fmnn74j9jj6dr1kfgxlaj78qmz"))
        (("tensile" "6.0.2") . ,(base32 "0dwlwlww4s89kzynq9rzlx0zijsvpjh0hx9bxb5h11sw1lizdpq7"))
        (("tensile" "6.0.0") . ,(base32 "0dwlwlww4s89kzynq9rzlx0zijsvpjh0hx9bxb5h11sw1lizdpq7"))
        (("tensile" "5.7.1") . ,(base32 "0visjmv63fmk8ywqjfcfvfbsr5784pmv83gsff4xppgrry4cc8qb"))
        (("tensile" "5.6.1") . ,(base32 "1s2fmq5p0yd2s3r92sz8kzrmmgjkqv9pz4rjy25i8xvaips9wl3s"))
        (("tensile" "5.5.1") . ,(base32 "0fs3cz6yaymawnzhm3szy9g3yg4r11gc9zni0k3m7gmycympbsg9"))
        (("tensile" "5.4.4") . ,(base32 "1a4d1sds391s99ymzyigqnd493d8l24hikrc964whzkddbmapb2v"))
        (("tensile" "5.3.3") . ,(base32 "1l3jxp9j4las9hwgsvbqx2alqxh9n0gyqqdjirkgdhs8hw8x23p8"))
    )
)

(define rocm-patches
    `(
        ; llvm-project
        (("llvm-project" "6.2.0") . ("amd/packages/patches/llvm-rocm-6.2.0.patch"
                                     ;; upstream patches for llvm 18.1.8
                                     "clang-18.0-libc-search-path.patch"
                                     "clang-17.0-link-dsymutil-latomic.patch"))
        (("llvm-project" "6.1.2") . ("amd/packages/patches/llvm-rocm-6.1.1.patch"
                                     ;; upstream patches for llvm 17.0.6
                                     ;; "clang-17.0-libc-search-path.patch" does not apply cleanly
                                     "clang-17.0-link-dsymutil-latomic.patch"))
        (("llvm-project" "6.1.1") . ("amd/packages/patches/llvm-rocm-6.1.1.patch"
                                     ;; upstream patches for llvm 17.0.6
                                     ;; "clang-17.0-libc-search-path.patch" does not apply cleanly
                                     "clang-17.0-link-dsymutil-latomic.patch"))
        (("llvm-project" "6.0.2") . ("amd/packages/patches/llvm-rocm-5.7.1.patch"
                                     ;; upstream patches for llvm 17.0.6
                                     ;; "clang-17.0-libc-search-path.patch" does not apply cleanly
                                     "clang-17.0-link-dsymutil-latomic.patch"))
        (("llvm-project" "6.0.0") . ("amd/packages/patches/llvm-rocm-5.7.1.patch"
                                     ;; upstream patches for llvm 17.0.6
                                     ;; "clang-17.0-libc-search-path.patch" does not apply cleanly
                                     "clang-17.0-link-dsymutil-latomic.patch"))
        (("llvm-project" "5.7.1") . ("amd/packages/patches/llvm-rocm-5.7.1.patch"
                                     ;; upstream patches for llvm 17.0.6
                                     ;; "clang-17.0-libc-search-path.patch" does not apply cleanly
                                     "clang-17.0-link-dsymutil-latomic.patch"))
        (("llvm-project" "5.6.1") . ("amd/packages/patches/llvm-rocm-5.6.1.patch"
                                     ;; upstream patches for llvm 16.0.6
                                     "clang-16.0-libc-search-path.patch"
                                     "clang-16-remove-crypt-interceptors.patch"))
        (("llvm-project" "5.5.1") . ("amd/packages/patches/llvm-rocm-5.5.1.patch"
                                     ;; upstream patches for llvm 16.0.6
                                     "clang-16.0-libc-search-path.patch"
                                     "clang-16-remove-crypt-interceptors.patch"))
        (("llvm-project" "5.4.4") . ("amd/packages/patches/llvm-rocm-5.4.4.patch"
                                     ;; upstream patches for llvm 15.0.7
                                     "clang-15.0-libc-search-path.patch"
                                     "clang-16-remove-crypt-interceptors.patch"))
        (("llvm-project" "5.3.3") . ("amd/packages/patches/llvm-rocm-5.3.3.patch"
                                     ;; upstream patches for llvm 15.0.7
                                     "clang-15.0-libc-search-path.patch"
                                     "clang-16-remove-crypt-interceptors.patch"))
        ; hipify
        (("hipify" "6.2.0") . ("amd/packages/patches/hipify-6.2.0.patch"))
        ; rocprofiler-register
        (("rocprofiler-sdk" "6.2.0") . ("amd/packages/patches/rocprof-sdk-6.2.0.patch"))
        ; rocprofiler-register
        (("rocprofiler-register" "6.2.0") . ("amd/packages/patches/rocprof-register-6.2.0.patch"))
        (("rocprofiler-register" "6.1.2") . ("amd/packages/patches/rocprof-register-6.2.0.patch"))
        ; rocr-runtime
        (("rocr-runtime" "6.2.0") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "6.1.2") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "6.1.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "6.0.2") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "6.0.0") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.7.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.6.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.5.1") . ("amd/packages/patches/rocr-runtime-5.5.patch"))
        (("rocr-runtime" "5.4.4") . ("amd/packages/patches/rocr-runtime-5.3.3.patch"))
        (("rocr-runtime" "5.3.3") . ("amd/packages/patches/rocr-runtime-5.3.3.patch"))
        ; hip
        (("hip" "6.2.0") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "6.1.2") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "6.1.1") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "6.0.2") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "6.0.0") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "5.7.1") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "5.6.1") . ("amd/packages/patches/hip-headers-5.6.1.patch"))
        (("hip" "5.5.1") . ("amd/packages/patches/hip-5.5.1.patch"))
        (("hip" "5.4.4") . ("amd/packages/patches/hip-5.4.4.patch"))
        (("hip" "5.3.3") . ("amd/packages/patches/hip-5.3.3.patch"))
        ; hipcc
        (("hipcc" "6.0.2") . ("amd/packages/patches/hipcc-5.6.1.patch"))
        (("hipcc" "6.0.0") . ("amd/packages/patches/hipcc-5.6.1.patch"))
        (("hipcc" "5.7.1") . ("amd/packages/patches/hipcc-5.6.1.patch"))
        (("hipcc" "5.6.1") . ("amd/packages/patches/hipcc-5.6.1.patch"))
        ; hipamd (post rocm-5.5.X)
        (("clr" "6.0.2") . ("amd/packages/patches/hipamd-5.6.1.patch"))
        (("clr" "6.0.0") . ("amd/packages/patches/hipamd-5.6.1.patch"))
        (("clr" "5.7.1") . ("amd/packages/patches/hipamd-5.6.1.patch"))
        (("clr" "5.6.1") . ("amd/packages/patches/hipamd-5.6.1.patch"))
        ; hipamd (pre rocm-5.6.X)
        (("hipamd" "5.4.4") . ("amd/packages/patches/hipamd-5.4.4.patch"))
        ; tensile
        (("tensile" "6.2.0") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "6.1.2") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "6.1.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "6.0.2") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "6.0.0") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.7.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.6.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.5.1") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.4.4") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        (("tensile" "5.3.3") . ("amd/packages/patches/tensile-5.3.3-copy-if-not-exist.patch"))
        ; rocblas
        (("rocblas" "6.2.0") . ("amd/packages/patches/rocblas-6.2.0.patch"))
        (("rocblas" "5.6.1") . ("amd/packages/patches/rocblas-5.6.1.patch"))
        (("rocblas" "5.5.1") . ("amd/packages/patches/rocblas-5.5.1.patch"))
        (("rocblas" "5.4.4") . ("amd/packages/patches/rocblas-5.4.4.patch"))
        (("rocblas" "5.3.3") . ("amd/packages/patches/rocblas-5.3.3.patch"))
        ; hipblas
        (("hipblas" "6.2.0") . ("amd/packages/patches/hipblas-6.2.0.patch"))
        ; rocm-bandwidth-test
        (("rocm_bandwidth_test" "6.1.2") . ("amd/packages/patches/rocm-bandwidth-test-reorg.patch"))
        (("rocm_bandwidth_test" "6.1.1") . ("amd/packages/patches/rocm-bandwidth-test-reorg.patch"))
        (("rocm_bandwidth_test" "6.0.2") . ("amd/packages/patches/rocm-bandwidth-test-reorg.patch"))
        (("rocm_bandwidth_test" "6.0.0") . ("amd/packages/patches/rocm-bandwidth-test-reorg.patch"))
    )
)

(define* (rocm-origin name version
                      #:key (recursive? #f))
  "This procedure returns origin objects for ROCm components."
  (origin
    (method git-fetch)
    (uri (git-reference (url (string-append "https://github.com/ROCm/" name))
                        (commit (string-append "rocm-" version))
                        (recursive? recursive?)))
    (file-name (git-file-name name
                              (string-append "rocm-" version)))
    (sha256 (assoc-ref rocm-hashes
                       (list name version)))
    (patches (map search-patch
                  (or (assoc-ref rocm-patches
                                 (list name version))
                      '())))))
