#ifndef __NODE_H__
#define __NODE_H__

struct node;
enum ntype {
    VALUE_INVALID,                                
    NODE_term,    //44
    NODE_PROGRAM,    //45                 
    NODE_STAT, //46
    NODE_LT, //47
    NODE_GE, //48
    NODE_GT, //49
    NODE_LE, //50
    NODE_EQUAL, //51
    NODE_notEQUAL, //52
    NODE_THEN,//53
    NODE_variable, //54
    NODE_PARAMETER, //55
    NODE_ARG, //56
    NODE_SUB, //57
    NODE_lambda, //58
    NODE_ID_LIST, //59
    NODE_SUB_PRO_declas, //60
    NODE_SUB_PRO,//61
    NODE_PLUS, //1
    NODE_MINUS,//2
    NODE_STAR, //3
    NODE_SLASH,//4
    NODE_REALNUMBER, //6
    NODE_DIGSEQ, //5
    NODE_VAR, //7
    NODE_integer, //8
    NODE_real, //9
    NODE_STRING,//10
    NODE_ID, //11
    NODE_factor,//12
    NODE_NOT, //13
    NODE_LP, //14
    NODE_RP, //15
    NODE_SMP, //16
    NODE_EXP, //17
    NODE_EXP_LIST, //18
    NODE_COMMA, //19
    NODE_LB, //20
    NODE_RB, //21
    NODE_tail, //22
    NODE_WHILE, //23
    NODE_DO, //24
    NODE_IF, //25
    NODE_ELSE, //26
    NODE_COM, //27
    NODE_Pro, //28
    NODE_ASSIGNMENT, //29
    NODE_STAT_LIST, //30
    NODE_SEMI, //31
    NODE_OPT, //32
    NODE_BEGIN, //33
    NODE_END, //34
    NODE_COLON, //35
    NODE_PROCEDURE, //36
    NODE_FUNCTION, //37
    NODE_STAN, //38
    NODE_ARRAY, //39
    NODE_DOTDOT, //40
    NODE_OF, //41
    NODE_TYPE,//42
    NODE_DOT//43
};

// #include "symtab.h"
struct node {
    int nodeType;
    struct node *parent;
    struct node *child;
    struct node *lsibling;
    struct node *rsibling;

    /* Attribute for NODE_TOKEN */
    int tokenType;

    /* items for Array */
    int idxstart;
    int idxend;
    int arraydepth;
    struct node *ref;

    /* Values for general use */
    int iValue;
    double rValue;
    char valueValid;
    char *string;
    
    /* Indicates which OP */
    char op;

};

struct node* newNode(int type);
void deleteNode(struct node* node);
void addChild(struct node *node, struct node *child);
void printTree(struct node *node, int ident);

#endif

