#include <stdio.h>
#include <ctype.h>

#include "sym_table.tab.h"

typedef struct Node_t{
	char val[100];
	char idn[100];
	int is_idn;
}Node;

int yylex();

void yyerror(const char *error);