%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "common.h"
#define GARBAGE 0
typedef struct symbol_table
{
    char name[31];
    char val[20];
    char datatype[10];
    int line_num;
}ST;
ST st[10000];
int sno = 0;



/*stack*/
char stack[100][100];
int top = -1;
int temp_ind = 0;

typedef struct quadruples_table{
	char op[10];
	char arg1[31];
	char arg2[31];
	char res[31];
}quadruple;

int quad_ind = 0;
quadruple quad[100];

int label_ind = 0;

Node* makenode();
void insert_to_ST(char *name,char *datatype,int line_num);
void print_symbol_table();
void insert_array_st(char *type, char *id, char* size,char *values,int line_num);
char *search_symbol(char *str);
char *validate_exp(char *var1, char *var2, char op);
void insert(char *name,char *datatype,int line_num,char *lval,char *rval);
void update_symbol_table(char *lval,char *rval,int line_num);

/*Quaruple Functions*/
void stack_push(Node *var);
void stack_push_str(char *var);
void codegen_assignment();
char *codegen();
void print_quadraples();
void else_body();
void if_cond(Node *cond,int line_num);
void if_body();
char temp[2]="t";
int temp_i = 0;
char tmp_i[3];
int lab_ind = 0;
int ltop=0;
int label[20];
int l_while=0;
void while1();
void while2();
void while3();

%}


%define api.value.type union
%define parse.error verbose


%start S



%token T_INCLUDE
%token T_STD
%token <char *> T_INT 
%token <char *> T_FLOAT 
%token <char *> T_CHAR 
%token <char *> T_STRING
%token T_VOID 
%token T_MAIN 
%token T_IF 
%token T_ELSE 
%token T_WHILE 
%token T_BREAK 
%token T_CONTINUE 
%token T_COUT 
%token T_CIN
%token T_ENDL 
%token T_RETURN
%token T_BOOL 
%token <char *> T_bool 
%token T_LIB_H  
%token T_lt 
%token T_le 
%token T_gt 
%token T_ge
%token T_eq 
%token T_ee 
%token T_ne 
%token <char *> T_and
%token <char *> T_or 
%token <char *> T_not 
%token T_comma 
%token T_dot 
%token T_semic 
%token T_dims 
%token T_brackets 
%token T_flow_brackets 
%token T_open_sq 
%token T_close_sq
%token T_mod

%token <char *> number
%token <char *> float_num
%token <char *> identifier
%token <char *> character
%token <char *> string
%token <char *> T_inc 
%token <char *> T_dec
%token <char *> T_add 
%token <char *> T_sub 
%token <char *> T_mul 
%token <char *> T_div 



%type <struct Node_t *> ASSIGNMENT
%type <struct Node_t *> EXP ADD_SUB MUL_DIV VAL DECLARATION TYPE MUL_DEC ARRAY_EXPR COND TERN_OP '(' ')' INC

%right T_eq
%left T_ee T_ne
%left T_lt T_gt T_le T_ge
%left T_pl T_min
%left T_mul T_div
%left '(' ')'


%%

S : INCLUDE {printf("\nINPUT ACCEPTED\n");};

INCLUDE : T_INCLUDE T_LIB_H INCLUDE  
		| T_INCLUDE string INCLUDE
		| FUNCTIONS
		| T_STD ';' INCLUDE ;


FUNCTIONS : MAIN
		  | FUNC_DEF FUNCTIONS;
 
MAIN : T_VOID T_MAIN FUNC_BODY  
	 | TYPE T_MAIN FUNC_BODY ;

FUNC_PAR : FUNC_PAR TYPE identifier
		 | FUNC_PAR TYPE ASSIGNMENT
		 | TYPE ASSIGNMENT
		 | FUNC_PAR T_comma
		 | TYPE identifier ;

FUNC_DEF :	T_VOID identifier PARAMS FUNC_BODY
		 |	TYPE identifier PARAMS FUNC_BODY ;

PARAMS : '(' FUNC_PAR ')'
		| T_brackets ; 


FUNC_BODY : '{' LINE '}'
		  | ';'
		  | '{' '}';

FUNC_CALL : identifier '(' FUNC_CALL_PAR ')' 
		  | identifier T_brackets ; 


FUNC_CALL_PAR : FUNC_CALL_PAR VAL
		 	  | FUNC_CALL_PAR T_comma
		 	  | VAL ;


LINE : LINE STATEMENT ';' 
	 | STATEMENT ';'
	 | LINE IF 
	 | IF
	 | LINE LOOP
	 | LOOP ;

/*IF : T_IF '(' COND ')' IF_BODY
   | T_IF '(' COND ')' IF_BODY T_ELSE IF_BODY 
   | T_IF '(' COND ')' IF_BODY T_ELSE T_IF '(' COND ')' IF_BODY T_ELSE IF_BODY;*/

IF : T_IF '(' COND ')' {if_cond($3,@3.last_line);} IF_BODY {if_body();} ELSE 	

ELSE: T_ELSE T_IF '(' COND ')' IF_BODY ELSE
	| T_ELSE {printf("L%d:\n",label_ind++);} IF_BODY	{else_body();}
	| {printf("L%d:\n",label_ind++);} {printf("L%d:\n",label_ind++);};
   

IF_BODY : '{' IF_LINE '}'
		| STATEMENT ';' ;

IF_LINE : IF_LINE STATEMENT ';'
		| IF_LINE IF
		| IF_LINE LOOP
		| STATEMENT ';'
		| IF 
		| LOOP;

LOOP : T_WHILE {while1();} '(' COND ')' {while2($4);} LOOP_BODY {while3();} ;

LOOP_BODY : '{' LOOP_LINE '}'
		  | STATEMENT ';' 
		  | ';' ;

LOOP_LINE : LOOP_LINE STATEMENT ';'
		  | LOOP_LINE LOOP
		  | LOOP_LINE IF
		  | STATEMENT ';'
		  | LOOP
		  | T_BREAK ';'		
		  | T_CONTINUE ';'
		  | IF;

ARRAY_EXPR	:	ARRAY_EXPR T_comma VAL 			{sprintf($$->val,"%s,%s",$1->val,$3->val);}
			|	VAL 							{strcpy($$->val,$1->val);};			

ARRAY	: TYPE identifier '[' VAL ']'   							{insert_array_st($1->val,$2,$4->val,"NA",@1.last_line);}
		| TYPE identifier T_dims T_eq '{' ARRAY_EXPR '}'			{insert_array_st($1->val,$2,"NA",$6->val,@1.last_line);}
		| TYPE identifier '[' VAL ']' T_eq '{' ARRAY_EXPR '}'		{insert_array_st($1->val,$2,$4->val,$8->val,@1.last_line);};

STATEMENT : PRINT
		  | INPUT
		  | EXP
		  | ASSIGNMENT			{insert_to_ST($1->val,"NULL",@1.last_line);}
		  | DECLARATION 
		  | ARRAY
		  | FUNC_CALL
		  | TERN_OP
		  | T_RETURN VAL        {    	printf("return %s\n",$2->val);
									    strcpy(quad[quad_ind].op,"return");
									    strcpy(quad[quad_ind].arg1,$2->val);
										strcpy(quad[quad_ind].arg2,"NULL");
									    strcpy(quad[quad_ind].res,"null");
									    quad_ind++;
								}
		  | T_RETURN;

PRINT_EXPR : T_lt T_lt EXP 
           | T_lt T_lt T_ENDL 
           | PRINT_EXPR T_lt T_lt EXP
		   | PRINT_EXPR T_lt T_lt T_ENDL ;

PRINT : T_COUT PRINT_EXPR ;

INPUT_EXPR : T_gt T_gt VAL
		   | INPUT_EXPR T_gt T_gt VAL;

INPUT   :	T_CIN INPUT_EXPR ;

ASSIGNMENT : identifier T_eq EXP 				{$$ = makenode(); sprintf($$->val,"%s=%s",$1,$3->val); stack_push_str($1);stack_push_str("=");stack_push($3); codegen_assignment();}
		   /*| identifier T_eq FUNC_CALL */
		   | identifier '[' VAL ']' T_eq EXP	{$$ = makenode(); sprintf($$->val,"%s[%s]=%s",$1,$3->val,$6->val);};

TYPE : T_INT 	{$$ = makenode(); strcpy($$->val,$1);}
	 | T_FLOAT  {$$ = makenode(); strcpy($$->val,$1);}
	 | T_CHAR   {$$ = makenode(); strcpy($$->val,$1);}
	 | T_STRING {$$ = makenode(); strcpy($$->val,$1);};

DECLARATION : TYPE MUL_DEC 		{$$ = makenode(); insert_to_ST($2->val,$1->val,@1.last_line);};
			
MUL_DEC : identifier T_comma MUL_DEC	{$$ = makenode(); sprintf($$->val,"%s,%s",$1,$3->val);} 
		| identifier 				 	{$$ = makenode(); strcpy($$->val,$1);} 
		| ASSIGNMENT T_comma MUL_DEC 	{$$ = makenode(); sprintf($$->val,"%s,%s",$1->val,$3->val);}
		| ASSIGNMENT 					{$$ = makenode(); $$ = $1;} ;

EXP : ADD_SUB				{ $$ = makenode(); $$ = $1;}
	| INC 					{$$ = makenode(); $$ = $1;}
	| identifier '[' VAL ']' {$$ = makenode(); char temp[31];sprintf(temp,"%s[%s]",$1,$3->val);strcpy($$->val,search_symbol(temp));};

INC : identifier T_inc 		{char id[31];char val[20];strcpy(id,$1);strcpy(val,search_symbol($1));sprintf($$->val,"%f",atof(val));
																sprintf(val,"%f",atof(val)+1);update_symbol_table(id,val,@1.last_line);}

	| identifier T_dec		{char id[31];char val[20];strcpy(id,$1);strcpy(val,search_symbol($1));sprintf($$->val,"%f",atof(val));
																	sprintf(val,"%f",atof(val)-1);update_symbol_table(id,val,@1.last_line);}

	| T_inc identifier		{char id[31];char val[20];strcpy(id,$2);strcpy(val,search_symbol($2));sprintf($$->val,"%f",atof(val)+1);
																	sprintf(val,"%f",atof(val)+1);update_symbol_table(id,val,@1.last_line);}
	| T_dec identifier		{char id[31];char val[20];strcpy(id,$2);strcpy(val,search_symbol($2));sprintf($$->val,"%f",atof(val)-1);
																	sprintf(val,"%f",atof(val)-1);update_symbol_table(id,val,@1.last_line);};

ADD_SUB : MUL_DIV					{ $$ = makenode(); $$ = $1;}
		| ADD_SUB T_add MUL_DIV	 	{stack_push($1);stack_push_str("+");stack_push($3); $$ = makenode(); sprintf($$->val,"%f",atof($1->val) + atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}     
		| ADD_SUB T_sub MUL_DIV 	{stack_push($1);stack_push_str("-");stack_push($3); $$ = makenode(); sprintf($$->val,"%f",atof($1->val) - atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;} ;

MUL_DIV : VAL 					{$$ = makenode(); $$ = $1;}
		| MUL_DIV T_mul VAL		{stack_push($1);stack_push_str("*");stack_push($3);	$$ = makenode(); sprintf($$->val,"%f",atof($1->val) * atof($3->val)); strcpy($$->idn,codegen());$$->is_idn=1;} 
		| MUL_DIV T_div VAL 	{stack_push($1);stack_push_str("/");stack_push($3);	$$ = makenode(); sprintf($$->val,"%f",atof($1->val) / atof($3->val)); strcpy($$->idn,codegen());$$->is_idn=1;} ;
		

VAL : number				{$$ = makenode(); strcpy($$->val,$1);$$->is_idn = 0;}
	| float_num				{$$ = makenode(); strcpy($$->val,$1);$$->is_idn = 0;}
	| character 			{$$ = makenode(); strcpy($$->val,$1);$$->is_idn = 0;}
	| string   				{$$ = makenode(); strcpy($$->val,$1);$$->is_idn = 0;}
	| identifier 			{$$ = makenode(); strcpy($$->val,search_symbol($1)); strcpy($$->idn,$1); $$->is_idn = 1;}
	| '(' EXP ')'			{	$$ = makenode(); $$ = $2; };	 
			

COND : COND T_ee VAL  		{stack_push($1);stack_push_str("==");stack_push($3); $$ = makenode(); sprintf($$->val,"%d",atof($1->val) == atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_ne VAL 		{stack_push($1);stack_push_str("!=");stack_push($3); $$ = makenode(); sprintf($$->val,"%d",atof($1->val) != atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_le VAL        {stack_push($1);stack_push_str("<=");stack_push($3); $$ = makenode(); sprintf($$->val,"%d",atof($1->val) <= atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_ge VAL 		{stack_push($1);stack_push_str(">=");stack_push($3); $$ = makenode(); sprintf($$->val,"%d",atof($1->val) >= atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_lt VAL 		{stack_push($1);stack_push_str("<");stack_push($3);  $$ = makenode(); sprintf($$->val,"%d",atof($1->val) <  atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_gt VAL 		{stack_push($1);stack_push_str(">");stack_push($3);  $$ = makenode(); sprintf($$->val,"%d",atof($1->val) >  atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_and VAL 		{stack_push($1);stack_push_str("&&");stack_push($3); $$ = makenode(); sprintf($$->val,"%d",atof($1->val) && atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | COND T_or VAL 		{stack_push($1);stack_push_str("||");stack_push($3); $$ = makenode(); sprintf($$->val,"%d",atof($1->val) || atof($3->val));strcpy($$->idn,codegen());$$->is_idn=1;}
	 | T_not VAL   			{$$ = makenode(); sprintf($$->val,"%d",!atof($2->val));}
	 /*| T_not '(' COND ')'*/
	 | VAL ;

TERN_OP : TYPE identifier T_eq COND '?' EXP ':' EXP 	{$$ = makenode(); char a[100];sprintf(a,"%f",atof($4->val) ? atof($6->val) : atof($8->val));insert($2,$1->val,@1.last_line,$2,a);}
		| identifier T_eq COND '?' EXP ':' EXP 			{$$ = makenode(); char a[100];sprintf(a,"%f",atof($3->val) ? atof($5->val) : atof($7->val));update_symbol_table($1,a,@1.last_line);};

%%


void yyerror(const char * error){
	printf("%s", error);
}

int main () {
	
	printf("---------------------Three Add Code--------------------\n\n");
	if (yyparse() !=0 ){
		printf("\nDidn't Compile");
		return 1;
	}
    printf("--------------------------------------------------------\n\n");
	print_quadraples();
	print_symbol_table();
	return 0;
}

Node *makenode(){
	Node *temp = (Node *)malloc(sizeof(Node));
	return temp;
}

int search_table(char *str){
	for(int i = 0; i< sno; ++i){
		if(!strcmp(str,st[i].name)) return i;
	}
	return -1;
}

char *search_symbol(char *str){
	int flag = search_table(str);
	if(flag == -1){
		printf("*****ERROR : Variable '%s' not declared *****\n", str);
		exit(0);
	}
	else{
		return strdup(st[flag].val);
	}
}
	
void intialise_array(char *type, char *id, char* size,int line_num,int ind){
	int new_size = atoi(size);
	int arr[new_size];
	for(int i=ind;i<new_size;++i){
		char temp[40];
		sprintf(temp,"%s[%d]",id,i);
		strcpy(st[sno].name, temp);
		char temp1[40];
		sprintf(temp1,"%d",arr[i]);
		if(GARBAGE) 	strcpy(st[sno].val, temp1);
		else 	strcpy(st[sno].val,"NA");
		st[sno].line_num = line_num;
		strcpy(st[sno].datatype, type);
		++sno;
	}
}

void assign(char *type, char *id, char* size,char *values,int line_num){
	strcpy(st[sno].name,id);
	strcpy(st[sno].datatype,type);
	strcpy(st[sno].val,size);
	st[sno].line_num = line_num;
	++sno;
}

void insert_array_st(char *type, char *id, char* size,char *values,int line_num){
	int flag = search_table(id);
	if(flag == -1){
		if(!strcmp(values,"NA")){
			assign(type,id,size,values,line_num);
			intialise_array(type,id,size,line_num,0);
		}
		else if(!strcmp(size,"NA")){
			const char *p = ",";
			char *a,*b;
			int c = 0;
			int temp_sno = sno;
			assign(type,id,size,values,line_num);
			for(a = strtok_r(values, p, &b) ; a!=NULL ; a = strtok_r(NULL,p,&b)){
				char temp[40];
				sprintf(temp,"%s[%d]",id,c);
				strcpy(st[sno].name, temp);
				strcpy(st[sno].val, a);
				st[sno].line_num = line_num;
				strcpy(st[sno].datatype, type);
				++sno;
				++c;
			}
			char count[10];
			sprintf(count,"%d",c);
			strcpy(st[temp_sno].val,count);
		}
		else{
			const char *p = ",";
			char *a,*b;
			assign(type,id,size,values,line_num);
			int c = 0;
			for(a = strtok_r(values, p, &b) ; a!=NULL ; a = strtok_r(NULL,p,&b)){
				char temp[40];
				if(c >= atoi(size)){
					printf("Too many intializers for %s %s[%s]",type,id,size);
					exit(0);
				}
				sprintf(temp,"%s[%d]",id,c);
				strcpy(st[sno].name, temp);
				strcpy(st[sno].val, a);
				st[sno].line_num = line_num;
				strcpy(st[sno].datatype, type);
				++sno;
				++c;
			}
			intialise_array(type,id,size,line_num,c);
		}
	}
	else{
		printf("*****ERROR : Redeclaration of Variable '%s' *****\n", id);
		exit(1);	
	}
}



void insert(char *name,char *datatype,int line_num,char *lval,char *rval){
	int flag = search_table(lval);
	if(flag == -1)
		strcpy(st[sno].name, lval);
	else{
		printf("*****ERROR : Redeclaration of Variable '%s' *****\n", lval);
		exit(1);
	}
	if(rval == ""){
		int g;
		char garb[40];
		sprintf(garb,"%d",g);
		if(GARBAGE)	strcpy(st[sno].val,garb);
		else 	strcpy(st[sno].val, "NA");
	}
	else{
		if(!strcmp(datatype, "int")){
			int temp = atoi(rval);
			sprintf(rval,"%d",temp);
		}
		strcpy(st[sno].val, rval);
	}
	strcpy(st[sno].datatype, datatype);
	st[sno].line_num = line_num;
	sno++;
}


void update_symbol_table(char *lval,char *rval,int line_num){
	int flag = search_table(lval);
	if(flag == -1){
		printf("*****ERROR : Variable '%s' not declared *****\n", lval);
		exit(0);
	}
	else{
		if(!strcmp(st[flag].datatype, "int")){
			int temp = atoi(rval);
			sprintf(rval,"%d",temp);
		}
		strcpy(st[flag].val, rval);
		st[flag].line_num = line_num;
	}
}

void insert_to_ST(char *name,char *datatype,int line_num){
		/*printf("%s\t",name);*/
		const char *p = "," , *q = "=";
		char *a,*b,*c,*d;
		char *arr[2];
		arr[0] = arr[1] = "";
		for(a = strtok_r(name, p, &c) ; a!=NULL ; a = strtok_r(NULL,p,&c)){
				int k = 0;
				for(b = strtok_r(a,q,&d); b!=NULL; b = strtok_r(NULL,q,&d))
					arr[k++] = b;
					if(datatype != "NULL")
						insert(name,datatype,line_num,arr[0],arr[1]);
					else
						update_symbol_table(arr[0],arr[1],line_num);
				arr[0] = "";
				arr[1] = "";
		}
			
}

char *find_type(char *var){
	int n = strlen(var);
	int a = 0;
	int d = 0;
	int dot = 0;
	if(n == 1){
		if(isdigit(var[0])) return "int";
		else return "char";
	}
	for(int i=0;i<n;++i){
	
	}
}


void print_symbol_table(){
/*	printf("datatype\tname\t\tvalue\t\tline number\n");
	for(int i = 0;i < sno ; ++i){
		printf("%s	\t", st[i].datatype);
		printf("%s	\t", st[i].name);
		printf("%s  \t\t", st[i].val);
		printf("%d	\t", st[i].line_num);
		printf("\n");
	}*/
    printf("---------------------Symbol Table-----------------------\n\n");
    printf("datatype \t name \t\t tvalue \t line number \n\n");
    for(int i=0;i<sno;i++)
    {
        printf("%-8s \t %-8s \t %-8s \t %-6d \n",st[i].datatype,st[i].name,st[i].val,st[i].line_num);
    }
    printf("--------------------------------------------------------\n\n");

}

void stack_push(Node *var){
	++top;
	if (var->is_idn){
		strcpy(stack[top],var->idn);
	}
	else{
		strcpy(stack[top],var->val);
	}
}

void stack_push_str(char *var){
	++top;
	strcpy(stack[top],var);
}

void codegen_assignment(){
    printf("%s = %s\n",stack[top-2],stack[top]);
    strcpy(quad[quad_ind].op,"=");
    strcpy(quad[quad_ind].arg1,stack[top]);
	strcpy(quad[quad_ind].arg2,"NULL");
    strcpy(quad[quad_ind].res,stack[top-2]);
    quad_ind++;
    top-=2;	
}

char* codegen(){
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = %s %s %s\n",temp,stack[top-2],stack[top-1],stack[top]);
    strcpy(quad[quad_ind].op,stack[top-1]);
    strcpy(quad[quad_ind].arg1,stack[top-2]);
    strcpy(quad[quad_ind].arg2,stack[top]);
    strcpy(quad[quad_ind].res,temp);
    quad_ind++;
    top-=2;
    //strcpy(stack[top],temp);

	temp_i++;
	return temp;
}

void print_quadraples(){
    printf("---------------------Quadruples-------------------------\n\n");
    printf("Operator \t Arg1 \t\t Arg2 \t\t Result \n\n");
    int i;
    for(i=0;i<quad_ind;i++)
    {
        printf("%-8s \t %-8s \t %-8s \t %-6s \n",quad[i].op,quad[i].arg1,quad[i].arg2,quad[i].res);
    }
    printf("--------------------------------------------------------\n\n");
}

void else_body(){
	printf("L%d:\n",label_ind++);
}


void if_body(){
	printf("goto L%d\n",label_ind+1);
}

void insert_to_ST_temp(char *lval, char *rval,char *datatype, int line_num){
	strcpy(st[sno].name, lval);
	strcpy(st[sno].val, rval);
	strcpy(st[sno].datatype, datatype);
	st[sno].line_num = line_num;
	sno++;
}

void if_cond(Node *cond,int line_num){
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
	
    temp_i++;
	printf("%s = not %s\n",temp,cond->idn);

    strcpy(quad[quad_ind].op,"not");
    strcpy(quad[quad_ind].arg1,cond->idn);
    strcpy(quad[quad_ind].arg2,"NULL");
    strcpy(quad[quad_ind].res,temp);	
    quad_ind++;
	printf("if %s goto L%d\n",temp,label_ind);
    strcpy(quad[quad_ind].op,"if");
    strcpy(quad[quad_ind].arg1,temp);
    strcpy(quad[quad_ind].arg2,"NULL");
    char x[10];
    sprintf(x,"%d",label_ind);
    char l[]="L";
    strcpy(quad[quad_ind].res,strcat(l,x));
    quad_ind++;
    temp_i++;
}

void while1()
{

    l_while = label_ind;
    printf("L%d: \n",label_ind++);
    strcpy(quad[quad_ind].arg1, "NULL");
    strcpy(quad[quad_ind].arg2, "NULL");
    strcpy(quad[quad_ind].op,"Label");
    char x[10];
    sprintf(x,"%d",label_ind-1);
    char l[]="L";
    strcpy(quad[quad_ind].res,strcat(l,x));
    quad_ind++;
}

void while2(Node *cond)
{
 	strcpy(temp,"T");
 	sprintf(tmp_i, "%d", temp_i);
 	strcat(temp,tmp_i);
 	printf("%s = not %s\n",temp,cond->idn);
    strcpy(quad[quad_ind].arg2, "NULL");
    strcpy(quad[quad_ind].op,"not");
    strcpy(quad[quad_ind].arg1,cond->idn);
    strcpy(quad[quad_ind].res,temp);
    quad_ind++;
    printf("if %s goto L%d\n",temp,label_ind);
    strcpy(quad[quad_ind].arg2, "NULL");
    strcpy(quad[quad_ind].op,"if");
    strcpy(quad[quad_ind].arg1,temp);
    char x[10];
    sprintf(x,"%d",label_ind);char l[]="L";
    strcpy(quad[quad_ind].res,strcat(l,x));
    quad_ind++;
	temp_i++;
 }

void while3()
{

	printf("goto L%d \n",l_while);
    strcpy(quad[quad_ind].arg1, "NULL");
    strcpy(quad[quad_ind].arg2, "NULL");
    strcpy(quad[quad_ind].op,"goto");
    char x[10];
    sprintf(x,"%d",l_while);
    char l[]="L";
    strcpy(quad[quad_ind].res,strcat(l,x));
    quad_ind++;
    printf("L%d: \n",label_ind++);
    strcpy(quad[quad_ind].arg1, "NULL");
    strcpy(quad[quad_ind].arg2, "NULL");
    strcpy(quad[quad_ind].op,"Label");
    char x1[10];
    sprintf(x1,"%d",label_ind-1);
    char l1[]="L";
    strcpy(quad[quad_ind].res,strcat(l1,x1));
    quad_ind++;
}