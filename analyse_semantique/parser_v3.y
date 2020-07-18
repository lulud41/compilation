%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "tables/tabla_simbolos.h"
#include "tables/tabla_tipos.h"
#include "string_dir_table.h"
#include "quadruples.h"

// Valores posibles para TipoVar, en la tabla de simbolos
#define TIPO_VAR_VAR 1  // 1 para una variable
#define TIPO_VAR_FUNC 2 // 2 para una funcion

extern int yylineno;
extern int yylex();

void yyerror(char *s);

int dir = 0; // direccion actual de la memoria
int currentType;   // tipo que actual que se esta declarando
int baseType;       // tipo base (nativo) que esta usado por la declaracion

int FuncType = 0;   // tipo de la funcion que se esta declarando
bool FuncReturn = 0;

symstack* StackST;  // Pila de tabla de simbolos
typestack* StackTT; // Pila de table de tipos

stringTable* StringTable;   // Tabla de cadenas
stackDir* StackDir;         // Tabla de direcciones

listParam* lista;           // Lista de parametros, para las funciones

int label = 0;      // Label initial, se incrementa luego, segun las llamadas de newLabel()
int index = 0;      // Index initial, se incrementa luego, segun las llamadas de newIndex()

int wideningConversion[] = {DREAL, REAL,ENT,CAR}; // Jerarquia de los tipos : las conversiones se hacen segun
                                                    // el index en el arreglo : DREAL > REAL > ENT > CAR

code* code = createCode();   // Initialisacion de la variable code, que almacena el codigo intermedio
/*
    Funcion max : Devuelve el tipo mas grande entre t1 y t2,
    segun el arreglo wideningConversion, que da la jerarquia.
    por ejemplo : max(DREAL, ENT) = DREAL
*/
int max(int t1, int t2){
    int index_t1, index_t2 = -1;
    // buscar el indice en el arreglo
    for (int i=0;i<4;i++){
        if(wideningConversion[i] == t1){
            index_t1 = i;
        }
        if(wideningConversion[i] == t2){
            index_t2 = i;
        }
    }
    // si uno de los tipos no esta en el arreglo wideningConversion
    // no se puede hacer conversion, ya que no es un tipo DREAL,REAL,ENT,CAR
    if(t1 == -1 || t2 == -1){
        return -1;
    }
    else{ // Devuelve el max
        if(t1 >= t2){return t1;}
        else{return t2;}
    }
}
/*
    Genera el codigo intermedio para ampliar el tipo t1,
    hacia el tipo t2.
*/
int ampliar(int dir, int t1, int t2){
    if(t1 == t2){ // no se necesita ampliar
        return dir;
    }
    else{
        int index_t1, index_t2 = -1;
        for (int i=0;i<4;i++){ // buscar los indices en el arreglo wideningConversion
            if(wideningConversion[i] == t1){
                index_t1 = i;
            }
            if(wideningConversion[i] == t2){
                index_t2 = i;
            }
        }
        // Si t1 y t2 estan en el arreglo, buscar el tipo mayor
        if(index_t1 != -1 && index_t2 != -1 && index_t1 > index_t2){
            // generar el codigo para  cast :   (t1) t2
            int temp = newTemp();
            char *tempStr;
            sprintf(tempStr,"%d",temp);
            char *nombreT1 = getNombreFromTypeTab(t1);
            addQuadToCode(code,tempStr,"=",nombreT1,dir);
        }
        if(index_t1 != -1 && index_t2 != -1 && index_t2 > index_t1){
            // generar el codigo para  cast :   (t2) t1
            int temp = newTemp();
            char *tempStr;
            sprintf(tempStr,"%d",temp);
            char *nombreT2 = getNombreFromTypeTab(t2);
            addQuadToCode(code,tempStr,"=",nombreT2,dir);
        }
        else{
            printf("no se puede ampliar\n");return -1;
        }
    }
}
/*
    Funcion para hacer la conversion de un tipo t1 hacia
    un tipo mas pequeno t2, es el mismo procedimiento que ampliar
*/
int reducir(expresion.dir, int t1, int t2){
    if(t1 == t2){
        return dir;
    }
    else{
        int index_t1, index_t2 = -1;
        for (int i=0;i<4;i++){
            if(wideningConversion[i] == t1){
                index_t1 = i;
            }
            if(wideningConversion[i] == t2){
                index_t2 = i;
            }
        }
        //check index
        if(index_t1 != -1 && index_t2 != -1 && index_t1 > index_t2){
            int temp = newTemp();
            char *tempStr;
            sprintf(tempStr,"%d",temp);
            char *nombreT2 = getNombreFromTypeTab(t1);
            addQuadToCode(code,tempStr,"=",nombreT2,dir);
        }
        if(index_t1 != -1 && index_t2 != -1 && index_t2 > index_t1){
            int temp = newTemp();
            char *tempStr;
            sprintf(tempStr,"%d",temp);
            char *nombreT1 = getNombreFromTypeTab(t1);
            addQuadToCode(code,tempStr,"=",nombreT1,dir);
        }
        else{
            printf("no se puede ampliar\n");return -1;
        }
    }
}

/*
    Crear una nueva variable temporal. No se reemplean las variables
    que ya no se usan, solo se incrementa el numero.
*/
int newTemp(){
    int temp = dir;
    dir = dir+4;
    return temp;
}
/*
    Crear un nuevo label. Se incrementa siempre el valor.
*/
int newLabel(){
    int newLab = label;
    label = label+1;
    return newLab;
}

/*
    Crear un nuevo index. Se incrementa siempre el valor.
*/
ind newIndex(){
    int id = index;
    index = index+1;
    return id;
}

/*
    Crea una lista de instrucciones, la estructura esta en tabla_tipos.h :

    typedef struct _instruction instruction;
    struct _instruction{
        int instruction_num;
        instruction* next;
    };

    Esta lista sirve para los tipos de no-terminales : "expr_booleana" y "rel"
    que usan una lista de numeros de instrucciones : listaNext para los relacionales
    o listaTrue y False para las expresiones booleanas
*/
instruction* newList(){
    instruction* i = malloc(sizeof(instruction));
    i->next = NULL;
    i->instruction_num = -1;
    return i;
}

/*
    Dada una lista de instrucciones y un numero de instruccion (un Index)
    se pone el numero en al final de la lista.
*/
void addInstructionToList(instruction* list, int instruction_num){
    // alcanzar el ulimo termino de la lista
    while(list->next != NULL) {
        list = list->next;
    }
    // anadir la nueva instruccion (Index)
    instruction* newInstruction = newList();
    newInstruction->instruction_num = instruction_num;
    list->next = newInstruction;
    return;
}
/*
    Permite concatenar dos listas de instruccion.
*/
instruction* combinar(instruction* list1 , instruction *list2){
    while (list1->next != NULL) { // obtener el ultimo termino
        list1 = list1->next;
    }
    list1->next = list2; // anadir la segunda lista
    return list1;
}

/*
    Realizar el backpatching : dada una lista de instrucciones :
    busca en la lista "code" los quadruples que tienen un index
    que corresponde a un termino de la lista de instrucciones.
    Luego se cambia el valor del index con el valor del label,
    en los quadruples encontrados.
*/
void backpatch(code* code, instruction* list, int label){
    quadruples* currentQuad = code.root; // recorrer la lista de quadruples
    int currentIndex =  list->instruction_num; // recorrer la lista de indices
    int finished = 0;
    // los quadruples solo tiene char* , hay que converter los int en char*
    char *stringIndex;
    sprintf(stringIndex,"%d",currentIndex);

    char *stringLabel;
    sprintf(stringLabel,"%d",label);

    while (finished != 1) {
        if(strcmp(currentQuad->res,stringIndex) == 0){ // si el quadruple actual tiene el index actual
            strcpy(currentQuad->res, stringLabel); // poner el label
            // el que se busca es ahora el siguiente
            list = list->next;
            currentIndex = list->instruction_num;
            //conversion del index
            sprintf(stringIndex,"%d",currentIndex);
            // cambiar el quadruple par ael siguiente
            if(currentQuad->next == NULL){
                finished = 1;
            }
            else{
                currentQuad = currentQuad->next
            }
        }
        // si el quadruple actual no tiene el index que se busca, ir al quadruple siguiente
        else{
            currentQuad = currentQuad->next;
        }
    }
}

%}
// union par definir el tipo de los tokens y de los no terminales que tiene atributos
%union{
    struct{
        int tipo;
        union{
            int ival;
            float fval;
        }val;
    }num; // tipo para los NUM : un tipo, y un valor. int tipo se initializa con un valor de ENT / REAL / DREAL

    char id[32];    // para las cadenas, caracteres o ID

    int tipo;       // para los tipos, su valor es uno de los de los tokens : CAR REAL ENT DREAL

    listParam *lista; // lista de parametros definida en "tabla_simbolos.h"

    struct{
        struct instruction* listNext_root;
        int num;
    }listNext;   // lista de index, definida en tabla_tipos.h

    struct{
        instruction* listFalse_root;
        instruction* listTrue_root;
        int num_false;
        int num_true;
    }expr_booleana; // listas false y true para las expresiones booleanas

    struct{
        int dir;
        int tipo;
    }expr;  // dir y tipo para las expresiones

    struct{
        int tipo;
        int base;
        int dir;
    }var;          // para los no-terminales variable

    struct{
        instruction* listTrue_root;
        instruction* listFalse_root;
        int tipo;
        int dir;
    }rel;       // para los relacionales

    struct{
        int base;
        int tipo;
        int tam;
        int dir;
    }arr;   // para los arreglos
}

// ================ TOKENS =================


%token SL // salto de linea

%token REGISTRO INICIO FIN FUNC

%token ENT REAL DREAL CAR SIN

%token COMA PUNTO

%token PAR_I PAR_D LLAVE_I LLAVE_D // parentesis  ( ) y llaves  [ ]

%token SI SINO ENTONCES
%token MIENTRAS HACER QUE
%token ASIGN ESCRIBIR LEER
%token DEVOLVER TERMINAR // ASIGN es ':='

%token OR NO AND TRUE FALSE

%token MAYOR MENOR MAYOR_IG MENOR_IG IGUAL DIF // MAYOR_IG es >= ; dif es <>

%token MAS MENOS MUL DIV MOD

// tokens especiales con atributos
%token<num> NUM
%token<id> ID
%token<id> CADENA
%token<id> CARACTER


//=============== ASSOCIATION ====================

%right ASIGN    // :=
%left MAS MENOS
%left MUL DIV MOD
%nonassoc PAR_D PAR_I


// ================== NO TERMINALES ====================


%type<tipo> tipo
%type<tipo> tipo_registro
%type<tipo> base
%type<tipo> tipo_arreglo
%type<tipo> tipo_arg
%type<tipo> param_arr
%type<tipo> arg

%type<lista> argumentos
%type<lista> lista_arg
%type<lista> parametros
%type<lista> lista_param

%type<listNext> sentencias
%type<listNext> sentencia

%type<expr_booleana> expresion_booleana

%type<expr> expresion

%type<var> variable

%type<rel> relacional

%type<arr> arreglo

%start program

%% // implementacion de la definicion dirigida por sintaxis
    program:
        {
            dir = 0;
            StackST = crearSymStack();   //symbol stack
            StackTT = crearTypeStack();   // type stack

            typetab* tt =  crearTypeTab();
            symtab* st =  crearSymTab();

            addSymTabInSymStack(StackST, st);
            addTypeTabInTypeStack(StackTT, tt);

            stackDir* StackDir = createStackDir();

            StringTable = createStringTable();
        }

        declaraciones SL funciones { printf("correct syntax !\n");  };


    declaraciones : tipo {currentType = $1.tipo; } lista_var SL declaraciones {}
                | tipo_registro { currentType = $1.tipo; } lista_var SL declaraciones {}
                | {};


    tipo_registro : REGISTRO SL INICIO {

        symtab* st = crearSymTab();
        typetab* tt = crearTypeTab();

        stackDirPush(StackDir, dir);
        dir = 0;

        addSymTabInSymStack(StackST, st);
        addTypeTabInTypeStack(StackTT, tt); }


        declaraciones SL FIN {

            dir = stackDirPop(StackDir);

            typetab* tt1 = removeLastTypeTabFromTypeStack(StackTT);
            symtab* topSymTab = getTopSymStack(StackST);
            setTypeTabForSymTab(topSymTab, tt1);

            symtab* ts1 = removeLastSymTabFromSymStack(StackST);
            dir = stackDirPop(StackDir);

            // add the new struct type
            typetab* topTypeTab = getTopTypeStack(StackTT);
            //crear el nuevo tipo
            tipo* newTipo = crearTipo(0, ts1);
            tipoBase* tb = crearTipoBase(newTipo, TRUE);
            int id = (topTypeTab->num) +1 ;
            int tamByte = getTotalSize(tt1);
            type* newType = crearType(id, "registro", tb, tamByte , tt1->num);
            currentType = addTypeInTypeTab(topTypeTab, newType);
    };

    tipo : base { baseType = $1; } tipo_arreglo {$$.tipo=$3.tipo;};

    base : ENT { // aqui se anade los tipos nativos a la tabla de tipos, cuando se encuentran por
        $$.tipo = ENT;  // la primera vez
        typetab* topTypeTab = getTopTypeStack(StackTT);
        symtab* topSymTab = getTopSymStack(StackST);
        //crear el nuevo tipo si ya no existe
        if (getTipoFromSymtab(topSymTab,"ent") == -1){
            tipo* newTipo = crearTipo(ENT, ts1);
            tipoBase* tb = crearTipoBase(newTipo, FALSE);
            int id = (topTypeTab->num) +1 ;
            int tamByte = 4;
            type* newType = crearType(id, "ent", tb, tamByte , -1);
            int foo = addTypeInTypeTab(topTypeTab, newType);
            }

        }
        | REAL {$$.tipo = REAL;
            symtab* topSymTab = getTopSymStack(StackST);
            //crear el nuevo tipo si ya no existe
            if (getTipoFromSymtab(topSymTab,"real") == -1){
                typetab* topTypeTab = getTopTypeStack(StackTT);
                //crear el nuevo tipo
                tipo* newTipo = crearTipo(REAL, ts1);
                tipoBase* tb = crearTipoBase(newTipo, FALSE);
                int id = (topTypeTab->num) +1 ;
                int tamByte = 4;
                type* newType = crearType(id, "real", tb, tamByte , -1);
                int foo = addTypeInTypeTab(topTypeTab, newType);
            }
        }
        | DREAL {$$.tipo = DREAL;
            symtab* topSymTab = getTopSymStack(StackST);
            //crear el nuevo tipo si ya no existe
            if (getTipoFromSymtab(topSymTab,"dreal") == -1){
                typetab* topTypeTab = getTopTypeStack(StackTT);
                //crear el nuevo tipo
                tipo* newTipo = crearTipo(DREAL, ts1);
                tipoBase* tb = crearTipoBase(newTipo, FALSE);
                int id = (topTypeTab->num) +1 ;
                int tamByte = 4;
                type* newType = crearType(id, "dreal", tb, tamByte , -1);
                int foo = addTypeInTypeTab(topTypeTab, newType);
            }
        }
        | CAR {$$.tipo = CAR;
            symtab* topSymTab = getTopSymStack(StackST);
            //crear el nuevo tipo si ya no existe
            if (getTipoFromSymtab(topSymTab,"car") == -1){
                typetab* topTypeTab = getTopTypeStack(StackTT);
                //crear el nuevo tipo
                tipo* newTipo = crearTipo(CAR, ts1);
                tipoBase* tb = crearTipoBase(newTipo, FALSE);
                int id = (topTypeTab->num) +1 ;
                int tamByte = 2;
                type* newType = crearType(id, "car", tb, tamByte , -1);
                int foo = addTypeInTypeTab(topTypeTab, newType);
            }
        }
        | SIN {$$.tipo = SIN;};

    tipo_arreglo : LLAVE_I NUM LLAVE_D tipo_arreglo  {

        if (NUM.tipo == ENT && NUM.val.ival > 0){
            typetab* topTypeTab = getTopTypeStack(StackTT);
            // crear un nuevo tipo
            tipo* newTipo = crearTipo($4.tipo, NULL);
            tipoBase* tb = crearTipoBase(newTipo, FALSE);
            int id = (topTypeTab->num) +1 ;
            int tamByte = NUM.val.ival*  getTamOfTypeFromTypeTab(topTypeTab, baseType);
            type* newType = crearType(id, "array", tb, tamByte , NUM.val.ival);
            currentType = addTypeInTypeTab(topTypeTab, newType);
        }
        else{
            printf("El indice tiene que ser entero y mayor que cero\n");
        }

    }

                | {$$.tipo = baseType;};


    lista_var : lista_var COMA ID {

        symtab* topSymTab = getTopSymStack(StackST);
        typetab* topTypeTab = getTopTypeStack(StackTT);

        if (findIdInSymtab(topSymTab, $3.id) == -1){
            symbol * newSym= crearSymbol($3.id, currentType, dir, TIPO_VAR_VAR, NULL);
            int foo = addSymbolInSymtab(topSymTab, newSym);
            dir = dir + getTamOfTypeFromTypeTab(topTypeTab, currentType);
        }
        else{
            printf("El identificador ya fue declarado");
        }

    }
        | ID {
                 symtab* topSymTab = getTopSymStack(StackST);
                 typetab* topTypeTab = getTopTypeStack(StackTT);

                 if (findIdInSymtab(topSymTab, $1.id) == -1){
                     symbol * newSym= crearSymbol($1.id, currentType, dir, TIPO_VAR_VAR, NULL);
                     int foo = addSymbolInSymtab(topSymTab, newSym);
                     dir = dir + getTamOfTypeFromTypeTab(topTypeTab, currentType);
                 }
                 else{
                     printf("El identificador ya fue declarado");
                 }
            };


    funciones : FUNC tipo ID PAR_I argumentos PAR_D INICIO SL {

            symtab* rootSymTab = getRootSymStack(StackST);
            if(findIdInSymtab(rootSymTab, $3.id) == -1){
                if($2.tipo != SIN && FuncReturn == FALSE){
                    printf("la función no tiene valor de retorno");
                }
                else{
                    //add symbol
                    symbol * newSym= crearSymbol($3.id, $2.tipo, 0, TIPO_VAR_FUNC, NULL);
                    int foo = addSymbolInSymtab(rootSymTab, newSym);
                    dir = dir + getTamOfTypeFromTypeTab(topTypeTab, currentType);

                    stackDirPush(stackDir, dir);
                    FuncType = $2.tipo;
                    FuncReturn = FALSE;

                    typetab* tt =  crearTypeTab();
                    symtab* st =  crearSymTab();

                    addSymTabInSymStack(StackST, st);
                    addTypeTabInTypeStack(StackTT, tt);

                    int foo = addListParamToSymbol(rootSymTab, $3.id, $5.lista);

                    addQuadToCode(code, "label","","",$3.id);


                }
            }
            else{
                printf("El identificador ya fue declarado");
            }
    }
            declaraciones sentencias SL FIN SL
            {

                int L = newLabel();
                backpatch(code, $11.listNext_root,L);
                addQuadToCode(code,"label","","",L);

                typetab* tt = removeLastTypeTabFromTypeStack(StackTT);
                symtab* ts = removeLastSymTabFromSymStack(StackST);

                dir = stackDirPop(StackDir);



            } funciones {}
            | {};


    argumentos : lista_arg {$$.lista = $1.lista;}
            | SIN {$$.lista = NULL;};


    lista_arg : lista_arg arg {

        $$.lista = $1.lista;
        addTipoInListparam($$.lista, $2.tipo;);
}
            | arg {
                $$.lista = crearListaParam();
                addTipoInListparam($$.lista, $1.tipo);
            };


    arg : tipo_arg ID {

        symtab* topSymTab = getTopSymStack(StackST);
        typetab* topTypeTab = getTopTypeStack(StackTT);

        if(findIdInSymtab(topSymTab, $2.id) == -1){
            symbol * newSym= crearSymbol($2.id, $1.tipo, dir, TIPO_VAR_VAR, NULL);
            int foo = addSymbolInSymtab(topSymTab, newSym);
            dir = dir + getTamOfTypeFromTypeTab(topTypeTab, $1.tipo);
        }
        else{
            printf("El identificador ya fue declarado\n");
        }
        $$.tipo = $1.tipo;
    };


    tipo_arg : base {baseType = $1.tipo; } param_arr {$$.tipo = $3.tipo;};


    param_arr : LLAVE_I LLAVE_D param_arr {
        typetab* topTypeTab = getTopTypeStack(StackTT);

        tipo* newTipo = crearTipo(currentType, NULL);
        tipoBase* tb = crearTipoBase(newTipo, FALSE);
        int id = (topTypeTab->num) +1 ;
        int tamByte = getTamOfTypeFromTypeTab(topTypeTab, $3.tipo);
        type* newType = crearType(id, "array", tb, tamByte ,0, $3.tipo);
        $$.tipo = addTypeInTypeTab(topTypeTab, newType);
    }
            | { $$.tipo = baseType;};


    sentencias : sentencias SL sentencia {
            int L = newLabel();
            backpatch(code,$$.listNext_root,L);
            $$.listNext = $3.listNext_root;
    }
            | sentencia { $$.listNext_root = $1.listNext_root;};


    sentencia : SI expresion_booleana ENTONCES SL sentencias SL FIN {
            L = newLabel();
            backpatch(code,$2.listTrue_root,L);
            $$.listNext_root = combinar($2.listFalse_root, $5.listNext_root);
    }
                | SI expresion_booleana SL sentencias SL SINO SL sentencias SL FIN {
                    L = newLabel();
                    L1 = newLabel();
                    backpatch(code,$2.listTrue_root,L);
                    backpatch(code,$2.listFalse_root,L);
                    $$.listNext_root = combinar($4.listNext_root,$8.listNext_root);
                }
                | MIENTRAS SL expresion_booleana HACER SL sentencias SL FIN {
                    L = newLabel();
                    L1 = newLabel();
                    backpatch(code,$6.listNext_root,L);
                    backpatch(code,$3.listTrue_root,L);
                    $$.listNext_root = $3.listFalse_root;
                    addQuadToCode(code,"goto","","",L);

                    L = newLabel();
                    backpatch(code,$3.listTrue_root,L);
                    backpatch(code,$6.listNext_root,L1);
                    $$.listNext_root = $3.listFalse_root;
                    addQuadToCode(code,"label","","",L);

                }
                | HACER SL sentencias SL MIENTRAS QUE expresion_booleana {
                    L = newLabel();
                    L1 = newLabel();
                    backpatch(code,$3.listNext_root,L);
                    backpatch(code,$7.listTrue_root,L);
                    $$.listNext_root = $7.listFalse_root;
                    addQuadToCode(code,"goto","","",L);

                    L = newLabel();
                    backpatch(code,$7.listTrue_root,L);
                    backpatch(code,$3.listNext_root,L1);
                    $$.listNext_root = $7.listFalse_root;
                    addQuadToCode(code,"label","","",L);

                }



                | ID ASIGN expresion {

                    symtab* topSymTab = getTopSymStack(StackST);
                    if(findIdInSymtab(topSymTab, $1.id) == -1) {
                        int t = getTipoFromSymtab(topSymTab, $1.id);
                        int d = getDirFromSymtab(topSymTab, $1.id);
                        int a = reducir($3.dir, $3.tipo,t);
                        char *dString;
                        sprintf(dString,"%d",d);
                        addQuadToCode(code, "=",a,"",strcat("Id",dString));
                    }
                    else{
                    printf("El identificador no ha sido declarado");
                }
                $$.listNext_root = NULL;
            }



                | variable ASIGN expresion {
                    int a = reducir($3.dir , $3.tipo, $1.tipo);
                    char *base;
                    sprintf(base,"%d",$1.base)
                    addQuadToCode(code, "=",a,"",base);
                    $$.listNext_root = NULL;
                }
                | ESCRIBIR expresion {
                    addQuadToCode(code,"print",$2.dir,"","");
                    $$.listNext_root = NULL;
                }
                | LEER variable {
                    addQuadToCode(code,"scan",$2.dir,"","");
                    $$.listNext_root = NULL;
                }

                | DEVOLVER {
                    if(FuncType == SIN){
                        addQuadToCode(code,"return","","","");
                    }
                    else{
                        printf("La función debe retornar algún valor de tipo : %d\n",FuncType);
                    }
                    $$.listNext_root = NULL;
                }

                | DEVOLVER expresion {
                    if(FuncType != SIN){
                        int a = reducir($2.dir, $2.tipo,FuncType);
                        addQuadToCode(code,"return",$2.dir,"","");
                        FuncReturn = TRUE;
                    }
                    else{
                        printf("La función no puede retornar algún valor de tipo");
                    }
                    $$.listNext_root = NULL;
                }
                | TERMINAR {
                    I = newIndex();
                    char *Istring;
                    sprintf(Istring,"%d",I);
                    addQuadToCode(code,"goto","","",Istring);
                    $$.listNext_root = newList();
                    addInstructionToList($$.listNext_root,I);
                };

/*
    En lo que sigue se convierten siempre los enteros en cadenas char * para
    usar el backpatch, ya que solo usa cadenas como parametros.
    Lo conversion se hace mediante sprintf
*/

    expresion_booleana : expresion_booleana OR expresion_booleana {
            L = newLabel();
            backpatch(code,$1.listFalse_root,L);
            $$.listTrue_root = combinar($1.listTrue_root, $3.listTrue_root);
            $$.listFalse_root = $3.listFalse_root;
            char *Lstring;
            sprintf(Lstring,"%d",L);
            addQuadToCode(code,"label","","",Lstring);
    }
                    | expresion_booleana AND expresion_booleana {
                        L = newLabel();
                        backpatch(code,$1.listTrue_root,L);
                        $$.listTrue_root = $3.listFalse_root;
                        $$.listFalse_root = combinar($1.listFalse_root, $3.listFalse_root);
                        char *Lstring;
                        sprintf(Lstring,"%d",L);
                        addQuadToCode(code,"label","","",Lstring);
                    }
                    | NO expresion_booleana {
                        $$.listTrue_root = $2.listFalse_root;
                        $$.listFalse_root = $2.listTrue_root;
                    }
                    | relacional {
                        $$.listTrue_root = $1.listTrue_root;
                        $$.listFalse_root = $1.listFalse_root;
                    }
                    | TRUE {
                        I = newIndex();
                        $$.listTrue_root = newList();
                        addInstructionToList($$.listTrue_root,I);
                        char *Istring;
                        sprintf(Istring,"%d",I);
                        addQuadToCode(code,"goto","","",Istring);
                    }
                    | FALSE {
                        I = newIndex();
                        $$.listTrue_root = NULL;
                        $$.listFalse_root = newList();
                        addInstructionToList($$.listFalse_root,I);
                        char *Istring;
                        sprintf(Istring,"%d",I);
                        addQuadToCode(code,"goto","","",Istring);
                    };


    relacional : relacional MENOR relacional {
        $$.listTrue_root = newList();
        $$.listFalse_root = newList();
        I = newIndex();
        I1 = newIndex();
        addInstructionToList($$.listTrue_root,I);
        addInstructionToList($$.listFalse_root, I1);
        $$.tipo = max($1.tipo, $3.tipo);
        int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
        int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

        char *Istring;
        sprintf(Istring,"%d",I);

        char *I1string;
        sprintf(I1string,"%d",I1);

        char *a1string;
        sprintf(a1string,"%d",a1);
        char *a2string;
        sprintf(a2string,"%d",a2);

        addQuadToCode(code,"<",a1,a2,Istring);
        addQuadToCode(code,"goto","","",I1string);
    }
            | relacional MAYOR relacional {
                $$.listTrue_root = newList();
                $$.listFalse_root = newList();
                I = newIndex();
                I1 = newIndex();
                addInstructionToList($$.listTrue_root,I);
                addInstructionToList($$.listFalse_root, I1);
                $$.tipo = max($1.tipo, $3.tipo);
                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *Istring;
                sprintf(Istring,"%d",I);

                char *I1string;
                sprintf(I1string,"%d",I1);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,">",a1,a2,Istring);
                addQuadToCode(code,"goto","","",I1string);
            }
            | relacional MENOR_IG relacional {
                $$.listTrue_root = newList();
                $$.listFalse_root = newList();
                I = newIndex();
                I1 = newIndex();
                addInstructionToList($$.listTrue_root,I);
                addInstructionToList($$.listFalse_root, I1);
                $$.tipo = max($1.tipo, $3.tipo);
                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *Istring;
                sprintf(Istring,"%d",I);

                char *I1string;
                sprintf(I1string,"%d",I1);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"<=",a1,a2,Istring);
                addQuadToCode(code,"goto","","",I1string);
            }
            | relacional MAYOR_IG relacional {
                $$.listTrue_root = newList();
                $$.listFalse_root = newList();
                I = newIndex();
                I1 = newIndex();
                addInstructionToList($$.listTrue_root,I);
                addInstructionToList($$.listFalse_root, I1);
                $$.tipo = max($1.tipo, $3.tipo);
                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *Istring;
                sprintf(Istring,"%d",I);

                char *I1string;
                sprintf(I1string,"%d",I1);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"<",a1,a2,Istring);
                addQuadToCode(code,"goto","","",I1string);
            }
            | relacional IGUAL relacional {
                $$.listTrue_root = newList();
                $$.listFalse_root = newList();
                I = newIndex();
                I1 = newIndex();
                addInstructionToList($$.listTrue_root,I);
                addInstructionToList($$.listFalse_root, I1);
                $$.tipo = max($1.tipo, $3.tipo);
                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *Istring;
                sprintf(Istring,"%d",I);

                char *I1string;
                sprintf(I1string,"%d",I1);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"==",a1,a2,Istring);
                addQuadToCode(code,"goto","","",I1string);
            }
            | relacional DIF relacional {
                $$.listTrue_root = newList();
                $$.listFalse_root = newList();
                I = newIndex();
                I1 = newIndex();
                addInstructionToList($$.listTrue_root,I);
                addInstructionToList($$.listFalse_root, I1);
                $$.tipo = max($1.tipo, $3.tipo);
                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *Istring;
                sprintf(Istring,"%d",I);

                char *I1string;
                sprintf(I1string,"%d",I1);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"<>",a1,a2,Istring);
                addQuadToCode(code,"goto","","",I1string);
            }
            | expresion {
                    $$.tipo = $1.tipo;
                    $$.dir = $1.dir;
            };


    expresion : expresion MAS expresion {
        $$.tipo = max($1.tipo,$3.tipo);
        $$.dir = newTemp();

        int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
        int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

        char *a1string;
        sprintf(a1string,"%d",a1);
        char *a2string;
        sprintf(a2string,"%d",a2);

        addQuadToCode(code,"+",a1string,a2string,$$.dir);

    }
            | expresion MENOS expresion {
                $$.tipo = max($1.tipo,$3.tipo);
                $$.dir = newTemp();

                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"-",a1string,a2string,$$.dir);
            }
            | expresion MUL expresion {
                $$.tipo = max($1.tipo,$3.tipo);
                $$.dir = newTemp();

                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"*",a1string,a2string,$$.dir);
            }
            | expresion DIV expresion {
                $$.tipo = max($1.tipo,$3.tipo);
                $$.dir = newTemp();

                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"/",a1string,a2string,$$.dir);
            }
            | expresion MOD expresion {
                $$.tipo = max($1.tipo,$3.tipo);
                $$.dir = newTemp();

                int a1 = ampliar($1.dir, $1.tipo, $3.tipo);
                int a2 = ampliar($3.dir,$3.tipo,$$.tipo);

                char *a1string;
                sprintf(a1string,"%d",a1);
                char *a2string;
                sprintf(a2string,"%d",a2);

                addQuadToCode(code,"%",a1string,a2string,$$.dir);
            }

            | PAR_I expresion PAR_D {
                $$.dir = $2.dir;
                $$.tipo = $2.tipo;

            }
            | variable {
                $$.dir = newTemp();
                $$.tipo = $1.tipo;

                char* base;
                sprintf(base,"%d",variable.base);
                addQuadToCode(code,"*",base,"",$$.dir);
            }

            | NUM { // initializar los atributos de num
                $$.tipo = NUM.tipo;
                if(NUM.tipo == ENT){
                    $$.val = NUM.val.ival;
                }
                else{
                    $$.val = NUM.val.fval;
                }
            }

            | CADENA {
                $$.tipo = CADENA;
                $$.dir = addStringToStringTable(StringTable,CADENA.id)
            }

            | CARACTER {
                $$.tipo = CARACTER;
                $$.dir = addStringToStringTable(StringTable,CARACTER.id)
            }

            | ID PAR_I parametros PAR_D {

                symtab* rootSymTab = getRootSymStack(StackST);

                if(findIdInSymtab(rootSymTab, $1.id) != -1) {
                    if(getTipoVarFromSymtab(rootSymTab,$1.id) == TIPO_VAR_FUNC){
                        lista = getListParamFromSymtab(rootSymTab, $1.id);
                        if(getNumListParam(lista) != getNumListParam($3.lista)){
                            printf("El numero de argumentos no coincide \n");
                        }

                        listParam *listGived = $3.lista;
                        param *givedParam = listGived->root;
                        param *expectedParam = lista->root;

                        for (int i=0;i<getNumListParam($3.lista);i++){
                            if(givedParam->tipo != expectedParam->tipo){
                                printf("El tipo de los parametros no coindide\n");
                            }
                            else{
                                givedParam = givedParam->next;
                                expectedParam = expectedParam ->next;
                            }

                        }
                        $$.dir = newTemp();
                        $$.tipo = getTipoFromSymtab(rootSymTab,$1.id);

                        char *dirString;
                        sprintf(dirString,"%d",$$.dir);
                        addQuadToCode(code,"=","call",$1.id,dirString);

                    }
                    else{
                        printf("El identificador no ha sido declarado\n");
                    }
                }
            };

    variable : arreglo {

        $$.dir = $1.dir;
        $$.base = $1.base;
        $$.tipo = $1.tipo;
    }

            | ID PUNTO ID {

                symtab* rootSymTab = getRootSymStack(StackST);
                typetab* rootTypeTab = getRootTypeStack(StackTT);

                if(findIdInSymtab(rootSymTab, $1.id) != -1) {
                    int t = getTipoFromSymtab(rootSymTab, $1.id);
                    char *t1;
                    int id =
                    strcpy(t1, getNombreFromTypeTab(rootTypeTab, t));

                    if(strcmp(t1,"registro") == 0){
                        tipoBase tb = getTipoBaseFromTypeTab(rootTypeTab,t);
                        if(tb->t->type != -1){
                            $$.tipo = tb->t->type;
                            $$.dir = $3;
                            $$.base = $1;
                        }
                        else{
                            printf("el id no existe en la estructura\n");
                        }
                    }
                    else{
                        printf("El id no es una estructura\n");
                    }
                }
                else{
                    printf("El identificador no ha sido declarado");
                }
            };


    arreglo : ID LLAVE_I expresion LLAVE_D {
        symtab* topSymTab = getTopSymStack(StackST);
        typetab* topTypeTab = getTopTypeStack(StackTT);

        if(findIdInSymtab(topSymTab, $1.id) != -1){
            int t = getTipoFromSymtab(topSymTab,$1.id);
            char *name;
            strcpy(name, getNombreFromTypeTab(rootTypeTab,$1.id));
            if(strcmp(name,"array") == 0) {
                if($3.tipo = ENT){
                    $$.base = $1.id;
                    $$.tipo = getTipoBaseFromTypeTab(t)->t->type;
                    $$.tam = getTamOfTypeFromTypeTab(rootTypeTab,t);
                    $$.dir = newTemp();

                    char *dirString;
                    char *tamString;
                    char *dirArrString;

                    sprintf(dirString,"%d",$3.dir);
                    sprintf(tamString,"%d",$$.tam);
                    sprintf(dirArrString,"%d",$$.dir);
                    addQuadToCode(code,"*",dirString,tamString,dirArrString);
                }
                else{
                    printf("La expresión para un ı́ndice debe ser de tipo entero");
                }
            }
            else{
                printf("El identificador no es un arreglo");
            }
        }
    else{
        printf("El idendificador no ha sido declarado");
    }

}
            | arreglo LLAVE_I expresion LLAVE_D {
                typetab* topTypeTab = getTopTypeStack(StackTT);
                char *nombre;
                strcpy(nombre,getNombreFromTypeTab(topTypeTab,$1.tipo));
                if(strcmp(nombre,"array") == 0){
                    if($3.tipo == $1.base){
                        $$.base = $1.base;
                        $$.tipo = getTipoBaseFromTypeTab(rootTypeTab,$1.tipo)->tipo->type;
                        $$.tam = getTamOfTypeFromTypeTab(rootTypeTab,$1.tipo);

                        int temp = newTemp();
                        $$.dir = newTemp();

                        char *dirExpr;
                        char *tamArr;
                        char *tempStr;
                        char *dirArr1;
                        char *dirArr;

                        sprintf(dirExpr,"%d",$3.dir);
                        sprintf(tamArr,"%d",$$.tam);
                        sprintf(tempStr,"%d"temp);

                        addQuadToCode(code,"*",dirExpr,tamArr,tempStr);

                        sprintf(dirArr1,"%d",$1.dir);
                        sprintf(dirArr,"%d",$$.dir);

                        addQuadToCode(code,"+",dirArr1,tempStr,dirArr;
                    }
                    else{
                        printf("La expresión para un ı́ndice debe ser de tipo entero");
                    }
                }
                else{
                    printf("El arreglo no tiene tantas dimensiones");
                }
            };



    parametros : lista_param { $$.lista = $1.lista;}
            | {$$.lista = NULL;};


    lista_param : lista_param COMA expresion {
        $$.lista = $1.lista;
        addTipoInListparam($$.lista, $3.tipo);

        char* dirStr;
        sprintf(dirStr,"%d",$3.dir);
        addQuadToCode(code,"param",dirStr,"","");
    }
                |expresion {
                    $$.lista = newList();
                    addTipoInListparam($$.lista,$1.tipo);

                    char* dirStr;
                    sprintf(dirStr,"%d",$1.dir);
                    addQuadToCode(code,"param",dirStr,"","");
                };

%%
void yyerror(char *s)
{
    printf("ERR %s\n", s);
}
