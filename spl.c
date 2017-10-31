#include <stdio.h>

int yyparse();
int yylex();
void yyerror(char *s);

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


