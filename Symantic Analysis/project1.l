%{
#include<stdio.h>
%}

%%
if return IF;
else return ELSE;
while return WHILE;
do return DO;
for return FOR;

"return" return RTN;

"{" return SB; 
"}" return EB;

void return VOID;
main return MAIN;

var return VAR;

bool return BOOL;
char return CHAR;
true return TRUE;
false return FALSE;
int	return SINT;
real return SREAL;
string return STRING;

"int*" return PINT;
"char*" return PCHAR;
"real*" return PREAL;

"null" return NONE;

"+"		return PLUS;
"-"		return MINUS;
"*"		return MUL;
"/"		return DIV;
"=="	return EQ;
"="		return ASS;
"&&"	return AND;
"||"	return OR;
"&"		return AMPR;
"!" 	return NOT;
"!="	return NOTEQ;
">"		return L;
"<"		return S;
">="	return LEQ;
"<="	return SEQ;


"'"[^"]"'" return CH;

"\""[^"]*"\"" return STR;

[a-zA-Z]['_'a-zA-Z0-9]*	return ID;

[+]*[-]*[1-9][0-9]*		return INT;
0 	return INT;
0[xX][0-9A-F]+	return INT;

[+]*[-]*[0-9eE]*+"."[eE0-9]+		return REAL;

[[:space:]]*      ;
. 		return *yytext;
.|\n;

"/*"((("*"[^/])?)|[^*])*"*/"  {printf ("");};
%%
