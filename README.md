|===============================================|
|				  								|
|  	 README  - 08348 - SPL COMPILER 			|
|				  								|
|===============================================|

# DIRECTORY CONTENTS
./
	* The base directory that contains the files below
	spl.bnf - The BNF definition of the spl language
	spl.y 	- The yacc file for the language
	spl.l 	- The parser or lex of the spl language
	spl.c 	- Any auxially code
	RUN.bat	- Runs and compiles all code and generates output for all the provided example programs in "Example_Code"

./Compiled_Code
	* The output of the generated .c and .exe files of the RUN.bat script, this is where a.spl -> e.spl outputs will reside.

./Example_Code
	* The provided example programs are contained in this directory
	a.spl
	b.spl
	c.spl
	d.spl
	e.spl
	
# OPTIMISATIONS INCLUDED
	* The SPL compiler has the optimisation of removing dead variables included, if a variable hasn't been used apart from it's
 	definition it is not included in the compiled C code.


# CONSIDERATIONS
	* SPL's type sysyem has been assumed to be like C's where it is strongly typed.
