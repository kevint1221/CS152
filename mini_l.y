/* CS152
  Kai Wen Tsai
  861261944 
*/


/* DECLARATIONS */
%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
extern int current_Line;
extern int current_Pos;
extern char *text;
FILE * yyin;
%}


%union {
    int ival;
    char* tokenName;
}

%token   FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN 
%token <ival> NUMBER
%token <tokenName> IDENT

/* ASSOCIATIVITY & PRECEDENCE */
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left SUB ADD
%left MULT DIV MOD


/* TOKENS */
ident:         IDENT        { printf( "Ident -> IDENT (%s)\n",$1); };
number:        NUMBER        { printf( "number -> NUMBER (%d)\n",$1);};



/* GRAMMAR RULES  */
%%



//program
Program:        	Function 		{printf("Program -> Function\n"); }
        |       	Function Program 	{printf("Program -> Function Program\n");}
        |       	%empty 			{printf("Program -> epsilon\n");};

//function
Function:       FUNCTION ident SEMICOLON BEGIN_PARAMS Declaration_Block END_PARAMS BEGIN_LOCALS Declaration_Block END_LOCALS BEGIN_BODY Statement_Block END_BODY			     {printf("FUNCTION IDENT SEMICOLON BEGIN_PARAMS Declaration_Block END_PARAMS BEGIN_LOCALS Declaration_Block END_LOCALS BEGIN_BODY Statement_Block END_BODY \n");};

//declaration block
Declaration_Block:   	Declaration SEMICOLON 	{printf("Declaration_Block -> declaration SEMICOLON \n");}
        |       	Declaration SEMICOLON Declaration_Block {printf("Declaration_Block -> declaration SEMICOLON Declaration_Block\n");}
        |       	%empty 			{printf("Declaration_Block -> epsilon\n");};

//statement block
Statement_Block:    	Statement SEMICOLON 	{printf("Statement_Block -> Statement SEMICOLON\n");}
        |      		Statement SEMICOLON Statement_Block {printf("Statement_Block -> Statement SEMICOLON Statement_Block\n");};

//declaration
Declaration:    	ident COMMA Declaration {printf("declaration -> ident COMMA declaration\n");};
        |       	ident COLON Array_Block  INTEGER {printf("declaration -> ident COLON Array_Block INTEGER\n");};
        
//array block
Array_Block: 		ARRAY L_PAREN number R_PAREN OF  {printf("Array_Block -> ARRAY L_PAREN number R_PAREN OF\n");}
        |    		%empty                  {printf("Array_Block -> epsilon\n");};

//statement
Statement:      	Statement_Var    	{printf("Statement -> Statement_Var\n");}
        |       	Statement_If     	{printf("Statement -> Statement_If\n");}
        |       	Statement_While    	{printf("Statement -> Statement_While\n");}
        |       	Statement_Do        	{printf("Statement -> Statement_Do\n");}
        |       	Statement_For     	{printf("Statement -> Statement_For\n");}      
        |       	Statement_Read    	{printf("Statement -> Statement_Read\n");}
        |       	Statement_Write    	{printf("Statement -> Sta_Write\n");}
        |       	Statement_Continue    	{printf("Statement -> Statement_Continue\n");}
        |       	Statement_Return     	{printf("Statement -> Statement_Return\n");};


//statement var
Statement_Var:    	Var ASSIGN Expression   {printf("Statement_Var -> Var ASSIGN Expression\n");};

//statement if        
Statement_If:         	IF Bool_Exp THEN If_Statement_Block ENDIF {printf("StaIf -> IF bool_Exp THEN If_Statement_Block ENDIF\n");};

//if statement block
If_Statement_Block:     Statement SEMICOLON 	{printf("If_Statement_Block -> Statement SEMICOLON\n");}
        |       	Statement SEMICOLON If_Statement_Block {printf("If_Statement_Block -> Statement SEMICOLON If_Statement_Block\n");}
        |       	Statement SEMICOLON ELSE Statement_Block {printf("If_Statement_Block -> Statement SEMICOLON ELSE Statement_Block\n");};

//statement while
Statement_While:        WHILE Bool_Exp BEGINLOOP Statement_Block ENDLOOP {printf("Statement_While -> WHILE Bool_Exp BEGINLOOP Statement_Block ENDLOOP\n");};

//statement do
Statement_Do:         	DO BEGINLOOP Statement_Block ENDLOOP WHILE Bool_Exp {printf("Statement_Do -> DO BEGINLOOP  Statement_Block ENDLOOP WHILE Bool_Exp\n");};

//statement for
Statement_For:          FOR Var ASSIGN number SEMICOLON  Bool_Exp SEMICOLON Var ASSIGN Expression BEGINLOOP Statement_Block ENDLOOP {printf("Statement_For -> FOR Var ASSIGN number SEMICOLON Bool_Exp SEMICOLON Var ASSIGN Expression BEGINLOOP Statement_Block ENDLOOP \n");};

//statement read
Statement_Read:        	READ Var_Block          {printf("Statement_Read -> READ Var_Block\n");};

//var block
Var_Block:      	Var COMMA 		{printf("Var_Block -> Var SEMICOLON\n");}
        |       	Var 			{printf("Var_Block -> Var\n");};

//statement write
Statement_Write:        WRITE Var_Block         {printf("Statement_Write -> WRITE Var_Block \n");};

//statement continue
Statement_Continue:     CONTINUE             	{printf("Statement_Continue -> CONTINUE\n");};

//statement return
Statement_Return:       RETURN Expression 	{printf("Statement_Return -> RETURN Expression");};

//boolean expression
Bool_Exp:      		Relation_And_Exp Or_Relation_And_Exp_Block     {printf("Bool_Exp -> Relation_And_Exp Or_Relation_And_Exp\n"); }   

//or relation and expression block
Or_Relation_And_Exp_Block:        OR Relation_And_Exp Or_Relation_And_Exp_Block {printf("Or_Relation_Exp -> OR Relation_Exp Or_Relation_And_Exp_Block\n");}
        |       	%empty  		{printf("Or_Relation_And_Exp_Block -> epsilon\n");};

//relation and expression
Relation_And_Exp:  	Relation_Exp And_Relation_Block    { printf( "relation_and_exp -> relation_Exp And_Relation_Block\n");};

//and relation block
And_Relation_Block:     AND Relation_Exp And_Relation_Block {printf("And_Relation_Block -> AND Relation_Exp And_Relation_Block\n");}
        |       	%empty  		{printf("And_Relation_Block -> epsilon\n");};

//relation expression
Relation_Exp:   	NOT Relation_Cases  	{printf("Relation_Exp -> NOT Relation_Cases\n");}
        |       	Relation_Cases  	{printf("Relation_Exp -> Relation_Cases\n");};



// relation cases
Relation_Cases:      	Expression Comp Expression   {printf("Relation_Cases -> Expression Comp Expression\n");}
        |      		TRUE                         {printf("Relation_Cases -> TRUE\n");}
        |      		FALSE                        {printf("Relation_Cases -> FALSE\n");}
        |      		L_PAREN Bool_Exp R_PAREN     {printf("Relation_Cases -> L_PAREN Bool_Exp R_PAREN\n");};



//compare
Comp:          		EQ       		{printf( "Comp -> EQ\n");}
        |      		NEQ      		{printf( "Comp -> NEQ\n");}
        |      		LT       		{printf( "Comp -> LT\n");}
        |      		GT       		{printf( "Comp -> GT\n");}
        |      		LTE      		{printf( "Comp -> LTE\n");}
        |      		GTE      		{printf( "Comp -> GTE\n");};


//expression
Expression:    		Multiplicative_Exp Multiplicative_Exp_Block    {printf("Expression -> Multiplicative_Exp_Block\n");};

//multiplicative expression block
Multiplicative_Exp_Block:      ADD Multiplicative_Exp Multiplicative_Exp_Block   {printf("Multiplicative_Exp_Block -> ADD Multiplicative_Exp Multiplicative_Exp_Block\n");}
        |       	SUB Multiplicative_Exp Multiplicative_Exp_Block {printf("Multiplicative_Exp_Block -> SUB Multiplicative_Exp Multiplicative_Exp_Block\n");}
        |       	%empty  		{printf("Multiplicative_Exp_Block -> epsilon\n");};

//Multiplicative expression
Multiplicative_Exp:     Term Term_Block 	{printf("Multiplicative_Exp -> Term Term_Block\n");};

//term block
Term_Block:     	MULT Term Term_Block    {printf("Term_Block -> MULT Term\n");}
        |       	DIV Term Term_Block     {printf("Term_Block -> DIV Term\n");}
        |       	MOD Term Term_Block     {printf("Term_Block -> MOD Term\n");};
        |       	%empty  		{printf("Term_Block -> epsilon\n");};

//term
Term:          		SUB Term_Cases          {printf("Term -> SUB Ter_Cases\n"); }
        |      		Term_Cases              {printf("Term -> Ter_Cases\n"); }
        |      		ident L_PAREN Expression_Block R_PAREN {printf("term -> ident L_PAREN Expression_Block R_PAREN");};

//express BLOCK
Expression_Block: 	Expression           	{printf("Expression_Block -> Expression\n");} 
        |      		Expression COMMA Expression_Block    {printf("Expression_Block -> Expression COMMA\n");}
        |      		%empty               	{printf("Expression_Block -> epsilon\n");};       


Term_Cases:      	Var                     {printf( "Term_Cases -> Var\n");}
        |      		number                  {printf( "Term_Cases -> number\n");}
        |      		L_PAREN Expression R_PAREN       {printf( "Term_Cases -> L_PAREN Expression R_PAREN\n");};

Var:           		ident                   {printf( "Var -> ident\n");}
        |      		ident L_PAREN Expression R_PAREN     {printf( "Var -> ident L_PAREN expression R_PAREN\n");};





%%



/*====== USER CODE ==========*/

int main(int argc, char ** argv)
{
    if(argc >= 2)
    { yyin = fopen(argv[1], "r");
        if(yyin == NULL)
        { yyin = stdin;}
    }
    else {yyin = stdin;}
    yyparse();
    
}
/*====== ERROR HANDLING =======*/
void yyerror(const char *msg) {
    
    printf("** SYNTAX ERROR: LINE %d %s:", current_Line, msg);
    char *tt="=";
    int val = strcmp(text, tt);
if (val==0)
  {printf( " Unexpected Symbol \"%s\" Did You Mean ':='?\n", text);}
  else
 {printf( " Error on or before input \"%s\" \n", text);}
  ;
    
}
