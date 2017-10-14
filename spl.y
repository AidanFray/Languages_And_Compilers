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
enum ParseTreeNodeType_RULE 
{ 
	PROGRAM, BLOCK,DECLARATION_IDENTIFIER,DECLARATION_BLOCK,TYPE_RULE,STATEMENT_LIST,STATEMENT,
	CHARACTER_VALUE,INTEGER_VALUE,REAL_VALUE,ASSIGNMENT_STATEMENT,IF_STATEMENT,DO_STATEMENT,WHILE_STATEMENT,
	FOR_STATEMENT,WRITE_STATEMENT,READ_STATEMENT,OUTPUT_LIST,CONDITIONAL,CONDITIONAL_BODY,NOT_VALUE,
	COMPARATOR,EXPRESSION,PLUS_EXPRESSION,MINUS_EXPRESSION,TERM,DIVIDE_TERM,TIMES_TERM,VALUE,NUMBER_CONSTANT,
	CHAR_CONSTANT,LITERAL_CHAR_CONSTANT,LITERAL_NUMBER_CONSTANT,ANY_DIGIT
};  

char *NodeName[] = 
{
	"PROGRAM", "BLOCK","DECLARATION_IDENTIFIER","DECLARATION_BLOCK","TYPE_RULE","STATEMENT_LIST","STATEMENT",
	"CHARACTER_VALUE","INTEGER_VALUE","REAL_VALUE","ASSIGNMENT_STATEMENT","IF_STATEMENT","DO_STATEMENT","WHILE_STATEMENT",
	"FOR_STATEMENT","WRITE_STATEMENT","READ_STATEMENT","OUTPUT_LIST","CONDITIONAL","CONDITIONAL_BODY","NOT_VALUE",
	"COMPARATOR","EXPRESSION","PLUS_EXPRESSION","MINUS_EXPRESSION","TERM","DIVIDE_TERM","TIMES_TERM","VALUE","NUMBER_CONSTANT",
	"CHAR_CONSTANT","LITERAL_CHAR_CONSTANT","LITERAL_NUMBER_CONSTANT","ANY_DIGIT"
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

/* ------------- Parse Tree definition -------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
	struct treeNode *forth;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE *TREE;

/* ------------- Forward declarations --------------------------- */
 

TREE create_node(int,int,TREE,TREE,TREE,TREE);
int yylex (void);
void PrintTree(TREE);
void ID_CHECK(char*, TREE);

/* ------------- Symbol table definition ----------------------- */

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
	TREE  tVal;
}

%type<tVal>
	program 
	block 
	declaration_identifier 
	declaration_block 
	type_rule
	statement_list 
	statement 
	assignment_statement 
	if_statement
	do_statement 
	while_statement 
	for_statement
	write_statement
	read_statement
	output_list
	conditional
	conditional_body
	not
	comparator
	expression
	term
	value
	constant
	character_constant
	number_constant
	any_digit

%token<iVal>
	ID
	NUMBER

%token 
	DECLARATIONS
	ENDP
	CODE

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
			TREE ParseTree; 
			ParseTree = create_node($1, PROGRAM, $3, NULL, NULL, NULL);
			
			/*Prints the tree*/
			PrintTree(ParseTree);
		}
		;	
	
block : 
		DECLARATIONS declaration_block CODE statement_list 
		{
			$$ = create_node(NOTHING, BLOCK, $2, $4, NULL, NULL);
		}
		| CODE statement_list
		{
			$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL, NULL);
		}
		;	
	
declaration_identifier : 
		ID 
		{
			$$ = create_node($1, DECLARATION_IDENTIFIER, NULL, NULL, NULL, NULL);
		}
		| ID COMMA declaration_identifier
		{
			$$ = create_node($1, DECLARATION_IDENTIFIER, $3, NULL, NULL, NULL);
		}
		;	
	
declaration_block : 
		declaration_identifier OF TYPE type_rule SEMICOLON 
		{
			$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL, NULL);
		}
		| declaration_identifier OF TYPE type_rule SEMICOLON declaration_block
		{
			$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6, NULL);
		}
		;
	
type_rule : 
		CHARACTER
		{
			$$ = create_node(CHARACTER_VALUE, TYPE_RULE, NULL, NULL, NULL, NULL);
		}
		| INTEGER
		{
			$$ = create_node(INTEGER_VALUE, TYPE_RULE, NULL, NULL, NULL, NULL);
		}
		| REAL
		{
			$$ = create_node(REAL_VALUE, TYPE_RULE, NULL, NULL, NULL, NULL);
		}
		;
	
statement_list : 
		statement 
		{
			$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL, NULL);
		}
		| statement SEMICOLON statement_list
		{
			$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL, NULL);
		}
		;
	
statement : 
		assignment_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);
		}
		| if_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);
		}
		| do_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);			
		}
		| while_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);			
		}
		| for_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);			
		}
		| write_statement
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);
		} 
		| read_statement
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL);
		} 
		;
	
assignment_statement : 
		expression ASSIGNMENT ID
		{
			$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL, NULL);
		}
		;
	
if_statement : 
		IF conditional THEN statement_list ENDIF 
		{
			$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL, NULL);
		}
		| IF conditional THEN statement_list ELSE statement_list ENDIF
		{
			$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6, NULL);
		}
		;
	
do_statement : 
		DO statement_list WHILE conditional ENDDO
		{
			$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL, NULL);
		}	
		;
	
while_statement : 
		WHILE conditional DO statement_list ENDWHILE
		{
			$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL, NULL);
		}
		;
	
for_statement : 
		FOR ID IS expression BY expression TO expression DO statement_list ENDFOR
		{	
			$$ = create_node(NOTHING, FOR_STATEMENT, $4, $6, $8, $10);
		}
		;
	
write_statement : 
		WRITE BRA output_list KET 
		{
			$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL, NULL);
		}
		| NEWLINE
		{
			$$ = create_node(NOTHING, WRITE_STATEMENT, NULL, NULL, NULL, NULL);
		}
		;
	
read_statement : 
		READ BRA ID KET
		{
			$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL, NULL);	
		}
		;
	
output_list : 
		value 
		{
			$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL, NULL);	
		}
		| value COMMA output_list
		{
			$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL, NULL);		
		}
		;
	
conditional : 
		conditional_body 
		{
			$$ = create_node(NOTHING, CONDITIONAL, $1, NULL, NULL, NULL);		
		}
		| conditional_body AND conditional 
		{
			$$ = create_node(NOTHING, CONDITIONAL, $1, $3, NULL, NULL);			
			
		}
		| conditional_body OR conditional
		{
			$$ = create_node(NOTHING, CONDITIONAL, $1, $3, NULL, NULL);		
		}
		;
	
conditional_body : 
		not expression comparator expression 
		{
			$$ = create_node(NOTHING, CONDITIONAL_BODY, $1, $2, $3, $4);			
		}
		| expression comparator expression
		{
			$$ = create_node(NOTHING, CONDITIONAL_BODY, $1, $2, $3, NULL);
		}
		;
	
not : 
		NOT
		{
			$$ = create_node(NOTHING, NOT_VALUE, NULL, NULL, NULL, NULL);
		} 
		| NOT not
		{
			$$ = create_node(NOTHING, NOT_VALUE, $2, NULL, NULL, NULL);			
		}
		;
	
comparator : 
		ET 
		{
			$$ = create_node(ET, COMPARATOR, NULL, NULL, NULL, NULL);		
		}
		| NET
		{
			$$ = create_node(NET, COMPARATOR, NULL, NULL, NULL, NULL);		
		} 
		| LT
		{
			$$ = create_node(LT, COMPARATOR, NULL, NULL, NULL, NULL);		
		} 
		| ELT
		{
			$$ = create_node(ELT, COMPARATOR, NULL, NULL, NULL, NULL);		
		} 
		| GT
		{
			$$ = create_node(GT, COMPARATOR, NULL, NULL, NULL, NULL);		
		} 
		| EGT
		{
			$$ = create_node(EGT, COMPARATOR, NULL, NULL, NULL, NULL);		
		} 
		;
	
expression : 
		term
		{
			$$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL, NULL);		
		} 
		| term PLUS expression 
		{
			$$ = create_node(NOTHING, PLUS_EXPRESSION, $1, $3, NULL, NULL);		
		}
		| term MINUS expression
		{
			$$ = create_node(NOTHING, MINUS_EXPRESSION, $1, $3, NULL, NULL);		
		}
		;
	
term : 
		value 
		{
			$$ = create_node(NOTHING, TERM, $1, NULL, NULL, NULL);					
		}
		| value TIMES term
		{
			$$ = create_node(NOTHING, TIMES_TERM, $1, $3, NULL, NULL);					
		}
		| value DIVIDE term
		{
			$$ = create_node(NOTHING, DIVIDE_TERM, $1, $3, NULL, NULL);		
		}
		;
	
value : ID 
		{
			$$ = create_node($1, VALUE, NULL, NULL, NULL, NULL);	
		}
		| constant 
		{
			$$ = create_node(NOTHING, VALUE, $1, NULL, NULL, NULL);	
		}
		| BRA expression KET
		{
			$$ = create_node(NOTHING, VALUE, $2, NULL, NULL, NULL);	
		}
		;
	
constant : 
		number_constant 
		{
			$$ = create_node(NOTHING, NUMBER_CONSTANT, $1, NULL, NULL, NULL);	
		}
		| character_constant
		{
			$$ = create_node(NOTHING, CHAR_CONSTANT, $1, NULL, NULL, NULL);
		}
		;
	
character_constant : 
		SINGLE_QUOTE ID SINGLE_QUOTE
		{
			$$ = create_node($2, LITERAL_CHAR_CONSTANT, NULL, NULL, NULL, NULL);			
		}
		;
	
number_constant : 
		MINUS any_digit FULLSTOP any_digit
		{
			$$ = create_node(NOTHING, LITERAL_NUMBER_CONSTANT, $2, $4, NULL, NULL);		
		} 
		| any_digit FULLSTOP any_digit
		{
			$$ = create_node(NOTHING, LITERAL_NUMBER_CONSTANT, $1, $3, NULL, NULL);					
		}
		| MINUS any_digit
		{
			$$ = create_node(NOTHING, LITERAL_NUMBER_CONSTANT, $2, NULL, NULL, NULL);					
		}
		| any_digit
		{
			$$ = create_node(NOTHING, LITERAL_NUMBER_CONSTANT, $1, NULL, NULL, NULL);		
		}
		;
	
any_digit : 
		NUMBER 
		{
			$$ = create_node($1, ANY_DIGIT, NULL, NULL, NULL, NULL);		
		}
		| NUMBER any_digit
		{
			$$ = create_node($1, ANY_DIGIT, $2, NULL, NULL, NULL);		
		}
		;
			
%%

/* Code for routines for managing the Parse Tree */
TREE create_node(int ival, int case_identifier,  
TREE p1,TREE  p2,TREE  p3, TREE p4)
{
     
	TREE t;
	t =  (TREE)malloc(sizeof(TREE_NODE));
	t->item = ival;
	t->nodeIdentifier = case_identifier;
	t->first = p1;
	t->second = p2;
	t->third = p3;
	t->forth = p4;
    return (t);
}

//Keeps track of how much indent there should be
int spaceCount = 0;

/* Put other auxiliary functions here */
void PrintTree(TREE t)
{
	/* Guard statement */
	if (t == NULL) return;

	/* Prints special id's */
	if (t->item != NOTHING) 	
	{	
		switch (t->nodeIdentifier) 
		{
			case ANY_DIGIT:
				printf("NUMBER: %d ", t->item);
				break;
			case VALUE:
				ID_CHECK("ID", t);
				break;
			case DECLARATION_IDENTIFIER:
				ID_CHECK("DECLARATION ID", t);
				break;
		}
	}


	/* Printing the name of the ID */
	if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
		printf("Unknown nodeID: %d\n", t->nodeIdentifier);
	else
		printf("nodeID: %s\n", NodeName[t->nodeIdentifier]);

	//Indetent priniting
	for (int i = 0; i < spaceCount; i++)
	{
		printf("  ");
	}

	/*The ident works by incrementing until it reaches a terminator then resets
	  it just shows a very basic relationship*/
	if(t->first == NULL && t->forth == NULL)
		spaceCount = 0; 
	else
		spaceCount++;
	
	PrintTree(t->first);
	PrintTree(t->second);
	PrintTree(t->third);
	PrintTree(t->forth);
}

/* Function that checks if the ID is in the symbol table */
void ID_CHECK(char *idType, TREE t)
{
		if (t->item > 0 && t->item < SYMTABSIZE)
			printf("%s: %s ", idType, symTab[t->item]->identifier);
		else
			printf("UNKNOWN ID: %d ", t->item);
}

#include "lex.yy.c"