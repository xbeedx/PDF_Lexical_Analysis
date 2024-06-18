%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int yyerror(const char *);
extern int yylex();
extern int yyparse();
extern int yydebug;

%}

%code requires {
    #include <stdbool.h>
}


%union {
    char *str;
    bool boolean;
    long integer;
    double real;
}

%token <str> NULL_TOKEN STRING HEX_STRING NAME REF
%token <boolean> BOOLEAN 
%token <integer> SIGNED_INT
%token <real> SIGNED_REAL
%token OTHER STARTLIST ENDLIST STARTDICT ENDDICT

%start objects

%%

objects: | objects object;
   
   
object :
    NULL_TOKEN{ printf("Valid PDF object of type NULL: %s\n",$1); }
    | BOOLEAN { printf("Valid PDF object of type BOOLEAN: %s\n",$1 ? "true" : "false"); }
    | SIGNED_INT { printf("Valid PDF object of type SIGNED_INT: %ld\n",$1); }
    | SIGNED_REAL { printf("Valid PDF object of type SIGNED_REAL: %f\n",$1); }
    | STRING { printf("Valid PDF object of type STRING: %s\n",$1); }
    | HEX_STRING { printf("Valid PDF object of type HEX_STRING: %s\n",$1); }
    | NAME { printf("Valid PDF object of type NAME: %s\n",$1); }
    | REF { printf("Valid PDF object of type REF: %s\n",$1); }
    | list
    | dict
    | OTHER { }
    | error { }
    ;


list : 
    STARTLIST {printf("Valid PDF object of type LIST \n[ \n"); } list_body
    ;

list_body: 
    ENDLIST { printf("] \n"); }
    | object list_body
    ;

dict :
    STARTDICT  {printf("Valid PDF object of type DICT \n{ \n"); } dict_body
    ;

dict_body:
    ENDDICT { printf("} \n"); }
    | NAME object dict_body
    ;

%%

int yyerror(const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int main(int argc, char *argv[]) {
    yydebug = 0;

    yyparse();

    return 0;
}