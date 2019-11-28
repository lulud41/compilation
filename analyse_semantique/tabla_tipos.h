#ifndef TABLA_TIPOS
#define TABLA_TIPOS



typedef struct _type type;
typedef struct _tipoBase tipoBase;
typedef union _tipo tipo;



union _tipo{
    int type;  //Tipo simple
    symtab *estructura;  //Tipo estructura
};

struct _tipoBase{
    bool est;  //Si es verdadero es estructura sino es tipo simple
    tipo* t;
};

struct _type{
    int id;
    char nombre[10];//se puede sustituir por un entero tambien
    tipoBase* tb;
    int tamBytes;
    int numElem;
    type *next;
};

typedef struct _typetab typetab;
struct _typetab{
    type* root;
    int num;
    typetab* next;
};

typedef struct _typestack typestack;
struct _typestack{
        typetab* root;
        int num;
};

tipo* crearTipo();

void borrarTipo(tipo *t);

type* crearType(int id, char nombre[], tipoBase *tb,int tamBytes,int numElem);

void borrarType(type* Type);

void borrarTipoBase(tipoBase* tb);

typetab* crearTypeTab();

void borrarTypeTab();

int insertarTypeInTypeTab(typetab* tt,type* t);

tipoBase* crearTipoBase(tipo *tipo, bool est);

type* getTypeFromTypeTable(typetab * tt, int id);

tipoBase* getTipoBaseFromTypeTab(typetab *tt,int id);

int getTamBaseFromTypeTab(typetab *tt,int id);

int getNumElemFromTypeTab(typetab *tt,int id);

char* getNombreFromTypeTab(typetab* tt,int id);

typestack *crearTypeStack();

void borrarTypeStack(typestack* ts);

void insertarTypeTabInTypeStack(typestack *ts,typetab *tt);

typetab* getCimaTypeStack(typestack *ts);

typetab* sacarTypeTab(typestack *ts);

#endif
