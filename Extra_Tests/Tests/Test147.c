
/* Program: Test */

#include <stdio.h>

int main(void) 
{
    register int _by;
    int a_V;
    a_V = 1;
    do {
        printf("%d", a_V);
        a_V = a_V + 1;
    } while(a_V <= 0);

    printf("\n");
}
