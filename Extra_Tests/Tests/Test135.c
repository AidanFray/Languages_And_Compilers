
/* Program: Test */

#include <stdio.h>

int main(void) 
{
    register int _by;
    int a_V;
    int b_V;
    a_V = 1;
    b_V = 2;
    if (b_V >= a_V) {
        printf("%c", 'y');
    }
    else {
        printf("%c", 'n');
    }

    printf("\n");
}
