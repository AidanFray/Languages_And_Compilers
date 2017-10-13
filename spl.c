#include <stdio.h>

int yyparse();
int yylex();

int main(void)
{
	/*Bison test mode*/
#ifdef YYDEBUG
	extern int yydebug;
	yydebug = 1;
#endif

	return(yyparse());
}

void yyerror(char *s) {
	fprintf(stderr, "Error: %s\n", s);
}


