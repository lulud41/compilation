%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>


#include "tables/tabla_simbolos.h"
#include "tables/tabla_tipos.h"

#include "parser_v3.tab.h"

%}

%option noyywrap
%option yylineno

cadena ["].+["]
id [a-zA-Z_][a-zA-Z_0-9]*
caracter ["].["]

num [0-9]*([.])?[0-9]+

%%

"real" {return REAL;}
"registro" {return REGISTRO;}

"inicio" {return INICIO;}

"fin" {return FIN;}
"func" {return FUNC;}

"entonces" {return ENTONCES;}
"ent" {return ENT;}

"escribir" {return ESCRIBIR;}

"dreal" {return DREAL;}
"devolver" {return DEVOLVER;}

"car" {return CAR;}

"sin" {return SIN;}
"sino" {return SINO;}
"si" {return SI;}

"mientras" {return MIENTRAS;}
"hacer" {return HACER;}
"que" {return QUE;}
"leer" {return LEER;}
"terminar" {return TERMINAR;}

"oo" {return OR;}
"no" {return NO;}
"yy" {return AND;}

"verdadero" {return TRUE;}
"falso" {return FALSE;}

{id} {strcpy(yylval.id,yytext);
    return ID;}

{caracter} {strcpy(yylval.id,yytext);return CARACTER;}

{cadena} {strcpy(yylval.id,yytext);return CADENA;}

{num} { // en funcion del valor de yytext, se adatpan los atributos de NUM
    // puede ser un numero entero / relativo o flotante
    float valNum = atof(yytext);
    if (ceil(valNum) == valNum && valNum >= 0){ // si es entero y positivo
        yylval.num.tipo = ENT;
        yylval.num.val.ival = (int) valNum;
    }
    if(ceil(valNum) == valNum){ // si es entero pero relativo
        yylval.num.tipo = REAL;
        yylval.num.val.ival = (int) valNum;
    }
    else{
        yylval.tipo = DREAL; // si no es entero
        yylval.num.val.fval = valNum;
    }
    return NUM;}

"(" {return PAR_I;}
")" {return PAR_D;}
"[" {return LLAVE_I;}
"]" {return LLAVE_D;}

":=" {return ASIGN;}

"<=" {return MENOR_IG;}
">=" {return MAYOR_IG;}
"<>" {return DIF;}

"<" {return MENOR;}
">" {return MAYOR;}

"==" {return IGUAL;}

"+" {return MAS;}
"-" {return MENOS;}
"*" {return MUL;}
"/" {return DIV;}
"%" {return MOD;}

"\n" {return SL;}

[ \t\v]+ {}
"," {return COMA;}
"." {return PUNTO;}

<<EOF>> {return EOF;}

. {printf("Lexical error : '%s' not a token at line %d \n",yytext,yylineno);return -1;}

%%
