%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);

/* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

/* Enum that defines the types used in the ParseTree */
enum ParseTreeNodeType_RULE 
{ 
	PROGRAM, BLOCK,DECLARATION_IDENTIFIER,DECLARATION_BLOCK,TYPE_RULE,STATEMENT_LIST,STATEMENT,
	CHARACTER_VALUE,INTEGER_VALUE,REAL_VALUE,ASSIGNMENT_STATEMENT,IF_STATEMENT,IF_ELSE_STATEMENT,DO_STATEMENT,WHILE_STATEMENT,
	FOR_STATEMENT,WRITE_STATEMENT,WRITE_STATEMENT_NEWLINE,READ_STATEMENT,OUTPUT_LIST,CONDITIONAL,CONDITIONAL_AND, 
	CONDITIONAL_OR, CONDITIONAL_BODY, CONDITIONAL_BODY_NOT ,NOT_VALUE,
	COMPARATOR,EXPRESSION,PLUS_EXPRESSION,MINUS_EXPRESSION,TERM,DIVIDE_TERM,TIMES_TERM,VALUE,NUMBER_CONSTANT,
	CHAR_CONSTANT,LITERAL_CHAR_CONSTANT,LITERAL_NUMBER_CONSTANT,ANY_DIGIT, VALUE_EXPRESSION, NEG_LITERAL_NUMBER_CONSTANT
};  

char *NodeName[] = 
{
	"PROGRAM", "BLOCK","DECLARATION_IDENTIFIER","DECLARATION_BLOCK","TYPE_RULE","STATEMENT_LIST","STATEMENT",
	"CHARACTER_VALUE","INTEGER_VALUE","REAL_VALUE","ASSIGNMENT_STATEMENT","IF_STATEMENT","IF_ELSE_STATEMENT","DO_STATEMENT","WHILE_STATEMENT",
	"FOR_STATEMENT","WRITE_STATEMENT","WRITE_STATEMENT_NEWLINE","READ_STATEMENT","OUTPUT_LIST","CONDITIONAL", "CONDITIONAL_AND", 
	"CONDITIONAL_OR","CONDITIONAL_BODY", "CONDITIONAL_BODY_NOT" ,"NOT_VALUE",
	"COMPARATOR","EXPRESSION","PLUS_EXPRESSION","MINUS_EXPRESSION","TERM","DIVIDE_TERM","TIMES_TERM","VALUE","NUMBER_CONSTANT",
	"CHAR_CONSTANT","LITERAL_CHAR_CONSTANT","LITERAL_NUMBER_CONSTANT","ANY_DIGIT", "VALUE_EXPRESSION", "NEG_LITERAL_NUMBER_CONSTANT"
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
void PrintTree(TREE, int);
void ID_CHECK(char*, TREE);
void Code(TREE);

/* ------------- Symbol table definition ----------------------- */
struct symTabNode {
    char identifier[IDLENGTH];
	char type_name[10];
};
typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE *SYMTABNODEPTR;
SYMTABNODEPTR  symTab[SYMTABSIZE]; 
int currentSymTabSize = 0;
%}

%start  program

%union {
    int iVal;
	TREE tVal;
}

%type<tVal>
	program block declaration_identifier declaration_block type_rule statement_list statement assignment_statement 	if_statement do_statement while_statement for_statement write_statement
	read_statement output_list conditional conditional_body comparator expression term value constant number_constant any_digit

%token<iVal>
	ID NUMBER CHAR

%token 
	DECLARATIONS ENDP CODE IF THEN ELSE ENDIF WHILE DO ENDDO ENDWHILE FOR IS BY TO ENDFOR OF TYPE COLON SEMICOLON COMMA KET BRA FULLSTOP ASSIGNMENT
	SINGLE_QUOTE PLUS MINUS DIVIDE TIMES ET NET LT ELT GT EGT CHARACTER INTEGER REAL READ NEWLINE WRITE AND OR NOT

%%

program : 
		ID COLON block ENDP ID FULLSTOP  	
		{ 	
			TREE ParseTree; 
			ParseTree = create_node($1, PROGRAM, $3, NULL, NULL, NULL);
			
			/*Prints the tree*/
			#ifdef DEBUG
			PrintTree(ParseTree, 0);
			#endif	

			#ifndef DEBUG
			Code(ParseTree)
			#endif
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
			$$ = create_node(NOTHING, IF_ELSE_STATEMENT, $2, $4, $6, NULL);
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
			$$ = create_node($2, FOR_STATEMENT, $4, $6, $8, $10);
		}
		;
	
write_statement : 
		WRITE BRA output_list KET 
		{
			$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL, NULL);
		}
		| NEWLINE
		{
			$$ = create_node(NOTHING, WRITE_STATEMENT_NEWLINE, NULL, NULL, NULL, NULL);
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
			$$ = create_node(NOTHING, CONDITIONAL_AND, $1, $3, NULL, NULL);			
			
		}
		| conditional_body OR conditional
		{
			$$ = create_node(NOTHING, CONDITIONAL_OR, $1, $3, NULL, NULL);		
		}
		;
	
conditional_body : 
		NOT expression comparator expression 
		{
			$$ = create_node(NOTHING, CONDITIONAL_BODY_NOT, $2, $3, $4, NULL);			
		}
		| expression comparator expression
		{
			$$ = create_node(NOTHING, CONDITIONAL_BODY, $1, $2, $3, NULL);
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
	
value : 
		ID 
		{
			$$ = create_node($1, VALUE, NULL, NULL, NULL, NULL);	
		}
		| constant 
		{
			$$ = create_node(NOTHING, VALUE, $1, NULL, NULL, NULL);	
		}
		| BRA expression KET
		{
			$$ = create_node(NOTHING, VALUE_EXPRESSION, $2, NULL, NULL, NULL);	
		}
		;
	
constant : 
		number_constant 
		{
			$$ = create_node(NOTHING, NUMBER_CONSTANT, $1, NULL, NULL, NULL);	
		}
		| CHAR
		{
			$$ = create_node($1, CHAR_CONSTANT, NULL, NULL, NULL, NULL);
		}
		;
	
number_constant : 
		MINUS any_digit FULLSTOP any_digit
		{
			$$ = create_node(NOTHING, NEG_LITERAL_NUMBER_CONSTANT, $2, $4, NULL, NULL);		
		} 
		| any_digit FULLSTOP any_digit
		{
			$$ = create_node(NOTHING, LITERAL_NUMBER_CONSTANT, $1, $3, NULL, NULL);					
		}
		| MINUS any_digit
		{
			$$ = create_node(NOTHING, NEG_LITERAL_NUMBER_CONSTANT, $2, NULL, NULL, NULL);					
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

//Reccursive method used to assign all variables a type
void AssignAllVariables(TREE t, char* c)
{
	if(t->first != NULL)
	{
		strncpy(symTab[t->first->item]->type_name, c, 10);
		AssignAllVariables(t->first, c);
	}
	else
	{
		return;
	}
}

/* Code for routines for managing the Parse Tree */
TREE create_node(int ival, int case_identifier, TREE p1,TREE  p2,TREE  p3, TREE p4)
{
	TREE t;
	t = (TREE)malloc(sizeof(TREE_NODE));
	t->item = ival;
	t->nodeIdentifier = case_identifier;
	t->first = p1;
	t->second = p2;
	t->third = p3;
	t->forth = p4;
    return (t);
}

//Keeps track of how much indent there should be
#define INDENTVALUE 2
int currentPosition = 0;
/* Put other auxiliary functions here */
void PrintTree(TREE t, int indent)
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
			case PROGRAM:
				ID_CHECK("PROGRAM", t);
				break;
			default:
				printf("ITEM: %d ", t->item);
		}
	}

	/* Printing the name of the ID */
	if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
		printf("Unknown nodeID: %d\n", t->nodeIdentifier);
	else
		printf("nodeID: %s\n", NodeName[t->nodeIdentifier]);

	//Indetent priniting
	printf("|");
	for (int i = 0; i < indent; i++) printf(" ");

	//Prints the rest of the tree sections
	PrintTree(t->first, indent + INDENTVALUE);
	PrintTree(t->second, indent + INDENTVALUE);
	PrintTree(t->third, indent + INDENTVALUE);
	PrintTree(t->forth, indent + INDENTVALUE);
}

/* Function that checks if the ID is in the symbol table */
void ID_CHECK(char *idType, TREE t)
{
		if (t->item >= 0 && t->item < SYMTABSIZE)
			printf("%s: %s ", idType, symTab[t->item]->identifier);
		else
			printf("UNKNOWN ID: %d ", t->item);
}


void Code(TREE t)
{
	if (t == NULL) return; 

	switch (t->nodeIdentifier)
	{
		//PROGRAM DESIGN
		case PROGRAM:
			//Includes
			printf("#include <stdio.h>\n");
			printf("\n");

			printf("int main(void) \n{\n");
			Code(t->first);
			printf("}");
			return;

		case DECLARATION_IDENTIFIER:
			if(t->first == NULL)
			{
				printf("%s", symTab[t->item]->identifier);
			}
			else
			{
				printf("%s", symTab[t->item]->identifier);
				printf(",");
				Code(t->first);
			}
		 	return;
		case DECLARATION_BLOCK:
			//Assigning a type
			if (t->second->item == CHARACTER_VALUE)
			{
				AssignAllVariables(t, "CHAR");
			}
			else if(t->second->item == INTEGER_VALUE)
			{
				AssignAllVariables(t, "INT");		
			}
			else if(t->second->item == REAL_VALUE)
			{
				AssignAllVariables(t, "DOUBLE");		
			}
			
			Code(t->second);
			printf(" ");
			Code(t->first);
			printf(";\n");
			Code(t->third);
			return;

		//TYPES
		case TYPE_RULE:
			if(t->item == CHARACTER_VALUE)
			{
				printf("char");
				return;
			}
			else if (t->item == INTEGER_VALUE)
			{
				printf("int");
				return;
			}
			else if (t->item == REAL_VALUE)
			{
				printf("double");
				return;
			}
		
		case ASSIGNMENT_STATEMENT:
			printf("%s", symTab[t->item]->identifier);
			Code(t->second);
			printf(" = ");
			Code(t->first);
			printf(";\n");
			return;

		case IF_STATEMENT:
			printf("if (");
			Code(t->first);
			printf(") \n{\n\t");
			Code(t->second);
			printf("\n}\n\t");		
			return;

		case IF_ELSE_STATEMENT:
			printf("if (");
			Code(t->first);
			printf(") \n{\n");
			Code(t->second);
			printf("\n}\n");
			printf("else \n{\n");
			Code(t->third);
			printf("\n}\n");
			return;

		case DO_STATEMENT:
			printf("do {\n");
			Code(t->first);
			printf("\n} while(");
			Code(t->second);
			printf(");\n");
			return;

		case WHILE_STATEMENT:
			printf("while (");
			Code(t->first);
			printf(") {\n");
			Code(t->second);
			printf("\n}\n");
			return;

		case FOR_STATEMENT:
			//for(a = 3;
			printf("for (");
			printf("%s", symTab[t->item]->identifier); //ID
			printf(" = ");
			Code(t->first);
			printf("; ");

			//a < XX;
			printf("%s", symTab[t->item]->identifier); //ID			
			printf(" < ");
			Code(t->third);
			printf("; ");

			//a++) {
			printf("%s", symTab[t->item]->identifier); //ID			
			printf("++) {\n");
			Code(t->forth);
		
			//}
			printf("\n}\n");
			return;

		case WRITE_STATEMENT_NEWLINE:
			printf("printf(\"\\n\");\n");
			return;

		case READ_STATEMENT:
			//CHARACTER
			if (symTab[t->item]->type_name[0] == 'C')
			{	
				printf("scanf(\"%%s\", &" );
			}
			//NUMBER
			else 
			if (symTab[t->item]->type_name[0] == 'I')
			{
				printf("scanf(\"%%d\", &" );
			}
			//DOUBLE
			else if(symTab[t->item]->type_name[0] == 'D')
			{
				printf("scanf(\"%%lf\", &" );
			}
			//STRING
			else
			{
				printf("scanf(\"%%s\", &" );				
			}
			printf("%s", symTab[t->item]->identifier);
			printf(");\n");
			return;

		case OUTPUT_LIST:
			//SINGLE VALUE and ID
			if (t->first->item != NOTHING)
			{
				char* type_n = symTab[t->first->item]->type_name;
				
				//TODO: Make these comparasons stronger
				if (type_n[0] == 'C')
				{
					printf("printf(\"%%c\", ");
				}
				else if (type_n[0] == 'I')
				{
					printf("printf(\"%%d\", ");
				}
				else if (type_n[0] == 'D')
				{
					printf("printf(\"%%lf\", ");
				}
			}
			else if(t->first->nodeIdentifier == VALUE_EXPRESSION)
			{
				printf("printf(\"%%d\", ");
			}
			else
			{
				printf("printf(\"%%s\", ");
			}

			Code(t->first);
			printf(");\n");
			Code(t->second);

			return;

		case CONDITIONAL_AND:
			Code(t->first);
			printf(" && ");
			Code(t->second);
			return;

		case CONDITIONAL_OR:
			Code(t->first);
			printf(" || ");
			Code(t->second);
			return;

		case CONDITIONAL_BODY_NOT:
			printf("!(");
			Code(t->first);
			printf(" ");
			Code(t->second);
			printf(" ");
			Code(t->third);			
			printf(")");
			return;

		case COMPARATOR:
			if (t->item == ET)
				printf(" == ");
			else if (t->item == NET)
				printf(" != ");
			else if (t->item == LT)
				printf(" < ");
			else if (t->item == ELT)
				printf(" <= ");
			else if (t->item == GT)
				printf(" > ");
			else if (t->item == EGT)
				printf(" >= ");
		
		case PLUS_EXPRESSION:
			Code(t->first);
			printf(" + ");
			Code(t->second);
			return;

		case MINUS_EXPRESSION:
			Code(t->first);
			printf(" - ");
			Code(t->second);
			return;

		case TIMES_TERM:
			Code(t->first);
			printf(" * ");
			Code(t->second);
			return;
		
		case DIVIDE_TERM:
			Code(t->first);
			printf(" / ");
			Code(t->second);
			return;

		case VALUE:
			if (t->first != NULL)
				Code(t->first);
			else
				//Prints the variable ID from the symbol table
				printf("%s", symTab[t->item]->identifier);
			return;

		case VALUE_EXPRESSION:
			printf("(");
			Code(t->first);
			printf(")");
			return;
	
        char* letter;
		char* total;
		case CHAR_CONSTANT:	

			//Allocates memory to char *
			letter = malloc(sizeof(char) * 4);
			total = malloc(sizeof(char) * 10);
			
			//Grabs the letter
			memcpy(letter, &symTab[t->item]->identifier[1], 1);
			
			//Encases it in double quotes
			total[0] = '\"';
			total[1] = letter[0];
			total[2] = '\"';
			total[3] = '\0';
			
			//Prints the chracter
			printf("%s", total);
			return;

		case NEG_LITERAL_NUMBER_CONSTANT:
			if (t->second == NULL)
			{
				printf("-");
				Code(t->first);
			}
			else
			{
				printf("-");
				Code(t->first);
				printf(".");
				Code(t->second);

			}
			return;

		case LITERAL_NUMBER_CONSTANT:
			if(t->second == NULL)
			{
				Code(t->first);		
			}
			else
			{
				Code(t->first);
				printf(".");
				Code(t->second);
			}
			return;

		case ANY_DIGIT:
			if(t->first == NULL)
			{
				printf("%d", t->item);
			}
			else
			{
				printf("%d", t->item);
				Code(t->first);
			}
			return;

		default:
			Code(t->first);
			Code(t->second);
			Code(t->third);
			Code(t->forth);
	}
}

#include "lex.yy.c"