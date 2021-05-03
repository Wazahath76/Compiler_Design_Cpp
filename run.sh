flex lex_analyser.l
bison -d sym_table.y
gcc lex.yy.c sym_table.tab.c common.h -ll
