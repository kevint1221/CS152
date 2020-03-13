/* 
 * 
 */


/*====== C DECLARATIONS ========*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include <map>
#include <stack>

using namespace std;

int yylex(void);

void yyerror(const char *msg);
extern int current_Line;
extern int current_Pos;
extern char *text;

ostringstream code;
ostringstream convert;

ofstream MilCode;
string name;
int identCount=0;
int counting=0;
int Tcount=0;
stack<string> identifiers;
stack<string> temporaries;


//FUNCTION TO CREATE NEW LABELS//
int labelcount=-1;
string newlabel(int *a)
{   string tmp;
    if (*a<0)
    { tmp.append(": START\n");}
    else{
    tmp.append("__label__");
    tmp.append(to_string(*a));}
    
    *a=*a+1;
    return tmp;
}

//FUNCTION TO CREATE TEMPORARIES//
int tempcount=0;
int booleancount=0;
string newvar(int *a,bool b)
{   string tmp;
    if (b)
    { tmp.append("__temporary__");
      tmp.append(to_string(*a));
    }
    else{
        tmp.append("p");
        tmp.append(to_string(*a));}
    *a=*a+1;
    return tmp;
}


map<string, int> SymbolTab;

%}

/*======= BISON DECLARATIONS =======*/

%union {
    int ival;
    char *tokenName;
    
    struct S {
        char* result_id;
        char* code;
    } expr;
}
%start stprogram
%token   FOR RETURN R_SQUARE_BRACKET L_SQUARE_BRACKET PROGRAM FUNCTION BEGIN_BODY END_BODY BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS SPROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN

/*======= Types ======*/
%token <ival> NUMBER
%token <tokenName> IDENT
%type <expr> var declaration declainter number term terCases relation_and_exp comp StaWri
%type <expr> ident StaVar MultStat statement expression StaRea relCases relation_exp
%type <expr> multiplicative_exp MultVar Begin_params StaWhi bool_exp StaDo block MultDec


/*===== ASSOCIATIVITY & PRECEDENCE====*/
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left SUB ADD
%left MULT DIV MOD

/*===== GRAMMAR RULES ===== */
%%

stprogram:        FUNCTION ident SEMICOLON Begin_params END_PARAMS BEGIN_LOCALS MultDec END_LOCALS BEGIN_BODY MultStat END_BODY
{
    string tmp= "func " + string($2.result_id);
    identifiers.push(tmp);
    counting++;
    
    while(counting!=0)
    {  
        //if it is first don't do .
        if(!identifiers.top().find("func"))
        {
            code<< identifiers.top()<<endl;
            counting--;
            identifiers.pop();
        }
        else
        {
            code<<". "<< identifiers.top()<<endl;
            counting--;
            identifiers.pop();
        }
        
    } while(Tcount!=0)
    {   code<<". "<< temporaries.top()<<endl;
        Tcount--;
        temporaries.pop();
    }code<<$10.code;
    MilCode.open (name.c_str());
    MilCode << code.str();
    MilCode.close();

};


MultDec:        declainter SEMICOLON MultDec   {  }
        |       declainter SEMICOLON           {  };

declainter: declaration    { };

declaration:    ident COMMA declaration        {
    string tmp=string($1.result_id);
    identifiers.push(tmp);
    counting++;
    $$.result_id = strdup(tmp.c_str());
    $$.code = strdup("");
 }
        |       ident COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF  INTEGER {
        string tmp = "[] ";
        tmp.append(string($1.result_id));
        tmp.append(", ");
        tmp.append($5.result_id);
        identifiers.push(tmp);
        counting++;
        $$.result_id = strdup(tmp.c_str());
        $$.code = strdup("");
        }
        |       ident COLON INTEGER {
        string tmp = string($1.result_id);
        identifiers.push(tmp);
        counting++;
        $$.result_id = strdup(tmp.c_str());
        $$.code = strdup("");
        } ;

        



statement:      StaVar    { $$.code = strdup($1.code);}
        |       StaIf     {  }
        |       StaWhi    { $$.code = strdup($1.code); }
        |       StaDo     { $$.code = strdup($1.code); }
        |       StaRea    { $$.code = strdup($1.code); }
        |       StaWri    { $$.code = strdup($1.code); }
        |       StaCon    {  };

StaVar:         var ASSIGN expression    {
    string tmp;
    tmp.append($3.code);
    tmp.append(" = ");
    tmp.append($1.result_id);
    tmp.append(", ");
    tmp.append($3.result_id);
    tmp.append("\n");
    $$.code=strdup(tmp.c_str());  }
        |       var error expression    ;  // ERROR (on assgnment symbol)

StaIf:         IF bool_exp THEN MultStat alternativeElse ENDIF { 


     };

alternativeElse: ELSE MultStat  {  }
        |                       {  };

StaWhi:        WHILE bool_exp BEGINLOOP MultStat ENDLOOP {string bvar; bvar.append(newvar(&booleancount,0));temporaries.push(bvar);Tcount++; string tmp,Slabel,Elabel; Slabel.append(newlabel(&labelcount)); Elabel.append(newlabel(&labelcount));     tmp.append(":"+Slabel+"\n");tmp.append($2.code); tmp.append("== "+bvar+", ");tmp.append($2.result_id);tmp.append(", 0\n"); tmp.append("?:="+Elabel+", "+bvar+"\n");       tmp.append($4.code);tmp.append(":=");tmp.append(Slabel+"\n");tmp.append(": "+Elabel+"\n"); $$.code=strdup(tmp.c_str()); };


// newlabel is for new label

StaDo:         DO BEGINLOOP  MultStat ENDLOOP WHILE bool_exp { string bvar; bvar.append(newvar(&booleancount,0));temporaries.push(bvar); string tmp,Slabel,Elabel; Slabel.append(newlabel(&labelcount));Elabel.append(newlabel(&labelcount));  tmp.append(":"+Slabel+"\n");tmp.append($3.code); tmp.append("== "+bvar+", ");tmp.append("?:="+Elabel+", "+bvar+"\n");tmp.append($6.result_id);tmp.append(", 0\n");$$.code=strdup(tmp.c_str());};



StaRea:        READ MultVar         {  string tmp; tmp.append(".< "); tmp.append($2.result_id); tmp.append("\n"); $$.code=strdup(tmp.c_str()); };

StaWri:        WRITE MultVar        { string tmp; tmp.append(".> "); tmp.append($2.result_id); tmp.append("\n"); $$.code=strdup(tmp.c_str());  };

StaCon:        CONTINUE             {  };

MultVar:       var COMMA MultVar    {  }
        |      var                  { $$.result_id = strdup($1.result_id); };

MultStat:      statement SEMICOLON MultStat     { string tmp;tmp.append($1.code);tmp.append($3.code);  $$.code=strdup(tmp.c_str()); }
        |      statement SEMICOLON              { $$.code = strdup($1.code);  };

bool_exp:      bool_exp OR relation_and_exp     {  }
        |      relation_and_exp                 {  };

relation_and_exp:  relation_and_exp AND relation_exp    {  }
        |          relation_exp                         { $$.code = strdup($1.code);$$.result_id = strdup($1.result_id); };

relation_exp:  relCases             {  $$.code = strdup($1.code);$$.result_id = strdup($1.result_id); }
        |      NOT relCases         {  };

relCases:      expression comp expression   {  string tmp,bvar; bvar.append(newvar(&booleancount,0));temporaries.push(bvar);Tcount++; tmp.append("");tmp.append($2.result_id);tmp.append(" "+bvar);tmp.append(", ");tmp.append($1.result_id);tmp.append(", ");tmp.append($3.result_id); tmp.append("\n");$$.code=strdup(tmp.c_str());$$.result_id=strdup(bvar.c_str());   }
        |      TRUE                         {  }
        |      FALSE                        {  }
        |      L_PAREN bool_exp R_PAREN     {  };

comp:          EQ       {  $$.result_id=strdup("=="); }
        |      NEQ      {  $$.result_id=strdup("<>"); }
        |      LT       {  $$.result_id=strdup("<"); }
        |      GT       {  $$.result_id=strdup(">"); }
        |      LTE      {  $$.result_id=strdup("<="); }
        |      GTE      {  $$.result_id=strdup(">="); };

expression:    expression ADD multiplicative_exp    {string tmp, tmVar; tmVar=newvar(&tempcount,1);temporaries.push(tmVar);Tcount++; tmp.append("+ ");tmp.append(tmVar); tmp.append(", "); tmp.append($1.result_id); tmp.append(", "); tmp.append($3.result_id);tmp.append("\n"); $$.code=strdup(tmp.c_str()); $$.result_id=strdup(tmVar.c_str()); }

        |      expression SUB multiplicative_exp    {  }
        |      multiplicative_exp                   { $$.result_id = strdup($1.result_id);$$.code=strdup(""); };

multiplicative_exp:  multiplicative_exp MULT term       {  }
        |            multiplicative_exp DIV term        {  }
        |            multiplicative_exp MOD term        {  }
        |            term                               { $$.result_id = strdup($1.result_id);$$.code=strdup(""); };

term:          SUB terCases         {  }
        |      terCases             { $$.result_id = strdup($1.result_id); $$.code=strdup(""); };

terCases:      var                              { $$.result_id = strdup($1.result_id); $$.code=strdup("");}
        |      number                           { $$.result_id = strdup($1.result_id); $$.code=strdup("");}
        |      L_PAREN expression R_PAREN       {  };

var:           ident                                { string tmp;tmp.append("");tmp.append($1.result_id);
    $$.result_id=strdup(tmp.c_str());$$.code=strdup("");}
|      ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET     {  string tmp;tmp.append("_");tmp.append($1.result_id);
    $$.result_id=strdup(tmp.c_str());$$.code=strdup("");} ;

ident:         IDENT
{ if (identCount==0)
    {name=string($1)+".mil";
        identCount++;}
    else {  $$.result_id = strdup($1);
            $$.code = strdup("");}
};
number:        NUMBER        {  $$.result_id = strdup(to_string($1).c_str());$$.code=strdup("");};

Begin_params:   BEGIN_PARAMS   { $$.code=strdup((newlabel(&labelcount)).c_str()); };

%%



/*====== USER CODE ==========*/

int main(int argc, char ** argv)
{
    if(argc >= 2)
    {      if (freopen(argv[1], "r", stdin) == NULL)
        {printf("** OPEN FILE ERROR\n");
        }
    }
    yyparse();
}
/*====== ERROR HANDLING =======*/
void yyerror(const char *msg) {
    
    printf("** SYNTAX ERROR: LINE %d %s:", current_Line, msg);
    
    //FIX COMPATIVILITY ISSUES//
    //char *tt="=";
    //int val = strcmp(text, tt);
//if (val==0)
 // {printf( " Unexpected Symbol \"%s\" Did You Mean ':='?\n", text);}
  //else
 //{printf( " Error on or before imput \"%s\" \n", text);}
 
    
}
