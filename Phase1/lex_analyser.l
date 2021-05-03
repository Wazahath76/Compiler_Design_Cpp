%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
#include "sym_table.tab.h"
#include "common.h"
%}

%option yylineno

%%
[/][/].*    ;
"/*"[^*]*"*"+([^*/][^*]*"*"+)*"/" ;
[ \t\n]     ;
"using namespace std" {return T_STD;}
"#include"  {return T_INCLUDE;}
"void"      {return T_VOID;}
"int"       {yylval.id = strdup(yytext);return T_INT;}
"float"     {yylval.id = strdup(yytext);return T_FLOAT;}
"char"      {yylval.id = strdup(yytext);return T_CHAR;}
"string"    {yylval.id = strdup(yytext);return T_STRING;}
"main()"    {return T_MAIN;}
"if"        {return T_IF;}
"else"      {return T_ELSE;}
"while"     {return T_WHILE;}
"break"     {return T_BREAK;}
"continue"  {return T_CONTINUE;}
"cout"      {return T_COUT;}
"cin"      {return T_CIN;}
"endl"      {return T_ENDL;}
"bool"		{return T_BOOL;}
"return"	{return T_RETURN;}
"true"|"false" 	{yylval.id = yytext;return T_bool;}
[0-9]+      {yylval.id = strdup(yytext); return number;}      
[a-zA-Z_][0-9a-zA-Z_]*    {yylval.id = strdup(yytext); return identifier;}
[0-9]+"."[0-9]+           {yylval.id = strdup(yytext); return float_num;}
\'.\'       {yylval.id = strdup(yytext); return character; }
(<)[a-zA-Z][a-zA-Z]*(>) {return T_LIB_H;}
\".*\"      {yylval.id = strdup(yytext);return string;}
"+"         {yylval.id = strdup(yytext);return T_add;}
"-"         {yylval.id = strdup(yytext);return T_sub;}
"*"         {yylval.id = strdup(yytext);return T_mul;}
"/"         {yylval.id = strdup(yytext);return T_div;}
"%"         {return T_mod;}
"<"         {return T_lt;}
"<="        {return T_le;}
">"         {return T_gt;}
">="        {return T_ge;}
"="         {return T_eq;}
"=="        {return T_ee;}
"!="        {return T_ne;}
"++" 		{yylval.id = strdup(yytext);return T_inc;}
"--"		{yylval.id = strdup(yytext);return T_dec;}
"&&"        {yylval.id = strdup(yytext);return T_and;}
"||"        {yylval.id = strdup(yytext);return T_or;}
"!"         {yylval.id = strdup(yytext);return T_not;}
","         {return T_comma;}
"."         {return T_dot;}
"[]"        {return T_dims;}
"()"        {return T_brackets;}
.           {return yytext[0];}
%%

int yywrap (void) {return 1;}