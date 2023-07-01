%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
#define YYSTYPE struct  node*

typedef struct node
{
  char *token;
  struct node *left;
  struct node *right;
} node;

int yylex(void);
int yyerror();
node *mknode(char *token,node *left,node *right);
void printtree(node *tree,int tabs);

extern char* yytext;
node* ast;
%}

%token ID BOOL TRUE FALSE SINT SREAL INT CHAR CH REAL PINT PCHAR PREAL STRING STR VOID MAIN
%token PLUS MINUS MUL DIV NONE
%token EQ AND OR NOT NOTEQ L S LEQ SEQ
%token ASS AMPR VAR SB EB
%token IF ELSE WHILE DO FOR RTN

%left EQ AND OR NOT NOTEQ L S LEQ SEQ
%left PLUS MINUS
%left MUL DIV  

%%
START: 
CODE {printf("\nCode Compiled:\n\n"); ast = $1; printtree(ast,0);}

CODE: 
FUNCS CODE {$$=mknode("(CODE",mknode(NULL,$1,$2),mknode(")",NULL,NULL));}|
FUNCS {$$=mknode("(CODE",$1,mknode(")",NULL,NULL));}|
MAIN_PROD {$$=mknode("(CODE",$1,mknode(")",NULL,NULL));}

FUNCS:
VAR_TYPE ID_PROD '(' ARGS ')' BLOCK {$$=mknode("(FUNC",mknode(NULL,mknode(NULL,$1,$2),mknode(NULL,$4,$6)),mknode(")",NULL,NULL));}|
VOID ID_PROD '(' ARGS ')' BLOCK {$$=mknode("(FUNC",mknode("VOID ",mknode(NULL,$2,$4),$6),mknode(")",NULL,NULL));}

MAIN_PROD:
VOID MAIN '(' ')' BLOCK {$$=mknode("(FUNC",mknode("VOID MAIN",$2,$5),mknode(")",NULL,NULL));}

BLOCK: SB BODY EB {$$=mknode("(BLOCK",$2,mknode(")",NULL,NULL));}

BODY: 
DECLARATIONS STATEMENTS {$$=mknode(NULL,$1,$2);}|
DECLARATIONS {$$=mknode(NULL,$1,NULL);}|
STATEMENTS {$$=mknode(NULL,$1,NULL);}|

ARGS: 
VAR_TYPE PARAMS ';' ARGS {$$=mknode("(ARGS",mknode(NULL,mknode(NULL,$1,$2),$4),mknode(")",NULL,NULL));}|
VAR_TYPE PARAMS {$$=mknode("(ARGS",mknode(NULL,$1,$2),mknode(")",NULL,NULL));}|

PARAMS: 
ID_PROD ',' PARAMS {$$=mknode(NULL,$1,$3);}|
ID_PROD {$$=mknode(NULL,$1,NULL);}

VAL_PARAMS: 
ID_PROD ',' VAL_PARAMS {$$=mknode(NULL,$1,$3);}|
VALUE ',' VAL_PARAMS {$$=mknode(NULL,$1,$3);}|
ID_PROD {$$=mknode(NULL,$1,NULL);}|
VALUE {$$=mknode(NULL,$1,NULL);}

DECLARATIONS: 
VAR_DECLAR DECLARATIONS {$$=mknode(NULL,$1,$2);}|
FUNCS DECLARATIONS {$$=mknode(NULL,$1,$2);}|
VAR_DECLAR {$$=mknode(NULL,$1,NULL);}|
FUNCS {$$=mknode(NULL,$1,NULL);}

STATEMENTS:
BLOCK STATEMENTS {$$=mknode(NULL,$1,$2);}|
RTN_STAT STATEMENTS {$$=mknode(NULL,$1,$2);}|
FUNC_CALL STATEMENTS {$$=mknode(NULL,$1,$2);}|
SEMICOL_ASS STATEMENTS {$$=mknode(NULL,$1,$2);}|
IF_STAT STATEMENTS {$$=mknode(NULL,$1,$2);}|
WHILE_STAT STATEMENTS {$$=mknode(NULL,$1,$2);}|
DO_STAT STATEMENTS {$$=mknode(NULL,$1,$2);}|
FOR_STAT STATEMENTS {$$=mknode(NULL,$1,$2);}|
BLOCK {$$=mknode(NULL,$1,NULL);}|
RTN_STAT {$$=mknode(NULL,$1,NULL);}|
FUNC_CALL {$$=mknode(NULL,$1,NULL);}|
SEMICOL_ASS {$$=mknode(NULL,$1,NULL);}|
IF_STAT {$$=mknode(NULL,$1,NULL);}|
WHILE_STAT {$$=mknode(NULL,$1,NULL);}|
DO_STAT {$$=mknode(NULL,$1,NULL);}|
FOR_STAT {$$=mknode(NULL,$1,NULL);}

VAR_DECLAR: 
VAR VAR_TYPE VAR_ASS {$$=mknode("VAR",$2,$3);}

RTN_STAT: 
RTN VALUE ';' {$$=mknode("RETURN",$2,NULL);}|
RTN CH_PROD ';' {$$=mknode("RETURN",$2,NULL);}|
RTN ID_PROD ';' {$$=mknode("RETURN",$2,NULL);}|
RTN FUNC_CALL ';' {$$=mknode("RETURN",$2,NULL);}|
RTN PTR_ADD ';' {$$=mknode("RETURN",$2,NULL);}|
RTN PTR_VALUE ';' {$$=mknode("RETURN",$2,NULL);}

FUNC_CALL:
ID_PROD '(' VAL_PARAMS ')' {$$=mknode("FUNC",$1,$3);}|
ID_PROD '(' ')' {$$=mknode("FUNC",$1,NULL);}

LHS:
ID_PROD {$$=mknode(NULL,$1,NULL);}|
PTR_ADD {$$=mknode(NULL,$1,NULL);}|
PTR_VALUE {$$=mknode(NULL,$1,NULL);}|
ID_PROD ADDRESSING {$$=mknode(NULL,$1,$2);}

ASSIGNMENT: 
LHS ASS PTR_ADD ADDRESSING {$$=mknode("=",$1,mknode("&",$3,$4));}|
LHS ASS FUNC_CALL {$$=mknode("=",$1,$3);}|
LHS ASS CH_PROD {$$=mknode("=",$1,$3);}|
LHS ASS PTR_ADD {$$=mknode("=",$1,$3);}|
LHS ASS PTR_VALUE {$$=mknode("=",$1,$3);}|
LHS ASS STR_PROD {$$=mknode("=",$1,$3);}|
LHS ASS STR_SIZE {$$=mknode("=",$1,$3);}|
LHS ASS ARTM_EXP {$$=mknode("=",$1,$3);}

SEMICOL_ASS:
ASSIGNMENT ';' {$$=mknode(NULL,$1,NULL);}

IF_STAT: 
IF '(' BOOL_EXP ')' BLOCK ELSE_STAT {$$=mknode("IF",mknode(NULL,$3,$5),$6);}|
IF '(' BOOL_EXP ')' BLOCK {$$=mknode("IF",$3,$5);}|
IF '(' BOOL_EXP ')' SEMICOL_ASS ELSE_STAT {$$=mknode("IF",mknode(NULL,$3,$5),$6);}|
IF '(' BOOL_EXP ')' SEMICOL_ASS {$$=mknode("IF",$3,$5);}

ELSE_STAT: 
ELSE BLOCK {$$=mknode("ELSE",$2,NULL);}|
ELSE SEMICOL_ASS {$$=mknode("ELSE",$2,NULL);}

WHILE_STAT: 
WHILE '(' BOOL_EXP ')' BLOCK {$$=mknode("WHILE",$3,$5);}|
WHILE '(' BOOL_EXP ')' SEMICOL_ASS {$$=mknode("WHILE",$3,$5);}

DO_STAT: 
DO BLOCK WHILE '(' BOOL_EXP ')' ';' {$$=mknode("DO-WHILE",$2,$5);}

FOR_STAT: 
FOR '(' INIT ';' BOOL_EXP ';' INC ')' BLOCK {$$=mknode("FOR",mknode(NULL,$3,$5),mknode(NULL,$7,$9));}|
FOR '(' INIT ';' BOOL_EXP ';' INC ')' SEMICOL_ASS {$$=mknode("FOR",mknode(NULL,$3,$5),mknode(NULL,$7,$9));}

VAR_TYPE: 
BOOL {$$=mknode("BOOL",NULL,NULL);}|
SINT {$$=mknode("INT",NULL,NULL);}|
SREAL {$$=mknode("REAL",NULL,NULL);}|
CHAR {$$=mknode("CHAR",NULL,NULL);}|
PINT {$$=mknode("INT*",NULL,NULL);}|
PCHAR {$$=mknode("CHAR*",NULL,NULL);}|
PREAL {$$=mknode("REAL*",NULL,NULL);}|
STRING {$$=mknode("STRING",NULL,NULL);}

VAR_ASS:
ASSIGNMENT ',' VAR_ASS {$$=mknode(NULL,$1,$3);}|
ID_PROD ',' VAR_ASS {$$=mknode(NULL,$1,$3);}|
ID_PROD ';' {$$=mknode(NULL,$1,NULL);}|
SEMICOL_ASS {$$=mknode(NULL,$1,NULL);}

BOOL_EXP:
'(' BOOL_EXP ')' {$$=mknode(NULL,$1,NULL);}|
ID_PROD BOOL_OP BOOL_EXP {$$=mknode(NULL,mknode(NULL,$1,$2),$3);}|
VALUE BOOL_OP BOOL_EXP {$$=mknode(NULL,mknode(NULL,$1,$2),$3);}|
ID_PROD {$$=mknode(NULL,$1,NULL);}|
VALUE {$$=mknode(NULL,$1,NULL);}

ARTM_EXP:
'(' ARTM_EXP ')' {$$=mknode(NULL,$1,NULL);}|
ID_PROD ARTM_OP ARTM_EXP {$$=mknode(NULL,mknode(NULL,$1,$2),$3);}|
VALUE ARTM_OP ARTM_EXP {$$=mknode(NULL,mknode(NULL,$1,$2),$3);}|
ID_PROD {$$=mknode(NULL,$1,NULL);}|
VALUE {$$=mknode(NULL,$1,NULL);}

ARTM_OP: 
PLUS {$$=mknode("+",NULL,NULL);}|
MINUS {$$=mknode("-",NULL,NULL);}|
MUL {$$=mknode("*",NULL,NULL);}|
DIV {$$=mknode("/",NULL,NULL);}

BOOL_OP: 
EQ {$$=mknode("==",NULL,NULL);}|
AND {$$=mknode("&&",NULL,NULL);}|
OR {$$=mknode("||",NULL,NULL);}|
NOT {$$=mknode("!",NULL,NULL);}|
NOTEQ {$$=mknode("!=",NULL,NULL);}|
L {$$=mknode(">",NULL,NULL);}|
S {$$=mknode("<",NULL,NULL);}|
LEQ {$$=mknode(">=",NULL,NULL);}|
SEQ {$$=mknode("<=",NULL,NULL);}

VALUE:
INT {$$=mknode(strdup(yytext),NULL,NULL);}|
REAL {$$=mknode(strdup(yytext),NULL,NULL);}|
TRUE {$$=mknode("TRUE",NULL,NULL);}|
FALSE {$$=mknode("FALSE",NULL,NULL);}|
NONE {$$=mknode("NULL",NULL,NULL);}

ID_PROD: 
ID {$$=mknode(yytext,NULL,NULL);}

CH_PROD: 
CH {$$=mknode(yytext,NULL,NULL);}

STR_PROD: 
STR {$$=mknode(yytext,NULL,NULL);}

AMPR_PROD:
AMPR {$$=mknode(yytext,NULL,NULL);}

MUL_PROD:
MUL {$$=mknode(yytext,NULL,NULL);}

STR_SIZE: 
'|' ID_PROD '|'  {$$=mknode("SIZE OF:",$2,NULL);}

INIT: 
LHS ASS ARTM_EXP {$$=mknode("=",$1,$3);}

INC:
ID_PROD ASS ARTM_EXP {$$=mknode("=",$1,$3);}

PTR_ADD:
AMPR_PROD ID_PROD {$$=mknode(NULL,$1,$2);}

PTR_VALUE:
MUL_PROD ID_PROD {$$=mknode(NULL,$1,$2);}

ADDRESSING:
'[' ID_PROD ']' {$$=mknode("ADDRESS OF:",$2,NULL);}|
'[' INT ']' {$$=mknode("ADDRESS OF:",$2,NULL);}
%%

int main(){
 return yyparse();
}

int yyerror()
{
  printf("ERROR %s\n",yytext);
  return 0;
}

node *mknode(char *token,node *left,node *right)
{
  node *newnode = (node*)malloc(sizeof(node));
  if(token){
    char *newstr = (char*)malloc(sizeof(token)+1);
    strcpy(newstr,token);
    newnode->token=newstr;
  }
  newnode->left=left;
  newnode->right=right;
  return newnode;
}

void printtree(node *tree,int tabs)
{
  if(tree->token != NULL)
  {
    for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
    printf("%s\n",tree->token);
  }
  if(tree->left)
        {printtree(tree->left,tabs+1);}
  if(tree->right)
        {printtree(tree->right,tabs+1);}
}