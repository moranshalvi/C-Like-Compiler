%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"
#define YYSTYPE struct  node*

  //lex project1.l
  //yacc project1.y
  //gcc -o project1 y.tab.c -ll -Ly
  //./project1 <project1.t

typedef struct node
{
  char *token;
  struct node *left;
  struct node *right;
} node;

typedef struct vars
{
  char type[50];
  int numOfVars;
  char **var_names;
} vars;

typedef struct args
{
  struct vars* varsArray;
  int arraySize;
  int numOfArgs;
} args;

typedef struct symbolTable
{
  int symLevel;
  int SymiD;
  struct vars *varsArray;
  int VarraySize;
  struct functions *funcsArray;
  int FarraySize;
  struct symbolTable *symbolArray;
  int SarraySize;
  int inc;
  struct functions *ref;
  struct symbolTable *Sref;
  struct node *checkBlockref;
} symbolTable;

typedef struct functions
{
  char fName[50];
  char fType[50];
  int fLevel;
  int rtn;
  struct args *fArgs;
  struct symbolTable *tbl;
  struct functions *ref;
} functions;

int yylex(void);
int yyerror();
int id_for_s=0;
symbolTable *symbolhelp=NULL;
node* mknode(char *token,node *left,node *right);
vars* mkvars(int nov, char **names, char *type);
char** twoDcharArrAlloc(char **names,int nov);
char** twoDcharArrDC(char **names1,char **names2,int nov);
args* mkargs(int non);
symbolTable* mksymbolTable(int symlevel,vars* varsArray,int nov,functions* funcsArray,int nof,functions *ref,node *Blockref);
void addSymbolTables(symbolTable *s,node* StatTree);
functions* mkfunctions(char *type, char *name,int l,args *ar,functions *ref);
void startSemantics(node *ast);
node enviArr[50];
int enviCounter=0;
void firstEnvi(node *ast);
void CrossGfuncs(functions *gfuncs);
functions* checkSemantics(node *funcTree,int level,functions *ref);
void checkArgs(node *argsTree,args* a,int non);
symbolTable* checkBlockDec(node *blockTree,int level,functions *ref);
void InnerFuncsValidation(functions *f,int index);
void AnalysisFuncs(node *funcTree,functions *f,functions *globalfuncs);
node *FindFunc(node *decTree,char *fname);
void CheckFuncSem(node *funcTree,functions *f,functions *globalfuncs,node *Blockref,int level);
void decValidations(functions *f);
void check2DArray(vars *v);
void check2Vars(vars *v1,vars *v2);
void CrossWithArgs(vars *v,args *a);
void checkAss(node *ASStree,functions* f,functions *globalfuncs);
void checkRTN(node *ASStree,functions* f,functions *globalfuncs);
char* checkCall(node *ASStree,functions* f,functions *globalfuncs);
char* ptrSem(node *ASStree,functions* f,functions *globalfuncs);
char* EXPsem(node *ASStree,functions* f,functions *globalfuncs);
char* checkStrSize(node *ASStree,functions* f,functions *globalfuncs);
char* findType(char* symbol,functions *f,functions *globalfuncs);
vars* SearchID(node *id,symbolTable *s,functions *globalfuncs);
symbolTable* helpsearch(symbolTable *s,int id);
functions* SearchFUNC(char *fname,functions *f,functions *globalfuncs,int flag);
int ArgsCounter(node *argsTree);
int NodesRightCounter(node *Tree);
int StringsRightCounter(node *stringTree);
int DecCounter(node *DecTree,char *dec);
void fillTrees(node *DecTree,char* dec,node *arr,int size);
void fillVarsArray(node *varsTree,char** ids,int size);
void fillStringstoVar(node *varsTree,char** ids,int size);
void ARTMto2Darray(node *artmTree,node *exps,int size);
int BlockStatCount(node *StatTree);
void fillStat(node *StatTree,symbolTable *s);
void AssRef(symbolTable *s);
void printtree(node *tree,int tabs);
void printfunc(functions *f,int tabs);
void printargs(args *a,int tabs);
void printvars(vars *v,int tabs);
void printtbl(symbolTable *tbl,int tabs);

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
CODE {printf("\nCode Compiled:\n"); ast = $1; startSemantics(ast); printf("AST:\n\n"); printtree(ast,0); printf("\n");}

CODE: 
FUNCS CODE {$$=mknode("(CODE",mknode("",$1,$2),mknode(")",NULL,NULL));}|
FUNCS {$$=mknode("(CODE",$1,mknode(")",NULL,NULL));}|
MAIN_PROD {$$=mknode("(CODE",$1,mknode(")",NULL,NULL));}

FUNCS:
VAR_TYPE ID_PROD '(' ARGS ')' BLOCK {$$=mknode("(FUNC",mknode("",mknode("",$1,$2),mknode("",$4,$6)),mknode(")",NULL,NULL));}|
VOID_PROD ID_PROD '(' ARGS ')' BLOCK {$$=mknode("(FUNC",mknode("",mknode("",$1,$2),mknode("",$4,$6)),mknode(")",NULL,NULL));}

MAIN_PROD:
VOID_PROD MAIN_PROD '(' MAIN_ARGS ')' BLOCK {$$=mknode("(FUNC",mknode("",mknode("",$1,$2),mknode("",$4,$6)),mknode(")",NULL,NULL));}

BLOCK: SB BODY EB {$$=mknode("(BLOCK",$2,mknode(")",NULL,NULL));}

BODY: 
DECLARATIONS STATEMENTS {$$=mknode("",$1,$2);}|
DECLARATIONS {$$=mknode("",$1,NULL);}|
STATEMENTS {$$=mknode("",NULL,$1);}|
{$$=mknode("",NULL,NULL);}

ARGS: 
VAR_TYPE PARAMS ';' ARGS {$$=mknode("(ARGS",mknode("",mknode("",$1,$2),$4),mknode(")",NULL,NULL));}|
VAR_TYPE PARAMS {$$=mknode("(ARGS",mknode("",mknode("",$1,$2),NULL),mknode(")",NULL,NULL));}|
STRING_PROD PARAMS ';' ARGS {$$=mknode("(ARGS",mknode("",mknode("",$1,$2),$4),mknode(")",NULL,NULL));}|
STRING_PROD PARAMS {$$=mknode("(ARGS",mknode("",mknode("",$1,$2),NULL),mknode(")",NULL,NULL));}|
{$$=mknode("(ARGS",NULL,mknode(")",NULL,NULL));}

MAIN_ARGS: 
{$$=mknode("(ARGS",NULL,mknode(")",NULL,NULL));}

PARAMS: 
ID_PROD ',' PARAMS {$$=mknode("",$1,$3);}|
ID_PROD {$$=mknode("",$1,NULL);}

VAL_PARAMS:
EXP ',' VAL_PARAMS {$$=mknode("",$1,$3);}|
EXP {$$=mknode("",$1,NULL);}

DECLARATIONS: 
VAR_DECLAR DECLARATIONS {$$=mknode("",$1,$2);}|
FUNCS DECLARATIONS {$$=mknode("",$1,$2);}|
VAR_DECLAR {$$=mknode("",$1,NULL);}|
FUNCS {$$=mknode("",$1,NULL);}

STATEMENTS:
BLOCK STATEMENTS {$$=mknode("",$1,$2);}|
RTN_STAT STATEMENTS {$$=mknode("",$1,$2);}|
FUNC_CALL ';' STATEMENTS {$$=mknode("",$1,$2);}|
SEMICOL_ASS STATEMENTS {$$=mknode("",$1,$2);}|
IF_STAT STATEMENTS {$$=mknode("",$1,$2);}|
WHILE_STAT STATEMENTS {$$=mknode("",$1,$2);}|
DO_STAT STATEMENTS {$$=mknode("",$1,$2);}|
FOR_STAT STATEMENTS {$$=mknode("",$1,$2);}|
BLOCK {$$=mknode("",$1,NULL);}|
RTN_STAT {$$=mknode("",$1,NULL);}|
FUNC_CALL ';' {$$=mknode("",$1,NULL);}|
SEMICOL_ASS {$$=mknode("",$1,NULL);}|
IF_STAT {$$=mknode("",$1,NULL);}|
WHILE_STAT {$$=mknode("",$1,NULL);}|
DO_STAT {$$=mknode("",$1,NULL);}|
FOR_STAT {$$=mknode("",$1,NULL);}

VAR_DECLAR: 
VAR VAR_TYPE VAR_ASS {$$=mknode("VAR",$2,$3);}|
STRING ID_PROD STRING_ASS {$$=mknode("STRING",$2,$3);}

RTN_STAT: 
RTN EXP ';' {$$=mknode("RETURN",$2,NULL);}

FUNC_CALL:
ID_PROD '(' VAL_PARAMS ')' {$$=mknode("FUNC",$1,$3);}|
ID_PROD '(' ')' {$$=mknode("FUNC",$1,NULL);}

LHS:
ID_PROD {$$=mknode("",$1,NULL);}|
PTR_ADD {$$=mknode("",$1,NULL);}|
PTR_VALUE {$$=mknode("",$1,NULL);}|
ID_PROD ADDRESSING {$$=mknode("",$1,$2);}

ASSIGNMENT: 
LHS ASS EXP {$$=mknode("=",$1,$3);}

STR_ASS:
ADDRESSING ASS STR {$$=mknode("=",$1,$3);}

SEMICOL_ASS:
ASSIGNMENT ';' {$$=mknode("",$1,NULL);}

IF_STAT: 
IF '(' EXP ')' BLOCK ELSE_STAT {$$=mknode("IF-ELSE",mknode("",$3,$5),$6);}|
IF '(' EXP ')' BLOCK {$$=mknode("IF",$3,$5);}|
IF '(' EXP ')' SEMICOL_ASS ELSE_STAT {$$=mknode("IF-ELSE",mknode("",$3,$5),$6);}|
IF '(' EXP ')' FUNC_CALL ';' ELSE_STAT {$$=mknode("IF-ELSE",mknode("",$3,$5),$7);}|
IF '(' EXP ')' SEMICOL_ASS {$$=mknode("IF",$3,$5);}|
IF '(' EXP ')' FUNC_CALL ';' {$$=mknode("IF",$3,$5);}

ELSE_STAT: 
ELSE BLOCK {$$=mknode("ELSE",$2,NULL);}|
ELSE SEMICOL_ASS {$$=mknode("ELSE",$2,NULL);}|
ELSE FUNC_CALL ';' {$$=mknode("ELSE",$2,NULL);}

WHILE_STAT: 
WHILE '(' EXP ')' BLOCK {$$=mknode("WHILE",$3,$5);}|
WHILE '(' EXP ')' SEMICOL_ASS {$$=mknode("WHILE",$3,$5);}|
WHILE '(' EXP ')' FUNC_CALL ';' {$$=mknode("WHILE",$3,$5);}

DO_STAT: 
DO BLOCK WHILE '(' EXP ')' ';' {$$=mknode("DO-WHILE",$2,$5);}

FOR_STAT: 
FOR '(' INIT ';' EXP ';' INC ')' BLOCK {$$=mknode("FOR",mknode("",$3,$5),mknode("",$7,$9));}|
FOR '(' INIT ';' EXP ';' INC ')' SEMICOL_ASS {$$=mknode("FOR",mknode("",$3,$5),mknode("",$7,$9));}|
FOR '(' INIT ';' EXP ';' INC ')' FUNC_CALL ';' {$$=mknode("FOR",mknode("",$3,$5),mknode("",$7,$9));}


VAR_TYPE: 
BOOL {$$=mknode("BOOL",NULL,NULL);}|
SINT {$$=mknode("INT",NULL,NULL);}|
SREAL {$$=mknode("REAL",NULL,NULL);}|
CHAR {$$=mknode("CHAR",NULL,NULL);}|
PINT {$$=mknode("INT*",NULL,NULL);}|
PCHAR {$$=mknode("CHAR*",NULL,NULL);}|
PREAL {$$=mknode("REAL*",NULL,NULL);}

VAR_ASS:
ASSIGNMENT ',' VAR_ASS {$$=mknode("",$1,$3);}|
ID_PROD ',' VAR_ASS {$$=mknode("",$1,$3);}|
ID_PROD ';' {$$=mknode("",$1,NULL);}|
SEMICOL_ASS {$$=mknode("",$1,NULL);}

STRING_ASS:
STR_ASS ',' ID_PROD STRING_ASS {$$=mknode("",$1,mknode("",$2,$3));}|
STR_ASS ';' {$$=mknode("",$1,NULL);}|
ADDRESSING ',' ID_PROD STRING_ASS {$$=mknode("",$1,mknode("",$3,$4));}|
ADDRESSING ';' {$$=mknode("",$1,NULL);}

EXP:
'(' EXP ')' OPERATORS EXP{$$=mknode("",mknode("()",$2,$4),$5);}|
'(' EXP ')' {$$=mknode("",mknode("()",$2,NULL),NULL);}|
ID_PROD OPERATORS EXP {$$=mknode("",mknode("",$1,$2),$3);}|
VALUE OPERATORS EXP {$$=mknode("",mknode("",$1,$2),$3);}|
PTR_ADD ADDRESSING OPERATORS EXP {$$=mknode("",mknode("",mknode("",$1,$2),$3),$4);}|
ID_PROD ADDRESSING OPERATORS EXP {$$=mknode("",mknode("",mknode("",$1,$2),$3),$4);}|
FUNC_CALL OPERATORS EXP {$$=mknode("",mknode("",$1,$2),$3);}|
PTR_ADD OPERATORS EXP {$$=mknode("",mknode("",$1,$2),$3);}|
PTR_VALUE OPERATORS EXP {$$=mknode("",mknode("",$1,$2),$3);}|
STR_SIZE OPERATORS EXP {$$=mknode("",mknode("",$1,$2),$3);}|
ID_PROD {$$=mknode("",$1,NULL);}|
VALUE {$$=mknode("",$1,NULL);}|
PTR_ADD ADDRESSING {$$=mknode("",mknode("",$1,$2),NULL);}|
ID_PROD ADDRESSING {$$=mknode("",mknode("",$1,$2),NULL);}|
FUNC_CALL {$$=mknode("",$1,NULL);}|
PTR_ADD {$$=mknode("",$1,NULL);}|
PTR_VALUE {$$=mknode("",$1,NULL);}|
STR_SIZE {$$=mknode("",$1,NULL);}

OPERATORS: 
EQ {$$=mknode("==",NULL,NULL);}|
AND {$$=mknode("&&",NULL,NULL);}|
OR {$$=mknode("||",NULL,NULL);}|
NOT {$$=mknode("!",NULL,NULL);}|
NOTEQ {$$=mknode("!=",NULL,NULL);}|
L {$$=mknode(">",NULL,NULL);}|
S {$$=mknode("<",NULL,NULL);}|
LEQ {$$=mknode(">=",NULL,NULL);}|
SEQ {$$=mknode("<=",NULL,NULL);}|
PLUS {$$=mknode("+",NULL,NULL);}|
MINUS {$$=mknode("-",NULL,NULL);}|
MUL {$$=mknode("*",NULL,NULL);}|
DIV {$$=mknode("/",NULL,NULL);}

VALUE:
INT {$$=mknode(strdup(yytext),NULL,NULL);}|
REAL {$$=mknode(strdup(yytext),NULL,NULL);}|
TRUE {$$=mknode("TRUE",NULL,NULL);}|
FALSE {$$=mknode("FALSE",NULL,NULL);}|
NONE {$$=mknode("NULL",NULL,NULL);}|
CH {$$=mknode(strdup(yytext),NULL,NULL);}|
STR {$$=mknode(strdup(yytext),NULL,NULL);} 

ID_PROD: 
ID {$$=mknode(yytext,NULL,NULL);}

STRING_PROD: 
STRING {$$=mknode("STRING",NULL,NULL);}

AMPR_PROD:
AMPR {$$=mknode(yytext,NULL,NULL);}

MUL_PROD:
MUL {$$=mknode(yytext,NULL,NULL);}

VOID_PROD:
VOID {$$=mknode(yytext,NULL,NULL);}

INT_PROD:
INT {$$=mknode(yytext,NULL,NULL);}

MAIN_PROD:
MAIN {$$=mknode(yytext,NULL,NULL);}

STR_SIZE: 
'|' ID_PROD '|'  {$$=mknode("SIZE_OF:",$2,NULL);}

INIT: 
LHS ASS EXP {$$=mknode("=",$1,$3);}

INC:
ID_PROD ASS EXP {$$=mknode("=",$1,$3);}

PTR_ADD:
AMPR_PROD ID_PROD {$$=mknode("",$1,$2);}

PTR_VALUE:
MUL_PROD ID_PROD {$$=mknode("",$1,$2);}

ADDRESSING:
'[' ID_PROD ']' {$$=mknode("[]",$2,NULL);}|
'[' INT_PROD ']' {$$=mknode("[]",$2,NULL);}
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

vars* mkvars(int nov, char **names, char *type)
{
  vars *varList = (vars*)malloc(sizeof(vars));
  strcpy(varList->type,type);
  varList->numOfVars = nov;
  varList->var_names = twoDcharArrAlloc(varList->var_names,nov);
  varList->var_names = twoDcharArrDC(varList->var_names,names,nov);
  return varList;
}

char** twoDcharArrAlloc(char **names,int nov)
{
  names = malloc(nov * sizeof(char*));
  for (int i = 0; i < nov; i++)
  {
      names[i] = malloc(50 * sizeof(char));
  }
  return names;
}

char** twoDcharArrDC(char **names1,char **names2,int nov)
{
  for (int i = 0; i < nov; i++)
  {
    strcpy(names1[i],names2[i]);
  }
  return names1;
}

args* mkargs(int non)
{
  args *argsList = (args*)malloc(sizeof(args));
  argsList->numOfArgs = 0;
  argsList->arraySize = non;
  argsList->varsArray = malloc(argsList->arraySize * sizeof(vars));
  return argsList;
}

symbolTable* mksymbolTable(int symlevel,vars* varsArray,int nov,functions* funcsArray,int nof,functions *ref,node *Blockref)
{
  symbolTable *tbl = (symbolTable*)malloc(sizeof(symbolTable));
  tbl->symLevel = symlevel;
  tbl->VarraySize = nov;
  tbl->varsArray = malloc(tbl->VarraySize * sizeof(vars));
  for (int i = 0; i < tbl->VarraySize; i++)
  {
    tbl->varsArray[i] = varsArray[i];
  }
  tbl->FarraySize = nof;
  tbl->funcsArray = malloc(tbl->FarraySize * sizeof(functions));
  for (int i = 0; i < tbl->FarraySize; i++)
  {
    tbl->funcsArray[i] = funcsArray[i];
  }
  tbl->symbolArray = NULL;
  tbl->inc = 0;
  tbl->ref = ref;
  tbl->checkBlockref = (node*)malloc(sizeof(node));
  tbl->checkBlockref = Blockref;
  tbl->Sref = NULL;
  tbl->SymiD = id_for_s++;
  return tbl;
}

void addSymbolTables(symbolTable *s,node* StatTree)
{
  s->symbolArray[s->inc] = *checkBlockDec(StatTree->left,s->symLevel,s->ref);
  s->inc++;
}

functions* mkfunctions(char *type, char *name,int l,args *ar,functions *ref)
{
  functions *f = (functions*)malloc(sizeof(functions));
  strcpy(f->fType,type);
  strcpy(f->fName,name);
  f->fLevel = l;
  f->fArgs = (args*)malloc(sizeof(args));
  f->fArgs = ar;
  if (strcmp(f->fType,"void")!=0)
  {
    f->rtn = 1;
  }
  else
    f->rtn = 0;
  f->ref = ref;
  return f;
}

void startSemantics(node *ast)
{
  firstEnvi(ast);
  functions *globalFunctions = malloc(enviCounter * sizeof(functions));
  for (int i = 0; i < enviCounter; i++)
  {
    globalFunctions[i] = *checkSemantics(&enviArr[i],0,NULL);
  }
  for (int i = 0; i < enviCounter; i++)
  {
    AssRef(globalFunctions[i].tbl);
  }
  /*for (int i = 0; i < enviCounter; i++)
  {
    printfunc(&globalFunctions[i],0);
    printf("\n\n");
  }*/
  CrossGfuncs(globalFunctions);
  for (int i = 0; i < enviCounter; i++)
  {
    AnalysisFuncs(&enviArr[i],&globalFunctions[i],globalFunctions);
  }
  printf("\nAnalysis complete\n\n");
}

void firstEnvi(node *ast)
{
  if(ast == NULL || ast->left == NULL || ast->right == NULL)
    return;
  if(strcmp(ast->left->token,"(FUNC") == 0 && strcmp(ast->right->token,"(CODE") == 0)
  {
    enviArr[enviCounter] = *ast->left;
    enviCounter++;
  } 
  if(strcmp(ast->token,"(CODE") == 0 && strcmp(ast->left->token,"(FUNC") == 0)
  {
    enviArr[enviCounter] = *ast->left;
    enviCounter++;
  }
  firstEnvi(ast->left);
  firstEnvi(ast->right);
}

void CrossGfuncs(functions *gfuncs)
{
  for (int i = 0; i < enviCounter; i++)
  {
    for (int j = i+1; j < enviCounter; j++)
    {
      if (strcmp(gfuncs[i].fName,gfuncs[j].fName)==0)
      {
        printf("Function %s is already declared\n",gfuncs[i].fName);
        exit(1);
      }
    }
  }
  if (strcmp(gfuncs[enviCounter-1].fName,"main")!=0)
  {
    printf("Function main isn't declared\n");
    exit(1);
  }
}

functions* checkSemantics(node *funcTree,int level,functions *ref)
{
  node *argsTree = funcTree->left->right->left;
  int numOfArgsNodes = ArgsCounter(argsTree);
  args *a = mkargs(numOfArgsNodes);
  checkArgs(argsTree,a,numOfArgsNodes);
  node *blockTree = funcTree->left->right->right->left;
  functions *f = mkfunctions(funcTree->left->left->left->token,funcTree->left->left->right->token,level,a,ref);
  symbolTable *s = checkBlockDec(blockTree,level,f);
  f->tbl = (symbolTable*)malloc(sizeof(symbolTable));
  f->tbl = s;
  return f;
}

symbolTable* checkBlockDec(node *blockTree,int level,functions *ref)
{
  node *DecTree = blockTree->left;
  int numOfvars = DecCounter(DecTree,"VAR");
  int numOfstrings = DecCounter(DecTree,"STRING");  
  int numOffuncs = DecCounter(DecTree,"(FUNC");
  node *varnodes = malloc(numOfvars * sizeof(node));
  node *stringnodes = malloc(numOfstrings * sizeof(node));  
  node *funcsnodes = malloc(numOffuncs * sizeof(node));
  fillTrees(DecTree,"VAR",varnodes,numOfvars-1);
  fillTrees(DecTree,"STRING",stringnodes,numOfstrings-1);  
  int totalSize = numOfvars+numOfstrings;
  node *newarr = malloc(totalSize * sizeof(node));
  for (int i = 0; i < numOfvars; i++)
  {
    newarr[i] = varnodes[i];
  }
  for (int i = 0; i < numOfstrings; i++,numOfvars++)
  {
    newarr[numOfvars] = stringnodes[i];
  }
  fillTrees(DecTree,"(FUNC",funcsnodes,numOffuncs-1);
  vars *varsArray = malloc(totalSize * sizeof(vars));
  for (int i = 0; i < totalSize; i++)
  {
    char** vars;
    int arraySize;
    if (strcmp(newarr[i].token,"STRING")==0)
    {
      arraySize = StringsRightCounter(&newarr[i]);
    }
    else
      arraySize = NodesRightCounter(newarr[i].right);
    vars = twoDcharArrAlloc(vars,arraySize);
    if (strcmp(newarr[i].token,"STRING")==0)
    {
      fillStringstoVar(&newarr[i],vars,arraySize-1);
    }
    else
      fillVarsArray(newarr[i].right,vars,arraySize-1);
    if(strcmp(newarr[i].token,"STRING")==0)
      varsArray[i] = *mkvars(arraySize,vars,"STRING");
    else
      varsArray[i] = *mkvars(arraySize,vars,newarr[i].left->token);
  }
  functions *funcsArray = malloc(numOffuncs * sizeof(functions));
  for (int i = 0; i < numOffuncs; i++)
  {
    funcsArray[i] = *checkSemantics(&funcsnodes[i],level+1,ref);
  }
  node *StatTree = blockTree->right;
  symbolTable *s = mksymbolTable(level+1,varsArray,numOfvars,funcsArray,numOffuncs,ref,StatTree);
  int numOfblocksStat = BlockStatCount(StatTree);
  s->symbolArray = malloc(numOfblocksStat * sizeof(symbolTable));
  s->SarraySize = numOfblocksStat;
  fillStat(StatTree,s);
  return s;
}

void AnalysisFuncs(node *funcTree,functions *f,functions *globalfuncs)
{
  InnerFuncsValidation(f,0);
  decValidations(f);
  CheckFuncSem(funcTree,f,globalfuncs,f->tbl->checkBlockref,0);
  for (int i = 0; i < f->tbl->FarraySize; i++)
  {
    AnalysisFuncs(FindFunc(funcTree->left->right->right->left->left,f->tbl->funcsArray[i].fName),&f->tbl->funcsArray[i],globalfuncs);
  }
}

void InnerFuncsValidation(functions *f,int index)
{
  for (int i = 0; i < f->tbl->FarraySize; i++)
  {
    for (int j = i+1; j < f->tbl->FarraySize; j++)
    {
      if(strcmp(f->tbl->funcsArray[i].fName,f->tbl->funcsArray[j].fName)==0)
      {
        printf("Function %s is already declared\n",f->tbl->funcsArray[i].fName);
        exit(1);
      }
    }
    functions *temp = f->tbl->funcsArray[i].ref;
    while(temp != NULL)
    {
      if (strcmp(f->tbl->funcsArray[i].fName,temp->fName)==0)
        {
          printf("Function %s is already declared\n",f->tbl->funcsArray[i].fName);
          exit(1);
        }
      temp = temp->ref;
    }
  }
  if(f->tbl->FarraySize==0)
    return;
  if(index<f->tbl->FarraySize)
    InnerFuncsValidation(&f->tbl->funcsArray[index],index+1);
}

node *FindFunc(node *decTree,char *fname)
{
  if (decTree == NULL)
  {
    return NULL;
  }
  if (decTree->left != NULL && strcmp(decTree->left->token,"(FUNC")==0)
  {

    if(strcmp(decTree->left->left->left->right->token,fname)==0)
      return decTree->left;
  }
  return FindFunc(decTree->right,fname);
}

void CheckFuncSem(node *funcTree,functions *f,functions *globalfuncs,node *Blockref,int level)
{
  node *start = Blockref;//f->tbl->checkBlockref;
  int rtnFlag=0;
  int counter=0;
  while(start != NULL)
  {
    if(start->left != NULL && strcmp(start->left->token,"")==0)//Assignment check
    {
      checkAss(start->left->left,f,globalfuncs);
    }
    if(start->left != NULL && strcmp(start->left->token,"RETURN")==0)//Return check
    {
      checkRTN(start->left,f,globalfuncs);
      rtnFlag=1;
    }
    if(start->left != NULL && strcmp(start->left->token,"FUNC")==0)//Func call check
    {
      checkCall(start->left,f,globalfuncs);
    }
    if(start->left != NULL && strcmp(start->left->token,"(BLOCK")==0)//BLOCK check
    {
      if (symbolhelp==NULL)
      {
        symbolhelp=&f->tbl->symbolArray[counter];
        counter++;
      }
      else
      {
        symbolhelp=&symbolhelp->symbolArray[counter];
        counter++;
      }
      CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
    }
    if(start->left != NULL && strcmp(start->left->token,"IF")==0)//IF check
    {
      if(strcmp(EXPsem(start->left->left,f,globalfuncs),"BOOL")!=0)
      {
        printf("IF condition must be BOOL type not %s\n",EXPsem(start->left->left,f,globalfuncs));
        exit(1);
      }
      if(start->left->right != NULL && strcmp(start->left->right->token,"(BLOCK")==0)
      {
        if (symbolhelp==NULL)
        {
          symbolhelp=&f->tbl->symbolArray[counter];
          counter++;
        }
        else
        {
          symbolhelp=&symbolhelp->symbolArray[counter];
          counter++;
        }
        CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
      }
      else if(start->left->right != NULL && strcmp(start->left->right->token,"FUNC")==0)
      {
        checkCall(start->left->right,f,globalfuncs);
      }
      else
      {
        checkAss(start->left->right->left,f,globalfuncs);
      }
    }
    if(start->left != NULL && strcmp(start->left->token,"IF-ELSE")==0)//IF-ELSE check
    {
      if(strcmp(EXPsem(start->left->left->left,f,globalfuncs),"BOOL")!=0)
      {
        printf("IF condition must be BOOL type not %s\n",EXPsem(start->left->left->left,f,globalfuncs));
        exit(1);
      }
      if(start->left->left->right != NULL && strcmp(start->left->left->right->token,"(BLOCK")==0)
      {
        if (symbolhelp==NULL)
        {
          symbolhelp=&f->tbl->symbolArray[counter+1];
        }
        else
        {
          symbolhelp=&symbolhelp->symbolArray[counter+1];
        }
        CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
        if(start->left->right->left != NULL && strcmp(start->left->right->left->token,"(BLOCK")==0)
        {
          if (symbolhelp==NULL)
          {
            symbolhelp=&f->tbl->symbolArray[counter];
            counter++;
          }
          else
          {
            symbolhelp=&symbolhelp->symbolArray[counter];
            counter++;
          }
          CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
        }
        else if (start->left->right->left != NULL && strcmp(start->left->right->left->token,"FUNC")==0)
        {
          checkCall(start->left->right->left,f,globalfuncs);
        }
        else
          checkAss(start->left->right->left->left,f,globalfuncs);
      }
      else if(start->left->left->right != NULL && strcmp(start->left->left->right->token,"FUNC")==0)
      {
        checkCall(start->left->left->right,f,globalfuncs);
        if(start->left->right->left != NULL && strcmp(start->left->right->left->token,"(BLOCK")==0)
        {
          if (symbolhelp==NULL)
          {
            symbolhelp=&f->tbl->symbolArray[counter];
            counter++;
          }
          else
          {
            symbolhelp=&symbolhelp->symbolArray[counter];
            counter++;
          }
          CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
        }
        else if (start->left->right->left != NULL && strcmp(start->left->right->left->token,"FUNC")==0)
        {
          checkCall(start->left->right->left,f,globalfuncs);
        }
        else
          checkAss(start->left->right->left->left,f,globalfuncs);
      }
      else
      {
        checkAss(start->left->left->right->left,f,globalfuncs);
        if(start->left->right->left != NULL && strcmp(start->left->right->left->token,"(BLOCK")==0)
        {
          if (symbolhelp==NULL)
          {
            symbolhelp=&f->tbl->symbolArray[counter];
            counter++;
          }
          else
          {
            symbolhelp=&symbolhelp->symbolArray[counter];
            counter++;
          }
          CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
        }
        else if (start->left->right->left != NULL && strcmp(start->left->right->left->token,"FUNC")==0)
        {
          checkCall(start->left->right->left,f,globalfuncs);
        }
        else
          checkAss(start->left->right->left->left,f,globalfuncs);
      }
    }
    if(start->left != NULL && strcmp(start->left->token,"WHILE")==0)//WHILE check
    {
      if(strcmp(EXPsem(start->left->left,f,globalfuncs),"BOOL")!=0)
      {
        printf("WHILE condition must be BOOL type not %s\n",EXPsem(start->left->left,f,globalfuncs));
        exit(1);
      }
      if(start->left->right != NULL && strcmp(start->left->right->token,"(BLOCK")==0)
      {
        if (symbolhelp==NULL)
        {
          symbolhelp=&f->tbl->symbolArray[counter];
          counter++;
        }
        else
        {
          symbolhelp=&symbolhelp->symbolArray[counter];
          counter++;
        }
        CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
      }
      else if(start->left->right != NULL && strcmp(start->left->right->token,"FUNC")==0)
      {
        checkCall(start->left->right,f,globalfuncs);
      }
      else
      {
        checkAss(start->left->right->left,f,globalfuncs);
      }
    }
    if(start->left != NULL && strcmp(start->left->token,"DO-WHILE")==0)//DO-WHILE check
    {
      if (symbolhelp==NULL)
          {
            symbolhelp=&f->tbl->symbolArray[counter];
            counter++;
          }
          else
          {
            symbolhelp=&symbolhelp->symbolArray[counter];
            counter++;
          }
          CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
      if(strcmp(EXPsem(start->left->right,f,globalfuncs),"BOOL")!=0)
      {
        printf("WHILE condition must be BOOL type not %s\n",EXPsem(start->left->right,f,globalfuncs));
        exit(1);
      }
    }
    if(start->left != NULL && strcmp(start->left->token,"FOR")==0)//FOR check
    {
      if (!(strcmp(EXPsem(start->left->left->left->left,f,globalfuncs),EXPsem(start->left->left->left->right,f,globalfuncs))==0 && strcmp(EXPsem(start->left->left->left->right,f,globalfuncs),"INT")==0))
      {
        printf("For loop can only be initialized with INT type\n");
        exit(1);
      }
      if(strcmp(EXPsem(start->left->left->right,f,globalfuncs),"BOOL")!=0)
      {
        printf("FOR condition must be BOOL type not %s\n",EXPsem(start->left->left,f,globalfuncs));
        exit(1);
      }
      if (!(strcmp(EXPsem(mknode("",start->left->left->left->left->left,NULL),f,globalfuncs),EXPsem(start->left->left->left->left,f,globalfuncs))==0 && strcmp(EXPsem(start->left->left->left->left,f,globalfuncs),"INT")==0))
      {
        printf("For loop can only be incremented with INT type\n");
        exit(1);
      }
      if(start->left->right->right != NULL && strcmp(start->left->right->right->token,"(BLOCK")==0)
      {
        if (symbolhelp==NULL)
        {
          symbolhelp=&f->tbl->symbolArray[counter];
          counter++;
        }
        else
        {
          symbolhelp=&symbolhelp->symbolArray[counter];
          counter++;
        }
        CheckFuncSem(funcTree,f,globalfuncs,symbolhelp->checkBlockref,level+1);
      }
      else if(start->left->right->right != NULL && strcmp(start->left->right->right->token,"FUNC")==0)
      {
        checkCall(start->left->right->right,f,globalfuncs);
      }
      else
        checkAss(start->left->right->right->left,f,globalfuncs);
    }
    symbolhelp=NULL;
    start = start->right;
  }
  if(strcmp(f->fType,"void")!=0 && rtnFlag==0 && level==0)
  {
    printf("Non void function %s (%s) must return a type\n",f->fName,f->fType);
    exit(1);
  }
}

void decValidations(functions *f)
{
  for (int i = 0; i < f->tbl->VarraySize; i++)
  {
    for (int j = 0; j < f->tbl->varsArray[i].numOfVars; j++)
    {
      check2DArray(&f->tbl->varsArray[i]);
    }
    for (int k = i+1; k < f->tbl->VarraySize; k++)
    {
      check2Vars(&f->tbl->varsArray[i],&f->tbl->varsArray[k]);
    }
    CrossWithArgs(&f->tbl->varsArray[i],f->fArgs);
  }
}

void check2DArray(vars *v)
{
  for (int i = 0; i < v->numOfVars; i++)
  {
    for (int j = i+1; j < v->numOfVars; j++)
    {
      if(strcmp(v->var_names[i],v->var_names[j])==0)
      {
        printf("%s already exists\n",v->var_names[i]);
        exit(1);
      }
    }
  }
}

void check2Vars(vars *v1,vars *v2)
{
  for (int i = 0; i < v1->numOfVars; i++)
  {
    for (int j = 0; j < v2->numOfVars; j++)
    {
      if(strcmp(v1->var_names[i],v2->var_names[j])==0)
      {
        printf("%s already exists\n",v1->var_names[i]);
        exit(1);
      }
    }
  }
}

void CrossWithArgs(vars *v,args *a)
{
    for (int j = 0; j < a->arraySize; j++)
    {
      check2Vars(v,&a->varsArray[j]);
    }
}

void checkAss(node *ASStree,functions* f,functions *globalfuncs)
{
  vars *lhs;
  char lhsType[10];
  char rhsType[10];
  if(strcmp(ASStree->left->left->token,"")!=0)
  {
    if(ASStree->left->right == NULL)
    {
      lhs = SearchID(ASStree->left->left,f->tbl,globalfuncs);
      strcpy(lhsType,lhs->type); 
    }
    else
    {
      strcpy(lhsType,ptrSem(ASStree,f,globalfuncs));
    }
  }
  else
  {
    strcpy(lhsType,ptrSem(ASStree->left->left,f,globalfuncs));
  }
  strcpy(rhsType,EXPsem(ASStree->right,f,globalfuncs));
  if(strcmp(lhsType,rhsType)!=0)
  {
    printf("Cannot assign between %s and %s\n",lhsType,rhsType);
    exit(1);
  }
}

void checkRTN(node *ASStree,functions* f,functions *globalfuncs)
{
  char fType[10];
  char rhsType[10];
  strcpy(fType,f->fType);
  strcpy(rhsType,EXPsem(ASStree->left,f,globalfuncs));
  if(strcmp(fType,rhsType)!=0)
  {
    printf("Error! - function %s type is %s, not %s\n",f->fName,fType,rhsType);
    exit(1);
  }
}

char* checkCall(node *ASStree,functions* f,functions *globalfuncs)
{
  functions *temp_f = SearchFUNC(ASStree->left->token,f,globalfuncs,0);
  int callArgs = NodesRightCounter(ASStree->right);
  if(temp_f->fArgs->numOfArgs == 0)
  {
    if(ASStree->right == NULL)
      return temp_f->fType;
    else
    {
      printf("Function %s recives 0 but %d sent\n",temp_f->fName,callArgs);
      exit(1);
    }
  }
  else
  {
    if(callArgs!=temp_f->fArgs->numOfArgs)
    {
      printf("Function %s recives %d but %d sent\n",temp_f->fName,temp_f->fArgs->numOfArgs,callArgs);
      exit(1);
    } 
  }
  char** args;
  args = twoDcharArrAlloc(args,callArgs);
  int i = 0;
  node *tempExp = ASStree->right;
  while(tempExp!=NULL)
  {
    strcpy(args[i],EXPsem(tempExp->left,f,globalfuncs));
    tempExp=tempExp->right;
    i++;
  }
  int index=0;
  for (int i = 0; i < temp_f->fArgs->arraySize; i++)
  {
    for (int j = 0; j < temp_f->fArgs->varsArray[i].numOfVars; j++)
    {
      if(strcmp(args[index],temp_f->fArgs->varsArray[i].type)!=0)
      {
        printf("Passing %s type insted of %s type\n",args[j],temp_f->fArgs->varsArray[i].type);
        exit(1);
      }
      index++;
    }
  }
  return temp_f->fType;
}

char* ptrSem(node *ASStree,functions* f,functions *globalfuncs)
{
  if (strcmp(ASStree->token,"=")==0)
  {
    if (strcmp(findType(ASStree->left->left->token,f,globalfuncs),"STRING")==0)
    {
      if(strcmp(findType(ASStree->left->right->left->token,f,globalfuncs),"INT")!=0)
        {
          printf("Value inside [] must be an INT (%s is %s)\n",ASStree->left->left->token,findType(ASStree->left->right->left->token,f,globalfuncs));
          exit(1);
        }
    }
    else
    {
      printf("[] can only be assign on STRING (not %s)\n",findType(ASStree->left->left->token,f,globalfuncs));
      exit(1);
    }
    return "CHAR";
  }
  if(strcmp(ASStree->left->token,"&")==0)
  {
    if (strcmp(findType(ASStree->right->token,f,globalfuncs),"INT")==0)
    {
      return "INT*";
    }
    if (strcmp(findType(ASStree->right->token,f,globalfuncs),"CHAR")==0)
    {
      return "CHAR*";
    }
    if (strcmp(findType(ASStree->right->token,f,globalfuncs),"REAL")==0)
    {
      return "REAL*";
    }
  }
  if (strcmp(ASStree->left->token,"*")==0)
  {
    if (strcmp(findType(ASStree->right->token,f,globalfuncs),"INT*")==0)
    {
      return "INT";
    }
    if (strcmp(findType(ASStree->right->token,f,globalfuncs),"CHAR*")==0)
    {
      return "CHAR";
    }
    if (strcmp(findType(ASStree->right->token,f,globalfuncs),"REAL*")==0)
    {
      return "REAL";
    }
    printf("%s isn't a pointer! (Cannot assign * on %s)\n",ASStree->right->token,findType(ASStree->right->token,f,globalfuncs));
    exit(1);
  }
  if (strcmp(ASStree->right->token,"[]")==0)
  {
    if (ASStree->left->left != NULL && strcmp(ASStree->left->left->token,"&")==0)
    {
      if (strcmp(findType(ASStree->left->right->token,f,globalfuncs),"STRING")==0)
      {
        if(strcmp(findType(ASStree->right->left->token,f,globalfuncs),"INT")!=0)
        {
          printf("Value inside [] must be an INT (%s is %s)\n",ASStree->left->right->token,findType(ASStree->left->right->token,f,globalfuncs));
          exit(1);
        }
      }
      else
      {
        printf("[] can only be assign on STRING (not %s)\n",findType(ASStree->left->right->token,f,globalfuncs));
        exit(1);
      }
      return "CHAR*";
    }
    else
    {
      if (strcmp(findType(ASStree->left->token,f,globalfuncs),"STRING")==0)
      {
        if(strcmp(findType(ASStree->right->left->token,f,globalfuncs),"INT")!=0)
        {
          printf("Value inside [] must be an INT\n");
          exit(1);
        }
        return "CHAR";
      }
      else
      {
        if (ASStree->left->right != NULL)
        {
          printf("[] can only be assign on STRING (not %s)\n",findType(ASStree->left->right->token,f,globalfuncs));
        }
        else
        {
          printf("[] can only be assign on STRING (not %s)\n",findType(ASStree->left->token,f,globalfuncs));
        }
      }
    }
  }
  printf("Error! incompetabale pointer\n");
  exit(1);
}

char* EXPsem(node *ASStree,functions* f,functions *globalfuncs)
{
  if (strcmp(ASStree->left->token,"")!=0 && ASStree->right == NULL && strcmp(ASStree->left->token,"FUNC")!=0
     && strcmp(ASStree->left->token,"SIZE_OF:")!=0  && strcmp(ASStree->left->token,"()")!=0)
  {
    return findType(ASStree->left->token,f,globalfuncs);
  }
  int size = NodesRightCounter(ASStree);
  node *rhs;
  rhs = malloc(size * sizeof(node));
  char **assArgs;
  char **opArgs;
  ARTMto2Darray(ASStree,rhs,size);
  assArgs = twoDcharArrAlloc(assArgs,size);
  opArgs = twoDcharArrAlloc(opArgs,size-1);
  node *ptrOP = ASStree;
  for (int i = 0; i < size; i++)
  {
    if(strcmp(rhs[i].token,"()")==0)
    {
      strcpy(assArgs[i],EXPsem(rhs[i].left,f,globalfuncs));
    }
    else if(strcmp(rhs[i].left->token,"")!=0)
    {
      if(strcmp(rhs[i].left->token,"FUNC")==0)
      {
        strcpy(assArgs[i],checkCall(rhs[i].left,f,globalfuncs));
      }
      else if(strcmp(rhs[i].left->token,"SIZE_OF:")==0)
      {
        strcpy(assArgs[i],checkStrSize(rhs[i].left,f,globalfuncs));
      }
      else if(strcmp(rhs[i].left->token,"()")==0)
      {
        strcpy(assArgs[i],EXPsem(rhs[i].left,f,globalfuncs));
      }
      else
      {
        strcpy(assArgs[i],findType(rhs[i].left->token,f,globalfuncs));
      }
    }
    else
    {
      strcpy(assArgs[i],ptrSem(rhs[i].left,f,globalfuncs));
    }
  }
  for (int i = 0; i < size-1; i++)
  {
    if (ptrOP->left->right!=NULL)
    {
      strcpy(opArgs[i],ptrOP->left->right->token);
    }
    ptrOP = ptrOP->right;
  }
  if(size == 1)
  {
    return assArgs[0];
  }
  else
  {
    char last[50];
    int Args_size = size;
    int Ops_size = size-1;
    while(Args_size > 1)
    {
      int loop = Ops_size;
      int totalSize = Args_size;
      if(Args_size%2 == 0)
      {
        Args_size = Args_size/2;
      }
      else
      {
        strcpy(last,assArgs[Args_size-1]);
        Args_size = (Args_size/2)+1;
      }
      Ops_size = Args_size-1;
      //int help = Args_size;
      char** NewArgsArr;
      char** NewOpsArr;
      int index = 0;
      int indexArgs = 0;
      int indexOp = 0;
      for (int i = 0; i < loop; i+=2)
      {
        NewArgsArr=twoDcharArrAlloc(NewArgsArr,Args_size);
        NewOpsArr=twoDcharArrAlloc(NewOpsArr,Ops_size);
        if (strcmp(assArgs[index+1],"")==0)
        {
          strcpy(assArgs[index+1],last);
        }
        if(strcmp(opArgs[i],"==")==0 || strcmp(opArgs[i],"!=")==0)
        {
          if(strcmp(assArgs[index],assArgs[index+1])==0)
          {
            strcpy(NewArgsArr[indexArgs],"BOOL");
            if (indexOp!=Ops_size)
            {
              strcpy(NewOpsArr[indexOp],opArgs[i+1]);
              indexOp++;
            }
            indexArgs++;
          }
          else
          {
            printf("Error! Cannot compare between %s and %s\n",assArgs[index],assArgs[index+1]);
            exit(1);
          }
        }
        else if (strcmp(opArgs[i],"+")==0 || strcmp(opArgs[i],"-")==0 || 
          strcmp(opArgs[i],"*")==0 || strcmp(opArgs[i],"/")==0 ||
          strcmp(opArgs[i],"<")==0 || strcmp(opArgs[i],">")==0 || 
          strcmp(opArgs[i],"<=")==0 || strcmp(opArgs[i],">=")==0)
        {
          if (strcmp(opArgs[i],"+")==0 || strcmp(opArgs[i],"-")==0 || 
          strcmp(opArgs[i],"*")==0 || strcmp(opArgs[i],"/")==0)
          {
            if (strcmp(assArgs[index],"INT")==0 || strcmp(assArgs[index],"REAL")==0)
            {
              if (strcmp(assArgs[index+1],"INT")==0 || strcmp(assArgs[index],"REAL")==0)
              {
                if(strcmp(assArgs[index],assArgs[index+1])==0)
                {
                  strcpy(NewArgsArr[indexArgs],assArgs[index]);
                  if (indexOp!=Ops_size)
                  {
                    strcpy(NewOpsArr[indexOp],opArgs[i+1]);
                    indexOp++;
                  }
                  indexArgs++;
                }
                else
                {
                  strcpy(NewArgsArr[indexArgs],"REAL");
                  if (indexOp!=Ops_size)
                  {
                    strcpy(NewOpsArr[indexOp],opArgs[i+1]);
                    indexOp++;
                  }
                  indexArgs++;
                }
              }
              else
              {
                printf("Error! Cannot compare between %s and %s\n",assArgs[index],assArgs[index+1]);
                exit(1);
              }
            }
            else
            {
              printf("Error! Cannot compare between %s and %s\n",assArgs[index],assArgs[index+1]);
              exit(1);
            }
          }
          else
          {
            if (strcmp(assArgs[index],"INT")==0 || strcmp(assArgs[index],"REAL")==0)
            {
              if (strcmp(assArgs[index+1],"INT")==0 || strcmp(assArgs[index],"REAL")==0)
              {
                strcpy(NewArgsArr[indexArgs],"BOOL");
                if (indexOp!=Ops_size)
                {
                  strcpy(NewOpsArr[indexOp],opArgs[i+1]);
                  indexOp++;
                }
                indexArgs++;
              }
              else
              {
                printf("Error! Cannot compare between %s and %s\n",assArgs[index],assArgs[index+1]);
                exit(1);
              }
            }
            else
            {
              if (strcmp(assArgs[index+1],"BOOL")==0)
              {
                  strcpy(NewArgsArr[indexArgs],assArgs[index]);
                  if (indexOp!=Ops_size)
                  {
                    strcpy(NewOpsArr[indexOp],opArgs[i+1]);
                    indexOp++;
                  }
                  indexArgs++;
              }
              else
              {
                printf("Error! Cannot compare between %s and %s\n",assArgs[index],assArgs[index+1]);
                exit(1);
              }
              
            }
          }
        }
        else if (strcmp(opArgs[i],"||")==0 || strcmp(opArgs[i],"&&")==0)
        {
          if (strcmp(assArgs[index],"BOOL")==0 && strcmp(assArgs[index+1],"BOOL")==0)
          {
            strcpy(NewArgsArr[indexArgs],assArgs[index]);
                  if (indexOp!=Ops_size)
                  {
                    strcpy(NewOpsArr[indexOp],opArgs[i+1]);
                    indexOp++;
                  }
                  indexArgs++;
          }
          else
          {
              printf("Error! Cannot compare between %s and %s\n",assArgs[index],assArgs[index+1]);
              exit(1);
          }
        }
        index+=2;
      }
      assArgs=twoDcharArrAlloc(assArgs,Args_size);
      assArgs=twoDcharArrDC(assArgs,NewArgsArr,Args_size);
      opArgs=twoDcharArrAlloc(opArgs,Args_size);
      opArgs=twoDcharArrDC(opArgs,NewOpsArr,Args_size-1);
    }
  }
  return assArgs[0];
}

char* checkStrSize(node *ASStree,functions* f,functions *globalfuncs)
{
  if (strcmp(findType(ASStree->left->token,f,globalfuncs),"STRING")==0)
  {
    return "INT";
  }
  printf("Operator | | can be assign only on STRING type\n");
  exit(1);
}

char* findType(char* symbol,functions *f,functions *globalfuncs)
{
  int symSize=0;
  for (int i = 0; i < symbol[i] != '\0'; i++)
  {
    symSize++;
  }
  if(symSize == 3 && symbol[0] == '\'' && symbol[2] == '\'')
  {
    return "CHAR";
  }
  int flag=0;
  if (symSize>=2 && symbol[0]=='0' && (symbol[1]=='x' || symbol[1]=='X'))
  {
      return "INT";
  }
  for (int i = 0; i < symbol[i] != '\0'; i++)
  {
    if(!(symbol[i] >= '0' && symbol[i] <= '9'))
      flag=1;
  }
  if (flag==0)
  {
    return "INT";
  }
  if (strcmp(symbol,"TRUE")==0 || strcmp(symbol,"FALSE")==0)
  {
    return "BOOL";
  }
  if (strcmp(symbol,"NULL")==0)
  {
    return "NULL";
  }
  for (int i = 0; i < symbol[i] != '\0'; i++)
  {
    if(symbol[i] == '.')
    {
      return "REAL";
    }
  }
  char str[2];
  str[0] = '"';
  if(symbol[0] == str[0])
  {
    return "STRING";
  }
  vars *v = SearchID(mknode(symbol,NULL,NULL),f->tbl,globalfuncs);
  return v->type;
}

vars* SearchID(node *id,symbolTable *s,functions *globalfuncs)
{
  if (symbolhelp != NULL)
  {
    while(symbolhelp!=NULL)
    {
      for (int i = 0; i < symbolhelp->VarraySize; i++)
      {
        for (int j = 0; j < symbolhelp->varsArray[i].numOfVars; j++)
        {
          if(strcmp(symbolhelp->varsArray[i].var_names[j],id->token)==0)
          {
            return &symbolhelp->varsArray[i];
          }
        }
      }
      symbolhelp = symbolhelp->Sref;
    }
    symbolhelp=NULL;
  }
  functions *temp = s->ref;
  while(temp != NULL)
  {
    for (int i = 0; i < temp->tbl->VarraySize; i++)
    {
      for (int j = 0; j < temp->tbl->varsArray[i].numOfVars; j++)
      {
        if(strcmp(temp->tbl->varsArray[i].var_names[j],id->token)==0)
        {
          return &temp->tbl->varsArray[i];
        }
      }
    }
    for(int k = 0; k < temp->fArgs->arraySize; k++)
    {
      for (int t = 0; t < temp->fArgs->varsArray[k].numOfVars; t++)
      {
        if(strcmp(temp->fArgs->varsArray[k].var_names[t],id->token)==0)
        {
          return &temp->fArgs->varsArray[k];
        }
      }
    }
    temp = temp->ref;
  }
  functions *f = SearchFUNC(id->token,s->ref,globalfuncs,1);
  if (f != NULL)
  {
    char **tempArr;
    tempArr = twoDcharArrAlloc(tempArr,1);
    strcpy(tempArr[0],f->fName);
    return mkvars(1,tempArr,f->fType);
  }
  printf("Error! - %s isn't declared\n",id->token);
  exit(1);
}

symbolTable* helpsearch(symbolTable *s,int id)
{
  printf("***********\n");
  if (s->SymiD == id)
  {
    return s;
  }
  for (int i = 0; i < s->SarraySize; i++)
  {
    return helpsearch(&s->symbolArray[i],id);
  }
  return NULL;
}

functions* SearchFUNC(char *fname,functions *f,functions *globalfuncs,int flag)
{
  functions *temp = f,f2;
  while(temp != NULL)
  {
    if(strcmp(fname,temp->fName)==0)
      return temp;
    f = temp;
    temp = temp->ref;
  }
  int index;
  for (int i = 0; i < enviCounter; i++)
  {
    if (strcmp(f->fName,globalfuncs[i].fName)==0)
    {
      index = i; 
    }
  }
  for (int i = 0; i < enviCounter; i++)
  {
    if (strcmp(globalfuncs[i].fName,fname)==0)
    {
      if(index>=i)
      {
        return &globalfuncs[i];
      } 
    }
  }
  if (flag==1)
  {
    return NULL;
  }
  printf("Error! function: %s isn't declared\n",fname);
  exit(1);
}

void checkArgs(node *argsTree,args* a,int non)
{
  for (int i = 0; i < non; i++)
  {
    char **ids;
    char type[50];
    strcpy(type,argsTree->left->left->left->token);
    int avc = NodesRightCounter(argsTree->left->left->right);
    ids = twoDcharArrAlloc(ids,avc);
    fillVarsArray(argsTree->left->left->right,ids,avc-1);
    a->varsArray[i] = *mkvars(avc,ids,type);
    a->numOfArgs += avc;
    argsTree = argsTree->left->right;
  }  
}

int ArgsCounter(node *Tree)
{
  if(Tree == NULL|| Tree->left == NULL)
    return 0;
  return 1 + ArgsCounter(Tree->left->right);
}

int NodesRightCounter(node *varsTree)
{
  if(varsTree == NULL)
    return 0;
  return 1 + NodesRightCounter(varsTree->right);
}

int StringsRightCounter(node *stringTree)
{
  if(stringTree == NULL)
    return 0;
  if(stringTree->right != NULL && strcmp(stringTree->right->token,"")==0)
    return 1 + StringsRightCounter(stringTree->right->right);
  return StringsRightCounter(stringTree->right);
}

int DecCounter(node *DecTree,char* dec)
{
  if(DecTree == NULL)
    return 0;
  if (DecTree->left != NULL && strcmp(DecTree->left->token,dec)==0)
    return 1 + DecCounter(DecTree->right,dec);
  else
    return 0 + DecCounter(DecTree->right,dec);
}

void fillTrees(node *DecTree,char* dec,node *arr,int size)
{
  if(DecTree == NULL)
    return;
  if (DecTree->left != NULL && strcmp(DecTree->left->token,dec)==0)
  {
    arr[size] = *DecTree->left;
    size--;
  }
  return fillTrees(DecTree->right,dec,arr,size);
}

void fillVarsArray(node *varsTree,char** ids,int size)
{
  if(varsTree == NULL)
    return;
  if(varsTree->left != NULL && strcmp(varsTree->left->token,"FUNC")==0)
    strcpy(ids[size],varsTree->left->left->token);
  else if(varsTree->left != NULL && strcmp(varsTree->left->token,"=")==0)
    strcpy(ids[size],varsTree->left->left->token);
  else
    strcpy(ids[size],varsTree->left->token);
  fillVarsArray(varsTree->right,ids,size - 1);
}

void fillStringstoVar(node *varsTree,char** ids,int size)
{
  if(varsTree == NULL)
    return;
  strcpy(ids[size],varsTree->left->token);
  if(varsTree->right != NULL && strcmp(varsTree->right->token,"")==0)
    fillStringstoVar(varsTree->right->right,ids,size - 1);
}

void ARTMto2Darray(node *artmTree,node *exps,int size)
{
  node *temp = artmTree;
  for (int i = 0; i < size; i++)
  {
    if(temp->right != NULL)
      exps[i] = *temp->left;
    else
      exps[i] = *temp;
    temp = temp->right;
  }
}

int BlockStatCount(node *StatTree)
{
  if(StatTree == NULL || StatTree->left == NULL)
    return 0;
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"(BLOCK")==0)
    return 1 + BlockStatCount(StatTree->right);
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"IF")==0)
  {
    if (strcmp(StatTree->left->right->token,"(BLOCK")==0)
    {
      return 1 + BlockStatCount(StatTree->right);
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"IF-ELSE")==0)
  {
    if (strcmp(StatTree->left->left->right->token,"(BLOCK")==0)
    {
      if (strcmp(StatTree->left->right->token,"ELSE")==0)
      {
        if (strcmp(StatTree->left->right->left->token,"(BLOCK")==0)
        {
          return 1 + BlockStatCount(StatTree->right);
        }
      }
      return 1 + BlockStatCount(StatTree->right);
    }
    else
    {
      if (strcmp(StatTree->left->right->token,"ELSE")==0)
      {
        if (strcmp(StatTree->left->right->left->token,"(BLOCK")==0)
        {
          return 1 + BlockStatCount(StatTree->right);
        }
      }
    }    
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"WHILE")==0)
  {
    if(strcmp(StatTree->left->right->token,"(BLOCK")==0)
    {
      return 0 + BlockStatCount(StatTree->right);
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"DO-WHILE")==0)
  {
    if(strcmp(StatTree->left->left->token,"(BLOCK")==0)
    {
      return 0 + BlockStatCount(StatTree->right);
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"FOR")==0)
  {
    if(strcmp(StatTree->left->right->right->token,"(BLOCK")==0)
    {
      return 0 + BlockStatCount(StatTree->right);
    } 
  }
  return 0 + BlockStatCount(StatTree->right);
}

void fillStat(node *StatTree,symbolTable *s)
{
  if(StatTree == NULL || StatTree->left == NULL)
    return;
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"(BLOCK")==0)
  {
    addSymbolTables(s,StatTree->left);
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"IF")==0)
  {
    if (strcmp(StatTree->left->right->token,"(BLOCK")==0)
    {
      addSymbolTables(s,StatTree->left->right);
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"IF-ELSE")==0)
  {
    if (strcmp(StatTree->left->left->right->token,"(BLOCK")==0)
    {
      if (strcmp(StatTree->left->right->token,"ELSE")==0)
      {
        if (strcmp(StatTree->left->right->left->token,"(BLOCK")==0)
        {
          addSymbolTables(s,StatTree->left->right->left);
        }
      }
      addSymbolTables(s,StatTree->left->left->right);
    }
    else
    {
      if (strcmp(StatTree->left->right->token,"ELSE")==0)
      {
        if (strcmp(StatTree->left->right->left->token,"(BLOCK")==0)
        {
          addSymbolTables(s,StatTree->left->right->left);
        }
      }
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"WHILE")==0)
  {
    if(strcmp(StatTree->left->right->token,"(BLOCK")==0)
    {
      addSymbolTables(s,StatTree->left->right);
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"DO-WHILE")==0)
  {
    if(strcmp(StatTree->left->left->token,"(BLOCK")==0)
    {
      addSymbolTables(s,StatTree->left->left);
    }
  }
  if(StatTree->left != NULL && strcmp(StatTree->left->token,"FOR")==0)
  {
    if(strcmp(StatTree->left->right->right->token,"(BLOCK")==0)
    {
      addSymbolTables(s,StatTree->left->right->right);
    } 
  }
  fillStat(StatTree->right,s);
}

void AssRef(symbolTable *s)
{ 
  if (s->SarraySize==0)
  {
    return;
  }
  for (int i = 0; i < s->SarraySize; i++)
  {
    s->symbolArray[i].Sref=s;
    AssRef(&s->symbolArray[i]);
  }
}

void printtree(node *tree,int tabs)
{
  if(tree->token != NULL && strcmp(tree->token,"") != 0)
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

void printfunc(functions *f,int tabs)
{
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Name: %s\n",f->fName);
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Type: %s\n",f->fType);
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  if(f->ref == NULL)
  {
    printf("Belongs to Global\n");
    for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  }
  else
  {
    printf("Belongs to: %s\n",f->ref->fName);
    for (int i = 0; i < tabs; ++i)
      {
        printf("  ");
      }
  }
  printf("Level: %d\n",f->fLevel);
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printargs(f->fArgs,tabs+1);
  printtbl(f->tbl,tabs+1); 
}

void printargs(args *a,int tabs)
{
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("%d Args:\n",a->numOfArgs);
  for (int i = 0; i < a->arraySize; i++)
  {
    printvars(&a->varsArray[i],tabs+1);
  }
}

void printvars(vars *v,int tabs)
{
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Type: %s\n",v->type);
  for (int i = 0; i < v->numOfVars; i++)
  {
    for (int j = 0; j < tabs; j++)
    {
      printf("  ");
    }
    printf("%s\n",v->var_names[i]);
  }
}

void printtbl(symbolTable *tbl,int tabs)
{
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Symbol Table %d:\n",tbl->SymiD);
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Belongs to: %s\n",tbl->ref->fName);
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Level: %d\n",tbl->symLevel);
  for (int i = 0; i < tbl->VarraySize; i++)
  {
    printvars(&tbl->varsArray[i],tabs+1);
  }
  for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
  printf("Contain:\n");
  printtree(tbl->checkBlockref,tabs+1);
  for (int i = 0; i < tbl->FarraySize; i++)
  {
    printfunc(&tbl->funcsArray[i],tabs+1);
  }
  if(tbl->SarraySize > 0)
  {
    for (int i = 0; i < tabs; ++i)
    {
      printf("  ");
    }
    printf("%d Inner Tables\n",tbl->SarraySize);
    for (int i = 0; i < tbl->SarraySize; i++)
    {
      printtbl(&tbl->symbolArray[i],tabs+1);
    }
  }
}