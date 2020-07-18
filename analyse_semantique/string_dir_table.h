#ifndef STRING_DIR_TABLE
#define STRING_DIR_TABLE


typedef struct _stringTable stringTable;
struct _stringTable{
    char *str;
    stringTable* next;
};

stringTable* createStringTable();

int addStringToStringTable(stringTable* strTab, char * string);

typedef struct _stackDir stackDir;
struct _stackDir{
    int dir;
    stackDir *next;
};

stackDir* createStackDir();

void stackDirPush(stackDir* sd, int dir);

int stackDirPop(stackDir* sd);

#endif
