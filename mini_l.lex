 /* cs152
    Kai Wen Tsai
    861261944
 */

%{
#include "y.tab.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
int current_Line = 1, current_Pos = 1; char *text;
%}
NUMBER    [0-9]+
LETER     [a-zA-Z]+

 /* RULES */
%%
 /* RESERVED WORDS  */
function	{ current_Pos += yyleng; text=strdup(yytext); return FUNCTION;}
beginparams     { current_Pos += yyleng; text=strdup(yytext); return BEGIN_PARAMS;}
endparams	{ current_Pos += yyleng; text=strdup(yytext); return END_PARAMS;}
beginlocals	{ current_Pos += yyleng; text=strdup(yytext); return BEGIN_LOCALS;}
endlocals	{ current_Pos += yyleng; text=strdup(yytext); return END_LOCALS;}
beginbody	{ current_Pos += yyleng; text=strdup(yytext); return BEGIN_BODY;}
endbody 	{ current_Pos += yyleng; text=strdup(yytext); return BEGIN_BODY;}
integer		{ current_Pos += yyleng; text=strdup(yytext); return INTEGER;}
array		{ current_Pos += yyleng; text=strdup(yytext); return ARRAY;}
of		{ current_Pos += yyleng; text=strdup(yytext); return OF;}
if 		{ current_Pos += yyleng; text=strdup(yytext); return IF;}
then 		{ current_Pos += yyleng; text=strdup(yytext); return THEN;}
endif		{ current_Pos += yyleng; text=strdup(yytext); return ENDIF;}
else		{ current_Pos += yyleng; text=strdup(yytext); return ELSE;}
while		{ current_Pos += yyleng; text=strdup(yytext); return WHILE;}
do		{ current_Pos += yyleng; text=strdup(yytext); return DO;}
for		{ current_Pos += ttleng; text=strdup(yytext); return FOR;}
beginloop	{ current_Pos += yyleng; text=strdup(yytext); return BEGINLOOP;}
endloop		{ current_Pos += yyleng; text=strdup(yytext); return ENDLOOP;}
continue	{ current_Pos += yyleng; text=strdup(yytext); return CONTINUE;}
read		{ current_Pos += yyleng; text=strdup(yytext); return READ;}
write		{ current_Pos += yyleng; text=strdup(yytext); return WRITE;}
and 		{ current_Pos += yyleng; text=strdup(yytext); return AND;}
or		{ current_Pos += yyleng; text=strdup(yytext); return OR;}
not 		{ current_Pos += yyleng; text=strdup(yytext); return NOT;}
true		{ current_Pos += yyleng; text=strdup(yytext); return TRUE;}
false		{ current_Pos += yyleng; text=strdup(yytext); return FALSE;}
return		{ CURRENT_POS += yyleng; text=strdup(yytext); return RETURN;}
 /* Arithmetic Operators */
"-"             { current_Pos += yyleng; text=strdup(yytext); return SUB;}
"+"             { current_Pos += yyleng; text=strdup(yytext); return ADD;}
"*"             { current_Pos += yyleng; text=strdup(yytext); return MULT;}
"/"             { current_Pos += yyleng; text=strdup(yytext); return DIV;}
"%"		{ current_Pos += yyleng; text=strdup(yytext); return MOD;}
 /* Comparison Operators */
"=="		{ current_Pos += yyleng; text=strdup(yytext); return EQ;}
"<>"		{ current_Pos += yyleng; text=strdup(yytext); return NEQ;}
"<"		{ current_Pos += yyleng; text=strdup(yytext); return LT;}
">"		{ current_Pos += yyleng; text=strdup(yytext); return GT;}
"<="		{ current_Pos += yyleng; text=strdup(yytext); return LTE;}
">="		{ current_Pos += yyleng; text=strdup(yytext); return GTE;}

 /* Identifiers and Numbers  */
((({NUMBER}|_)+({LETER}|_)+|_{NUMBER}+)({NUMBER}|{LETER})*(_)*({NUMBER}|{LETER})*)*       {printf("ERROR FROM LEX: at line %d, column %d: identifier \"%s\" must begin with a letter EXITING PROGRAM \n",current_Line,current_Pos, yytext);exit(0);}

({LETER}+({NUMBER}|{LETER}|_)*(_))* 	{printf("ERROR FROM LEX: at line %d, column %d: identifier \"%s\" cannot end with an underscore EXITING PROGRAM \n",current_Line,current_Pos, yytext);exit(0);}

{LETER}+({NUMBER}|{LETER})*(_({NUMBER}|{LETER})+)*	{current_Pos += yyleng; yylval.tokenName=strdup(yytext);text=strdup(yytext); return IDENT;}

{NUMBER}+	{current_Pos += yyleng; yylval.ival= atoi(yytext); return NUMBER;}

 /* Other Special Symbols  */
";"		{ current_Pos += yyleng; text=strdup(yytext); return SEMICOLON;}
":"		{ current_Pos += yyleng; text=strdup(yytext); return COLON;}
","		{ current_Pos += yyleng; text=strdup(yytext); return COMMA;}
"("             { current_Pos += yyleng; text=strdup(yytext); return L_PAREN;}
")"             { current_Pos += yyleng; text=strdup(yytext); return R_PAREN;}
"["             { current_Pos += yyleng; text=strdup(yytext); return L_SQUARE_BRACKET;}
"]"             { current_Pos += yyleng; text=strdup(yytext); return R_SQUARE_BRACKET;}
":="            { current_Pos += yyleng; text=strdup(yytext); return ASSIGN;}


[ \t]+          {/* omit spaces */ current_Pos += yyleng;}
##(.)*\n           {current_Line++; current_Pos =1;}
"\n"            {current_Line++; current_Pos = 1;}
.    	        {printf("ERROR FROM LEX: at line %d, column %d: unrecognized symbol \"%s\" \n",current_Line,current_Pos,yytext );text=strdup(yytext);}

%%
