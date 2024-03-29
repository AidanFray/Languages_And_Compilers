
# 08348 - SPL COMPILER

## DIRECTORY CONTENTS
### ./
The base directory that contains the files below

	spl.bnf - The BNF definition of the spl language
	spl.y 	- The yacc file for the language
	spl.l 	- The parser or lex of the spl language
	spl.c 	- Any auxially code
	RUN.bat	- Runs and compiles all code and generates output for all the provided example programs in "Example_Code"

### ./Compiled_Code
The output of the generated .c and .exe files of the RUN.bat script, this is where a.spl -> e.spl outputs will reside.

### ./Example_Code
The provided example programs are contained in this directory

	a.spl
	b.spl
	c.spl
	d.spl
	e.spl
	
## OPTIMIZATIONS INCLUDED
The SPL compiler has the optimisation of removing dead variables included, if a variable hasn't been used apart from it's definition it is not included in the compiled C code.


## CONSIDERATIONS
SPL's type system has been assumed to be like C's where it is strongly typed.

## EXAMPLE PROGRAM

SPL PROGRAM

	Prog4D:

	DECLARATIONS

	r1, r2, r3 OF TYPE REAL;

	CODE

	  -2.4 -> r1;
	  -34.989 -> r2;
	  r1 * r2 / 7.4 -> r3;
	  WRITE(r3);
	  NEWLINE;
	  READ(r1);
	  r1 + r3 -> r3;
	  WRITE( r3);
	  NEWLINE  

	ENDP Prog4D.
	
	
COMPILED C CODE

	/* Program: Prog4D */

	#include <stdio.h>

	int main(void) 
	{
	    register int _by;
	    double r1_V;
	    double r2_V;
	    double r3_V;
	    r1_V = -2.4;
	    r2_V = -34.989;
	    r3_V = r1_V * r2_V / 7.4;
	    printf("%lf", r3_V);
	    printf("\n");
	    scanf("%lf", &r1_V);
	    r3_V = r1_V + r3_V;
	    printf("%lf", r3_V);
	    printf("\n");
	}
