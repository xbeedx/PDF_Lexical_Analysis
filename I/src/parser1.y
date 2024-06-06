%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(char**, unsigned long*, const char*);
extern int yylex();
extern int yyparse(char**, unsigned long*);
extern FILE *yyin;
extern int yydebug;

%}

%parse-param {char** version} {unsigned long* refAddress}

%union {
    char *str;
    unsigned long num;
}

%token <str> VERSION LINE PEOF STARTREF
%token <num> NUM

%start S


%%

S:
    VERSION lines {
        *version = strdup($1);
    }
    ;

lines:
    LINE lines
    | NUM lines
    | PEOF lines
    | STARTREF ref { printf("STARTREF: %s\n", $1);}
    ;

ref:
    NUM end_line { *refAddress = $1;}

end_line: PEOF  { printf("LAST LINE: %s\n", $1);};

%%

int yyerror(char** version, unsigned long* refAddress, const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int main(int argc, char *argv[]) {
    yydebug = 0;
    char* version = NULL;
    unsigned long refAddress = 0;

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

    yyparse(&version, &refAddress);
    printf("Version: %s\n", version);
    printf("REF: %lu\n", refAddress);

    free(version);

    return 0;
}