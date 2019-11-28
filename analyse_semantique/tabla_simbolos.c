#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "tabla_simbolos.h"


/* retorna un apuntador a una variable Param */
param* crearParam(int tipo){
    param *parametro = malloc(sizeof(param));
    parametro->tipo = tipo;
    parametro->next = NULL;
    return parametro;
};

/*Borra param, libera la memoria*/
void borarParam(param *p){
    free(p);
}

/*Retorna un apuntador a una variable listParam*/
listParam* crearLP(){
    listParam* list = malloc(sizeof(listParam));
    list->root = NULL;
    list->num = 0;
    return list;
}

/*Agrega al final de la lista el parametro e incrementa num*/
void addTipoInListparam(listParam *lp, int tipo){
    // si lista vacia
    if (lp->root == NULL){
        lp->root = crearParam(tipo);
        lp->num = 1;
    }
    else{  // sino : iterar
        param* currentParam = lp->root;
        while (currentParam->next != NULL) {
            currentParam = currentParam->next;
        }
        currentParam->next = crearParam(tipo);
        lp->num = (lp->num) +1;
    }
}

/*Borra toda la lista, libera la memoria*/
void borrarListParam(listParam *lp){
    //si la lista esta vacilla
    if(lp->root == NULL){
        free(lp);
        return;
    }
    else{
        param* pointers[lp->num];
        param* currentParam = lp->root;
        pointers[0] = currentParam;

        for(int i=1;i<lp->num;i++){
            pointers[i] = currentParam->next;
            if(currentParam->next != NULL){
                currentParam = currentParam->next;
            }
        }
        // free las direcciones
        free(lp);
        for(int i=0;i<lp->num;i++){
            free(pointers[i]);
        }

        return;
    }
}

/*Cuenta el numero de parametros en la lista*/
int getNumListParam(listParam *lp){
    return lp->num;
}

/*Retorna un apuntadora una variable symbol */
symbol *crearSymbol(){
    symbol* sym = malloc(sizeof(symbol));
    return sym;
}

/*Borra symbol, libera la memoria*/
void borarSymbol(symbol *s){
    free(s);
}

/*
* Retorna un apuntador a una variable symtab,
* inicia contadoren 0
*/
symtab* crearSymTab(){
    symtab* s = malloc(sizeof(symtab));
    s-> root = NULL;
    s-> num = 0;
    s-> next = NULL;

    return s;
}

/* Borra toda la lista, libera la memoria */
void borarSymTab(symtab *st){
    if(st->root == NULL){
        free(st);
        return;
    }
    else{
        symbol* pointers[st->num];
        symbol* currentSym = st->root;
        pointers[0] = currentSym;

        for(int i=1;i<st->num;i++){
            pointers[i] = currentSym->next;
            if(currentSym->next != NULL){
                currentSym = currentSym->next;
            }
        }
        // free las direcciones
        for(int i=0;i<st->num;i++){
            if( pointers[i]->params != NULL){
                borrarListParam(pointers[i]->params);
            }
            free(pointers[i]);
        }
        free(st);
        return;
    }
}

/* inserta al final de la lista en caso de insertar
*  incrementa num
*  retorna la posicion donde inserto en caso contrario retorna -1
*
*  La posicion : Sym_root = 1, s2 =  2 , ...
*
*/
int insertarSymbolInSymtab(symtab *st, symbol *sym){
    if(st->root == NULL){
        st->root = sym;
        st->root->next = NULL;
        st->num = 1;
        return 1;
    }
    else{
        symbol* currentSym = st->root;

        while (currentSym->next != NULL) {
            currentSym = currentSym->next;
        }
        currentSym->next = sym;
        currentSym->next->next = NULL;
        st->num = (st->num)+1;

        return st->num;
        }
}


/*Busca en la tabla de simbolos mediante el id
* En caso de encontrar el id retorna la posicion
* En caso contrario retorna -1

 */
int buscarIdInSymtab(symtab *st, char *id){
    symbol* currentSym = st->root;
    for(int i=0;i<st->num;i++){
        if(strcmp(currentSym->id,id) == 0){
            return i+1;
        }
        if(currentSym->next != NULL){
            currentSym = currentSym->next;
        }
    }
    return -1;
}
/*
* Retorna el tipo de dato de un id
* En caso de no encontrarlo retorna -1
*/
symbol* getSymbolFromSymTab(symtab* st,int pos){
    // se considera que la posicion existe en la lista
    // a voir si il faudrait pas parcourir la liste, et chercher
    // terme avec terme->pos = pos
    symbol* currentSym = st->root;
    for (int i=0;i<pos-1;i++){
        if(currentSym->next != NULL){
            currentSym = currentSym->next;
        }
        else{
            return NULL;
        }
    }
    return currentSym;
}

int getTipoFromSymtab(symtab *st, char *id){
    int pos = buscarIdInSymtab(st,id);
    if(pos != -1){
        symbol* sym = getSymbolFromSymTab(st,pos);
        return sym->tipo;
    }
    else{
        return -1;
    }
}

/*
* Retorna el tipo de variable de un id
* En caso de no encontrarlo retorna -1
*/
int getTipoVarFromSymtab(symtab *st, char *id){
    int pos = buscarIdInSymtab(st,id);
    if(pos != -1){
        symbol* sym = getSymbolFromSymTab(st,pos);
        return sym->tipoVar;
    }
    else{
        return -1;
    }
}


/*
* Retorna la direccion de un id
* En caso de no encontrarlo retorna NULL
*/
int getDirFromSymtab(symtab *st, char *id){
    int pos = buscarIdInSymtab(st,id);
    if(pos != -1){
        symbol* sym = getSymbolFromSymTab(st,pos);
        return sym->dir;
    }
    else{
        return -1;
    }
}

/*
* Retorna la lista de parametros de un id
* En caso de no encontrarlo retorna NULL
*/
listParam* getListParamFromSymtab(symtab *st,char *id){
    int pos = buscarIdInSymtab(st,id);
    if(pos != -1){
        symbol* sym = getSymbolFromSymTab(st,pos);
        return sym->params;
    }
    else{
        return NULL;
    }
}

/*
*Retorna el numero de parametros de un id
* En caso de no encontrarlo retorna -1
*/
int getNumParamFromSymtab(symtab *st, char *id){
    listParam* listP = getListParamFromSymtab(st,id);
    if(listP != NULL){
        return listP->num;
    }
    else{
        return -1;
    }
}

symstack* crearSymStack(){
    return malloc(sizeof(symstack));
}

void borrarSymStack(symstack *ss){
    if(ss->root == NULL){
        free(ss);
        return;
    }
    else{
        symtab* pointers[ss->num];
        symtab* currentSymTab = ss->root;
        pointers[0] = currentSymTab;

        for(int i=1;i<ss->num;i++){
            pointers[i] = currentSymTab->next;
            if(currentSymTab->next != NULL){
                currentSymTab = currentSymTab->next;
            }
        }
        // free las direcciones
        for(int i=0;i<ss->num;i++){
            borarSymTab(pointers[i]);
        }
        free(ss);
        return;
    }
}

void insertarSymTabInSymStack(symstack *ss, symtab *st){
    if(ss->root == NULL){
        ss->root = st;
        ss->root->next = NULL;
        ss->num = 1;
        return;
    }
    else{
        symtab* currentSymTab = ss->root;

        while (currentSymTab->next != NULL) {
            currentSymTab = currentSymTab->next;
        }
        currentSymTab->next = st;
        currentSymTab->next->next = NULL;
        ss->num = (ss->num)+1;
        return;
        }
}

symtab* getCimaSymstack(symstack *ss){
    return ss->root;
}

symtab* sacarSymTab(symstack *ss){
// No entiendo esta funcion
    return NULL;

}
