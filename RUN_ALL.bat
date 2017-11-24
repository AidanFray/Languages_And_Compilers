flex spl.l
bison spl.y
gcc -o parser spl.tab.c spl.c -lfl

mkdir Compiled_Code

parser < Example_code/a.spl 
parser < Example_code/b.spl
parser < Example_code/c.spl 
parser < Example_code/d.spl 
parser < Example_code/e.spl

parser < Example_code/a.spl > Compiled_Code/a_code.c
parser < Example_code/b.spl > Compiled_Code/b_code.c
parser < Example_code/c.spl > Compiled_Code/c_code.c
parser < Example_code/d.spl > Compiled_Code/d_code.c
parser < Example_code/e.spl > Compiled_Code/e_code.c

cd Compiled_Code

gcc -o a a_code.c
gcc -o b b_code.c
gcc -o c c_code.c
gcc -o d d_code.c
gcc -o e e_code.c

cd ..

XCOPY parser.exe .\Extra_Tests\parser.exe