set TESTS=(002 004 032 033 039 046 047 049 071 114 123)

for %%x in %TESTS% do parser.exe < Test%%x.spl 1> Test%%x.c
 for %%y in %TESTS% do gcc -o Test%%y.exe Test%%y.c

