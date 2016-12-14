; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=sse4.2                                                 | FileCheck %s --check-prefix=ALL --check-prefix=STRICT
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=sse4.2 -enable-unsafe-fp-math -enable-no-nans-fp-math  | FileCheck %s --check-prefix=ALL --check-prefix=RELAX --check-prefix=UNSAFE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=sse4.2 -enable-no-nans-fp-math                         | FileCheck %s --check-prefix=ALL --check-prefix=RELAX --check-prefix=FINITE

; Some of these patterns can be matched as SSE min or max. Some of
; them can be matched provided that the operands are swapped.
; Some of them can't be matched at all and require a comparison
; and a conditional branch.

; The naming convention is {,x_,y_}{o,u}{gt,lt,ge,le}{,_inverse}
;  _x: use 0.0 instead of %y
;  _y: use -0.0 instead of %y
; _inverse : swap the arms of the select.

define double @ogt(double %x, double %y)  {
; ALL-LABEL: ogt:
; ALL:       # BB#0:
; ALL-NEXT:    maxsd %xmm1, %xmm0
; ALL-NEXT:    retq
;
  %c = fcmp ogt double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @olt(double %x, double %y)  {
; ALL-LABEL: olt:
; ALL:       # BB#0:
; ALL-NEXT:    minsd %xmm1, %xmm0
; ALL-NEXT:    retq
;
  %c = fcmp olt double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @ogt_inverse(double %x, double %y)  {
; STRICT-LABEL: ogt_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ogt_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ogt_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ogt double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @olt_inverse(double %x, double %y)  {
; STRICT-LABEL: olt_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: olt_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: olt_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp olt double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @oge(double %x, double %y)  {
; STRICT-LABEL: oge:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm1, %xmm2
; STRICT-NEXT:    cmplesd %xmm0, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm0
; STRICT-NEXT:    andnps %xmm1, %xmm2
; STRICT-NEXT:    orps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: oge:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp oge double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @ole(double %x, double %y)  {
; STRICT-LABEL: ole:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmplesd %xmm1, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm0
; STRICT-NEXT:    andnps %xmm1, %xmm2
; STRICT-NEXT:    orps %xmm0, %xmm2
; STRICT-NEXT:    movaps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ole:
; RELAX:       # BB#0:
; RELAX-NEXT:    minsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ole double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @oge_inverse(double %x, double %y)  {
; STRICT-LABEL: oge_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm1, %xmm2
; STRICT-NEXT:    cmplesd %xmm0, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm2
; STRICT-NEXT:    orps %xmm1, %xmm2
; STRICT-NEXT:    movaps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: oge_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: oge_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp oge double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @ole_inverse(double %x, double %y)  {
; STRICT-LABEL: ole_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmplesd %xmm1, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm2
; STRICT-NEXT:    orps %xmm1, %xmm2
; STRICT-NEXT:    movaps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ole_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ole_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ole double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @ogt_x(double %x)  {
; ALL-LABEL: ogt_x:
; ALL:       # BB#0:
; ALL-NEXT:    xorpd %xmm1, %xmm1
; ALL-NEXT:    maxsd %xmm1, %xmm0
; ALL-NEXT:    retq
;
  %c = fcmp ogt double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @olt_x(double %x)  {
; ALL-LABEL: olt_x:
; ALL:       # BB#0:
; ALL-NEXT:    xorpd %xmm1, %xmm1
; ALL-NEXT:    minsd %xmm1, %xmm0
; ALL-NEXT:    retq
;
  %c = fcmp olt double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @ogt_inverse_x(double %x)  {
; STRICT-LABEL: ogt_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorpd %xmm1, %xmm1
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ogt_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ogt_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ogt double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @olt_inverse_x(double %x)  {
; STRICT-LABEL: olt_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorpd %xmm1, %xmm1
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: olt_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: olt_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp olt double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @oge_x(double %x)  {
; STRICT-LABEL: oge_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm1, %xmm1
; STRICT-NEXT:    cmplesd %xmm0, %xmm1
; STRICT-NEXT:    andps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: oge_x:
; RELAX:       # BB#0:
; RELAX-NEXT:    xorpd %xmm1, %xmm1
; RELAX-NEXT:    maxsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp oge double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @ole_x(double %x)  {
; STRICT-LABEL: ole_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm2, %xmm2
; STRICT-NEXT:    movaps %xmm0, %xmm1
; STRICT-NEXT:    cmplesd %xmm2, %xmm1
; STRICT-NEXT:    andps %xmm0, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ole_x:
; RELAX:       # BB#0:
; RELAX-NEXT:    xorpd %xmm1, %xmm1
; RELAX-NEXT:    minsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ole double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @oge_inverse_x(double %x)  {
; STRICT-LABEL: oge_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm1, %xmm1
; STRICT-NEXT:    cmplesd %xmm0, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: oge_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: oge_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp oge double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @ole_inverse_x(double %x)  {
; STRICT-LABEL: ole_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm2, %xmm2
; STRICT-NEXT:    movaps %xmm0, %xmm1
; STRICT-NEXT:    cmplesd %xmm2, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ole_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ole_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ole double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @ugt(double %x, double %y)  {
; STRICT-LABEL: ugt:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmpnlesd %xmm1, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm0
; STRICT-NEXT:    andnps %xmm1, %xmm2
; STRICT-NEXT:    orps %xmm0, %xmm2
; STRICT-NEXT:    movaps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ugt:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ugt double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @ult(double %x, double %y)  {
; STRICT-LABEL: ult:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm1, %xmm2
; STRICT-NEXT:    cmpnlesd %xmm0, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm0
; STRICT-NEXT:    andnps %xmm1, %xmm2
; STRICT-NEXT:    orps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ult:
; RELAX:       # BB#0:
; RELAX-NEXT:    minsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ult double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @ugt_inverse(double %x, double %y)  {
; STRICT-LABEL: ugt_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmpnlesd %xmm1, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm2
; STRICT-NEXT:    orps %xmm1, %xmm2
; STRICT-NEXT:    movaps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ugt_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ugt_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ugt double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @ult_inverse(double %x, double %y)  {
; STRICT-LABEL: ult_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm1, %xmm2
; STRICT-NEXT:    cmpnlesd %xmm0, %xmm2
; STRICT-NEXT:    andps %xmm2, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm2
; STRICT-NEXT:    orps %xmm1, %xmm2
; STRICT-NEXT:    movaps %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ult_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ult_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ult double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @uge(double %x, double %y)  {
; STRICT-LABEL: uge:
; STRICT:       # BB#0:
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: uge:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp uge double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @ule(double %x, double %y)  {
; STRICT-LABEL: ule:
; STRICT:       # BB#0:
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ule:
; RELAX:       # BB#0:
; RELAX-NEXT:    minsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ule double %x, %y
  %d = select i1 %c, double %x, double %y
  ret double %d
}

define double @uge_inverse(double %x, double %y)  {
; STRICT-LABEL: uge_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    minsd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: uge_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: uge_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp uge double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @ule_inverse(double %x, double %y)  {
; STRICT-LABEL: ule_inverse:
; STRICT:       # BB#0:
; STRICT-NEXT:    maxsd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ule_inverse:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ule_inverse:
; FINITE:       # BB#0:
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ule double %x, %y
  %d = select i1 %c, double %y, double %x
  ret double %d
}

define double @ugt_x(double %x)  {
; STRICT-LABEL: ugt_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm2, %xmm2
; STRICT-NEXT:    movaps %xmm0, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm2, %xmm1
; STRICT-NEXT:    andps %xmm0, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ugt_x:
; RELAX:       # BB#0:
; RELAX-NEXT:    xorpd %xmm1, %xmm1
; RELAX-NEXT:    maxsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ugt double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @ult_x(double %x)  {
; STRICT-LABEL: ult_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm1, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm0, %xmm1
; STRICT-NEXT:    andps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ult_x:
; RELAX:       # BB#0:
; RELAX-NEXT:    xorpd %xmm1, %xmm1
; RELAX-NEXT:    minsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ult double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @ugt_inverse_x(double %x)  {
; STRICT-LABEL: ugt_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm2, %xmm2
; STRICT-NEXT:    movaps %xmm0, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm2, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ugt_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ugt_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ugt double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @ult_inverse_x(double %x)  {
; STRICT-LABEL: ult_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorps %xmm1, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm0, %xmm1
; STRICT-NEXT:    andnps %xmm0, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ult_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ult_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ult double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @uge_x(double %x)  {
; STRICT-LABEL: uge_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorpd %xmm1, %xmm1
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: uge_x:
; RELAX:       # BB#0:
; RELAX-NEXT:    xorpd %xmm1, %xmm1
; RELAX-NEXT:    maxsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp uge double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @ule_x(double %x)  {
; STRICT-LABEL: ule_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorpd %xmm1, %xmm1
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ule_x:
; RELAX:       # BB#0:
; RELAX-NEXT:    xorpd %xmm1, %xmm1
; RELAX-NEXT:    minsd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ule double %x, 0.000000e+00
  %d = select i1 %c, double %x, double 0.000000e+00
  ret double %d
}

define double @uge_inverse_x(double %x)  {
; STRICT-LABEL: uge_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorpd %xmm1, %xmm1
; STRICT-NEXT:    minsd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: uge_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    minsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: uge_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp uge double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @ule_inverse_x(double %x)  {
; STRICT-LABEL: ule_inverse_x:
; STRICT:       # BB#0:
; STRICT-NEXT:    xorpd %xmm1, %xmm1
; STRICT-NEXT:    maxsd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ule_inverse_x:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    xorpd %xmm1, %xmm1
; UNSAFE-NEXT:    maxsd %xmm1, %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ule_inverse_x:
; FINITE:       # BB#0:
; FINITE-NEXT:    xorpd %xmm1, %xmm1
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ule double %x, 0.000000e+00
  %d = select i1 %c, double 0.000000e+00, double %x
  ret double %d
}

define double @ogt_y(double %x)  {
; ALL-LABEL: ogt_y:
; ALL:       # BB#0:
; ALL-NEXT:    maxsd {{.*}}(%rip), %xmm0
; ALL-NEXT:    retq
;
  %c = fcmp ogt double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @olt_y(double %x)  {
; ALL-LABEL: olt_y:
; ALL:       # BB#0:
; ALL-NEXT:    minsd {{.*}}(%rip), %xmm0
; ALL-NEXT:    retq
;
  %c = fcmp olt double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @ogt_inverse_y(double %x)  {
; STRICT-LABEL: ogt_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ogt_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ogt_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ogt double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @olt_inverse_y(double %x)  {
; STRICT-LABEL: olt_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: olt_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: olt_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp olt double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @oge_y(double %x)  {
; STRICT-LABEL: oge_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    movapd %xmm1, %xmm2
; STRICT-NEXT:    cmplesd %xmm0, %xmm2
; STRICT-NEXT:    andpd %xmm2, %xmm0
; STRICT-NEXT:    andnpd %xmm1, %xmm2
; STRICT-NEXT:    orpd %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: oge_y:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxsd {{.*}}(%rip), %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp oge double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @ole_y(double %x)  {
; STRICT-LABEL: ole_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; STRICT-NEXT:    movapd %xmm0, %xmm1
; STRICT-NEXT:    cmplesd %xmm2, %xmm1
; STRICT-NEXT:    andpd %xmm1, %xmm0
; STRICT-NEXT:    andnpd %xmm2, %xmm1
; STRICT-NEXT:    orpd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ole_y:
; RELAX:       # BB#0:
; RELAX-NEXT:    minsd {{.*}}(%rip), %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ole double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @oge_inverse_y(double %x)  {
; STRICT-LABEL: oge_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; STRICT-NEXT:    movapd %xmm2, %xmm1
; STRICT-NEXT:    cmplesd %xmm0, %xmm1
; STRICT-NEXT:    andpd %xmm1, %xmm2
; STRICT-NEXT:    andnpd %xmm0, %xmm1
; STRICT-NEXT:    orpd %xmm2, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: oge_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: oge_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp oge double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @ole_inverse_y(double %x)  {
; STRICT-LABEL: ole_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; STRICT-NEXT:    movapd %xmm0, %xmm1
; STRICT-NEXT:    cmplesd %xmm2, %xmm1
; STRICT-NEXT:    andpd %xmm1, %xmm2
; STRICT-NEXT:    andnpd %xmm0, %xmm1
; STRICT-NEXT:    orpd %xmm2, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ole_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ole_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ole double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @ugt_y(double %x)  {
; STRICT-LABEL: ugt_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; STRICT-NEXT:    movapd %xmm0, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm2, %xmm1
; STRICT-NEXT:    andpd %xmm1, %xmm0
; STRICT-NEXT:    andnpd %xmm2, %xmm1
; STRICT-NEXT:    orpd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ugt_y:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxsd {{.*}}(%rip), %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ugt double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @ult_y(double %x)  {
; STRICT-LABEL: ult_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    movapd %xmm1, %xmm2
; STRICT-NEXT:    cmpnlesd %xmm0, %xmm2
; STRICT-NEXT:    andpd %xmm2, %xmm0
; STRICT-NEXT:    andnpd %xmm1, %xmm2
; STRICT-NEXT:    orpd %xmm2, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ult_y:
; RELAX:       # BB#0:
; RELAX-NEXT:    minsd {{.*}}(%rip), %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ult double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @ugt_inverse_y(double %x)  {
; STRICT-LABEL: ugt_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; STRICT-NEXT:    movapd %xmm0, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm2, %xmm1
; STRICT-NEXT:    andpd %xmm1, %xmm2
; STRICT-NEXT:    andnpd %xmm0, %xmm1
; STRICT-NEXT:    orpd %xmm2, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ugt_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ugt_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ugt double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @ult_inverse_y(double %x)  {
; STRICT-LABEL: ult_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; STRICT-NEXT:    movapd %xmm2, %xmm1
; STRICT-NEXT:    cmpnlesd %xmm0, %xmm1
; STRICT-NEXT:    andpd %xmm1, %xmm2
; STRICT-NEXT:    andnpd %xmm0, %xmm1
; STRICT-NEXT:    orpd %xmm2, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ult_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ult_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ult double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @uge_y(double %x)  {
; STRICT-LABEL: uge_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: uge_y:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxsd {{.*}}(%rip), %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp uge double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @ule_y(double %x)  {
; STRICT-LABEL: ule_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: ule_y:
; RELAX:       # BB#0:
; RELAX-NEXT:    minsd {{.*}}(%rip), %xmm0
; RELAX-NEXT:    retq
;
  %c = fcmp ule double %x, -0.000000e+00
  %d = select i1 %c, double %x, double -0.000000e+00
  ret double %d
}

define double @uge_inverse_y(double %x)  {
; STRICT-LABEL: uge_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    minsd {{.*}}(%rip), %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: uge_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: uge_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp uge double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

define double @ule_inverse_y(double %x)  {
; STRICT-LABEL: ule_inverse_y:
; STRICT:       # BB#0:
; STRICT-NEXT:    maxsd {{.*}}(%rip), %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: ule_inverse_y:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: ule_inverse_y:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %c = fcmp ule double %x, -0.000000e+00
  %d = select i1 %c, double -0.000000e+00, double %x
  ret double %d
}

; Test a few more misc. cases.

define double @clampTo3k_a(double %x)  {
; STRICT-LABEL: clampTo3k_a:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_a:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_a:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp ogt double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_b(double %x)  {
; STRICT-LABEL: clampTo3k_b:
; STRICT:       # BB#0:
; STRICT-NEXT:    minsd {{.*}}(%rip), %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_b:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_b:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp uge double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_c(double %x)  {
; STRICT-LABEL: clampTo3k_c:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_c:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_c:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp olt double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_d(double %x)  {
; STRICT-LABEL: clampTo3k_d:
; STRICT:       # BB#0:
; STRICT-NEXT:    maxsd {{.*}}(%rip), %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_d:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_d:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp ule double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_e(double %x)  {
; STRICT-LABEL: clampTo3k_e:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    maxsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_e:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_e:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp olt double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_f(double %x)  {
; STRICT-LABEL: clampTo3k_f:
; STRICT:       # BB#0:
; STRICT-NEXT:    maxsd {{.*}}(%rip), %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_f:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    maxsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_f:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    maxsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp ule double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_g(double %x)  {
; STRICT-LABEL: clampTo3k_g:
; STRICT:       # BB#0:
; STRICT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; STRICT-NEXT:    minsd %xmm0, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_g:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_g:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp ogt double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define double @clampTo3k_h(double %x)  {
; STRICT-LABEL: clampTo3k_h:
; STRICT:       # BB#0:
; STRICT-NEXT:    minsd {{.*}}(%rip), %xmm0
; STRICT-NEXT:    retq
;
; UNSAFE-LABEL: clampTo3k_h:
; UNSAFE:       # BB#0:
; UNSAFE-NEXT:    minsd {{.*}}(%rip), %xmm0
; UNSAFE-NEXT:    retq
;
; FINITE-LABEL: clampTo3k_h:
; FINITE:       # BB#0:
; FINITE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; FINITE-NEXT:    minsd %xmm0, %xmm1
; FINITE-NEXT:    movapd %xmm1, %xmm0
; FINITE-NEXT:    retq
;
  %t0 = fcmp uge double %x, 3.000000e+03
  %y = select i1 %t0, double 3.000000e+03, double %x
  ret double %y
}

define <2 x double> @test_maxpd(<2 x double> %x, <2 x double> %y)  {
; STRICT-LABEL: test_maxpd:
; STRICT:       # BB#0:
; STRICT-NEXT:    movapd %xmm0, %xmm2
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    cmplepd %xmm2, %xmm0
; STRICT-NEXT:    blendvpd %xmm2, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_maxpd:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxpd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %max_is_x = fcmp oge <2 x double> %x, %y
  %max = select <2 x i1> %max_is_x, <2 x double> %x, <2 x double> %y
  ret <2 x double> %max
}

define <2 x double> @test_minpd(<2 x double> %x, <2 x double> %y)  {
; STRICT-LABEL: test_minpd:
; STRICT:       # BB#0:
; STRICT-NEXT:    movapd %xmm0, %xmm2
; STRICT-NEXT:    cmplepd %xmm1, %xmm0
; STRICT-NEXT:    blendvpd %xmm2, %xmm1
; STRICT-NEXT:    movapd %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_minpd:
; RELAX:       # BB#0:
; RELAX-NEXT:    minpd %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %min_is_x = fcmp ole <2 x double> %x, %y
  %min = select <2 x i1> %min_is_x, <2 x double> %x, <2 x double> %y
  ret <2 x double> %min
}

define <4 x float> @test_maxps(<4 x float> %x, <4 x float> %y)  {
; STRICT-LABEL: test_maxps:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    cmpleps %xmm2, %xmm0
; STRICT-NEXT:    blendvps %xmm2, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_maxps:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxps %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %max_is_x = fcmp oge <4 x float> %x, %y
  %max = select <4 x i1> %max_is_x, <4 x float> %x, <4 x float> %y
  ret <4 x float> %max
}

define <4 x float> @test_minps(<4 x float> %x, <4 x float> %y)  {
; STRICT-LABEL: test_minps:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmpleps %xmm1, %xmm0
; STRICT-NEXT:    blendvps %xmm2, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_minps:
; RELAX:       # BB#0:
; RELAX-NEXT:    minps %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %min_is_x = fcmp ole <4 x float> %x, %y
  %min = select <4 x i1> %min_is_x, <4 x float> %x, <4 x float> %y
  ret <4 x float> %min
}

define <2 x float> @test_maxps_illegal_v2f32(<2 x float> %x, <2 x float> %y)  {
; STRICT-LABEL: test_maxps_illegal_v2f32:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    cmpleps %xmm2, %xmm0
; STRICT-NEXT:    insertps {{.*#+}} xmm0 = xmm0[0,1],zero,xmm0[1]
; STRICT-NEXT:    pslld $31, %xmm0
; STRICT-NEXT:    blendvps %xmm2, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_maxps_illegal_v2f32:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxps %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %max_is_x = fcmp oge <2 x float> %x, %y
  %max = select <2 x i1> %max_is_x, <2 x float> %x, <2 x float> %y
  ret <2 x float> %max
}

define <2 x float> @test_minps_illegal_v2f32(<2 x float> %x, <2 x float> %y)  {
; STRICT-LABEL: test_minps_illegal_v2f32:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmpleps %xmm1, %xmm0
; STRICT-NEXT:    insertps {{.*#+}} xmm0 = xmm0[0,1],zero,xmm0[1]
; STRICT-NEXT:    pslld $31, %xmm0
; STRICT-NEXT:    blendvps %xmm2, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_minps_illegal_v2f32:
; RELAX:       # BB#0:
; RELAX-NEXT:    minps %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %min_is_x = fcmp ole <2 x float> %x, %y
  %min = select <2 x i1> %min_is_x, <2 x float> %x, <2 x float> %y
  ret <2 x float> %min
}

define <3 x float> @test_maxps_illegal_v3f32(<3 x float> %x, <3 x float> %y)  {
; STRICT-LABEL: test_maxps_illegal_v3f32:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    cmpleps %xmm2, %xmm0
; STRICT-NEXT:    blendvps %xmm2, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_maxps_illegal_v3f32:
; RELAX:       # BB#0:
; RELAX-NEXT:    maxps %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %max_is_x = fcmp oge <3 x float> %x, %y
  %max = select <3 x i1> %max_is_x, <3 x float> %x, <3 x float> %y
  ret <3 x float> %max
}

define <3 x float> @test_minps_illegal_v3f32(<3 x float> %x, <3 x float> %y)  {
; STRICT-LABEL: test_minps_illegal_v3f32:
; STRICT:       # BB#0:
; STRICT-NEXT:    movaps %xmm0, %xmm2
; STRICT-NEXT:    cmpleps %xmm1, %xmm0
; STRICT-NEXT:    blendvps %xmm2, %xmm1
; STRICT-NEXT:    movaps %xmm1, %xmm0
; STRICT-NEXT:    retq
;
; RELAX-LABEL: test_minps_illegal_v3f32:
; RELAX:       # BB#0:
; RELAX-NEXT:    minps %xmm1, %xmm0
; RELAX-NEXT:    retq
;
  %min_is_x = fcmp ole <3 x float> %x, %y
  %min = select <3 x i1> %min_is_x, <3 x float> %x, <3 x float> %y
  ret <3 x float> %min
}
