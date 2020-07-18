#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "string_dir_table.h"

/*
    Este archivo define las tablas de Cadenas : stringTable y la de las direcciones  : stackDir
*/

extern int dir;

stringTable* createStringTable(){
    stringTable* strTab = malloc(sizeof(stringTable));
    strTab->next = NULL;
    strTab->str = NULL;
    return strTab;
}

/*
    Anade al final de la tabla una cadena, y devuelve el nuevo valor de dir.
    Su valor se encontra en funcion del valor actual y del tamano de la cadena.
*/
int addStringToStringTable(stringTable* strTab, char * string){
    int address =0;
    if(strTab->str == NULL){
        strTab->str = strdup(string);
        address = strlen(string)+dir;
        return address;
    }
    else{
        stringTable* currentStrTab = strTab;
        while (currentStrTab->next != NULL) {
            currentStrTab = currentStrTab->next;
        }
        currentStrTab->next = malloc(sizeof(stringTable));
        currentStrTab->next->str = strdup(string);
        address = strlen(currentStrTab->next->str) + dir;
        return address;
    }
}
/*
    Crear una tabla de direcciones, dir se initializa a 99999, para indicar que
    ya no fue initializada a 0.
*/
stackDir* createStackDir(){
    stackDir* sd = malloc(sizeof(stackDir));
    sd->dir=99999;
    sd->next = NULL;
}
/*
    Anadir un valor de dir en cima de la pila.
*/
void stackDirPush(stackDir* sd, int dir){
    stackDir *currentStackDir = sd;
    if(currentStackDir->dir == 99999){
        currentStackDir->dir = dir;
        return;
    }
    while (currentStackDir->next != NULL) {
        currentStackDir = currentStackDir->next;
    }
    currentStackDir->next = malloc(sizeof(stackDir));
    currentStackDir->next->dir = dir;
    return;
}

/*
    Quita el ultimo valor de la pila, y lo devuelve
*/
int stackDirPop(stackDir* sd){
    stackDir *currentStackDir = sd;
    stackDir *last = NULL;
    //find last
    while (currentStackDir->next != NULL) {
        currentStackDir = currentStackDir->next;
    }
    last = currentStackDir;
    // delete last form list
    currentStackDir = sd;
    while (currentStackDir->next != last) {
        currentStackDir = currentStackDir->next;
    }
    currentStackDir->next = NULL;
    return last->dir;
}
