set TESTS=(023 024 025 029 031 036 053 054 110 111 112 113 156 157)

for %%x in %TESTS% do parser.exe < Test%%x.spl 1> Test%%x.spl.c
 for %%y in %TESTS% do gcc -o Test%%y.spl.c.exe Test%%y.spl.c

