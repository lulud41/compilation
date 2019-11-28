#ifndef TABLA_SIMBOLOS
#define TABLA_SIMBOLOS

typedef struct _param param;
struct _param{
    int tipo;
    param *next;
};

typedef struct _listParam listParam;
struct _listParam{
    param *root;
    int num;
};

typedef struct _symbol symbol;
struct _symbol{
    char id[32];
    int tipo;
    int dir;
    int tipoVar;
    listParam *params;
    symbol *next;
};

typedef struct _symtab symtab;
struct _symtab{
    symbol *root;
    int num;
    symtab *next;
};

typedef struct _symstack symstack;
struct _symstack{
    symtab* root;
    int num;
};


param* crearParam(int tipo);

void borarParam(param *p);

listParam* crearLP();

void addTipoInListparam(listParam *lp, int tipo);

void borrarListParam(listParam *lp);

int getNumListParam(listParam *lp);

symbol *crearSymbol();

void borarSymbol(symbol *s);

symtab* crearSymTab();

void borarSymTab(symtab *st);

int insertarSymbolInSymtab(symtab *st, symbol *sym);

int buscarIdInSymtab(symtab *st, char *id);

symbol* getSymbolFromSymTab(symtab* st,int pos);

int getTipoFromSymtab(symtab *st, char *id);

int getTipoVarFromSymtab(symtab *st, char *id);

int getDirFromSymtab(symtab *st, char *id);

listParam* getListParamFromSymtab(symtab *st,char *id);

int getNumParamFromSymtab(symtab *st, char *id);

symstack* crearSymStack();

void borrarSymStack(symstack *ss);

void insertarSymTabInSymStack(symstack *ss, symtab *st);

symtab* getCimaSymstack(symstack *ss);

symtab* sacarSymTab(symstack *ss);

#endif
