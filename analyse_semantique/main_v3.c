#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int yylex();
extern int yyparse();
extern char *yytext;
extern FILE* yyin;
extern FILE* yyout;



int main() {
    int claseToken;
    yyin = fopen("entrada","r");
    yyout = fopen("salida","w");

    if(yyin != NULL){
        yyparse();
        printf("Termino la generacion\n");
    }
    else{
        printf("error : no esta el archivo de entrada");
    }
    return 0;
}
