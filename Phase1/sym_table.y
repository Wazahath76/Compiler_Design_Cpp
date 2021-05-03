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
void insert_to_ST(char *name,char *datatype,int line_num);
void print_symbol_table();
void insert_array_st(char *type, char *id, char* size,char *values,int line_num);
char *search_symbol(char *str);
char *validate_exp(char *var1, char *var2, char op);
void insert(char *name,char *datatype,int line_num,char *lval,char *rval);
void update_symbol_table(char *lval,char *rval,int line_num);
%}


%union {char* id;} 
%start S



%token T_INCLUDE
%token T_STD
%token <id> T_INT 
%token <id> T_FLOAT 
%token <id> T_CHAR 
%token <id> T_STRING
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
%token T_bool 
%token T_LIB_H  
%token T_lt 
%token T_le 
%token T_gt 
%token T_ge
%token T_eq 
%token T_ee 
%token T_ne 
%token T_and
%token T_or 
%token <id> T_not 
%token T_comma 
%token T_dot 
%token T_semic 
%token T_dims 
%token T_brackets 
%token T_flow_brackets 
%token T_open_sq 
%token T_close_sq
%token T_mod

%token <id> number
%token <id> float_num
%token <id> identifier
%token <id> character
%token <id> string
%token <id> T_inc 
%token <id> T_dec
%token <id> T_add 
%token <id> T_sub 
%token <id> T_mul 
%token <id> T_div   

%type <id> ASSIGNMENT
%type <id> EXP ADD_SUB MUL_DIV VAL DECLARATION TYPE MUL_DEC ARRAY_EXPR COND TERN_OP '(' ')' INC

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
   
IF : T_IF '(' COND ')' IF_BODY ELSE

ELSE: T_ELSE T_IF '(' COND ')' IF_BODY ELSE
	| T_ELSE IF_BODY
	|;
   

IF_BODY : '{' IF_LINE '}'
		| STATEMENT ';' ;

IF_LINE : IF_LINE STATEMENT ';'
		| IF_LINE IF
		| IF_LINE LOOP
		| STATEMENT ';'
		| IF 
		| LOOP;

LOOP : T_WHILE '(' COND ')' LOOP_BODY ;

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

ARRAY_EXPR	:	ARRAY_EXPR T_comma VAL 			{sprintf($$,"%s,%s",$1,$3);}
			|	VAL 							{$$ = $1;};			

ARRAY	: TYPE identifier '[' VAL ']'   							{insert_array_st($1,$2,$4,"NA",@1.last_line);}
		| TYPE identifier T_dims T_eq '{' ARRAY_EXPR '}'			{insert_array_st($1,$2,"NA",$6,@1.last_line);}
		| TYPE identifier '[' VAL ']' T_eq '{' ARRAY_EXPR '}'		{insert_array_st($1,$2,$4,$8,@1.last_line);};

STATEMENT : PRINT
		  | INPUT
		  | EXP
		  | ASSIGNMENT			{insert_to_ST($1,"NULL",@1.last_line);}
		  | DECLARATION 
		  | ARRAY
		  | FUNC_CALL
		  | TERN_OP
		  | T_RETURN VAL
		  | T_RETURN;

PRINT_EXPR : T_lt T_lt EXP 
           | T_lt T_lt T_ENDL 
           | PRINT_EXPR T_lt T_lt EXP
		   | PRINT_EXPR T_lt T_lt T_ENDL ;

PRINT : T_COUT PRINT_EXPR ;

INPUT_EXPR : T_gt T_gt VAL
		   | INPUT_EXPR T_gt T_gt VAL;

INPUT   :	T_CIN INPUT_EXPR ;

ASSIGNMENT : identifier T_eq EXP 				{ sprintf($$,"%s=%s",$1,$3);}
		   | identifier T_eq FUNC_CALL 
		   | identifier '[' VAL ']' T_eq EXP	{sprintf($$,"%s[%s]=%s",$1,$3,$6);};

TYPE : T_INT 	{$$ = $1;}
	 | T_FLOAT  {$$ = $1;}
	 | T_CHAR   {$$ = $1;}
	 | T_STRING {$$	= $1;};

DECLARATION : TYPE MUL_DEC 		{insert_to_ST($2,$1,@1.last_line);};
			
MUL_DEC : identifier T_comma MUL_DEC	{sprintf($$,"%s,%s",$1,$3);} 
		| identifier 				 	{$$ = $1;} 
		| ASSIGNMENT T_comma MUL_DEC 	{sprintf($$,"%s,%s",$1,$3);}
		| ASSIGNMENT 					{$$ = $1;} ;

EXP : ADD_SUB				{$$ = $1;}
	| INC 					{$$ = $1;}
	| identifier '[' VAL ']' {char temp[31];sprintf(temp,"%s[%s]",$1,$3);$$ = search_symbol(temp);};  

INC : identifier T_inc 		{char id[31];char val[20];strcpy(id,$1);strcpy(val,search_symbol($1));sprintf($$,"%f",atof(val));
																sprintf(val,"%f",atof(val)+1);update_symbol_table(id,val,@1.last_line);}

	| identifier T_dec		{char id[31];char val[20];strcpy(id,$1);strcpy(val,search_symbol($1));sprintf($$,"%f",atof(val));
																	sprintf(val,"%f",atof(val)-1);update_symbol_table(id,val,@1.last_line);}

	| T_inc identifier		{char id[31];char val[20];strcpy(id,$2);strcpy(val,search_symbol($2));sprintf($$,"%f",atof(val)+1);
																	sprintf(val,"%f",atof(val)+1);update_symbol_table(id,val,@1.last_line);}
	| T_dec identifier		{char id[31];char val[20];strcpy(id,$2);strcpy(val,search_symbol($2));sprintf($$,"%f",atof(val)-1);
																	sprintf(val,"%f",atof(val)-1);update_symbol_table(id,val,@1.last_line);};

ADD_SUB : MUL_DIV					{$$ = $1;}
		| ADD_SUB T_add MUL_DIV		/*{sprintf($$,"%s+%s",$1,$3);}  {printf("%s+%s\t",$1,$3);} */ {sprintf($$,"%f",atof($1) + atof($3));}     
		| ADD_SUB T_sub MUL_DIV 	/*{sprintf($$,"%s-%s",$1,$3);} {printf("%s-%s\t",$1,$3);}  */ {sprintf($$,"%f",atof($1) - atof($3));} ;

MUL_DIV : VAL 					{$$ = $1;}
		| MUL_DIV T_mul VAL		/*{sprintf($$,"%s*%s",$1,$3);}	{printf("%s*%s\t",$1,$3);}*/	{sprintf($$,"%f",atof($1) * atof($3));} 
		| MUL_DIV T_div VAL 	/*{sprintf($$,"%s/%s",$1,$3);}	{printf("%s/%s\t",$1,$3);}*/	{sprintf($$,"%f",atof($1) / atof($3));} 
		| '(' EXP ')'			{$$ = $2;};


VAL : number				{ $$ = $1;}
	| float_num				{ $$ = $1;}
	| character 			{ $$ = $1;}
	| string   				{ $$ = $1;}
	| identifier 			{ $$ = search_symbol($1);};		 
			

COND : COND T_ee VAL  		{sprintf($$,"%d",atof($1) == atof($3));}
	 | COND T_ne VAL 		{sprintf($$,"%d",atof($1) != atof($3));}
	 | COND T_le VAL        {sprintf($$,"%d",atof($1) <= atof($3));}
	 | COND T_ge VAL 		{sprintf($$,"%d",atof($1) >= atof($3));}
	 | COND T_lt VAL 		{sprintf($$,"%d",atof($1) < atof($3));}
	 | COND T_gt VAL 		{sprintf($$,"%d",atof($1) > atof($3));}
	 | COND T_and VAL 		{sprintf($$,"%d",atof($1) && atof($3));}
	 | COND T_or VAL 		{sprintf($$,"%d",atof($1) || atof($3));}
	 | T_not VAL   			{sprintf($$,"%d",!atof($2));}
	 | T_not '(' COND ')'
	 | VAL ;

TERN_OP : TYPE identifier T_eq COND '?' EXP ':' EXP 	{char a[100];sprintf(a,"%f",atof($4) ? atof($6) : atof($8));insert($2,$1,@1.last_line,$2,a);}
		| identifier T_eq COND '?' EXP ':' EXP 			{char a[100];sprintf(a,"%f",atof($3) ? atof($5) : atof($7));update_symbol_table($1,a,@1.last_line);};

%%

void yyerror(const char * error){
	printf("%s", error);
}

int main () {
	

	if (yyparse() !=0 ){
		printf("\nDidn't Compile");
		return 1;
	}
	print_symbol_table();
	return 0;
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
	printf("datatype\tname\t\tvalue\t\tline number\n");
	for(int i = 0;i < sno ; ++i){
		printf("%s	\t", st[i].datatype);
		printf("%s	\t", st[i].name);
		printf("%s  \t\t", st[i].val);
		printf("%d	\t", st[i].line_num);
		printf("\n");
	}
}
