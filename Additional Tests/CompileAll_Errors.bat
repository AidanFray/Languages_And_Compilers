set ERROR_TESTS=(005 006 007 011 012 014 030 034 035 037 038 050 063 080 099)

for %%x in %ERROR_TESTS% do parser.exe < Test%%x.spl 1> Test%%x.c
 for %%y in %ERROR_TESTS% do gcc -o Test%%y.exe Test%%y.c

