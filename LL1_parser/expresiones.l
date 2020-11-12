%{
	#include <stdio.h>	
%}

digito [0-9]+

%%
        
"+" {return 0;}
"-" {return 1;}
"*" {return 2;}
"/" {return 3;}
"%" {return 4;}
"(" {return 5;}
")" {return 6;}
{digito} {return 7;}

<<EOF>> {return 8;}

. {return -1;}

%%