%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(const char *);
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yydebug;

typedef struct PDFObject {
    int address;
    int objectId;
    int generationNumber;
    struct PDFObject* next;
} PDFObject;

extern PDFObject* pdfObjects;

void printPDFObjects(PDFObject* head);

%}

%token XREF TABLESTART TABLELINE DICTSTART DICTEND TRAILER DICTLINE STARTXREF NUM END

%%

S: XREF tables trailer;

tables: table | table tables;

table: TABLESTART tablelines;

tablelines: TABLELINE | TABLELINE tablelines;

trailer: TRAILER dict STARTXREF NUM END;

dict: DICTSTART dictlines DICTEND;

dictlines: DICTLINE | DICTLINE dictlines;



%%

int yyerror(const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int main(int argc, char *argv[]) {
    yydebug = 0;
    unsigned long refAdress;
    FILE *file;

    if (argc == 3) {
        refAdress = strtoul(argv[2],NULL,10);
    } else if(argc == 2) {
        int resultMake = system("make -C ../I/ >/dev/null 2>&1");
        char result[100]; 
        strcpy(result, "cd ../I && ./src/parser1.bin ../II/");
        strcat(result, argv[1]);
        int resultExe = system(result);
        file = fopen("../I/adress.txt", "r");
        if (!file) {
            perror("../I/adress.txt");
            return 1;
        }
        fscanf(file, "%lu", &refAdress);
        fclose(file);
        if (resultMake != 0 || resultExe != 0) {
            printf("Error executing make command.\n");
            return 1;
        }
        system("make cleanAll -C ../I/ >/dev/null 2>&1");
    } else {
        fprintf(stderr, "Usage: %s <filename> <refAdress>\n", argv[0]);
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }

    fseek(file, refAdress, SEEK_SET);

    yyin = file;
    
    yyparse();

    return 0;
}