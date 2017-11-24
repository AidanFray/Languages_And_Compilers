
/* Program: Test */

#include <stdio.h>

int main(void) 
{
    register int _by;
    int a_V;
    a_V = 1;
    while (a_V <= 5) {
        printf("%d", a_V);
        a_V = a_V + 1;
    }

    printf("\n");
}
