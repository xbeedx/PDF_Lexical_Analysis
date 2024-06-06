%{
#include "parser2.tab.h"
#include <stdlib.h>
%}

line [^\n]+

%option noyywrap
%%


{line} {
    return LINE;
}

<<EOF>> { return 0;}

%%
