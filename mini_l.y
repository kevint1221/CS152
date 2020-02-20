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
    char *tokenName;
}
%start stprogram
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

stprogram:        program ident SEMICOLON block end_program { printf( "stprogram -> program ident SEMICOLON block end_program \n"); };

Program:        Function { printf( "Program -> Function \n"); };

Function:       FUNCTION ident SEMICOLON BEGIN_PARAMS Declar_Block

Declar_Block:   Declaration SEMICOLON {printf( "Declar_Bdeclaration SEMICOLON \n"); }
        |       Declaration SEMICOLON Dec_Block {printf( "declaration SEMICOLON \n");}
|       %empty {printf("")};



block:        MultDec begin_program MultStat  { printf( "block -> MultDec begin_program MultStat\n"); } ;





MultDec:        declaration SEMICOLON MultDec   { printf( "MultDec -> declaration SEMICOLON MultDec\n"); }
        |       declaration SEMICOLON           { printf( "MultDec -> declaration SEMICOLON\n"); };

Declaration:    IDENT COMMA Declaration               { printf( "declaration -> ident COMMA declaration\n"); };
        |       IDENT COLON alternativeArray  INTEGER { printf( "declaration -> ident COLON alternativeArray  INTEGER\n"); }
        |       ident error alternativeArray  INTEGER ; //ERROR (on comma/colon)

alternativeArray: ARRAY L_PAREN number R_PAREN OF  { printf( "alternativeArray -> ARRAY L_PAREN number R_PAREN OF\n"); }
        |                                          { printf( "alternativeArray -> epsilon\n"); } ;

statement:      StaVar    { printf( "statement -> StaVar\n"); }
        |       StaIf     { printf( "statement -> StaIf\n"); }
        |       StaWhi    { printf( "statement -> StaWhi\n"); }
        |       StaDo     { printf( "statement -> StaDo\n"); }
        |       StaRea    { printf( "statement -> StaRea\n"); }
        |       StaWri    { printf( "statement -> StaWri\n"); }
        |       StaCon    { printf( "statement -> StaCon\n"); };

StaVar:         var ASSIGN expression    { printf( "StaVar -> var ASSIGN expression\n"); }
        |       var error expression    ;  // ERROR (on assgnment symbol)

StaIf:         IF bool_exp THEN MultStat alternativeElse ENDIF { printf( "StaIf -> IF bool_exp THEN MultStat alternativeElse ENDIF\n"); };

alternativeElse: ELSE MultStat  { printf( "alternativeElse -> ELSE MultStat\n"); }
        |                       { printf( "alternativeElse -> epsilon\n"); };

StaWhi:        WHILE bool_exp BEGINLOOP MultStat ENDLOOP { printf( "StaWhi -> WHILE bool_exp BEGINLOOP MultStat ENDLOOP\n"); };

StaDo:         DO BEGINLOOP  MultStat ENDLOOP WHILE bool_exp { printf( "StaDo -> DO BEGINLOOP  MultStat ENDLOOP WHILE bool_exp\n"); };

StaRea:        READ MultVar         { printf( "StaRea -> READ MultVar\n"); };

StaWri:        WRITE MultVar        { printf( "StaWri -> WRITE MultVar \n"); };

StaCon:        CONTINUE             { printf( "StaCon -> CONTINUE\n"); };

MultVar:       var COMMA MultVar    { printf( "MultVar -> var COMMA MultVar\n"); }
        |      var                  { printf( "MultVar -> var\n"); };

MultStat:      statement SEMICOLON MultStat     { printf( "MultStat -> statement SEMICOLON MultStat\n"); }
        |      statement SEMICOLON              { printf( "MultStat -> statement SEMICOLON\n"); };

bool_exp:      bool_exp OR relation_and_exp     { printf( "bool_exp -> bool_exp OR relation_and_exp\n"); }
        |      relation_and_exp                 { printf( "bool_exp -> relation_and_exp\n"); };

relation_and_exp:  relation_and_exp AND relation_exp    { printf( "relation_and_exp -> relation_and_exp AND relation_exp\n"); }
        |          relation_exp                         { printf( "relation_and_exp -> relation_exp\n"); };

relation_exp:  relCases             { printf( "relation_exp -> relCases\n"); }
        |      NOT relCases         { printf( "relation_exp -> NOT relCases\n"); };

relCases:      expression comp expression   { printf( "relCases -> expression comp expression\n"); }
        |      TRUE                         { printf( "relCases -> TRUE\n"); }
        |      FALSE                        { printf( "relCases -> FALSE\n"); }
        |      L_PAREN bool_exp R_PAREN     { printf( "relCases -> L_PAREN bool_exp R_PAREN\n"); };

comp:          EQ       { printf( "comp -> EQ\n"); }
        |      NEQ      { printf( "comp -> NEQ\n"); }
        |      LT       { printf( "comp -> LT\n"); }
        |      GT       { printf( "comp -> GT\n"); }
        |      LTE      { printf( "comp -> LTE\n"); }
        |      GTE      { printf( "comp -> GTE\n"); };

expression:    expression ADD multiplicative_exp    { printf( "expression -> expression ADD multiplicative_exp\n"); }
        |      expression SUB multiplicative_exp    { printf( "expression -> expression SUB multiplicative_exp\n"); }
        |      multiplicative_exp                   { printf( "expression -> multiplicative_exp\n"); };

multiplicative_exp:  multiplicative_exp MULT term       { printf( "multiplicative_exp -> multiplicative_exp MULT term\n"); }
        |            multiplicative_exp DIV term        { printf( "multiplicative_exp -> multiplicative_exp DIV term\n"); }
        |            multiplicative_exp MOD term        { printf( "multiplicative_exp -> multiplicative_exp MOD term\n"); }
        |            term                               { printf( "multiplicative_exp -> term\n"); };

//TERM CASE
term:          SUB terCases         { printf("term -> SUB terCases\n"); }
        |      terCases             { printf("term -> terCases\n"); }
|      ident L_PAREN Express_Block R_PAREN {printf("term -> ident L_PAREN Express_Block R_PAREN");};

//express BLOCK
Express_Block: Expression           { printf("Express_Block -> Expression\n");} 
        |      Expression COMMA Express_Block    {printf("Express_Block -> Expression COMMA\n");}
        |      %empty               {printf("Express_Block -> epsilon\n");};       

terCases:      var                              { printf( "terCases -> var\n"); }
        |      number                           { printf( "terCases -> number\n"); }
        |      L_PAREN expression R_PAREN       { printf( "terCases -> L_PAREN expression R_PAREN\n"); };

var:           ident                                { printf( "var -> ident\n"); }
        |      ident L_PAREN expression R_PAREN     { printf( "var -> ident L_PAREN expression R_PAREN\n"); } ;





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
 {printf( " Error on or before imput \"%s\" \n", text);}
  ;
    
}
