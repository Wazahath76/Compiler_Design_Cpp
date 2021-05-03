#!/bin/bash
flex --debug lex_analyser.l
bison -d --debug sym_table.y
gcc lex.yy.c sym_table.tab.c -ll