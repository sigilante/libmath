#   `/lib/math` for Urbit

We support the following functions and special functions:

- $+$ addition
- $-$ subtraction
- $\times$ multiplication
- $/$ division
- $\text{fma}$ fused multiply-add
- $\text{sgn}$ signum
- $-$ unary negation
- $!$ factorial
- $\abs$
- $\exp$
- $\sin$
- $\cos$
- $\tan$

Logical functions:

- $<$
- $\leq$
- $>$
- $\geq$
- $=$
- $\neq$ not equal to
- `isclose`
- `allclose`
- `isint`

It would be nice to have the following special functions as well:

- $\arcsin$
- $\arccos$
- $\arctan$
- $\sinh$
- $\cosh$
- $\tanh$

We do not envision including the Bessel functions and other more abstruse functions.

We use naïve algorithms which are highly reproducible.  We special-case some arguments to make them tractable without catastrophic cancellation.
