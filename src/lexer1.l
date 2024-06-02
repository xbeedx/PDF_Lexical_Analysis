%{
#include "parser1.tab.h"
#include <stdlib.h>
%}

digit   [0-9]
number  {digit}+ 
entier_positif  [1-9][0-9]*
VERSION %PDF-{number}\.{number}
line [^\n]+

%option noyywrap
%%

{VERSION} { 
    yylval.str = strdup(yytext); 
    return VERSION; 
}

{entier_positif} {
    yylval.num = strtoul(yytext,NULL,10);
    return NUM;

}

[ \t\n\r]+   { /* Skip whitespace */ }

{line} {
    yylval.str = strdup(yytext);
    return LINE;
}


<<EOF>> { return 0;}

%%
