#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "quadruples.h"
/*
    Implementacion de los quadruples, como fueron descritos en la practica 7
*/

quad* createQuad(char *op, char* arg1, char *arg2, char *res){
    quad *q = malloc(sizeof(quad));
    strcpy(q->op,op);
    strcpy(q->arg1,arg1);
    strcpy(q->arg2,arg2);
    strcpy(q->res,res);

    q->next = NULL;
    return q;
}

void deleteQuad(quad *q){
    free(q);
}

code *createCode(){
    code *c = malloc(sizeof(code));
    c->root= NULL;
    c->num_instructions =0;
    return c;
}

void deleteCode(code *c){
    free(c);
}
/*
    Encontrar el final de la lista de quadruples 'code', y anadir el nuevo quadruple
*/
void addQuadToCode(code *c, char *op, char *arg1, char *arg2, char* res){
    quad *newQuad = createQuad(op,arg1,arg2,res);
    if(c->root = NULL){
        c->root = newQuad;
        c->num_instructions = 1;
        return;
    }
    else {
        quad *currentQuad = c->root;
        while (currentQuad->next != NULL) {
            currentQuad = currentQuad->next;
        }
        currentQuad->next =  newQuad;
        c->num_instructions = (c->num_instructions) +1;
        return;
    }
}
