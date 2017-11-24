
/* Program: Test */

#include <stdio.h>

int main(void) 
{
    register int _by;
    double a_V;
    for (a_V = 0.1, _by = 0.1; (a_V-(0.5))*((_by > 0) - (_by < 0)) <= 0; a_V += _by) {
        printf("%lf", a_V);
        printf("\n");
    }

    printf("\n");
}
