#ifndef QUADRUPLES
#define QUADRUPLES


typedef struct _quad quad;
struct _quad{
    char op[32];
    char arg1[32];
    char arg2[32];
    char res[32];
    quad *next;
};

typedef struct _code code;
struct _code{
    quad *root;
    int num_instructions;
};

quad* create_quad(char *op, char* arg1, char *arg2, char *res);

void deleteQuad(quad *q);

code *createCode();

void deleteCode(code *c);

void addQuadToCode(code *c, char *op, char *arg1, char *arg2, char* res);


#endif
