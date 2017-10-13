%{
#include "spl.c"
#include <stdio.h>
#include <stdlib.h>

/* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

/* Enum that defines the types used in the ParseTree */
enum ParseTreeNodeType 
{ 
	PROGRAM, 
	BLOCK 
};  

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
int yylex (void);

/* ------------- symbol table definition --------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
};

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;

%}

%start  program

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

%token 
	DECLARATIONS
	ENDP
	CODE
	ID
	NUMBER
	
%token
	IF
	THEN
	ELSE
	ENDIF
	
%token
	WHILE
	DO
	ENDDO
	ENDWHILE
	
%token
	FOR
	IS
	BY
	TO
	ENDFOR
	
%token
	OF
	TYPE
	
%token
	COLON
	SEMICOLON
	COMMA
	KET
	BRA
	FULLSTOP
	ASSIGNMENT
	SINGLE_QUOTE
	PLUS
	MINUS
	DIVIDE
	TIMES
	ET
	NET
	LT
	ELT
	GT
	EGT

%token
	CHARACTER
	INTEGER
	REAL

%token
	READ
	NEWLINE
	WRITE
	AND
	OR
	NOT

%%

program : 
		ID COLON block ENDP ID FULLSTOP  	
		{ 	
			TERNARY_TREE ParseTree; 
			ParseTree = create_node(NOTHING,PROGRAM,$3,NULL,NULL);
		}
		;	
	
block : 
		DECLARATIONS declaration_block CODE statement_list 
		{
			$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
		}
		| 
		CODE statement_list
		{
			$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);
		}
		;	
	
declaration_identifier : 
		ID 
		{
		
		}
		| 
		ID COMMA declaration_identifier
		{
		
		}
		;	
	
declaration_block : declaration_identifier OF TYPE type SEMICOLON 
					| declaration_identifier OF TYPE type SEMICOLON declaration_block
	;
	
type : CHARACTER | INTEGER | REAL
	;
	
statement_list : statement | statement SEMICOLON statement_list
	;
	
statement : assignment_statment 
			| if_statment 
			| do_statment 
			| while_statment 
			| for_statment 
			| write_statment 
			| read_statment 
	;
	
assignment_statment : expression ASSIGNMENT ID
	;
	
if_statment : IF conditional THEN statement_list ENDIF | IF conditional THEN statement_list ELSE statement_list ENDIF
	;
	
do_statment : DO statement_list WHILE conditional ENDDO
	;
	
while_statment : WHILE conditional DO statement_list ENDWHILE
	;
	
for_statment : FOR ID IS expression BY expression TO expression DO statement_list ENDFOR
	;
	
write_statment : WRITE BRA output_list KET | NEWLINE
	;
	
read_statment : READ BRA ID KET
	;
	
output_list : value | value COMMA output_list
	;
	
conditional : conditional_body | conditional_body AND conditional | conditional_body OR conditional
	;
	
conditional_body : not expression comparator expression 
				| expression comparator expression
	;
	
not : NOT | NOT not
	;
	
comparator : 
			  ET 
			| NET 
			| LT 
			| ELT 
			| GT 
			| EGT 
	;
	
expression : term 
			| term PLUS expression 
			| term MINUS expression
	;
	
term : value | value TIMES term| value DIVIDE term
	;
	
value : ID | constant | BRA expression KET
	;
	
constant : number_constant | character_constant
	;
	
character_constant : SINGLE_QUOTE ID SINGLE_QUOTE
	;
	
number_constant : MINUS any_digit FULLSTOP any_digit 
				| any_digit FULLSTOP any_digit
				| MINUS any_digit| any_digit
	;
	
any_digit : NUMBER | NUMBER any_digit
	;
			
%%

/* Code for routines for managing the Parse Tree */

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}


/* Put other auxiliary functions here */

#include "lex.yy.c"