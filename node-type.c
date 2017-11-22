#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "node-type.h"

struct node* newNode(int type) {
    struct node *node = (struct node*)malloc(sizeof(struct node));
    node->nodeType = type;
    node->valueValid = VALUE_INVALID;
    node->string = NULL;
    node->parent = NULL;
    node->child = NULL;
    node->lsibling = node;
    node->rsibling = node;
    return node;
}

void addChild(struct node *node, struct node *child) {
    child->parent = node;

    if(node->child == NULL) {
        node->child = child;
    }
    else {
        child->lsibling = node->child->lsibling;
        child->rsibling = node->child;
        node->child->lsibling->rsibling = child;
        node->child->lsibling = child;
    }
}

void deleteNode(struct node *node) {
    if(node->string != NULL)
        free(node->string);
    free(node);
}

void printTree(struct node *node, int ident) {
    static char blank[1024];
    for(int i=0; i<ident; i++)
        blank[i] = ' ';
    blank[ident] = 0;

    switch(node->nodeType) {
        case NODE_PLUS://1
            printf("%s+\n" , blank);
            ident += 8;            
            break;
        case NODE_MINUS://2
            printf("%s-\n" , blank);
            ident += 8;            
            break;
        case NODE_STAR://3
            printf("%s*\n" , blank);
            ident += 8;            
            break;
        case NODE_SLASH://4
            printf("%s/\n" , blank);
            ident += 8;            
            break;
        case NODE_DIGSEQ://5
            printf("%s%d\n", blank, node->iValue);
            ident += 8;
            break;
        case NODE_REALNUMBER: //6
            printf("%s%g\n", blank, node->rValue);
            ident += 8;
            break;
        case NODE_VAR:  //7
            printf("%sVAR\n", blank);
            ident += 8;
            break;
        case NODE_integer://8
            printf("%sinteger\n", blank);
            ident += 8;
            break;
        case NODE_real://9
            printf("%sreal\n", blank);
            ident += 8;
            break;
        case NODE_STRING://10
            printf("%sstring\n", blank);
            ident += 8;
            break;
        case NODE_ID://11
            printf("%s%s\n" , blank , node->string);
            ident += 8;
            break;
        case NODE_factor://12
            printf("%s/factor\n", blank);
            ident += 8;
            break;
        case NODE_NOT://13
            printf("%sNOT\n", blank);
            ident += 8;
            break;
        case NODE_LP://14
            printf("%s(\n", blank);
            ident += 8;
            break;
        case NODE_RP://15
            printf("%s)\n", blank);
            ident += 8;
            break;
        case NODE_SMP://16
            printf("%s/simple expression \n", blank);
            ident += 8;
            break;
        case NODE_EXP://17
            printf("%s/expression \n", blank);
            ident += 8;
            break;
        case NODE_EXP_LIST://18
            printf("%s/expression_list\n", blank);
            ident += 8;
            break;
        case NODE_COMMA://19
            printf("%s,\n", blank);
            ident += 8;
            break;
        case NODE_LB://20
            printf("%s[\n", blank);
            ident += 8;
            break;
        case NODE_RB://21
            printf("%s]\n", blank);
            ident += 8;
            break;
        case NODE_tail://22
            printf("%s/tail\n", blank);
            ident += 8;
            break;
        case NODE_WHILE://23
            printf("%sWHILE\n", blank);
            ident += 8;
            break;
        case NODE_DO://24
            printf("%sDO\n", blank);
            ident += 8;
            break;
        case NODE_IF://25
            printf("%sIF\n", blank);
            ident += 8;
            break;
        case NODE_ELSE://26
            printf("%sELSE\n", blank);
            ident += 8;
            break;
        case NODE_COM://27
            printf("%s/compound_statement\n", blank);
            ident += 8;
            break;
        case NODE_Pro://28
            printf("%s/procedure_statement\n", blank);
            ident += 8;
            break;
        case NODE_ASSIGNMENT://29
            printf("%s:=\n", blank);
            ident += 8;
            break;
        case NODE_STAT_LIST://30
            printf("%s/statement_list\n", blank);
            ident += 8;
            break;
        case NODE_SEMI://31
            printf("%s;\n", blank);
            ident += 8;
            break;
        case NODE_OPT://32
            printf("%s/optional_statements\n", blank);
            ident += 8;
            break;
        case NODE_BEGIN://33
            printf("%sBEGIN\n", blank);
            ident += 8;
            break;
        case NODE_END://34
            printf("%sEND\n", blank);
            ident += 8;
            break;
        case NODE_COLON: //35
            printf("%s:\n", blank);
            ident += 8;
            break;
        case NODE_PROCEDURE://36
            printf("%sPROCEDURE\n", blank);
            ident += 8;
            break;
        case NODE_FUNCTION://37
            printf("%sFUNCTION\n", blank);
            ident += 8;
            break;
        case NODE_STAN://38
            printf("%s/standard_type\n", blank);
            ident += 8;
            break;
        case NODE_ARRAY://39
            printf("%sARRAY\n", blank);
            ident += 8;
            break;
        case NODE_DOTDOT://40
            printf("%s../n", blank);
            ident += 8;
            break;
        case NODE_OF://41
            printf("%sOF\n", blank);
            ident += 8;
            break;
        case NODE_TYPE://42
            printf("%s/type\n", blank);
            ident += 8;
            break;
        case NODE_DOT://43
            printf("%s.\n", blank);
            ident += 8;
            break;
        case NODE_term://44
            printf("%s/term\n", blank);
            ident += 8;
            break;
        case NODE_PROGRAM://45
            printf("%s PROGRAM\n", blank);
            ident += 8;
            break;
        case NODE_STAT://46
            printf("%s/statement\n" , blank);
            ident += 8;
            break;
        case NODE_LT://47
            printf("%s < \n" , blank);
            ident += 8;
            break;
        case NODE_GE://48
            printf("%s >=\n" , blank);
            ident += 8;
            break;
        case NODE_GT://49
            printf("%s >\n" , blank);
            ident += 8;
            break;
        case NODE_LE://50
            printf("%s <=\n" , blank);
            ident += 8;
            break;
        case NODE_EQUAL://51
            printf("%s =\n" , blank);
            ident += 8;
            break;
        case NODE_notEQUAL://52
            printf("%s !=\n" , blank);
            ident += 8;
            break;
        case NODE_THEN://53
            printf("%s THEN\n" , blank);
            ident += 8;
            break;
        case NODE_variable://54
            printf("%s /varible\n" , blank);
            ident += 8;
            break;
        case NODE_PARAMETER://55
            printf("%s /PARAMETER_LISt\n" , blank);
            ident += 8;
            break;
        case NODE_ARG://56
            printf("%s /arguments\n" , blank);
            ident += 8;
            break;
        case NODE_SUB://57
            printf("%s /subprogram_head\n" , blank);
            ident += 8;
            break;
        case NODE_lambda://58
            break;
        case NODE_ID_LIST://59
            printf("%s /identifier_list\n" , blank);
            ident += 8;
            break;       
        case NODE_SUB_PRO_declas://60
            printf("%s /subprogram_declarations\n" , blank);
            ident += 8;
         case NODE_SUB_PRO://60
            printf("%s /subprogram_declaration\n" , blank);
            ident += 8;
            break;         
        default:
            printf("%sdefault:%d\n", blank, node->nodeType);
          break;
    }

    struct node *child = node->child;
    if(child != NULL) {
        do {
            printTree(child, ident);
            child = child->rsibling;
        } while(child != node->child);
    }
}

