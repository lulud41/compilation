#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "tabla_simbolos.h"
#include "tabla_tipos.h"


/*Retorna un apuntador a una variable type*/
tipo* crearTipo(){
    tipo *t = malloc(sizeof(tipo));
    return t;
}

type* crearType(int id,char nombre[], tipoBase *tb,int tamBytes,int numElem){
    type* t = malloc(sizeof(type));
    t->id = id;
    strcpy(t->nombre,nombre);
    t->tb = tb;
    t->tamBytes = tamBytes;
    t->numElem = numElem;
    t->next = NULL;
    return t;
}

typetab* crearTypeTab(){
    typetab* tt = malloc(sizeof(typetab));
    tt->root = NULL;
    tt->num = 0;
    tt->next = NULL;
    return tt;
}

/*Borra type ,libera la memoria*/
void borrarType(type* Type){
    borrarTipoBase(Type->tb);
    free(Type);
}

/*Borra tipoBase ,libera la memoria*/
void borrarTipoBase(tipoBase* tb){
    if(tb->est == true){
        borarSymTab(tb->t->estructura);
        free(tb->t);
        free(tb);
        return;
    }
    else{
        free(tb->t);
        free(tb);
        return;
    }
}

tipoBase* crearTipoBase(tipo *tipo, bool est){
    tipoBase* tb = malloc(sizeof(tipoBase));
    tb->t = tipo;
    tb->est = est;
    return tb;
}

int insertarTypeInTypeTab(typetab* tt,type* t){
    if(tt->root == NULL){
        tt->root = t;
        tt->root->next = NULL;
        tt->num = 1;
        return 1;
    }
    else{
        type* currentType = tt->root;

        while (currentType->next != NULL) {
            currentType = currentType->next;
        }
        currentType->next = t;
        currentType->next->next = NULL;
        tt->num = (tt->num)+1;

        return tt->num;
        }
}

/*
    Buscar un Type en la lista, segun su id
    retorna NULL si no esta
*/
type* getTypeFromTypeTable(typetab * tt, int id){
    // se considera que la posicion existe en la lista
    type* currentType = tt->root;
    for (int i=0; i<tt->num; i++){
        if(currentType->id != id && currentType->next != NULL){
            currentType = currentType->next;
        }
        else if(currentType->id == id){
            return currentType;
        }
    }
    return NULL;
}

/*Retorna el tipo base de un tipo
*En caso de no en contrar lo retorna NULL
*/
tipoBase* getTipoBaseFromTypeTab(typetab *tt,int id){
    type* typeFound = getTypeFromTypeTable(tt,id);
    if(typeFound != NULL){
        return typeFound->tb;
    }
    else{
        return NULL;
    }
}

/*Retorna el numero de bytes de un tipo
*En caso de no encontrar lo retorna −1
*/
int getTamBaseFromTypeTab(typetab *tt,int id){
    type* typeFound = getTypeFromTypeTable(tt,id);
    if(typeFound != NULL){
        return typeFound->tamBytes;
    }
    else{
        return -1;
    }
}

/*Retorna el numero de elementos de un tipo
*Encaso de no encontrar lo retorna −1
*/
int getNumElemFromTypeTab(typetab *tt,int id){
    type* typeFound = getTypeFromTypeTable(tt,id);
    if(typeFound != NULL){
        return typeFound->numElem;
    }
    else{
        return -1;
    }
}

/*Retorna el nombrede un tipo
*Encaso de no encontrarlo retorna NULL
*/
char* getNombreFromTypeTab(typetab* tt,int id){
    type* typeFound = getTypeFromTypeTable(tt,id);
    if(typeFound != NULL){
        return typeFound->nombre;
    }
    else{
        return NULL;
    }
}

void borrarTypeTab(typetab* tt){  
    if(tt->root == NULL){
        free(tt);
        return;
    }
    else{
        type* pointers[tt->num];
        type* currentType = tt->root;
        pointers[0] = currentType;

        for(int i=1;i<tt->num;i++){
            pointers[i] = currentType->next;
            if(currentType->next != NULL){
                currentType = currentType->next;
            }
        }
        // free las direcciones
        for(int i=0;i<tt->num;i++){
            borrarType(pointers[i]);
        }
        free(tt);
        return;
    }
}

typestack *crearTypeStack(){
    typestack* ts = malloc(sizeof(typestack));
    ts->root = NULL;
    ts->num = 0;
    return ts;
}

void borrarTypeStack(typestack* ts){
    if(ts->root == NULL){
        free(ts);
        return;
    }
    else{
        typetab* pointers[ts->num];
        typetab* currentTypeTab = ts->root;
        pointers[0] = currentTypeTab;

        for(int i=1;i<ts->num;i++){
            pointers[i] = currentTypeTab->next;
            if(currentTypeTab->next != NULL){
                currentTypeTab = currentTypeTab->next;
            }
        }
        // free las direcciones
        for(int i=0;i<ts->num;i++){
            borrarTypeTab(pointers[i]);
        }
        free(ts);
        return;
    }

}

void insertarTypeTabInTypeStack(typestack *ts,typetab *tt){
    if(ts->root == NULL){
        ts->root = tt;
        ts->root->next = NULL;
        ts->num = 1;
    }
    else{
        typetab* currentTypeTab = ts->root;

        while (currentTypeTab->next != NULL) {
            currentTypeTab = currentTypeTab->next;
        }
        currentTypeTab->next = tt;
        currentTypeTab->next->next = NULL;
        ts->num = (ts->num)+1;
        }
        return;
}

typetab* getCimaTypeStack(typestack *ts){
    return ts->root;
}

typetab* sacarTypeTab(typestack *ts){
    // A quoi ça sert ??????
    return NULL;
}
