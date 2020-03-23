 /* CS152 
    Kai Wen Tsai 
    861261944
    ktsai017
    phase1
 */

 /* DEFINITIONS */
%{
 int current_Line = 1, current_Pos = 1;
%}
NUMBER    [0-9]
LETER     [a-zA-Z]

 /* RULES */
%%
 /* WORDS  */
function        {printf("FUNCTION\n");current_Pos += yyleng;}
program         {printf("PROGRAM\n");current_Pos += yyleng;}
beginparams     {printf("BEGIN_PARAMS\n");current_Pos += yyleng;}
beginlocals     {printf("BEGIN_LOCALS\n");current_Pos += yyleng;}
endparams	    {printf("END_PARAMS\n");current_Pos += yyleng;}
endlocals       {printf("END_LOCALS\n");current_Pos += yyleng;}
beginbody       {printf("BEGIN_BODY\n");current_Pos += yyleng;}
endbody         {printf("END_BODY\n");current_Pos += yyleng;}
integer		    {printf("INTEGER\n");current_Pos += yyleng;}
array		    {printf("ARRAY\n");current_Pos += yyleng;}
of		        {printf("OF\n");current_Pos += yyleng;}
if 		        {printf("IF\n");current_Pos += yyleng;}
then 		    {printf("THEN\n");current_Pos += yyleng;}
endif		    {printf("ENDIF\n");current_Pos += yyleng;}
else		    {printf("ELSE\n");current_Pos += yyleng;}
while		    {printf("WHILE\n");current_Pos += yyleng;}
do		        {printf("DO\n");current_Pos += yyleng;}
for             {printf("FOR\n");current_Pos += yyleng;}     
beginloop	    {printf("BEGINLOOP\n");current_Pos += yyleng;}
endloop		    {printf("ENDLOOP\n");current_Pos += yyleng;}
continue	    {printf("CONTINUE\n");current_Pos += yyleng;}
read		    {printf("READ\n");current_Pos += yyleng;}
write		    {printf("WRITE\n");current_Pos += yyleng;}
and 		    {printf("AND\n");current_Pos += yyleng;}
or		        {printf("OR\n");current_Pos += yyleng;}
not 		    {printf("NOT\n");current_Pos += yyleng;}
true		    {printf("TRUE\n");current_Pos += yyleng;}
false		    {printf("FALSE\n");current_Pos += yyleng;}
return          {printf("RETURN\n");current_Pos += yyleng;}
 /* ARITHMETIC OPERATORS */

"-"             {printf("SUB\n");current_Pos += yyleng;}
"+"             {printf("ADD\n");current_Pos += yyleng;}
"*"             {printf("MULT\n");current_Pos += yyleng;}
"/"             {printf("DIV\n");current_Pos += yyleng;}
"%"		        {printf("MOD\n");current_Pos += yyleng;}
 /* COMPARISON OPERATORS */
"=="		    {printf("EQ\n");current_Pos += yyleng;}
"<>"		    {printf("NEQ\n");current_Pos += yyleng;}
"<"		        {printf("LT\n");current_Pos += yyleng;}
">"		        {printf("GT\n");current_Pos += yyleng;}
"<="		    {printf("LTE\n");current_Pos += yyleng;}
">="		    {printf("GTE\n");current_Pos += yyleng;}
 /* Identifiers and Numbers  */
((({NUMBER}|_)+({LETER}|_)+|_{NUMBER}+)({NUMBER}|{LETER})*(_)*({NUMBER}|{LETER})*)*       {printf("ERROR at line %d, column %d: identifier \"%s\" must begin with a letter EXITING PROGRAM \n",current_Line,current_Pos, yytext);exit(0);}
({LETER}+({NUMBER}|{LETER}|_)*(_))* 	{printf("ERROR at line %d, column %d: identifier \"%s\" cannot end with an underscore EXITING PROGRAM \n",current_Line,current_Pos, yytext);exit(0);}
{LETER}+({NUMBER}|{LETER})*(_({NUMBER}|{LETER})+)*	{printf("IDENT %s\n",yytext); current_Pos += yyleng;}    
{NUMBER}+	{printf("NUMBER %s\n",yytext); current_Pos += yyleng;}
 /* Other Special Symbols  */
";"		{printf("SEMICOLON\n");current_Pos += yyleng;}
":"		{printf("COLON\n");current_Pos += yyleng;}
","		{printf("COMMA\n");current_Pos += yyleng;}
"("             {printf("L_PAREN\n"); current_Pos += yyleng;}
")"             {printf("R_PAREN\n"); current_Pos += yyleng;}
"["             {printf("L_SQARE_BRACKET\n"); current_Pos += yyleng;}
"]"             {printf("R_SQUARE_BRACKET\n"); current_Pos += yyleng;}
":="            {printf("ASSIGN\n"); current_Pos += yyleng;}


[ \t]+          {/* omit spaces */ current_Pos += yyleng;}
##(.)*\n        {current_Line++; current_Pos =1;}
"\n"            {current_Line++; current_Pos = 1;}
.    	        {printf("ERROR at line %d, column %d: unrecognized symbol \"%s\" EXITING PROGRAM \n",current_Line,current_Pos,yytext );exit(0);}


%%

 /* USER CODE */

int main(int argc, char ** argv)
{  /* Allow to read from file */
   if(argc >= 2)
   { yyin = fopen(argv[1], "r");
      if(yyin == NULL)
      { yyin = stdin;}
   }
   else {yyin = stdin;}
   yylex();
}

