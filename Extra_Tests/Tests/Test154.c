
/* Program: Test */

#include <stdio.h>

int main(void) 
{
    register int _by;
    int a_V;
    for (a_V = -5, _by = 1; (a_V-(5))*((_by > 0) - (_by < 0)) <= 0; a_V += _by) {
        printf("%d", a_V);
    }

    printf("\n");
}
