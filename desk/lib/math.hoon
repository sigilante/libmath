  ::
::::  Mathematical library
::
::  Pure Hoon implementations are naive formally correct algorithms,
::  awaiting efficient jetting with GNU Scientific Library.
::
|%
++  rs
  ^|
  |_  $:  r=$?(%n %u %d %z)   :: round nearest, up, down, to zero
          rtol=_.1e-5         :: relative tolerance for precision of operations
      ==
  ::  mathematics constants to single precision
  ::  OEIS A019692
  ++  tau  .6.2831855
  ::  OEIS A000796
  ++  pi  .3.1415927
  ::  OEIS A001113
  ++  e  .2.7182817
  ::  OEIS A001622
  ++  phi  .1.618034
  ::  OEIS A002193
  ++  sqt2  .1.4142135
  ::  OEIS A010503
  ++  invsqt2  .70710677
  ::  OEIS A002162
  ++  log2  .0.6931472
  ++  invlog2  .1.442695
  ::  OEIS A002392
  ++  log10  .2.3025851
  ::
  ::  Operations
  ::
  ++  sea  sea:^rs
  ++  bit  bit:^rs
  ++  sun  sun:^rs
  ++  san  san:^rs
  ::++  exp  exp:^rs  :: no pass-through because of exp function
  ++  toi  toi:^rs
  ++  drg  drg:^rs
  ++  grd  grd:^rs
  ::
  ::  Comparison
  ::
  ++  lth  lth:^rs
  ++  lte  lte:^rs
  ++  leq  lte:^rs
  ++  equ  equ:^rs
  ++  gte  gte:^rs
  ++  gth  gth:^rs
  ++  geq  gte:^rs
  ++  neq  |=([a=@rs b=@rs] ^-(@rs !(equ:^rs a b)))
  ++  isclose
    |=  [p=@rs r=@rs]
    (lth (abs (sub p r)) rtol)
  ++  allclose
    |=  [p=@rs q=(list @rs)]
    =/  i  0
    =/  n  (lent q)
    |-  ^-  ?
    ?:  =(n i)
      %.y
    ?.  (isclose p (snag i q))
      %.n
    $(i +(i))
  ::  use equality rather than isclose here
  ++  isint
    |=  x=@rs  ^-  ?
    (equ x (san (need (toi x))))
  ::
  ::  Algebraic
  ::
  ++  add  add:^rs
  ++  sub  sub:^rs
  ++  mul  mul:^rs
  ++  div  div:^rs
  ++  fma  fma:^rs
  ++  sig  |=(x=@rs =(0 (rsh [0 31] x)))
  ++  sgn  sig
  ++  neg  |=(x=@rs (sub .0 x))
  ++  factorial
    |=  x=@rs  ^-  @rs
    =/  t=@rs  .1
    ?:  (isclose x .0)
      t
    |-  ^-  @rs
    ?:  (isclose x .1)
      t
    $(x (sub x .1), t (mul t x))
  ++  abs
    |=  x=@rs  ^-  @rs
    ?:((sgn x) x (neg x))
  ::  exponential of x
  ::  follows the sense of https://www.netlib.org/fdlibm/e_exp.c
  ::
  
  ++  exp
    |=  x=@rs  ^-  @rs
    |^
    =|  y=@rs
    =|  hi=@rs
    =|  lo=@rs
    =|  c=@rs
    =|  t=@rs
    =|  hx=@  (hi x)
    =|  xsb=@  (dis (rsh [0 31] hx) 0b1)
    =.  hx  (dis hx 0x7fff.ffff)
    ::  filter on non-finite arguments
    ?:  (gth hx 0x4086.2e42)
      ::  if |x| > 709.78... then overflow
      ?:  (gth hx 0x7ff0.0000)
        ?:  =(0 (con (dis hx 0xf.ffff) (lo x)))
          (add x x)  :: NaN
        ?:  =(0 xsb)  :: exp(+-inf) = {+inf,0}
          x
        .0.0
    =/  huge	.1.0e300
    =/  twom1000  .9.33263618503218878990e-302
    =/  o-threshold  7.09782712893383973096e+02  ::  0x40862E42, 0xFEFA39EF
    =/  u-threshold  -7.45133219101941108420e+02  ::  0xc0874910, 0xD52D3051
    ::  overflow?
    ?:  (gth x o-threshold)  (mul huge huge)
    ::  underflow?
    ?:  (lth x u-threshold)  (mul twom1000 twom1000)
    ::
    ::  argument reduction
    ::
    ?:  &((lth hx 0x3e30.0000) (gth (add huge x) .1))  ::  when |x| < 2**-28
      (add .1.0 x)
    ?:  (gth hx 0x3fd6.2e42)  ::  if |x| > 0.5 ln2
      ?:  (lth hx 0x3ff0.a2b2)  ::  and |x| < 1.5 ln2
        =/  hi  (sub x (mul ln2HI[xsb] .0.5))
      =/  k=@si  (add (mul invlog2 x) halF[xsb])
      =/  t  k
      =/  hi  (sub x (mul k ln2HI[xsb]))
      =/  lo  (mul k ln2LO[xsb])


ln2HI[2]   ={ 6.93147180369123816490e-01,  /* 0x3fe62e42, 0xfee00000 */
	     -6.93147180369123816490e-01,},/* 0xbfe62e42, 0xfee00000 */
ln2LO[2]   ={ 1.90821492927058770002e-10,  /* 0x3dea39ef, 0x35793c76 */
	     -1.90821492927058770002e-10,},/* 0xbdea39ef, 0x35793c76 */
invln2 =  1.44269504088896338700e+00, /* 0x3ff71547, 0x652b82fe */
P1   =  1.66666666666666019037e-01, /* 0x3FC55555, 0x5555553E */
P2   = -2.77777777770155933842e-03, /* 0xBF66C16C, 0x16BEBD93 */
P3   =  6.61375632143793436117e-05, /* 0x3F11566A, 0xAF25DE2C */
P4   = -1.65339022054652515390e-06, /* 0xBEBBBD41, 0xC5D26BF1 */
P5   =  4.13813679705723846039e-08; /* 0x3E663769, 0x72BEA4D0 */
    

    ?:  (gte:si k --1.021)
      =.  k  (div k 2)
      (con (hi y) (lsh [0 20] (sun:si k)))

    ++  hi
      |=  x=@  ^-  @
      (rsh [0 16] (dis 0xffff.0000 x))
    ++  lo
      |=  x=@  ^-  @
      (dis 0xffff x)
    --

  ++  exp
    |=  x=@rs  ^-  @rs
    =/  p   .1
    =/  po  .-1
    =/  i   .1
    |-  ^-  @rs
    ?:  (lth (abs (sub po p)) rtol)
      p
    $(i (add i .1), p (add p (div (pow-n x i) (factorial i))), po p)
  ::  restricted power for integers only
  ++  pow-n
    |=  [x=@rs n=@rs]  ^-  @rs
    ?:  =(n .0)  .1
    =/  p  x
    |-  ^-  @rs
    ?:  (lth n .2)
      p
    $(n (sub n .1), p (mul p x))
  ::  natural logarithm, only converges for z < 2
  ++  log-e-2
    |=  z=@rs  ^-  @rs
    =/  p   .0
    =/  po  .-1
    =/  i   .1
    |-  ^-  @rs
    ?:  (lth (abs (sub po p)) rtol)
      p
    =/  ii  (add .1 i)
    =/  term  (mul (pow-n .-1 (add .1 i)) (div (pow-n (sub z .1) i) i))
    $(i (add i .1), p (add p term), po p)
  ::  natural logarithm, z > 0
  ::  https://www.netlib.org/fdlibm/e_log.c
  ++  log
    |=  z=@rs  ^-  @rs
    =/  p   .0
    =/  po  .-1
    =/  i   .0
    |-  ^-  @rs
    ?:  (lth (abs (sub po p)) rtol)
      (mul (div (mul .2 (sub z .1)) (add z .1)) p)
    =/  term1  (div .1 (add .1 (mul .2 i)))
    =/  term2  (mul (sub z .1) (sub z .1))
    =/  term3  (mul (add z .1) (add z .1))
    =/  term  (mul term1 (pow-n (div term2 term3) i))
    $(i (add i .1), p (add p term), po p)
  ::  logarithm base 2
  ++  log2
    |=  z=@rs
    (div (log z) ln2)
  ::  logarithm base 10
  ++  log10
    |=  z=@rs
    (div (log z) ln10)
  ::  general power, based on logarithms
  ::  x^n = exp(n ln x)
  ++  pow
    |=  [x=@rs n=@rs]  ^-  @rs
    (exp (mul n (log x)))
  ::  square root
  ++  sqrt  sqt
  ++  sqt
    |=  x=@rs  ^-  @rs
    ?>  (sgn x)
    (pow x .0.5)
  ::  cube root
  ++  cbrt  cbt
  ++  cbt
    |=  x=@rs  ^-  @rs
    ?>  (sgn x)
    (pow x .0.33333333)
  ::  argument (real argument = absolute value)
  ++  arg  abs
  --
++  rd
  |%
  ::  mathematics constants to double precision
  ::  OEIS A019692
  ++  tau  .6.283185307179586
  ::  OEIS A000796
  ++  pi  .3.141592653589793
  ::  OEIS A001113
  ++  e  .2.718281828459045
  ::  OEIS A001622
  ++  phi  .1.618033988749895
  ::  OEIS A002193
  ++  sqt2  .1.4142135623730951
  ::  OEIS A010503
  ++  invsqt2  .7071067811865476
  ::  OEIS A002162
  ++  log2  .0.6931471805599453
  ++  invlog2  .1.4426950408889634
  ::  OEIS A002392
  ++  log10  .2.302585092994046
  --

++  rh
  |%
  ::  mathematics constants to half precision
  ::  OEIS A019692
  ++  tau  .6.28
  ::  OEIS A000796
  ++  pi  .3.14
  ::  OEIS A001113
  ++  e  .2.719
  ::  OEIS A001622
  ++  phi  .1.618
  ::  OEIS A002193
  ++  sqt2  .1.414
  ::  OEIS A010503
  ++  invsqt2  .707
  ::  OEIS A002162
  ++  log2  .0.6934
  ++  invlog2  .1.443
  ::  OEIS A002392
  ++  log10  .2.303
  --

++  rq
  |%
  ::  mathematics constants to quad precision
  ::  OEIS A019692
  ++  tau  .~~~6.2831853071795864769252867665590056
  ::  OEIS A000796
  ++  pi  .~~~3.1415926535897932384626433832795028
  ::  OEIS A001113
  ++  e  .~~~2.7182818284590452353602874713526623
  ::  OEIS A001622
  ++  phi  .~~~1.6180339887498948482045868343656382
  ::  OEIS A002193
  ++  sqt2  .~~~1.414213562373095048801688724209698
  ::  OEIS A010503
  ++  invsqt2  .~~~0.707106781186547524400844362104849
  ::  OEIS A002162
  ++  log2  .~~~0.6931471805599453094172321214581766
  ++  invlog2  .~~~1.442695040888963387004650940070860  :: TODO check
  ::  OEIS A002392
  ++  log10  .~~~2.302585092994045684017991454684364
  --

++  reference-core
  |%
  ::  hardcoded string constants for your viewing pleasure
  ::  OEIS A019692
  ++  tau    .~~~6.28318530717958647692528676655900576839433879875021164194988918461563281257241799625606965068423413596428
  ::  OEIS A000796
  ++  pi     .~~~3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214
  ::  OEIS A001113
  ++  e      .~~~2.71828182845904523536028747135266249775724709369995957496696762772407663035354759457138217852516642742746
  ::  OEIS A001622
  ++  phi    .~~~1.61803398874989484820458683436563811772030917980576286213544862270526046281890244970720720418939113748475
  ::  OEIS  A002193
  ++  sqt2  .~~~1.41421356237309504880168872420969807856967187537694807317667973799073247846210703885038753432764157273
  ::  OEIS A010503
  ++  invsqt2  .~~~0.70710678118654752440084436210484903928483593768847403658833986899536623923105351942519376716382086
  ::  OEIS A002162
  ++  log2    .~~~0.69314718055994530941723212145817656807550013436025525412068000949339362196969471560586332699641868754
  ::  OEIS A002392
  ++  log10   .~~~2.30258509299404568401799145468436420760110148862877297603332790096757260967735248023599726645985502929
  [tau pi e phi sqt2 invsqt2 log2 log10]
  --
