%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <stdbool.h>

int yyerror(const char *);
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yydebug;
extern int yy_scan_buffer(char *, size_t);

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

%token <str> NULL_TOKEN STRING HEX_STRING NAME REF FLUX
%token <boolean> BOOLEAN 
%token <integer> SIGNED_INT
%token <real> SIGNED_REAL
%token STARTLIST ENDLIST STARTDICT ENDDICT OBJ END OTHER

%start S

%%

S: OBJ object END;

object :
    NULL_TOKEN{ printf("Valid PDF object of type NULL : %s\n",$1); }
    | BOOLEAN { printf("Valid PDF object of type BOOLEAN : %s\n",$1 ? "true" : "false"); }
    | SIGNED_INT { printf("Valid PDF object of type SIGNED_INT :  %ld\n",$1); }
    | SIGNED_REAL { printf("Valid PDF object of type SIGNED_REAL : %f\n",$1); }
    | STRING { printf("Valid PDF object of type STRING : %s\n",$1); }
    | HEX_STRING { printf("Valid PDF object of type HEX_STRING : %s\n",$1); }
    | NAME { printf("Valid PDF object of type NAME : %s\n",$1); }
    | REF { printf("Valid PDF object of type REF : %s\n",$1); }
    | list
    | dict
    | OTHER
    ;


list : 
    STARTLIST {printf("Valid PDF object of type LIST \n[ \n"); } list_body
    ;

list_body: 
    ENDLIST { printf("] \n"); }
    | object list_body
    ;

dict :
    STARTDICT  {printf("Valid PDF object of type DICT \n{ \n"); } dict_body flux
    ;

dict_body:
    ENDDICT { printf("} \n"); }
    | NAME { printf("%s => ",$1); } object dict_body
    ;

flux: | FLUX

%%

int yyerror(const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int compare_ulong(const void *a, const void *b) {
        unsigned long ul_a = *(const unsigned long *)a;
        unsigned long ul_b = *(const unsigned long *)b;
        if (ul_a < ul_b) return -1;
        else if (ul_a > ul_b) return 1;
        else return 0;
    }

int main(int argc, char *argv[]) {
    yydebug = 0;
    FILE *file;
    unsigned long a,b;

    if(argc == 4) {
        a = strtoul(argv[2],NULL,10);
        b = strtoul(argv[3],NULL,10);
    } else {
        fprintf(stderr, "Usage: %s <filename> <a> <b>\n", argv[0]);
        return 1;
    }

    file = fopen(argv[1], "r");

    fseek(file, a, SEEK_SET);

    size_t size = b - a;

    char *buffer = malloc(size + 2);
    
    fread(buffer, 1, size, file);

    buffer[size] = '\0';
    buffer[size + 1] = '\0'; 
    fclose(file);

    yy_scan_buffer(buffer, size +2);
    yyparse();

    free(buffer);
    
    return 0;
}