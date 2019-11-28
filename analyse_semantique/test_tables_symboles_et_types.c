#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "tabla_simbolos.h"
#include "tabla_tipos.h"

void testTablaTipos(){

    printf("\n\n Prueba de la Tabla de Tipos\n\n");

    tipo* t1 = crearTipo();
    tipo* t2 = crearTipo();
    tipo* t3 = crearTipo();

    symtab* st = crearSymTab();

    t1->estructura = st;
    t2->type = 1;
    t3->type = 2;

    tipoBase* tb1 = crearTipoBase(t1,true);
    tipoBase* tb2 = crearTipoBase(t2,false);
    tipoBase* tb3 = crearTipoBase(t3,false);

    printf("tb3 = %p\n",tb3 );

    type* type1 = crearType(0,"struct",tb1,4,1);
    type* type2 = crearType(1,"float",tb2,4,1);
    type* type3 = crearType(2,"array",tb3,16,4);

    printf("\ntype 3\nid : %d, nombre %s, tipoBase %p, \
tam %d, numElem %d\n\n", type3->id,type3->nombre,\
        type3->tb,type3->tamBytes,type3->numElem);

    typetab* tt1 = crearTypeTab();

    insertarTypeInTypeTab(tt1,type1);
    insertarTypeInTypeTab(tt1,type2);

    printf("\ntabla tipos : elemento root : %p , next : %p",tt1->root,tt1->root->next);
    printf("\ntabla tipos elemento 2 : %p",tt1->root->next);
    printf("\nnum de elementos : %d\n\n\n",tt1->num);

    type* typeFound = getTypeFromTypeTable(tt1,1);
    tipoBase* tbFound = getTipoBaseFromTypeTab(tt1,1);
    int tamFound = getTamBaseFromTypeTab(tt1, 1);
    int numElemFound =  getNumElemFromTypeTab(tt1, 1);
    char* nombreFound =  getNombreFromTypeTab(tt1,1 );

    printf("Busquedades en la tabla 1, del elemento con id=1\n");
    printf("type : %p\n",typeFound);
    printf("tipo base : %p\n",tbFound );
    printf("tam found %d\n",tamFound );
    printf("numElem found %d\n",numElemFound );
    printf("nombre found %s\n",nombreFound );

    typestack* ts = crearTypeStack();

    typetab* tt2 = crearTypeTab();

    insertarTypeInTypeTab(tt2,type3);

    insertarTypeTabInTypeStack(ts,tt1);
    insertarTypeTabInTypeStack(ts,tt2);

    printf("\ntt1 %p y tt2 %p\n",tt1,tt2 );
    printf("\n\ntype stack : root %p , next : %p\n",ts->root,ts->root->next);

    borrarTypeStack(ts);
}

void testTablaSimbolos(){

    printf("\n\n Prueba de la Tabla de Simbolos\n");

    listParam* l = crearLP();
    addTipoInListparam(l,1);
    addTipoInListparam(l,2);
    addTipoInListparam(l,3);
    addTipoInListparam(l,4);

    printf("l root : %d\n",l->root->tipo);
    printf("l 1 : %d\n",l->root->next->tipo);
    printf("l 2 : %d\n",l->root->next->next->tipo);
    printf("l 3 : %d\n",l->root->next->next->next->tipo);
    printf("l 4 : %p\n",l->root->next->next->next->next);

    printf("tamano %d\n",l->num);

    symtab* st = crearSymTab();
    symbol* sym1 = crearSymbol();

    strcpy(sym1->id,"int");
    sym1->tipo = 0;
    sym1->dir=0;
    sym1->tipoVar=0;
    sym1->params =NULL;

    symbol* sym2 = crearSymbol();

    strcpy(sym2->id,"func");
    sym2->tipo = 10;
    sym2->dir=2;
    sym2->tipoVar=3;
    sym2->params =l;

    insertarSymbolInSymtab(st,sym1);
    printf("size st %d\n",st->num );
    insertarSymbolInSymtab(st,sym2);
    printf("size st %d\n",st->num );

    printf("id root %s\n",st->root->id );
    printf("id s2 %s\n",st->root->next->id );

    printf("next root %p\n",st->root->next );
    printf("p s2 %p\n",sym2 );

    printf("nm param s2 %d\n",st->root->next->params->num);
    printf("\n\n\n");

    int pos = buscarIdInSymtab(st,"func");
    printf("pos del simbolo 'func' %d \n",pos );

    printf("buscar tipo del id :'fun' =  %d\n", getTipoFromSymtab(st,"func"));
    printf("buscar tipoVar del id :'fun' =  %d\n", getTipoVarFromSymtab(st,"func"));
    printf("buscar dir del id :'fun' =  %d\n", getDirFromSymtab(st,"func"));
    printf("buscar params del id :'fun' =  %p\n", getListParamFromSymtab(st,"func"));
    printf("get num list param del id :'fun' =  %d\n", getNumParamFromSymtab(st,"func"));
    printf("OK 1\n" );

    symstack* ss = crearSymStack();
    symtab* st1 = crearSymTab();

    insertarSymTabInSymStack(ss,st1);

    insertarSymTabInSymStack(ss,st);

    printf("\nsymstack root : %p et num :%d\n",ss->root,ss->num);
    printf("symstack next %p = symtab st : %p\n",ss->root->next, st);
    printf("id of first type of second symtab : %s \n",ss->root->next->root->id);

    borrarSymStack(ss);
}

int main(int argc, char const *argv[]) {

    testTablaSimbolos();
    testTablaTipos();
    return 0;
}
