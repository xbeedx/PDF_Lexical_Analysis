%{
#include "parser2.tab.h"
#include <stdlib.h>

typedef struct PDFObject {
    int address;
    int objectId;
    int generationNumber;
    struct PDFObject* next;
} PDFObject;

PDFObject* pdfObjects = NULL;
int generationCounter = 0;

PDFObject* createPDFObject(int address, int objectId, int generationNumber) {
    PDFObject* newObject = (PDFObject*)malloc(sizeof(PDFObject));
    if (newObject == NULL) {
        fprintf(stderr, "Memory allocation error\n");
        exit(EXIT_FAILURE);
    }
    newObject->address = address;
    newObject->objectId = objectId;
    newObject->generationNumber = generationNumber;
    newObject->next = NULL;
    return newObject;
}

void insertPDFObject(PDFObject** head, PDFObject* newObject) {
    if (*head == NULL || (*head)->address > newObject->address) {
        newObject->next = *head;
        *head = newObject;
    } else {
        PDFObject* current = *head;
        while (current->next != NULL && current->next->address < newObject->address) {
            current = current->next;
        }
        newObject->next = current->next;
        current->next = newObject;
    }
}

void printPDFObjects(PDFObject* head) {
    PDFObject* current = head;
    while (current != NULL) {
        printf("Address: %d, Object ID: %d, Generation Number: %d\n",
            current->address, current->objectId, current->generationNumber);
        current = current->next;
    }
}

void freePDFObjects(PDFObject* head) {
    PDFObject* current = head;
    while (current != NULL) {
        PDFObject* temp = current;
        current = current->next;
        free(temp);
    }
}
%}

refStart    "xref"
digit   [0-9]
i   {digit}+
n   {digit}+
tableStart {i}" "{n}
objectAdress {digit}{digit}{digit}{digit}{digit}{digit}{digit}{digit}{digit}{digit}
objectId    {digit}{digit}{digit}{digit}{digit}
letter  [fn]
tableLine        {objectAdress}" "{objectId}" "{letter}([ ]|\r)?

trailerStart    "trailer"
dictStart   "<<"
dictEnd     ">>"
dictLine    "/".*

startxref "startxref"
num {digit}+
end "%%EOF"

%option noyywrap
%%

[ \t\n\r]+   { /* Skip whitespace */ }

{trailerStart} {
    printf("%s",yytext);
    return TRAILER;
}

{dictStart} {
    return DICTSTART;
}

{dictEnd} {
    return DICTEND;
}

{tableStart} {
    return TABLESTART;
}

{refStart} {
    return XREF;
}

{tableLine} {
    int address, generationNumber;
    char type;
    sscanf(yytext, "%10d %5d %c", &address, &generationNumber, &type);
    if (type == 'n') {
        PDFObject* newObject = createPDFObject(address, generationCounter++, generationNumber);
        insertPDFObject(&pdfObjects, newObject);
    }
    return TABLELINE;
}

{dictLine} {
    return DICTLINE;
}

{startxref} {
    return STARTXREF;
}

{num} {
    return NUM;
}

{end} {
    return END;
}

<<EOF>> { 
    printPDFObjects(pdfObjects);
    freePDFObjects(pdfObjects);
    return 0;
}

%%
