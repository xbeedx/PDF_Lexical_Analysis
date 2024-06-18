%{
#include "parser1.tab.h"
#include <stdlib.h>
%}

digit   [0-9]
number  {digit}+ 
entier_positif  [1-9][0-9]*
VERSION %PDF-{number}\.{number}
line [^\n]+
PEOF %%EOF
STARTREF startxref

%option noyywrap
%%

{VERSION} { 
    yylval.str = strdup(yytext); 
    return VERSION; 
}

{PEOF} {
    yylval.str = strdup(yytext);
    return PEOF;

}

{entier_positif} {
    yylval.num = strtoul(yytext,NULL,10);
    return NUM;

}

{STARTREF} {
    yylval.str = strdup(yytext);
    return STARTREF;
}

[ \t\n\r]+   { /* Skip whitespace */ }


{line} {
    yylval.str = strdup(yytext);
    return LINE;
}


<<EOF>> { return 0;}

%%
