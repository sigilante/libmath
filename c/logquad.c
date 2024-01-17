#include <stdio.h>
#include <quadmath.h>

int main() {
    // Define the largest positive finite quadruple-precision value
    __float128 max_value = 1.18973149535723176508575932662800702e4932q;

    // Calculate the logarithm in quadruple precision using libquadmath
    __float128 log_result = logq(max_value);

    // Print the result
    printf("Logarithm of the largest positive finite quadruple-precision value: %.30Qe\n", log_result);
    printf("%Qx\n", log_result);

    return 0;
}
