%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(const char *);
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yydebug;

%}

%token LINE

%%

S: LINE lines;

lines: lines LINE
    | LINE
    ;

%%

int yyerror(const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int main(int argc, char *argv[]) {
    yydebug = 0;
    unsigned long refAdress;

    if (argc == 3) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
        refAdress = atoi(argv[2]);
        printf("REF: %lu",refAdress);
    } else {
        fprintf(stderr, "Usage: %s <filename> <refAdress>\n", argv[0]);
        return 1;
    }

    yyparse();

    return 0;
}