%{

#ifdef PRINT
#define TOKEN(t) printf(#t "\n");
#else
#define TOKEN(t) return(t);
#endif

#ifndef PRINT 
/* SYMBOL TABLE */
#include <string.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
int installId(char *);
#endif
%}
	
delim       [ \t\n\r]
ws          {delim}+
letter      [A-Za-z]
digit       [0-9]
char        '{letter}'
id          {letter}({letter}|{digit})*
number      {digit}+
	
%%
		
{ws}        ; /* white space, do nothing */

{char}      {
                #ifndef PRINT
				yylval.iVal = installId(yytext);
                #endif

                TOKEN(CHAR)	
            }


			/* --------------------------KEYWORDS------------------------ */
DECLARATIONS TOKEN(DECLARATIONS)
ENDP		TOKEN(ENDP)
CODE		TOKEN(CODE)
	
IF      	TOKEN(IF)
THEN    	TOKEN(THEN)
ELSE    	TOKEN(ELSE)
ENDIF		TOKEN(ENDIF)

WHILE   	TOKEN(WHILE)
DO         	TOKEN(DO)
ENDDO		TOKEN(ENDDO)
ENDWHILE	TOKEN(ENDWHILE)
	
FOR			TOKEN(FOR)
IS			TOKEN(IS)
BY			TOKEN(BY)
TO			TOKEN(TO)
ENDFOR		TOKEN(ENDFOR)

OF			TOKEN(OF)
TYPE		TOKEN(TYPE)
NEWLINE		TOKEN(NEWLINE)

			/* ADD */
READ		TOKEN(READ)
AND			TOKEN(AND)
WRITE		TOKEN(WRITE)
OR			TOKEN(OR)
NOT			TOKEN(NOT)

			/* ---------------------------------------------------------- */
			
		
		
			/* ---------------------------TOKENS------------------------- */
":"			TOKEN(COLON)
";"        	TOKEN(SEMICOLON)
","			TOKEN(COMMA)
"("			TOKEN(BRA)
")"			TOKEN(KET)
"."			TOKEN(FULLSTOP)
"->"       	TOKEN(ASSIGNMENT) 
"'"			TOKEN(SINGLE_QUOTE)
	
			/* OPERATOR TOKENS */
"+"        	TOKEN(PLUS)
"-"        	TOKEN(MINUS)
"/"			TOKEN(DIVIDE)
"*"			TOKEN(TIMES)
	
			/* COMPARASON TOKENS */
"="			TOKEN(ET)
"<>"		TOKEN(NET)
"<"        	TOKEN(LT)
"<="		TOKEN(ELT)
">"        	TOKEN(GT)
">="		TOKEN(EGT)
			/* ---------------------------------------------------------- */
			
			
			
			/* ----------------------------TYPES------------------------- */
CHARACTER	TOKEN(CHARACTER)
INTEGER		TOKEN(INTEGER)
REAL		TOKEN(REAL)
			/* ---------------------------------------------------------- */

{id}        {
                #ifndef PRINT
				yylval.iVal = installId(yytext);
                #endif

				TOKEN(ID)
                
			}

{number}    {
                #ifndef PRINT
				yylval.iVal = atoi(yytext);
                #endif

				TOKEN(NUMBER)
			}

.           printf("Error: Unexpected symbol in spl.l: %s (%d)\n", yytext, yytext[0]);
%%

#ifndef PRINT	
SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}

/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}
#endif