;; intel-mode.el x86 assembly major mode -*- lexical-binding: t; -*-
;; A small tweak for Intel syntax for the from GCC / Clang CC assemblers.
;; Based on Nasm-Mode.el by Christopher Wellons
;; Author: Conner Stephens


(require 'imenu)

(defgroup intel-mode ()
  "Options for `intel-mode'."
  :group 'languages)

(defgroup intel-mode-faces ()
  "Faces used by `intel-mode'."
  :group 'intel-mode)

(defcustom intel-basic-offset (default-value 'tab-width)
  "Indentation level for `intel-mode'."
  :group 'intel-mode)

(defface intel-registers
  '((t :inherit (font-lock-variable-name-face)))
  "Face for registers."
  :group 'intel-mode-faces)

(defface intel-prefix
  '((t :inherit (font-lock-builtin-face)))
  "Face for prefix."
  :group 'intel-mode-faces)

(defface intel-types
  '((t :inherit (font-lock-type-face)))
  "Face for types."
  :group 'intel-mode-faces)

(defface intel-instructions
  '((t :inherit (font-lock-builtin-face)))
  "Face for instructions."
  :group 'intel-mode-faces)

(defface intel-directives
  '((t :inherit (font-lock-keyword-face)))
  "Face for directives."
  :group 'intel-mode-faces)

(defface intel-preprocessor
  '((t :inherit (font-lock-preprocessor-face)))
  "Face for preprocessor directives."
  :group 'intel-mode-faces)

(defface intel-labels
  '((t :inherit (font-lock-function-name-face)))
  "Face for label."
  :group 'intel-mode-faces)

(defface intel-constant
  '((t :inherit (font-lock-constant-face)))
  "Face for constant."
  :group 'intel-mode-faces)

(eval-and-compile
  (defconst intel-registers
    '("ah" "al" "ax" "bh" "bl" "bnd0" "bnd1" "bnd2" "bnd3" "bp" "bpl"
      "bx" "ch" "cl" "cr0" "cr1" "cr10" "cr11" "cr12" "cr13" "cr14"
      "cr15" "cr2" "cr3" "cr4" "cr5" "cr6" "cr7" "cr8" "cr9" "cs" "cx"
      "dh" "di" "dil" "dl" "dr0" "dr1" "dr10" "dr11" "dr12" "dr13"
      "dr14" "dr15" "dr2" "dr3" "dr4" "dr5" "dr6" "dr7" "dr8" "dr9" "ds"
      "dx" "eax" "ebp" "ebx" "ecx" "edi" "edx" "es" "esi" "esp" "fs"
      "gs" "k0" "k1" "k2" "k3" "k4" "k5" "k6" "k7" "mm0" "mm1" "mm2"
      "mm3" "mm4" "mm5" "mm6" "mm7" "r10" "r10b" "r10d" "r10w" "r11"
      "r11b" "r11d" "r11w" "r12" "r12b" "r12d" "r12w" "r13" "r13b"
      "r13d" "r13w" "r14" "r14b" "r14d" "r14w" "r15" "r15b" "r15d"
      "r15w" "r8" "r8b" "r8d" "r8w" "r9" "r9b" "r9d" "r9w" "rax" "rbp"
      "rbx" "rcx" "rdi" "rdx" "rsi" "rsp" "segr6" "segr7" "si" "sil"
      "sp" "spl" "ss" "st0" "st1" "st2" "st3" "st4" "st5" "st6" "st7"
      "tr0" "tr1" "tr2" "tr3" "tr4" "tr5" "tr6" "tr7" "xmm0" "xmm1"
      "xmm10" "xmm11" "xmm12" "xmm13" "xmm14" "xmm15" "xmm16" "xmm17"
      "xmm18" "xmm19" "xmm2" "xmm20" "xmm21" "xmm22" "xmm23" "xmm24"
      "xmm25" "xmm26" "xmm27" "xmm28" "xmm29" "xmm3" "xmm30" "xmm31"
      "xmm4" "xmm5" "xmm6" "xmm7" "xmm8" "xmm9" "ymm0" "ymm1" "ymm10"
      "ymm11" "ymm12" "ymm13" "ymm14" "ymm15" "ymm16" "ymm17" "ymm18"
      "ymm19" "ymm2" "ymm20" "ymm21" "ymm22" "ymm23" "ymm24" "ymm25"
      "ymm26" "ymm27" "ymm28" "ymm29" "ymm3" "ymm30" "ymm31" "ymm4"
      "ymm5" "ymm6" "ymm7" "ymm8" "ymm9" "zmm0" "zmm1" "zmm10" "zmm11"
      "zmm12" "zmm13" "zmm14" "zmm15" "zmm16" "zmm17" "zmm18" "zmm19"
      "zmm2" "zmm20" "zmm21" "zmm22" "zmm23" "zmm24" "zmm25" "zmm26"
      "zmm27" "zmm28" "zmm29" "zmm3" "zmm30" "zmm31" "zmm4" "zmm5"
      "zmm6" "zmm7" "zmm8" "zmm9")
    "INTEL registers (reg.c) for `intel-mode'."))

(eval-and-compile
  (defconst intel-directives
    '("absolute" "bits" "common" "cpu" "debug" "default" "extern"
      "float" "global" "list" "section" "segment" "warning" "sectalign"
      "export" "group" "import" "library" "map" "module" "org" "osabi"
      "safeseh" "uppercase")
    "INTEL directives (directiv.c) for `intel-mode'."))

(eval-and-compile
  (defconst intel-instructions
    '("aaa" "aad" "aam" "aas" "adc" "adcx" "add" "addpd" "addps"
      "addsd" "addss" "addsubpd" "addsubps" "adox" "aesdec"
      "aesdeclast" "aesenc" "aesenclast" "aesimc" "aeskeygenassist"
      "ah" "al" "and" "andn" "andnpd" "andnps" "andpd" "andps" "arpl"
      "ax" "bb0_reset" "bb1_reset" "bextr" "bh" "bl" "blcfill" "blci"
      "blcic" "blcmsk" "blcs" "blendpd" "blendps" "blendvpd"
      "blendvps" "blsfill" "blsi" "blsic" "blsmsk" "blsr" "bnd0"
      "bnd1" "bnd2" "bnd3" "bndcl" "bndcn" "bndcu" "bndldx" "bndmk"
      "bndmov" "bndstx" "bound" "bp" "bpl" "bsf" "bsr" "bswap" "bt"
      "btc" "btr" "bts" "bx" "bzhi" "call" "cbw" "cdq" "cdqe" "ch"
      "cl" "clac" "clc" "cld" "clflush" "clflushopt" "clgi" "cli"
      "clts" "cmc" "cmova" "cmovae" "cmovb" "cmovbe" "cmovc" "cmove"
      "cmovg" "cmovge" "cmovl" "cmovle" "cmovna" "cmovnae" "cmovnb"
      "cmovnbe" "cmovnc" "cmovne" "cmovng" "cmovnge" "cmovnl"
      "cmovnle" "cmovno" "cmovnp" "cmovns" "cmovnz" "cmovo" "cmovp"
      "cmovpe" "cmovpo" "cmovs" "cmovz" "cmp" "cmpeqpd" "cmpeqps"
      "cmpeqsd" "cmpeqss" "cmplepd" "cmpleps" "cmplesd" "cmpless"
      "cmpltpd" "cmpltps" "cmpltsd" "cmpltss" "cmpneqpd" "cmpneqps"
      "cmpneqsd" "cmpneqss" "cmpnlepd" "cmpnleps" "cmpnlesd"
      "cmpnless" "cmpnltpd" "cmpnltps" "cmpnltsd" "cmpnltss"
      "cmpordpd" "cmpordps" "cmpordsd" "cmpordss" "cmppd" "cmpps"
      "cmpsb" "cmpsd" "cmpsq" "cmpss" "cmpsw" "cmpunordpd"
      "cmpunordps" "cmpunordsd" "cmpunordss" "cmpxchg" "cmpxchg16b"
      "cmpxchg486" "cmpxchg8b" "comisd" "comiss" "cpu_read"
      "cpu_write" "cpuid" "cqo" "cr0" "cr1" "cr10" "cr11" "cr12"
      "cr13" "cr14" "cr15" "cr2" "cr3" "cr4" "cr5" "cr6" "cr7" "cr8"
      "cr9" "crc32" "cs" "cvtdq2pd" "cvtdq2ps" "cvtpd2dq" "cvtpd2pi"
      "cvtpd2ps" "cvtpi2pd" "cvtpi2ps" "cvtps2dq" "cvtps2pd"
      "cvtps2pi" "cvtsd2si" "cvtsd2ss" "cvtsi2sd" "cvtsi2ss"
      "cvtss2sd" "cvtss2si" "cvttpd2dq" "cvttpd2pi" "cvttps2dq"
      "cvttps2pi" "cvttsd2si" "cvttss2si" "cwd" "cwde" "cx" "daa"
      "das" "db" "dd" "dec" "dh" "di" "dil" "div" "divpd" "divps"
      "divsd" "divss" "dl" "dmint" "do" "dppd" "dpps" "dq" "dr0" "dr1"
      "dr10" "dr11" "dr12" "dr13" "dr14" "dr15" "dr2" "dr3" "dr4"
      "dr5" "dr6" "dr7" "dr8" "dr9" "ds" "dt" "dw" "dx" "dy" "dz"
      "eax" "ebp" "ebx" "ecx" "edi" "edx" "emms" "enter" "equ" "es"
      "esi" "esp" "extractps" "extrq" "f2xm1" "fabs" "fadd" "faddp"
      "fbld" "fbstp" "fchs" "fclex" "fcmovb" "fcmovbe" "fcmove"
      "fcmovnb" "fcmovnbe" "fcmovne" "fcmovnu" "fcmovu" "fcom" "fcomi"
      "fcomip" "fcomp" "fcompp" "fcos" "fdecstp" "fdisi" "fdiv"
      "fdivp" "fdivr" "fdivrp" "femms" "feni" "ffree" "ffreep" "fiadd"
      "ficom" "ficomp" "fidiv" "fidivr" "fild" "fimul" "fincstp"
      "finit" "fist" "fistp" "fisttp" "fisub" "fisubr" "fld" "fld1"
      "fldcw" "fldenv" "fldl2e" "fldl2t" "fldlg2" "fldln2" "fldpi"
      "fldz" "fmul" "fmulp" "fnclex" "fndisi" "fneni" "fninit" "fnop"
      "fnsave" "fnstcw" "fnstenv" "fnstsw" "fpatan" "fprem" "fprem1"
      "fptan" "frndint" "frstor" "fs" "fsave" "fscale" "fsetpm" "fsin"
      "fsincos" "fsqrt" "fst" "fstcw" "fstenv" "fstp" "fstsw" "fsub"
      "fsubp" "fsubr" "fsubrp" "ftst" "fucom" "fucomi" "fucomip"
      "fucomp" "fucompp" "fwait" "fxam" "fxch" "fxrstor" "fxrstor64"
      "fxsave" "fxsave64" "fxtract" "fyl2x" "fyl2xp1" "getsec" "gs"
      "haddpd" "haddps" "hint_nop0" "hint_nop1" "hint_nop10"
      "hint_nop11" "hint_nop12" "hint_nop13" "hint_nop14" "hint_nop15"
      "hint_nop16" "hint_nop17" "hint_nop18" "hint_nop19" "hint_nop2"
      "hint_nop20" "hint_nop21" "hint_nop22" "hint_nop23" "hint_nop24"
      "hint_nop25" "hint_nop26" "hint_nop27" "hint_nop28" "hint_nop29"
      "hint_nop3" "hint_nop30" "hint_nop31" "hint_nop32" "hint_nop33"
      "hint_nop34" "hint_nop35" "hint_nop36" "hint_nop37" "hint_nop38"
      "hint_nop39" "hint_nop4" "hint_nop40" "hint_nop41" "hint_nop42"
      "hint_nop43" "hint_nop44" "hint_nop45" "hint_nop46" "hint_nop47"
      "hint_nop48" "hint_nop49" "hint_nop5" "hint_nop50" "hint_nop51"
      "hint_nop52" "hint_nop53" "hint_nop54" "hint_nop55" "hint_nop56"
      "hint_nop57" "hint_nop58" "hint_nop59" "hint_nop6" "hint_nop60"
      "hint_nop61" "hint_nop62" "hint_nop63" "hint_nop7" "hint_nop8"
      "hint_nop9" "hlt" "hsubpd" "hsubps" "ibts" "icebp" "idiv" "imul"
      "in" "inc" "incbin" "insb" "insd" "insertps" "insertq" "insw"
      "int" "int01" "int03" "int1" "int3" "into" "invd" "invept"
      "invlpg" "invlpga" "invpcid" "invvpid" "iret" "iretd" "iretq"
      "iretw" "ja" "jae" "jb" "jbe" "jc" "jcxz" "je" "jecxz" "jg"
      "jge" "jl" "jle" "jmp" "jmpe" "jna" "jnae" "jnb" "jnbe" "jnc"
      "jne" "jng" "jnge" "jnl" "jnle" "jno" "jnp" "jns" "jnz" "jo"
      "jp" "jpe" "jpo" "jrcxz" "js" "jz" "k0" "k1" "k2" "k3" "k4" "k5"
      "k6" "k7" "kaddb" "kaddd" "kaddq" "kaddw" "kandb" "kandd"
      "kandnb" "kandnd" "kandnq" "kandnw" "kandq" "kandw" "kmovb"
      "kmovd" "kmovq" "kmovw" "knotb" "knotd" "knotq" "knotw" "korb"
      "kord" "korq" "kortestb" "kortestd" "kortestq" "kortestw" "korw"
      "kshiftlb" "kshiftld" "kshiftlq" "kshiftlw" "kshiftrb"
      "kshiftrd" "kshiftrq" "kshiftrw" "ktestb" "ktestd" "ktestq"
      "ktestw" "kunpckbw" "kunpckdq" "kunpckwd" "kxnorb" "kxnord"
      "kxnorq" "kxnorw" "kxorb" "kxord" "kxorq" "kxorw" "lahf" "lar"
      "lddqu" "ldmxcsr" "lds" "lea" "leave" "les" "lfence" "lfs"
      "lgdt" "lgs" "lidt" "lldt" "llwpcb" "lmsw" "loadall"
      "loadall286" "lodsb" "lodsd" "lodsq" "lodsw" "loop" "loope"
      "loopne" "loopnz" "loopz" "lsl" "lss" "ltr" "lwpins" "lwpval"
      "lzcnt" "maskmovdqu" "maskmovq" "maxpd" "maxps" "maxsd" "maxss"
      "mfence" "minpd" "minps" "minsd" "minss" "mm0" "mm1" "mm2" "mm3"
      "mm4" "mm5" "mm6" "mm7" "monitor" "montmul" "mov" "movapd"
      "movaps" "movbe" "movd" "movddup" "movdq2q" "movdqa" "movdqu"
      "movhlps" "movhpd" "movhps" "movlhps" "movlpd" "movlps"
      "movmskpd" "movmskps" "movntdq" "movntdqa" "movnti" "movntpd"
      "movntps" "movntq" "movntsd" "movntss" "movq" "movq2dq" "movsb"
      "movsd" "movshdup" "movsldup" "movsq" "movss" "movsw" "movsx"
      "movsxd" "movupd" "movups" "movzx" "mpsadbw" "mul" "mulpd"
      "mulps" "mulsd" "mulss" "mulx" "mwait" "neg" "nobnd" "nop" "not"
      "or" "orpd" "orps" "out" "outsb" "outsd" "outsw" "pabsb" "pabsd"
      "pabsw" "packssdw" "packsswb" "packusdw" "packuswb" "paddb"
      "paddd" "paddq" "paddsb" "paddsiw" "paddsw" "paddusb" "paddusw"
      "paddw" "palignr" "pand" "pandn" "pause" "paveb" "pavgb"
      "pavgusb" "pavgw" "pblendvb" "pblendw" "pclmulhqhqdq"
      "pclmulhqlqdq" "pclmullqhqdq" "pclmullqlqdq" "pclmulqdq"
      "pcmpeqb" "pcmpeqd" "pcmpeqq" "pcmpeqw" "pcmpestri" "pcmpestrm"
      "pcmpgtb" "pcmpgtd" "pcmpgtq" "pcmpgtw" "pcmpistri" "pcmpistrm"
      "pdep" "pdistib" "pext" "pextrb" "pextrd" "pextrq" "pextrw"
      "pf2id" "pf2iw" "pfacc" "pfadd" "pfcmpeq" "pfcmpge" "pfcmpgt"
      "pfmax" "pfmin" "pfmul" "pfnacc" "pfpnacc" "pfrcp" "pfrcpit1"
      "pfrcpit2" "pfrcpv" "pfrsqit1" "pfrsqrt" "pfrsqrtv" "pfsub"
      "pfsubr" "phaddd" "phaddsw" "phaddw" "phminposuw" "phsubd"
      "phsubsw" "phsubw" "pi2fd" "pi2fw" "pinsrb" "pinsrd" "pinsrq"
      "pinsrw" "pmachriw" "pmaddubsw" "pmaddwd" "pmagw" "pmaxsb"
      "pmaxsd" "pmaxsw" "pmaxub" "pmaxud" "pmaxuw" "pminsb" "pminsd"
      "pminsw" "pminub" "pminud" "pminuw" "pmovmskb" "pmovsxbd"
      "pmovsxbq" "pmovsxbw" "pmovsxdq" "pmovsxwd" "pmovsxwq"
      "pmovzxbd" "pmovzxbq" "pmovzxbw" "pmovzxdq" "pmovzxwd"
      "pmovzxwq" "pmuldq" "pmulhriw" "pmulhrsw" "pmulhrwa" "pmulhrwc"
      "pmulhuw" "pmulhw" "pmulld" "pmullw" "pmuludq" "pmvgezb"
      "pmvlzb" "pmvnzb" "pmvzb" "pop" "popa" "popad" "popaw" "popcnt"
      "popf" "popfd" "popfq" "popfw" "por" "prefetch" "prefetchnta"
      "prefetcht0" "prefetcht1" "prefetcht2" "prefetchw" "prefetchwt1"
      "psadbw" "pshufb" "pshufd" "pshufhw" "pshuflw" "pshufw" "psignb"
      "psignd" "psignw" "pslld" "pslldq" "psllq" "psllw" "psrad"
      "psraw" "psrld" "psrldq" "psrlq" "psrlw" "psubb" "psubd" "psubq"
      "psubsb" "psubsiw" "psubsw" "psubusb" "psubusw" "psubw" "pswapd"
      "ptest" "punpckhbw" "punpckhdq" "punpckhqdq" "punpckhwd"
      "punpcklbw" "punpckldq" "punpcklqdq" "punpcklwd" "push" "pusha"
      "pushad" "pushaw" "pushf" "pushfd" "pushfq" "pushfw" "pxor"
      "r10" "r10b" "r10d" "r10w" "r11" "r11b" "r11d" "r11w" "r12"
      "r12b" "r12d" "r12w" "r13" "r13b" "r13d" "r13w" "r14" "r14b"
      "r14d" "r14w" "r15" "r15b" "r15d" "r15w" "r8" "r8b" "r8d" "r8w"
      "r9" "r9b" "r9d" "r9w" "rax" "rbp" "rbx" "rcl" "rcpps" "rcpss"
      "rcr" "rcx" "rd-sae" "rdfsbase" "rdgsbase" "rdi" "rdm" "rdmsr"
      "rdpmc" "rdrand" "rdseed" "rdshr" "rdtsc" "rdtscp" "rdx" "resb"
      "resd" "reso" "resq" "rest" "resw" "resy" "resz" "ret" "retf"
      "retn" "rn-sae" "rol" "ror" "rorx" "roundpd" "roundps" "roundsd"
      "roundss" "rsdc" "rsi" "rsldt" "rsm" "rsp" "rsqrtps" "rsqrtss"
      "rsts" "ru-sae" "rz-sae" "sae" "sahf" "sal" "salc" "sar" "sarx"
      "sbb" "scasb" "scasd" "scasq" "scasw" "segr6" "segr7" "seta"
      "setae" "setb" "setbe" "setc" "sete" "setg" "setge" "setl"
      "setle" "setna" "setnae" "setnb" "setnbe" "setnc" "setne"
      "setng" "setnge" "setnl" "setnle" "setno" "setnp" "setns"
      "setnz" "seto" "setp" "setpe" "setpo" "sets" "setz" "sfence"
      "sgdt" "sha1msg1" "sha1msg2" "sha1nexte" "sha1rnds4"
      "sha256msg1" "sha256msg2" "sha256rnds2" "shl" "shld" "shlx"
      "shr" "shrd" "shrx" "shufpd" "shufps" "si" "sidt" "sil" "skinit"
      "sldt" "slwpcb" "smi" "smint" "smintold" "smsw" "sp" "spl"
      "sqrtpd" "sqrtps" "sqrtsd" "sqrtss" "ss" "st0" "st1" "st2" "st3"
      "st4" "st5" "st6" "st7" "stac" "stc" "std" "stgi" "sti"
      "stmxcsr" "stosb" "stosd" "stosq" "stosw" "str" "sub" "subpd"
      "subps" "subsd" "subss" "svdc" "svldt" "svts" "swapgs" "syscall"
      "sysenter" "sysexit" "sysret" "t1mskc" "test" "tr0" "tr1" "tr2"
      "tr3" "tr4" "tr5" "tr6" "tr7" "tzcnt" "tzmsk" "ucomisd"
      "ucomiss" "ud0" "ud1" "ud2" "ud2a" "ud2b" "umov" "unpckhpd"
      "unpckhps" "unpcklpd" "unpcklps" "vaddpd" "vaddps" "vaddsd"
      "vaddss" "vaddsubpd" "vaddsubps" "vaesdec" "vaesdeclast"
      "vaesenc" "vaesenclast" "vaesimc" "vaeskeygenassist" "valignd"
      "valignq" "vandnpd" "vandnps" "vandpd" "vandps" "vblendmpd"
      "vblendmps" "vblendpd" "vblendps" "vblendvpd" "vblendvps"
      "vbroadcastf128" "vbroadcastf32x2" "vbroadcastf32x4"
      "vbroadcastf32x8" "vbroadcastf64x2" "vbroadcastf64x4"
      "vbroadcasti128" "vbroadcasti32x2" "vbroadcasti32x4"
      "vbroadcasti32x8" "vbroadcasti64x2" "vbroadcasti64x4"
      "vbroadcastsd" "vbroadcastss" "vcmpeq_ospd" "vcmpeq_osps"
      "vcmpeq_ossd" "vcmpeq_osss" "vcmpeq_uqpd" "vcmpeq_uqps"
      "vcmpeq_uqsd" "vcmpeq_uqss" "vcmpeq_uspd" "vcmpeq_usps"
      "vcmpeq_ussd" "vcmpeq_usss" "vcmpeqpd" "vcmpeqps" "vcmpeqsd"
      "vcmpeqss" "vcmpfalse_oqpd" "vcmpfalse_oqps" "vcmpfalse_oqsd"
      "vcmpfalse_oqss" "vcmpfalse_ospd" "vcmpfalse_osps"
      "vcmpfalse_ossd" "vcmpfalse_osss" "vcmpfalsepd" "vcmpfalseps"
      "vcmpfalsesd" "vcmpfalsess" "vcmpge_oqpd" "vcmpge_oqps"
      "vcmpge_oqsd" "vcmpge_oqss" "vcmpge_ospd" "vcmpge_osps"
      "vcmpge_ossd" "vcmpge_osss" "vcmpgepd" "vcmpgeps" "vcmpgesd"
      "vcmpgess" "vcmpgt_oqpd" "vcmpgt_oqps" "vcmpgt_oqsd"
      "vcmpgt_oqss" "vcmpgt_ospd" "vcmpgt_osps" "vcmpgt_ossd"
      "vcmpgt_osss" "vcmpgtpd" "vcmpgtps" "vcmpgtsd" "vcmpgtss"
      "vcmple_oqpd" "vcmple_oqps" "vcmple_oqsd" "vcmple_oqss"
      "vcmple_ospd" "vcmple_osps" "vcmple_ossd" "vcmple_osss"
      "vcmplepd" "vcmpleps" "vcmplesd" "vcmpless" "vcmplt_oqpd"
      "vcmplt_oqps" "vcmplt_oqsd" "vcmplt_oqss" "vcmplt_ospd"
      "vcmplt_osps" "vcmplt_ossd" "vcmplt_osss" "vcmpltpd" "vcmpltps"
      "vcmpltsd" "vcmpltss" "vcmpneq_oqpd" "vcmpneq_oqps"
      "vcmpneq_oqsd" "vcmpneq_oqss" "vcmpneq_ospd" "vcmpneq_osps"
      "vcmpneq_ossd" "vcmpneq_osss" "vcmpneq_uqpd" "vcmpneq_uqps"
      "vcmpneq_uqsd" "vcmpneq_uqss" "vcmpneq_uspd" "vcmpneq_usps"
      "vcmpneq_ussd" "vcmpneq_usss" "vcmpneqpd" "vcmpneqps"
      "vcmpneqsd" "vcmpneqss" "vcmpnge_uqpd" "vcmpnge_uqps"
      "vcmpnge_uqsd" "vcmpnge_uqss" "vcmpnge_uspd" "vcmpnge_usps"
      "vcmpnge_ussd" "vcmpnge_usss" "vcmpngepd" "vcmpngeps"
      "vcmpngesd" "vcmpngess" "vcmpngt_uqpd" "vcmpngt_uqps"
      "vcmpngt_uqsd" "vcmpngt_uqss" "vcmpngt_uspd" "vcmpngt_usps"
      "vcmpngt_ussd" "vcmpngt_usss" "vcmpngtpd" "vcmpngtps"
      "vcmpngtsd" "vcmpngtss" "vcmpnle_uqpd" "vcmpnle_uqps"
      "vcmpnle_uqsd" "vcmpnle_uqss" "vcmpnle_uspd" "vcmpnle_usps"
      "vcmpnle_ussd" "vcmpnle_usss" "vcmpnlepd" "vcmpnleps"
      "vcmpnlesd" "vcmpnless" "vcmpnlt_uqpd" "vcmpnlt_uqps"
      "vcmpnlt_uqsd" "vcmpnlt_uqss" "vcmpnlt_uspd" "vcmpnlt_usps"
      "vcmpnlt_ussd" "vcmpnlt_usss" "vcmpnltpd" "vcmpnltps"
      "vcmpnltsd" "vcmpnltss" "vcmpord_qpd" "vcmpord_qps"
      "vcmpord_qsd" "vcmpord_qss" "vcmpord_spd" "vcmpord_sps"
      "vcmpord_ssd" "vcmpord_sss" "vcmpordpd" "vcmpordps" "vcmpordsd"
      "vcmpordss" "vcmppd" "vcmpps" "vcmpsd" "vcmpss" "vcmptrue_uqpd"
      "vcmptrue_uqps" "vcmptrue_uqsd" "vcmptrue_uqss" "vcmptrue_uspd"
      "vcmptrue_usps" "vcmptrue_ussd" "vcmptrue_usss" "vcmptruepd"
      "vcmptrueps" "vcmptruesd" "vcmptruess" "vcmpunord_qpd"
      "vcmpunord_qps" "vcmpunord_qsd" "vcmpunord_qss" "vcmpunord_spd"
      "vcmpunord_sps" "vcmpunord_ssd" "vcmpunord_sss" "vcmpunordpd"
      "vcmpunordps" "vcmpunordsd" "vcmpunordss" "vcomisd" "vcomiss"
      "vcompresspd" "vcompressps" "vcvtdq2pd" "vcvtdq2ps" "vcvtpd2dq"
      "vcvtpd2ps" "vcvtpd2qq" "vcvtpd2udq" "vcvtpd2uqq" "vcvtph2ps"
      "vcvtps2dq" "vcvtps2pd" "vcvtps2ph" "vcvtps2qq" "vcvtps2udq"
      "vcvtps2uqq" "vcvtqq2pd" "vcvtqq2ps" "vcvtsd2si" "vcvtsd2ss"
      "vcvtsd2usi" "vcvtsi2sd" "vcvtsi2ss" "vcvtss2sd" "vcvtss2si"
      "vcvtss2usi" "vcvttpd2dq" "vcvttpd2qq" "vcvttpd2udq"
      "vcvttpd2uqq" "vcvttps2dq" "vcvttps2qq" "vcvttps2udq"
      "vcvttps2uqq" "vcvttsd2si" "vcvttsd2usi" "vcvttss2si"
      "vcvttss2usi" "vcvtudq2pd" "vcvtudq2ps" "vcvtuqq2pd"
      "vcvtuqq2ps" "vcvtusi2sd" "vcvtusi2ss" "vdbpsadbw" "vdivpd"
      "vdivps" "vdivsd" "vdivss" "vdppd" "vdpps" "verr" "verw"
      "vexp2pd" "vexp2ps" "vexpandpd" "vexpandps" "vextractf128"
      "vextractf32x4" "vextractf32x8" "vextractf64x2" "vextractf64x4"
      "vextracti128" "vextracti32x4" "vextracti32x8" "vextracti64x2"
      "vextracti64x4" "vextractps" "vfixupimmpd" "vfixupimmps"
      "vfixupimmsd" "vfixupimmss" "vfmadd123pd" "vfmadd123ps"
      "vfmadd123sd" "vfmadd123ss" "vfmadd132pd" "vfmadd132ps"
      "vfmadd132sd" "vfmadd132ss" "vfmadd213pd" "vfmadd213ps"
      "vfmadd213sd" "vfmadd213ss" "vfmadd231pd" "vfmadd231ps"
      "vfmadd231sd" "vfmadd231ss" "vfmadd312pd" "vfmadd312ps"
      "vfmadd312sd" "vfmadd312ss" "vfmadd321pd" "vfmadd321ps"
      "vfmadd321sd" "vfmadd321ss" "vfmaddpd" "vfmaddps" "vfmaddsd"
      "vfmaddss" "vfmaddsub123pd" "vfmaddsub123ps" "vfmaddsub132pd"
      "vfmaddsub132ps" "vfmaddsub213pd" "vfmaddsub213ps"
      "vfmaddsub231pd" "vfmaddsub231ps" "vfmaddsub312pd"
      "vfmaddsub312ps" "vfmaddsub321pd" "vfmaddsub321ps" "vfmaddsubpd"
      "vfmaddsubps" "vfmsub123pd" "vfmsub123ps" "vfmsub123sd"
      "vfmsub123ss" "vfmsub132pd" "vfmsub132ps" "vfmsub132sd"
      "vfmsub132ss" "vfmsub213pd" "vfmsub213ps" "vfmsub213sd"
      "vfmsub213ss" "vfmsub231pd" "vfmsub231ps" "vfmsub231sd"
      "vfmsub231ss" "vfmsub312pd" "vfmsub312ps" "vfmsub312sd"
      "vfmsub312ss" "vfmsub321pd" "vfmsub321ps" "vfmsub321sd"
      "vfmsub321ss" "vfmsubadd123pd" "vfmsubadd123ps" "vfmsubadd132pd"
      "vfmsubadd132ps" "vfmsubadd213pd" "vfmsubadd213ps"
      "vfmsubadd231pd" "vfmsubadd231ps" "vfmsubadd312pd"
      "vfmsubadd312ps" "vfmsubadd321pd" "vfmsubadd321ps" "vfmsubaddpd"
      "vfmsubaddps" "vfmsubpd" "vfmsubps" "vfmsubsd" "vfmsubss"
      "vfnmadd123pd" "vfnmadd123ps" "vfnmadd123sd" "vfnmadd123ss"
      "vfnmadd132pd" "vfnmadd132ps" "vfnmadd132sd" "vfnmadd132ss"
      "vfnmadd213pd" "vfnmadd213ps" "vfnmadd213sd" "vfnmadd213ss"
      "vfnmadd231pd" "vfnmadd231ps" "vfnmadd231sd" "vfnmadd231ss"
      "vfnmadd312pd" "vfnmadd312ps" "vfnmadd312sd" "vfnmadd312ss"
      "vfnmadd321pd" "vfnmadd321ps" "vfnmadd321sd" "vfnmadd321ss"
      "vfnmaddpd" "vfnmaddps" "vfnmaddsd" "vfnmaddss" "vfnmsub123pd"
      "vfnmsub123ps" "vfnmsub123sd" "vfnmsub123ss" "vfnmsub132pd"
      "vfnmsub132ps" "vfnmsub132sd" "vfnmsub132ss" "vfnmsub213pd"
      "vfnmsub213ps" "vfnmsub213sd" "vfnmsub213ss" "vfnmsub231pd"
      "vfnmsub231ps" "vfnmsub231sd" "vfnmsub231ss" "vfnmsub312pd"
      "vfnmsub312ps" "vfnmsub312sd" "vfnmsub312ss" "vfnmsub321pd"
      "vfnmsub321ps" "vfnmsub321sd" "vfnmsub321ss" "vfnmsubpd"
      "vfnmsubps" "vfnmsubsd" "vfnmsubss" "vfpclasspd" "vfpclassps"
      "vfpclasssd" "vfpclassss" "vfrczpd" "vfrczps" "vfrczsd"
      "vfrczss" "vgatherdpd" "vgatherdps" "vgatherpf0dpd"
      "vgatherpf0dps" "vgatherpf0qpd" "vgatherpf0qps" "vgatherpf1dpd"
      "vgatherpf1dps" "vgatherpf1qpd" "vgatherpf1qps" "vgatherqpd"
      "vgatherqps" "vgetexppd" "vgetexpps" "vgetexpsd" "vgetexpss"
      "vgetmantpd" "vgetmantps" "vgetmantsd" "vgetmantss" "vhaddpd"
      "vhaddps" "vhsubpd" "vhsubps" "vinsertf128" "vinsertf32x4"
      "vinsertf32x8" "vinsertf64x2" "vinsertf64x4" "vinserti128"
      "vinserti32x4" "vinserti32x8" "vinserti64x2" "vinserti64x4"
      "vinsertps" "vlddqu" "vldmxcsr" "vldqqu" "vmaskmovdqu"
      "vmaskmovpd" "vmaskmovps" "vmaxpd" "vmaxps" "vmaxsd" "vmaxss"
      "vmcall" "vmclear" "vmfunc" "vminpd" "vminps" "vminsd" "vminss"
      "vmlaunch" "vmload" "vmmcall" "vmovapd" "vmovaps" "vmovd"
      "vmovddup" "vmovdqa" "vmovdqa32" "vmovdqa64" "vmovdqu"
      "vmovdqu16" "vmovdqu32" "vmovdqu64" "vmovdqu8" "vmovhlps"
      "vmovhpd" "vmovhps" "vmovlhps" "vmovlpd" "vmovlps" "vmovmskpd"
      "vmovmskps" "vmovntdq" "vmovntdqa" "vmovntpd" "vmovntps"
      "vmovntqq" "vmovq" "vmovqqa" "vmovqqu" "vmovsd" "vmovshdup"
      "vmovsldup" "vmovss" "vmovupd" "vmovups" "vmpsadbw" "vmptrld"
      "vmptrst" "vmread" "vmresume" "vmrun" "vmsave" "vmulpd" "vmulps"
      "vmulsd" "vmulss" "vmwrite" "vmxoff" "vmxon" "vorpd" "vorps"
      "vpabsb" "vpabsd" "vpabsq" "vpabsw" "vpackssdw" "vpacksswb"
      "vpackusdw" "vpackuswb" "vpaddb" "vpaddd" "vpaddq" "vpaddsb"
      "vpaddsw" "vpaddusb" "vpaddusw" "vpaddw" "vpalignr" "vpand"
      "vpandd" "vpandn" "vpandnd" "vpandnq" "vpandq" "vpavgb" "vpavgw"
      "vpblendd" "vpblendmb" "vpblendmd" "vpblendmq" "vpblendmw"
      "vpblendvb" "vpblendw" "vpbroadcastb" "vpbroadcastd"
      "vpbroadcastmb2q" "vpbroadcastmw2d" "vpbroadcastq"
      "vpbroadcastw" "vpclmulhqhqdq" "vpclmulhqlqdq" "vpclmullqhqdq"
      "vpclmullqlqdq" "vpclmulqdq" "vpcmov" "vpcmpb" "vpcmpd"
      "vpcmpeqb" "vpcmpeqd" "vpcmpeqq" "vpcmpeqw" "vpcmpestri"
      "vpcmpestrm" "vpcmpgtb" "vpcmpgtd" "vpcmpgtq" "vpcmpgtw"
      "vpcmpistri" "vpcmpistrm" "vpcmpq" "vpcmpub" "vpcmpud" "vpcmpuq"
      "vpcmpuw" "vpcmpw" "vpcomb" "vpcomd" "vpcompressd" "vpcompressq"
      "vpcomq" "vpcomub" "vpcomud" "vpcomuq" "vpcomuw" "vpcomw"
      "vpconflictd" "vpconflictq" "vperm2f128" "vperm2i128" "vpermb"
      "vpermd" "vpermi2b" "vpermi2d" "vpermi2pd" "vpermi2ps"
      "vpermi2q" "vpermi2w" "vpermilpd" "vpermilps" "vpermpd"
      "vpermps" "vpermq" "vpermt2b" "vpermt2d" "vpermt2pd" "vpermt2ps"
      "vpermt2q" "vpermt2w" "vpermw" "vpexpandd" "vpexpandq" "vpextrb"
      "vpextrd" "vpextrq" "vpextrw" "vpgatherdd" "vpgatherdq"
      "vpgatherqd" "vpgatherqq" "vphaddbd" "vphaddbq" "vphaddbw"
      "vphaddd" "vphadddq" "vphaddsw" "vphaddubd" "vphaddubq"
      "vphaddubw" "vphaddudq" "vphadduwd" "vphadduwq" "vphaddw"
      "vphaddwd" "vphaddwq" "vphminposuw" "vphsubbw" "vphsubd"
      "vphsubdq" "vphsubsw" "vphsubw" "vphsubwd" "vpinsrb" "vpinsrd"
      "vpinsrq" "vpinsrw" "vplzcntd" "vplzcntq" "vpmacsdd" "vpmacsdqh"
      "vpmacsdql" "vpmacssdd" "vpmacssdqh" "vpmacssdql" "vpmacsswd"
      "vpmacssww" "vpmacswd" "vpmacsww" "vpmadcsswd" "vpmadcswd"
      "vpmadd52huq" "vpmadd52luq" "vpmaddubsw" "vpmaddwd" "vpmaskmovd"
      "vpmaskmovq" "vpmaxsb" "vpmaxsd" "vpmaxsq" "vpmaxsw" "vpmaxub"
      "vpmaxud" "vpmaxuq" "vpmaxuw" "vpminsb" "vpminsd" "vpminsq"
      "vpminsw" "vpminub" "vpminud" "vpminuq" "vpminuw" "vpmovb2m"
      "vpmovd2m" "vpmovdb" "vpmovdw" "vpmovm2b" "vpmovm2d" "vpmovm2q"
      "vpmovm2w" "vpmovmskb" "vpmovq2m" "vpmovqb" "vpmovqd" "vpmovqw"
      "vpmovsdb" "vpmovsdw" "vpmovsqb" "vpmovsqd" "vpmovsqw"
      "vpmovswb" "vpmovsxbd" "vpmovsxbq" "vpmovsxbw" "vpmovsxdq"
      "vpmovsxwd" "vpmovsxwq" "vpmovusdb" "vpmovusdw" "vpmovusqb"
      "vpmovusqd" "vpmovusqw" "vpmovuswb" "vpmovw2m" "vpmovwb"
      "vpmovzxbd" "vpmovzxbq" "vpmovzxbw" "vpmovzxdq" "vpmovzxwd"
      "vpmovzxwq" "vpmuldq" "vpmulhrsw" "vpmulhuw" "vpmulhw" "vpmulld"
      "vpmullq" "vpmullw" "vpmultishiftqb" "vpmuludq" "vpor" "vpord"
      "vporq" "vpperm" "vprold" "vprolq" "vprolvd" "vprolvq" "vprord"
      "vprorq" "vprorvd" "vprorvq" "vprotb" "vprotd" "vprotq" "vprotw"
      "vpsadbw" "vpscatterdd" "vpscatterdq" "vpscatterqd"
      "vpscatterqq" "vpshab" "vpshad" "vpshaq" "vpshaw" "vpshlb"
      "vpshld" "vpshlq" "vpshlw" "vpshufb" "vpshufd" "vpshufhw"
      "vpshuflw" "vpsignb" "vpsignd" "vpsignw" "vpslld" "vpslldq"
      "vpsllq" "vpsllvd" "vpsllvq" "vpsllvw" "vpsllw" "vpsrad"
      "vpsraq" "vpsravd" "vpsravq" "vpsravw" "vpsraw" "vpsrld"
      "vpsrldq" "vpsrlq" "vpsrlvd" "vpsrlvq" "vpsrlvw" "vpsrlw"
      "vpsubb" "vpsubd" "vpsubq" "vpsubsb" "vpsubsw" "vpsubusb"
      "vpsubusw" "vpsubw" "vpternlogd" "vpternlogq" "vptest"
      "vptestmb" "vptestmd" "vptestmq" "vptestmw" "vptestnmb"
      "vptestnmd" "vptestnmq" "vptestnmw" "vpunpckhbw" "vpunpckhdq"
      "vpunpckhqdq" "vpunpckhwd" "vpunpcklbw" "vpunpckldq"
      "vpunpcklqdq" "vpunpcklwd" "vpxor" "vpxord" "vpxorq" "vrangepd"
      "vrangeps" "vrangesd" "vrangess" "vrcp14pd" "vrcp14ps"
      "vrcp14sd" "vrcp14ss" "vrcp28pd" "vrcp28ps" "vrcp28sd"
      "vrcp28ss" "vrcpps" "vrcpss" "vreducepd" "vreduceps" "vreducesd"
      "vreducess" "vrndscalepd" "vrndscaleps" "vrndscalesd"
      "vrndscaless" "vroundpd" "vroundps" "vroundsd" "vroundss"
      "vrsqrt14pd" "vrsqrt14ps" "vrsqrt14sd" "vrsqrt14ss" "vrsqrt28pd"
      "vrsqrt28ps" "vrsqrt28sd" "vrsqrt28ss" "vrsqrtps" "vrsqrtss"
      "vscalefpd" "vscalefps" "vscalefsd" "vscalefss" "vscatterdpd"
      "vscatterdps" "vscatterpf0dpd" "vscatterpf0dps" "vscatterpf0qpd"
      "vscatterpf0qps" "vscatterpf1dpd" "vscatterpf1dps"
      "vscatterpf1qpd" "vscatterpf1qps" "vscatterqpd" "vscatterqps"
      "vshuff32x4" "vshuff64x2" "vshufi32x4" "vshufi64x2" "vshufpd"
      "vshufps" "vsqrtpd" "vsqrtps" "vsqrtsd" "vsqrtss" "vstmxcsr"
      "vsubpd" "vsubps" "vsubsd" "vsubss" "vtestpd" "vtestps"
      "vucomisd" "vucomiss" "vunpckhpd" "vunpckhps" "vunpcklpd"
      "vunpcklps" "vxorpd" "vxorps" "vzeroall" "vzeroupper" "wbinvd"
      "wrfsbase" "wrgsbase" "wrmsr" "wrshr" "xabort" "xadd" "xbegin"
      "xbts" "xchg" "xcryptcbc" "xcryptcfb" "xcryptctr" "xcryptecb"
      "xcryptofb" "xend" "xgetbv" "xlat" "xlatb" "xmm0" "xmm1" "xmm10"
      "xmm11" "xmm12" "xmm13" "xmm14" "xmm15" "xmm16" "xmm17" "xmm18"
      "xmm19" "xmm2" "xmm20" "xmm21" "xmm22" "xmm23" "xmm24" "xmm25"
      "xmm26" "xmm27" "xmm28" "xmm29" "xmm3" "xmm30" "xmm31" "xmm4"
      "xmm5" "xmm6" "xmm7" "xmm8" "xmm9" "xor" "xorpd" "xorps"
      "xrstor" "xrstor64" "xrstors" "xrstors64" "xsave" "xsave64"
      "xsavec" "xsavec64" "xsaveopt" "xsaveopt64" "xsaves" "xsaves64"
      "xsetbv" "xsha1" "xsha256" "xstore" "xtest" "ymm0" "ymm1"
      "ymm10" "ymm11" "ymm12" "ymm13" "ymm14" "ymm15" "ymm16" "ymm17"
      "ymm18" "ymm19" "ymm2" "ymm20" "ymm21" "ymm22" "ymm23" "ymm24"
      "ymm25" "ymm26" "ymm27" "ymm28" "ymm29" "ymm3" "ymm30" "ymm31"
      "ymm4" "ymm5" "ymm6" "ymm7" "ymm8" "ymm9" "z" "zmm0" "zmm1"
      "zmm10" "zmm11" "zmm12" "zmm13" "zmm14" "zmm15" "zmm16" "zmm17"
      "zmm18" "zmm19" "zmm2" "zmm20" "zmm21" "zmm22" "zmm23" "zmm24"
      "zmm25" "zmm26" "zmm27" "zmm28" "zmm29" "zmm3" "zmm30" "zmm31"
      "zmm4" "zmm5" "zmm6" "zmm7" "zmm8" "zmm9")
    "INTEL instructions (tokhash.c) for `intel-mode'."))

(eval-and-compile
  (defconst intel-types
    '("1to16" "1to2" "1to4" "1to8" "__float128h__" "__float128l__"
      "__float16__" "__float32__" "__float64__" "__float80e__"
      "__float80m__" "__float8__" "__infinity__" "__nan__" "__qnan__"
      "__snan__" "__utf16__" "__utf16be__" "__utf16le__" "__utf32__"
      "__utf32be__" "__utf32le__" "abs" "byte" "dword" "evex" "far"
      "long" "near" "nosplit" "oword" "qword" "rel" "seg" "short"
      "strict" "to" "tword" "vex2" "vex3" "word" "wrt" "yword"
      "zword")
    "INTEL types (tokens.dat) for `intel-mode'."))

(eval-and-compile
  (defconst intel-prefix
    '("a16" "a32" "a64" "asp" "lock" "o16" "o32" "o64" "osp" "rep" "repe"
      "repne" "repnz" "repz" "times" "wait" "xacquire" "xrelease" "bnd")
    "INTEL prefixes (intellib.c) for `intel-mode'."))

(eval-and-compile
  (defconst intel-pp-directives
    '("%elif" "%elifn" "%elifctx" "%elifnctx" "%elifdef" "%elifndef"
      "%elifempty" "%elifnempty" "%elifenv" "%elifnenv" "%elifid"
      "%elifnid" "%elifidn" "%elifnidn" "%elifidni" "%elifnidni"
      "%elifmacro" "%elifnmacro" "%elifnum" "%elifnnum" "%elifstr"
      "%elifnstr" "%eliftoken" "%elifntoken" "%if" "%ifn" "%ifctx"
      "%ifnctx" "%ifdef" "%ifndef" "%ifempty" "%ifnempty" "%ifenv"
      "%ifnenv" "%ifid" "%ifnid" "%ifidn" "%ifnidn" "%ifidni" "%ifnidni"
      "%ifmacro" "%ifnmacro" "%ifnum" "%ifnnum" "%ifstr" "%ifnstr"
      "%iftoken" "%ifntoken" "%arg" "%assign" "%clear" "%define"
      "%defstr" "%deftok" "%depend" "%else" "%endif" "%endm" "%endmacro"
      "%endrep" "%error" "%exitmacro" "%exitrep" "%fatal" "%iassign"
      "%idefine" "%idefstr" "%ideftok" "%imacro" "%include" "%irmacro"
      "%ixdefine" "%line" "%local" "%macro" "%pathsearch" "%pop" "%push"
      "%rep" "%repl" "%rmacro" "%rotate" "%stacksize" "%strcat"
      "%strlen" "%substr" "%undef" "%unimacro" "%unmacro" "%use"
      "%warning" "%xdefine" "istruc" "at" "iend" "align" "alignb"
      "struc" "endstruc" "__LINE__" "__FILE__" "%comment" "%endcomment"
      "__INTEL_MAJOR__" " __INTEL_MINOR__" "__INTEL_SUBMINOR__"
      "___INTEL_PATCHLEVEL__" "__INTEL_VERSION_ID__" "__INTEL_VER__"
      "__BITS__" "__OUTPUT_FORMAT__" "__DATE__" "__TIME__" "__DATE_NUM__"
      "__TIME_NUM__" "__UTC_DATE__" "__UTC_TIME__" "__UTC_DATE_NUM__"
      "__UTC_TIME_NUM__" "__POSIX_TIME__" " __PASS__" "SECTALIGN")
    "INTEL preprocessor directives (pptok.c) for `intel-mode'."))

(defconst intel-label-regexp
  "\\(\\_<[a-zA-Z_.?][a-zA-Z0-9_$#@~.?]*\\_>\\)\\s-*:"
  "Regexp for `intel-mode' for matching labels.")

(defconst intel-constant-regexp
  "\\_<$?[-+0-9][-+_0-9A-Fa-fHhXxDdTtQqOoBbYyeE.]*\\_>"
  "Regexp for `intel-mode' for matching numeric constants.")

(defmacro intel--opt (keywords)
  "Prepare KEYWORDS for `looking-at'."
  `(eval-when-compile
     (regexp-opt ,keywords 'symbols)))

(defconst intel-imenu-generic-expression
  `((nil ,(concat "^\\s-*" intel-label-regexp) 1)
    (nil ,(concat (intel--opt '("%define" "%macro"))
                  "\\s-+\\([a-zA-Z0-9_$#@~.?]+\\)") 2))
  "Expressions for `imenu-generic-expression'.")

(defconst intel-font-lock-keywords
  `(("\\_<\\.[a-zA-Z0-9_$#@~.?]+\\_>" . font-lock-type-face)
    (,(intel--opt intel-registers) . 'intel-registers)
    (,(intel--opt intel-prefix) . 'intel-prefix)
    (,(intel--opt intel-types) . 'intel-types)
    (,(intel--opt intel-instructions) . 'intel-instructions)
    (,(intel--opt intel-directives) . 'intel-directives)
    (,(intel--opt intel-pp-directives) . 'intel-preprocessor)
    (,(concat "^\\s-*" intel-label-regexp) (1 'intel-labels))
    (,intel-constant-regexp . 'intel-constant))
"Keywords for `intel-mode'.")

(defconst intel-mode-syntax-table
  (with-syntax-table (copy-syntax-table)
    (modify-syntax-entry ?_  "_")
    (modify-syntax-entry ?#  "_")
    (modify-syntax-entry ?@  "_")
    (modify-syntax-entry ?\? "_")
    (modify-syntax-entry ?~  "_")
    (modify-syntax-entry ?\. "w")
    (modify-syntax-entry ?\# "<")
    (modify-syntax-entry ?\n ">")
    (modify-syntax-entry ?\" "\"")
    (modify-syntax-entry ?\' "\"")
    (modify-syntax-entry ?\` "\"")
    (syntax-table))
  "Syntax table for `intel-mode'.")

(defvar intel-mode-map
  (let ((map (make-sparse-keymap)))
    (prog1 map
      (define-key map (kbd ":") #'intel-colon)
      (define-key map (kbd "#") #'intel-comment)))
  "Key bindings for `intel-mode'.")

(defun intel-colon ()
  "Insert a colon and convert the current line into a label."
  (interactive)
  (call-interactively #'self-insert-command)
  (intel-indent-line))

(defun intel-indent-line ()
  "Indent current line as INTEL assembly code."
  (interactive)
  (let ((orig (- (point-max) (point))))
    (back-to-indentation)
    (if (or (looking-at (intel--opt intel-directives))
            (looking-at (intel--opt intel-pp-directives))
            (looking-at "\\[")
            (looking-at "##+")
            (looking-at intel-label-regexp))
        (indent-line-to 0)
      (indent-line-to intel-basic-offset))
    (when (> (- (point-max) orig) (point))
      (goto-char (- (point-max) orig)))))

(defun intel--current-line ()
  "Return the current line as a string."
  (save-excursion
    (let ((start (progn (beginning-of-line) (point)))
          (end (progn (end-of-line) (point))))
      (buffer-substring-no-properties start end))))

(defun intel--empty-line-p ()
  "Return non-nil if current line has non-whitespace."
  (not (string-match-p "\\S-" (intel--current-line))))

(defun intel--line-has-comment-p ()
  "Return non-nil if current line contains a comment."
  (save-excursion
    (end-of-line)
    (nth 4 (syntax-ppss))))

(defun intel--line-has-non-comment-p ()
  "Return non-nil of the current line has code."
  (let* ((line (intel--current-line))
         (match (string-match-p "\\S-" line)))
    (when match
      (not (eql ?\; (aref line match))))))

(defun intel--inside-indentation-p ()
  "Return non-nil if point is within the indentation."
  (save-excursion
    (let ((point (point))
          (start (progn (beginning-of-line) (point)))
          (end (progn (back-to-indentation) (point))))
      (and (<= start point) (<= point end)))))

(defun intel-comment (&optional arg)
  "Begin or edit a comment with context-sensitive placement.

The right-hand comment gutter is far away from the code, so this
command uses the mark ring to help move back and forth between
code and the comment gutter.

* If no comment gutter exists yet, mark the current position and
  jump to it.
* If already within the gutter, pop the top mark and return to
  the code.
* If on a line with no code, just insert a comment character.
* If within the indentation, just insert a comment character.
  This is intended prevent interference when the intention is to
  comment out the line.

With a prefix arg, kill the comment on the current line with
`comment-kill'."
  (interactive "p")
  (if (not (eql arg 1))
      (comment-kill nil)
    (cond
     ;; Empty line? Insert.
     ((intel--empty-line-p)
      (insert "#"))
     ;; Inside the indentation? Comment out the line.
     ((intel--inside-indentation-p)
      (insert "#"))
     ;; Currently in a right-side comment? Return.
     ((and (intel--line-has-comment-p)
           (intel--line-has-non-comment-p)
           (nth 4 (syntax-ppss)))
      (setf (point) (mark))
      (pop-mark))
     ;; Line has code? Mark and jump to right-side comment.
     ((intel--line-has-non-comment-p)
      (push-mark)
      (comment-indent))
     ;; Otherwise insert.
     ((insert "#")))))

;;;###autoload
(define-derived-mode intel-mode prog-mode "INTEL"
  "Major mode for editing INTEL assembly programs."
  :group 'intel-mode
  (setf font-lock-defaults '(intel-font-lock-keywords nil :case-fold)
        indent-line-function #'intel-indent-line
        comment-start "#"
        imenu-generic-expression intel-imenu-generic-expression))

(provide 'intel-mode)

;;; intel-mode.el ends here
