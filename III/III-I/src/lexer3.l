%{
#include "parser3.tab.h"
#include <stdlib.h>
%}

null        null
boolean     (true|false)
signedInt   -?[0-9]+
signedReal  -?[0-9]+\.[0-9]+
string      "("(?:[^()\\]|\\.)*")"
hexString   "<"[0-9A-Fa-f \t\n\r]*">"
name        "/"([^ \(\)\[\]\{\}\/%<>\n])+
digit       [0-9]
ref         ({digit}+" "{digit}+" R")
startList   "\["
endList     "\]"
startDict   "<<"
endDict     ">>"

%option noyywrap
%%

{null} {
    yylval.str = strdup(yytext);
    return NULL_TOKEN;
}

{boolean} {
    yylval.boolean = strcmp(yytext, "true") == 0;
    return BOOLEAN;
}

{signedInt} {
    yylval.integer = strtol(yytext, NULL, 10);
    return SIGNED_INT;
}

{signedReal} {
    yylval.real = strtod(yytext, NULL);
    return SIGNED_REAL;
}

{string} {
    yylval.str = strdup(yytext);
    return STRING;
}

{hexString} {
    yylval.str = strdup(yytext);
    return HEX_STRING;
}

{name} {
    yylval.str = strdup(yytext);
    return NAME;
}

{ref} {
    yylval.str = strdup(yytext);
    return REF;
}

{startList} {
    return STARTLIST;
}

{endList} {
    return ENDLIST;
}

{startDict} {
    return STARTDICT;
}

{endDict} {
    return ENDDICT;
}

[ \r\t\n] { /* ignore whitespace */ }

. {
    return OTHER;
}

<<EOF>> { return 0; }

%%

