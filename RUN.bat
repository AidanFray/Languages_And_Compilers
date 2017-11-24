flex spl.l
bison spl.y
gcc -o parser spl.tab.c spl.c -lfl