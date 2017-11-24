%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*For compatability of clearning the output*/
#if defined LINUX
#define CLEAR_SCREEN "clear"
#elif defined WIN32
#define CLEAR_SCREEN "cls"
#endif

void yyerror(const char *s);
void warning(char* s);
void error(char* s);

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
	COMPARATOR,EXPRESSION,PLUS_EXPRESSION,MINUS_EXPRESSION,TERM,DIVIDE_TERM,TIMES_TERM,VALUE, VALUE_ID,NUMBER_CONSTANT,
	CHAR_CONSTANT,LITERAL_CHAR_CONSTANT,LITERAL_NUMBER_CONSTANT, NEG_LITERAL_DECIMAL, LITERAL_DECIMAL ,ANY_DIGIT, VALUE_EXPRESSION, NEG_LITERAL_NUMBER_CONSTANT, NOT_EXPRESSION, INT_MAX_PLUS_EXPRESSION, INT_MIN_MINUS_EXPRESSION
};  

char *NodeName[] = 
{
	"PROGRAM", "BLOCK","DECLARATION_IDENTIFIER","DECLARATION_BLOCK","TYPE_RULE","STATEMENT_LIST","STATEMENT",
	"CHARACTER_VALUE","INTEGER_VALUE","REAL_VALUE","ASSIGNMENT_STATEMENT","IF_STATEMENT","IF_ELSE_STATEMENT","DO_STATEMENT","WHILE_STATEMENT",
	"FOR_STATEMENT","WRITE_STATEMENT","WRITE_STATEMENT_NEWLINE","READ_STATEMENT","OUTPUT_LIST","CONDITIONAL", "CONDITIONAL_AND", 
	"CONDITIONAL_OR","CONDITIONAL_BODY", "CONDITIONAL_BODY_NOT" ,"NOT_VALUE",
	"COMPARATOR","EXPRESSION","PLUS_EXPRESSION","MINUS_EXPRESSION","TERM","DIVIDE_TERM","TIMES_TERM","VALUE" ,"VALUE_ID","NUMBER_CONSTANT",
	"CHAR_CONSTANT","LITERAL_CHAR_CONSTANT","LITERAL_NUMBER_CONSTANT","NEG_LITERAL_DECIMAL","LITERAL_DECIMAL","ANY_DIGIT", "VALUE_EXPRESSION", "NEG_LITERAL_NUMBER_CONSTANT", "NOT_EXPRESSION", " INT_MAX_PLUS_EXPRESSION", "INT_MIN_MINUS_EXPRESSION"
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
TREE create_node(int,int,TREE,TREE,TREE);
int yylex (void);
void PrintTree(TREE, int);
void CheckForID(char*, TREE);
int CheckForChar(TREE t);
void Code(TREE);

/* ------------- Symbol table definition ----------------------- */
struct symTabNode {
    char identifier[IDLENGTH]; /*Variable ID*/
	char type_name[10]; /*The type of the variable*/
	int uses; /*Keeps track how many times a variable is used*/
	unsigned int assign_bool; /*Used to signal if a variable has been assigned*/
	unsigned int declared_bool;
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
	read_statement output_list conditional conditional_body comparator expression term value constant number_constant any_digit not_expression

%token<iVal>
	ID NUMBER CHAR

%token 
	DECLARATIONS ENDP CODE IF THEN ELSE ENDIF WHILE DO ENDDO ENDWHILE FOR IS BY TO ENDFOR OF TYPE COLON SEMICOLON COMMA KET BRA FULLSTOP ASSIGNMENT
	SINGLE_QUOTE PLUS MINUS DIVIDE TIMES ET NET LT ELT GT EGT CHARACTER INTEGER REAL READ NEWLINE WRITE AND OR NOT INT_MIN INT_MAX

%%


program : 
		ID COLON block ENDP ID FULLSTOP 	
		{ 	

			TREE ParseTree; 
			ParseTree = create_node($1, PROGRAM, create_node($5, PROGRAM, NULL, NULL, NULL), $3, NULL);
			
			/*Prints the tree*/
			#ifdef DEBUG
			PrintTree(ParseTree, 0);
			#elif !YYDEBUG
			Code(ParseTree)
			#endif
		}
		;	
	
block : 
		DECLARATIONS declaration_block CODE statement_list 
		{
			$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
		}
		| CODE statement_list
		{
			$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);
		}
		;	
	
declaration_identifier : 
		ID 
		{
			$$ = create_node($1, DECLARATION_IDENTIFIER, NULL, NULL, NULL);
		}
		| ID COMMA declaration_identifier
		{
			$$ = create_node($1, DECLARATION_IDENTIFIER, $3, NULL, NULL);
		}
		;	
	
declaration_block : 
		declaration_identifier OF TYPE type_rule SEMICOLON 
		{
			$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);
		}
		| declaration_identifier OF TYPE type_rule SEMICOLON declaration_block
		{
			$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);
		}
		;
	
type_rule : 
		CHARACTER
		{
			$$ = create_node(CHARACTER_VALUE, TYPE_RULE, NULL, NULL, NULL);
		}
		| INTEGER
		{
			$$ = create_node(INTEGER_VALUE, TYPE_RULE, NULL, NULL, NULL);
		}
		| REAL
		{
			$$ = create_node(REAL_VALUE, TYPE_RULE, NULL, NULL, NULL);
		}
		;
	
statement_list : 
		statement 
		{
			$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);
		}
		| statement SEMICOLON statement_list
		{
			$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
		}
		;
	
statement : 
		assignment_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
		}
		| if_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
		}
		| do_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);			
		}
		| while_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);			
		}
		| for_statement 
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);			
		}
		| write_statement
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
		} 
		| read_statement
		{
			$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
		} 
		;
	
assignment_statement : 
		expression ASSIGNMENT ID
		{
			$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);
		}
		|
		INT_MAX ASSIGNMENT ID
		{
			system(CLEAR_SCREEN);
			yyerror("Error - Assignment of interger larger than INT_MAX");
			YYABORT;
		}
		|
		INT_MIN ASSIGNMENT ID
		{
			system(CLEAR_SCREEN);			
			yyerror("Error - Assignment of integer smaller than INT_MIN");
			YYABORT;
		}
		;
	
if_statement : 
		IF conditional THEN statement_list ENDIF 
		{
			$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
		}
		| IF conditional THEN statement_list ELSE statement_list ENDIF
		{
			$$ = create_node(NOTHING, IF_ELSE_STATEMENT, $2, $4, $6);
		}
		;
	
do_statement : 
		DO statement_list WHILE conditional ENDDO
		{
			$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL);
		}	
		;
	
while_statement : 
		WHILE conditional DO statement_list ENDWHILE
		{
			$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL);
		}
		;
	
for_statement : 
		FOR ID IS expression BY expression TO expression DO statement_list ENDFOR
		{	
			$$ = create_node($2, FOR_STATEMENT, (create_node(NOTHING, FOR_STATEMENT, $4, $6, NULL)), $8, $10);
		}
		;

write_statement : 
		WRITE BRA output_list KET 
		{
			$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
		}
		| NEWLINE
		{
			$$ = create_node(NOTHING, WRITE_STATEMENT_NEWLINE, NULL, NULL, NULL);
		}
		;
	
read_statement : 
		READ BRA ID KET
		{
			$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL);	
		}
		;
	
output_list : 
		value 
		{
			$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);	
		}
		| value COMMA output_list
		{
			$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);		
		}
		;
	
conditional : 
		conditional_body 
		{
			$$ = create_node(NOTHING, CONDITIONAL, $1, NULL, NULL);		
		}
		| conditional_body AND conditional 
		{
			$$ = create_node(NOTHING, CONDITIONAL_AND, $1, $3, NULL);			
			
		}
		| conditional_body OR conditional
		{
			$$ = create_node(NOTHING, CONDITIONAL_OR, $1, $3, NULL);		
		}
		;
	
conditional_body : 
		not_expression expression comparator expression 
		{
			$$ = create_node(NOTHING, CONDITIONAL_BODY_NOT, 
			create_node(NOTHING, CONDITIONAL_BODY_NOT, $1, $2, $3), $4, NULL);			
		}
		| expression comparator expression
		{
			$$ = create_node(NOTHING, CONDITIONAL_BODY, $1, $2, $3);
		}
		;

not_expression :
		NOT
		{
			$$ = create_node(NOTHING, NOT_EXPRESSION, NULL, NULL, NULL);
		}
		|
		NOT not_expression
		{
			$$ = create_node(NOTHING, NOT_EXPRESSION, $2, NULL, NULL);
		}
		;
	
comparator : 
		ET 
		{
			$$ = create_node(ET, COMPARATOR, NULL, NULL, NULL);		
		}
		| NET
		{
			$$ = create_node(NET, COMPARATOR, NULL, NULL, NULL);		
		} 
		| LT
		{
			$$ = create_node(LT, COMPARATOR, NULL, NULL, NULL);		
		} 
		| ELT
		{
			$$ = create_node(ELT, COMPARATOR, NULL, NULL, NULL);		
		} 
		| GT
		{
			$$ = create_node(GT, COMPARATOR, NULL, NULL, NULL);		
		} 
		| EGT
		{
			$$ = create_node(EGT, COMPARATOR, NULL, NULL, NULL);		
		} 
		;
	
expression : 
		term
		{
			$$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL);		
		} 
		| INT_MAX PLUS expression
		{
			system(CLEAR_SCREEN);			
			yyerror("Error - Addition to INT_MAX");
			YYABORT;
		}
		| term PLUS expression 
		{
			$$ = create_node(NOTHING, PLUS_EXPRESSION, $1, $3, NULL);		
		}
		| INT_MIN MINUS expression
		{
			system(CLEAR_SCREEN);
			yyerror("Error - Minus from INT_MIN");
			YYABORT;
		}
		| term MINUS expression
		{
			$$ = create_node(NOTHING, MINUS_EXPRESSION, $1, $3, NULL);		
		}
		;
	
term : 
		value 
		{
			$$ = create_node(NOTHING, TERM, $1, NULL, NULL);					
		}
		| value TIMES term
		{
			$$ = create_node(NOTHING, TIMES_TERM, $1, $3, NULL);					
		}
		| value DIVIDE term
		{
			$$ = create_node(NOTHING, DIVIDE_TERM, $1, $3, NULL);		
		}
		;
	
value : 
		ID 
		{
			$$ = create_node($1, VALUE_ID, NULL, NULL, NULL);	
		}
		| constant 
		{
			$$ = create_node(NOTHING, VALUE, $1, NULL, NULL);	
		}
		| BRA expression KET
		{
			$$ = create_node(NOTHING, VALUE_EXPRESSION, $2, NULL, NULL);	
		}
		;
	
constant : 
		number_constant 
		{
			$$ = create_node(NOTHING, NUMBER_CONSTANT, $1, NULL, NULL);	
		}
		| CHAR
		{
			$$ = create_node($1, CHAR_CONSTANT, NULL, NULL, NULL);
		}
		;
	
number_constant : 
		MINUS any_digit FULLSTOP any_digit
		{
			$$ = create_node(NOTHING, NEG_LITERAL_DECIMAL, $2, $4, NULL);		
		} 
		| any_digit FULLSTOP any_digit
		{
			$$ = create_node(NOTHING, LITERAL_DECIMAL, $1, $3, NULL);					
		}
		| MINUS any_digit
		{
			$$ = create_node(NOTHING, NEG_LITERAL_NUMBER_CONSTANT, $2, NULL, NULL);					
		}
		| any_digit
		{
			$$ = create_node(NOTHING, LITERAL_NUMBER_CONSTANT, $1, NULL, NULL);		
		}
		;
	
any_digit : 
		NUMBER 
		{
			$$ = create_node($1, ANY_DIGIT, NULL, NULL, NULL);		
		}
		| NUMBER any_digit
		{
			$$ = create_node($1, ANY_DIGIT, $2, NULL, NULL);		
		}
		;
			
%%

/* Code for routines for managing the Parse Tree */
TREE create_node(int ival, int case_identifier, TREE p1,TREE  p2,TREE  p3)
{
	TREE t;
	t = (TREE)malloc(sizeof(TREE_NODE));
	t->item = ival;
	t->nodeIdentifier = case_identifier;
	t->first = p1;
	t->second = p2;
	t->third = p3;
    return (t);
}

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
			case VALUE_ID:
				CheckForID
			("ID", t);
				break;
			case DECLARATION_IDENTIFIER:
				CheckForID
			("DECLARATION ID", t);
				break;
			case PROGRAM:
				CheckForID
			("PROGRAM", t);
				break;
			default:
				printf("ITEM: %d ", t->item);
		}
	}

	/* PRINT_WITH_INDENT the name of the ID */
	if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
		printf("Unknown nodeID: %d\n", t->nodeIdentifier);
	else
		printf("nodeID: %s\n", NodeName[t->nodeIdentifier]);

	/*Indetent priniting*/
	printf("|");
	int i;
	for (i = 0; i < indent; i++) printf(" ");

	/*Prints the rest of the tree sections*/
	indent++;
	PrintTree(t->first, indent);
	PrintTree(t->second, indent);
	PrintTree(t->third, indent);
	indent--;
}

/*Reccursive method used to assign all variables a type*/
void AssignAllVariables(TREE t, char* c)
{

	if(t->first != NULL)
	{
		/*Sets the type*/
		strncpy(symTab[t->first->item]->type_name, c, 10);

		/*Checks if the ID has been defined prior*/
		if(symTab[t->first->item]->declared_bool == 0)
			symTab[t->first->item]->declared_bool = 1; /*Sets the bool to declared*/
		else
			error("Error - Redeclaration of variable performed");

		AssignAllVariables(t->first, c);
	}
	return;
}

/* Function that checks if the ID is in the symbol table */
void CheckForID(char *idType, TREE t)
{
		if (t->item >= 0 && t->item < SYMTABSIZE)
			printf("%s: %s ", idType, symTab[t->item]->identifier);
		else
			printf("UNKNOWN ID: %d ", t->item);
}

/*This method is used as a central point to print ID's of variables*/
char output[50];
char* Print_ID(int item, int USE)
{
	/*WARNING*/ 
	if(symTab[item]->assign_bool == 0 && USE == 1)
	{
		warning("Warning: A Variable is being used before it has been assigned");
	}

	/*Adds a unique ending to stop C keywords from breaking the compiling*/
	strcpy(output, symTab[item]->identifier);
	char id_array[] = "_V";

	strcat(output, id_array);
	return output;
}

/*Uses to print an expression*/
void Print_Expression(char* seperator, TREE t)
{
	if(CheckForChar(t->first) || CheckForChar(t->second))
		error("Error - Invalid character arithmatic performed");

	Code(t->first);
	printf(" %s ", seperator);
	Code(t->second);
}

/*This method sets the variable to be flagged as assigned
This is for warning when variables are uses before they're
assigned*/
void SetIDToAssigned(int item)
{
	symTab[item]->assign_bool = 1;
}

/*Recusively goes through and checks an expression for a float value*/
int CheckForFloat(TREE t)
{
	if(t == NULL) 
		return 0;

	if(t->nodeIdentifier == NEG_LITERAL_DECIMAL 
	|| t->nodeIdentifier == LITERAL_DECIMAL)
		return 1;

	if (CheckForFloat(t->first) || CheckForFloat(t->second) || CheckForFloat(t->third))
		return 1;
}

/*Recusively goes through and checks an expression for a char value*/
int CheckForChar(TREE t)
{
	if(t == NULL) 
		return 0;

	/*Checks for the char*/
	if(t->nodeIdentifier == CHAR_CONSTANT)
		return 1;

	if (CheckForChar(t->first) || CheckForChar(t->second) || CheckForChar(t->third))
		return 1;
}

/*Checks if the ID's bool for delaration has been set*/
int CheckIfID_IsUndeclared(TREE t)
{
	if(t == NULL) return 0;

	if(t->nodeIdentifier == VALUE_ID)
	{
		if(symTab[t->item]->declared_bool == 0)
		{
			return 1;
		}
	}
	return CheckIfID_IsUndeclared(t->first);
}

/*ERROR and WARNING PRINTING*/
void error(char* s)
{
	/*Stops previous C code from being part of the input*/
	system(CLEAR_SCREEN);
	yyerror(s);
	exit(1);
}

void warning(char *s)
{
	yyerror(s);
}

char* programID;
char* endProgramID;
void Code(TREE t)
{
 	setvbuf(stdout, NULL, _IONBF, 0);

	/* Deals with indent */
	#define PRINT_WITH_INDENT for (i = indent; i--;) printf("    "); printf
	int i;
	static unsigned indent;

	
	if (t == NULL) return; 

	switch (t->nodeIdentifier)
	{
		/*PROGRAM DESIGN*/
		case PROGRAM:
		
			/*Check for matching ID's*/
			programID = symTab[t->item]->identifier;
			endProgramID = symTab[t->first->item]->identifier;
			if(!(strcmp(programID, endProgramID) == 0))
			{
				warning("Warning: Program ID's do not match");
			}

			/*Program name comment*/
			printf("\n/* Program: %s */\n\n", endProgramID);

			/*Includes*/
			printf("#include <stdio.h>\n\n");
			printf("int main(void) \n{\n");

			/*Body*/
			indent++;
			PRINT_WITH_INDENT("register int _by;\n");
			Code(t->second);
			indent--;
			PRINT_WITH_INDENT("}\n");
			return;

		case DECLARATION_IDENTIFIER:
			/*Optimisation to remove dead variables
			If they haven't been used they aren't printed*/

			/*Checks if ID has ever been used*/
			if(symTab[t->item]->uses > 0)
			{
				if (symTab[t->item]->type_name[0] == 'C')
				{	
					PRINT_WITH_INDENT("char ");
					printf("%s;\n", Print_ID(t->item, 0));
				}
				else if (symTab[t->item]->type_name[0] == 'I')
				{	
					PRINT_WITH_INDENT("int ");
					printf("%s;\n", Print_ID(t->item, 0));
				}
				else if (symTab[t->item]->type_name[0] == 'D')
				{	
					PRINT_WITH_INDENT("double ");
					printf("%s;\n", Print_ID(t->item, 0));
				}
			}
			Code(t->first);
		 	return;
			 
		case DECLARATION_BLOCK:
			/*Assigning a type*/
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
			
			Code(t->first);
			Code(t->second);
			Code(t->third);
			return;

		case ASSIGNMENT_STATEMENT:
			/*ERROR CHECKS*/
			/*Checks if the assignment expression is and id
			it also checks if that id is declared*/
			if(CheckIfID_IsUndeclared(t) == 1) 
				error("Error - Using a variable to assign that is not declared");
			/*Check if the assigment value is the program ID*/
			if(strcmp(symTab[t->item]->identifier, programID) == 0)
				error("Error - Assignment attempt on the program ID");
			/*Checks if ID has been declared */
			if(symTab[t->item]->uses < 1)
				error("Error - Trying to assign to a variable that is underclared!");

			/*RULES*/		
			SetIDToAssigned(t->item);
			PRINT_WITH_INDENT("%s", Print_ID(t->item, 0));
			Code(t->second);
			printf(" = ");
			Code(t->first);
			printf(";\n");
			return;

		case NOT_EXPRESSION:
			printf("%s", "!");
			Code(t->first);
			return;

		case IF_STATEMENT:
			PRINT_WITH_INDENT("if (");
			Code(t->first);
			printf(") {\n");

			/*Body*/
			indent++;
			Code(t->second);
			indent--;

			PRINT_WITH_INDENT("}\n\n");		
			return;

		case IF_ELSE_STATEMENT:
			PRINT_WITH_INDENT("if (");
			Code(t->first);
			printf(") {\n");

			/*Body*/
			indent++;
			Code(t->second);
			indent--;

			PRINT_WITH_INDENT("}\n");
			PRINT_WITH_INDENT("else {\n");

			/*Body*/
			indent++;
			Code(t->third);
			indent--;

			PRINT_WITH_INDENT("}\n\n");
			return;

		case DO_STATEMENT:
			PRINT_WITH_INDENT("do {\n");
			/*Body*/
			indent++;
			Code(t->first);
			indent--;

			PRINT_WITH_INDENT("} while(");
			Code(t->second);
			printf(");\n\n");
			return;

		case WHILE_STATEMENT:
			PRINT_WITH_INDENT("while (");
			Code(t->first);
			printf(") {\n");

			/*Body*/ 
			indent++;
			Code(t->second);
			indent--;

			PRINT_WITH_INDENT("}\n\n");
			return;
		
		char loopID[50];
		char* buffer;
		case FOR_STATEMENT:
			/*
			Key:
			First->First 	= IS
			First->Second 	= BY
			Second 			= TO

			Note:
			This for loop design has been taken from the
			ACW Help section
			*/

			/*ERROR CHECKS*/
			if (CheckForFloat(t->first->first)) 
				error("Error - Float used in for-loop interator assignment");
			if (CheckForFloat(t->first->first)) 
				error("Error - Float used as max range specifier");
			if (CheckForFloat(t->first->first)) 
				error("Error - Float used as increment step value");

			/*ID value*/
			SetIDToAssigned(t->item);
			buffer = Print_ID(t->item, 0);
			strcpy(loopID, buffer);
	
			/*for(a = XX, _by = by;*/
			PRINT_WITH_INDENT("for (");
			printf("%s", loopID); 
			printf(" = ");
			Code(t->first->first);
			printf(", ");	
			printf("_by = ");
			Code(t->first->second);
			printf("; ");

			/*(a-to)*((_by > 0) - (_by < 0)) <= 0 ;*/
			printf("(%s-(", loopID);
			Code(t->second);
			printf("))*((_by > 0) - (_by < 0)) <= 0; ");
		
	        /*a += _by*/
			printf("%s", loopID);
			printf(" += _by");
			printf(") {\n");

			/*{
			<body> */
			indent++;
			Code(t->third);
			indent--;

			/*}*/
			PRINT_WITH_INDENT("}\n\n");
			return;

		case WRITE_STATEMENT_NEWLINE:
			PRINT_WITH_INDENT("printf(\"\\n\");\n");
			return;

		case READ_STATEMENT:
			/*Character*/
			if (symTab[t->item]->type_name[0] == 'C')
			{	
				PRINT_WITH_INDENT("scanf(\" %%c\", &" );
			}
			/*Integer*/
			else 
			if (symTab[t->item]->type_name[0] == 'I')
			{
				PRINT_WITH_INDENT("scanf(\"%%d\", &" );
			}
			/*Double*/
			else if(symTab[t->item]->type_name[0] == 'D')
			{
				PRINT_WITH_INDENT("scanf(\"%%lf\", &" );
			}
			/*Other*/			
			else
			{
				PRINT_WITH_INDENT("scanf(\"%%c\", &" );				
			}

			/*The value of the ID is assigned from the read statement*/
			SetIDToAssigned(t->item);
			printf("%s", Print_ID(t->item, 0));

			printf(");\n");
			return;

		case OUTPUT_LIST:
			/*Printing a Variable*/
			if (t->first->item != NOTHING)
			{
				/*ERROR CHECKS*/
				/*Check for initalisation*/
				if(symTab[t->first->item]->assign_bool == 0) 
					error("Error - Trying to print a variable that has not been initalised");	


				char* type_n = symTab[t->first->item]->type_name;

				if (type_n[0] == 'C')
				{
					PRINT_WITH_INDENT("printf(\"%%c\", ");
				}
				else if (type_n[0] == 'I')
				{
					PRINT_WITH_INDENT("printf(\"%%d\", ");
				}
				else if (type_n[0] == 'D')
				{
					PRINT_WITH_INDENT("printf(\"%%lf\", ");
				}
			}
			/*Printing an expression*/
			else if(t->first->nodeIdentifier == VALUE_EXPRESSION)
			{
				if(CheckForFloat(t->first))
				{
					PRINT_WITH_INDENT("printf(\"%%lf\",", "");
				}
				else
				{
					PRINT_WITH_INDENT("printf(\"%%d\", ");
				}
			}
			/*Printing a literal value*/
			else
			{
				if(t->first->first->nodeIdentifier == NUMBER_CONSTANT)
				{
					/* DECIMAL VALUE*/
					if(t->first->first->first->nodeIdentifier == NEG_LITERAL_DECIMAL ||
					   t->first->first->first->nodeIdentifier == LITERAL_DECIMAL)
					{
						PRINT_WITH_INDENT("printf(\"%%lf\", ");
					}
					/* INT VALUE */
					else
					{
						PRINT_WITH_INDENT("printf(\"%%d\", ");
					}
				}
				else
				{
					PRINT_WITH_INDENT("printf(\"%%c\", ");
				}
			}

			Code(t->first);
			printf(");\n");
			Code(t->second);
			return;

		case CONDITIONAL_BODY_NOT:
			Code(t->first->first);
			printf("(");
			Code(t->first->second);
			printf(" ");
			Code(t->first->third);	
			printf(" ");
			Code(t->second);
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
			return;

		case CONDITIONAL_AND:
			Print_Expression("&&", t);
			return;

		case CONDITIONAL_OR:
			Print_Expression("||", t);
			return;

		case PLUS_EXPRESSION:
			Print_Expression("+", t);
			return;

		case MINUS_EXPRESSION:
			Print_Expression("-", t);
			return;

		case TIMES_TERM:
			Print_Expression("*", t);
			return;
		
		case DIVIDE_TERM:
			Print_Expression("/", t);
			return;

		case VALUE_ID:
			printf("%s", Print_ID(t->item, 1));
			return;

		case VALUE_EXPRESSION:
			printf("(");
			Code(t->first);
			printf(")");
			return;

		case CHAR_CONSTANT:	
			printf("%s", symTab[t->item]->identifier); /* Prints the character */
			return;

		case NEG_LITERAL_NUMBER_CONSTANT:
			printf("-");
			Code(t->first);
			return;

		case NEG_LITERAL_DECIMAL:
			printf("-");
			Code(t->first);
			printf(".");
			Code(t->second);
			return;

		case LITERAL_NUMBER_CONSTANT:
			Code(t->first);		
			return;

		case LITERAL_DECIMAL:
			Code(t->first);
			printf(".");
			Code(t->second);
			return;

		case ANY_DIGIT:
			/*Single digit*/
			if(t->first == NULL)
			{
				printf("%d", t->item);
			}
			/*Multi digit*/
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
	}
}
#include "lex.yy.c"