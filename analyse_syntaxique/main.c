/*
DEROUET
Lucien Emile

Compiladores practica 4

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern FILE* yyin;

// compilar con : lex expresiones.l
//gcc -o lexer lex.yy.c connexion.c -lfl

#define TERM 1
#define NON_TERM 2
#define EPSILON 3

#define NUM_NO_TERM 5
#define NUM_TERM 9

extern int yylex();
extern char *yytext;

typedef struct _symbol{
    short type;
    char name[15];
    int pos;
}sym;

typedef struct _production{
    int head;
    char body[40];
    int num;
}prod;

typedef struct _node node;
struct _node{
    sym info;
    node *next;
};

typedef struct _stack{
    node *root;
    int num;
}stack;

char terminales[NUM_TERM][2]  = {"+","-","*","/","%",")","(","n","$"};

char noTerminales[NUM_NO_TERM][3] = {"E","E'","F","F'","G"};
char tockens_name[NUM_TERM][20] = {"OPERADOR","OPERADOR","OPERADOR",
"OPERADOR","OPERADOR","Parentesis1","Parentesis2","NUM","$"};

sym symbols[NUM_TERM+NUM_NO_TERM+1]; // 9 terminales, 5 no terminales + EPSILON

prod productions[11];  // arreglo que contiene las producciones

int LL1_matrix[NUM_NO_TERM][NUM_TERM]; //tabla LL1

// Funcion para generar todos los simbolos
// Index : 0 hasta 8 : terminales ; 9 à 13 no terminales ; 14 epsilon
void initSimbols(sym symArray[]){
    // init terminales
    for (int i=0;i<NUM_TERM;i++){
        symArray[i].type = TERM;
        strcpy(symArray[i].name,terminales[i]);
        symArray[i].pos = i;
    }
    //init no terminales
    for (int i=NUM_TERM;i<NUM_TERM+NUM_NO_TERM;i++){
        symArray[i].type = NON_TERM;
        strcpy(symArray[i].name,noTerminales[i- NUM_TERM ]);
        symArray[i].pos = i;
    }
    //epsilon
    symArray[NUM_NO_TERM+NUM_TERM].type = EPSILON;
    strcpy(symArray[NUM_NO_TERM+NUM_TERM].name, "EPSILON");
    symArray[NUM_NO_TERM+NUM_TERM].pos = NUM_NO_TERM+NUM_TERM;
    //pintar el arreglo
    printf("Simbolos : \n");
    for (int i=0;i<NUM_TERM+NUM_NO_TERM+1;i++){
        printf("sym %d = %s\n",i,symArray[i].name );
    }
    printf("\n");
}
// Funcion para generar todas las producciones
void initProductions(prod prodArray[]){
    // arreglo que representa la gramatica, con referencia hacia el numero del simbolo
    char grammar[11][40] = {"11 10 ", //E -> FE'
                            "0 11 10 ", "1 11 10 ", "14 ",  //E'-> +FE'  E' -> -FE'   E' -> epsilon
                            "13 12 ", //F -> GF'
                            "2 13 12 ", "3 13 12 ", "4 13 12 ","14 ",  //F'-> *GF'   F'-> /GF'  F'-> %GF'   F'-> epsilon
                            "5 9 6 ", "7 "};   // G -> (E)    G-> num

    int head[11] = {9,10,10,10,11,12,12,12,12,13,13};
    int numSymbols[11] = {2,3,3,1,2,3,3,3,1,3,1};   // quantidad de simbolos en la produccion

    for (int i=0;i<11;i++){
        prodArray[i].head = head[i];
        strcpy(prodArray[i].body,grammar[i]);
        prodArray[i].num = numSymbols[i];
    }
    //pintar las producciones
    printf("producciones : \n");
    for (int i=0;i<11;i++){
        printf("%d : %d -> %s n = %d\n",i,prodArray[i].head,prodArray[i].body, prodArray[i].num);
    }
    printf("\n");
}
// Funcion para generar la tabla LL1
void initMatrix(int matrix[NUM_NO_TERM][NUM_TERM], prod productions[]){
    for (int i=0;i<NUM_NO_TERM;i++){
        for (int j=0;j<NUM_TERM;j++){
            matrix[i][j] = 99;   //casillas vacias
        }
    }

    matrix[0][5] = 0;
    matrix[0][7] = 0;

    matrix[1][0] = 1;
    matrix[1][1] = 2;
    matrix[1][8] = 3;
    matrix[1][6] = 3;

    matrix[2][5] = 4;
    matrix[2][7] = 4;

    matrix[3][0] = 3;
    matrix[3][1] = 3;
    matrix[3][2] = 5;
    matrix[3][3] = 6;
    matrix[3][4] = 7;
    matrix[3][6] = 3;
    matrix[3][8] = 3;

    matrix[4][5] = 9;
    matrix[4][7] = 10;
}
// Funcion para pintar el token actual en forma : < TipoToken , token >
{
void printToken(char * token,int claseToken){
    char * salida = (char *) malloc(1 + strlen("<")+ strlen(tockens_name[claseToken]) );

    strcpy(salida, "<");
    strcat(salida, tockens_name[claseToken]);   // <tockens_name[claseToken]

    salida = (char *) realloc(salida, 1+strlen(salida)+strlen(" , "));
    strcat(salida," , ");

    salida = (char *) realloc(salida,1+strlen(salida)+strlen(token));
    strcat(salida, token);

    salida = (char *) realloc(salida,1+strlen(salida)+strlen(" >"));
    strcat(salida," >");

    printf("%s\n", salida);
}
//Funcion para pintar el contenido de la pila, de forma Root -> Nodo1 -> [...]
void printStack(stack *pila){
    node *currentNode = malloc(sizeof(node));
    currentNode = pila->root;
    printf("Pila : %s",pila->root->info.name );

    do{
        if(currentNode->next != NULL){
            currentNode = currentNode->next;
            printf(" %s", currentNode->info.name);
        }
    }while(currentNode-> next != NULL);
    printf("\n");
}
//Funcion para obtener el ultimo nodo de la pila
node* getLastElement(stack *pila){
    node *currentNode = malloc(sizeof(node));
    currentNode = pila->root;
    while (currentNode->next != NULL){
        currentNode = currentNode->next;
    }
    return currentNode;
}
//Funcion para suprimir el ultimo elemento
void popLastElement(stack *pila){
    int index = pila->num;
    node *currentNode = pila->root;

    if(index == 1){
        free(pila->root->next);
        pila->root->next = NULL;
        pila->num-=1;
    }
    else if(index >= 2){
        for (int i=0;i<index-1;i++){
            currentNode = currentNode->next;
        }
        free(currentNode->next);
        currentNode->next = NULL;
        pila->num -=1;
    }
}
//Funcion para anadir el contenido de una produccion en cima de la pila
void addProduction(stack *pila, prod new_production){

    char new_production_body[20];

    strcpy(new_production_body,new_production.body);
    char simbol[3] = "";

    int nb_of_simbols  = new_production.num;

    int result[nb_of_simbols];
    int index=0;
    int j=0;
    // extraer los numeros de simbolos de la cadena
    for (int i=0;i<nb_of_simbols;i++){
        while(new_production_body[index] != ' '){
            simbol[j] = new_production_body[index];
            index++;
            j++;
        }

        result[i] = atoi(simbol);
        char simbol[3]="";
        j=0;
        if(new_production_body[index] == ' '){
            index++;
        }
    }
    if(result[0] == 14){
        popLastElement(pila);
        node* lastElement = getLastElement(pila);
        return;
    }
    popLastElement(pila);
    // anadir el contenido de la produccion
    for (int i=nb_of_simbols-1;i>=0;i--){

        node *new_node = malloc(sizeof(node));
        new_node->info = symbols[result[i]];
        new_node->next = NULL;

        node* lastElement = getLastElement(pila);

        lastElement->next = new_node;
        pila->num ++;
    }
}
// Funcion para initializar la pila, con $ -> E
stack* initPila(){

    node *root_node = malloc(sizeof(node));
    root_node->info = symbols[NUM_TERM-1]; // -> $
    root_node->next = NULL;

    stack *pila = malloc(sizeof(stack));
    pila->root = root_node;
    pila->num = 0;  //nbr de node en plus de la root

    node *node1 = malloc(sizeof(node));
    node1->info = symbols[NUM_TERM]; // -> E
    node1->next = NULL;

    pila->root->next = node1;
    pila->num=1;
    printStack(pila);

    return pila;
}

int main(){

    initSimbols(symbols);
    initProductions(productions);
    initMatrix(LL1_matrix,productions);

    stack *pila = initPila();

    yyin = fopen("entrada","r");

    int iteration = 0;

    if(yyin != NULL){

        int claseToken;
        claseToken = yylex();
        char *token = strdup(yytext);
        node* lastElement=NULL;

        printToken(token,claseToken);
        // algoritmo :
        while (getLastElement(pila)->info.pos != NUM_TERM-1 )// NUM_TERM -1 : numero del simbolo $
        {
            printf("\niteration %d\n",iteration );
            lastElement = getLastElement(pila);
            printStack(pila);

            // si el token no es reconocido
            if(claseToken == -1){
                printf("Error lexico : token %s no reconocido \n",token);
                return -1;
            }
            // Si X == un terminal
            if(lastElement->info.pos == claseToken){
                printf("\nX = terminal -> next token\n" );
                popLastElement(pila);
                claseToken = yylex();
                char *token = strdup(yytext);
                printToken(token,claseToken);
                iteration++;
            }
            // error de sintaxis
            else if(lastElement->info.pos < (NUM_TERM-1) && lastElement->info.pos != claseToken){
                printf("Syntax error \n");
                return -1;
            }
            //si una production existe para el simbolo
            else if(LL1_matrix[lastElement->info.pos - NUM_TERM][claseToken] != 99){
                int id_new_production = LL1_matrix[lastElement->info.pos - NUM_TERM][claseToken];
                prod new_production = productions[id_new_production];

                addProduction(pila, new_production);
                iteration++;
            }
            // si no hay produccion para el simbolo : error
            else if(LL1_matrix[lastElement->info.pos - NUM_TERM][claseToken] == 99){
                printStack(pila);
                printf("Syntax error\n" );
                return -1;
            }
        }
        if (claseToken == NUM_TERM-1){
            printf("\niteration %d\n",iteration++ );
            printStack(pila);
            printf("\nLa cadena es correcta !\n");
            return 0;
        }
        else{
            printf("Syntax error 3\n" );
            return -1;
        }
    }
}
