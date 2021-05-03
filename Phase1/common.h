#include <stdio.h>
#include <ctype.h>

#include "sym_table.tab.h"

int yylex();

void yyerror(const char *error);