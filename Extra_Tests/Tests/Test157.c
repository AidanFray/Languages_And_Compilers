
/* Program: Test */

#include <stdio.h>

int main(void) 
{
    register int _by;
    char a_V;
    for (a_V = 'a', _by = 1; (a_V-('g'))*((_by > 0) - (_by < 0)) <= 0; a_V += _by) {
        printf("%c", a_V);
    }

    printf("\n");
}
