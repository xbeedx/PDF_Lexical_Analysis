%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(const char*);
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yydebug;

%}

%union {
    char *str;
    unsigned long num;
}

%token <str> VERSION LINE
%token <num> NUM

%start S


%%

S:
    VERSION lines {
        printf("Version: %s\n", $1);
    }
    ;

lines:
    LINE lines
    | NUM lines
    | NUM end_line { printf("REF: %lu\n", $1);}
    ;

end_line: LINE  { printf("LAST LINE: %s\n", $1);};

%%

int yyerror(const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int main(int argc, char *argv[]) {
    yydebug = 0;

    if (argc == 2) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    } else {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    yyparse();
    return 0;
}