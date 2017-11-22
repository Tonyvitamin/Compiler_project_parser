%{
/*
 * grammar.y
 *
 * Pascal grammar in Yacc format, based originally on BNF given
 * in "Standard Pascal -- User Reference Manual", by Doug Cooper.
 * This in turn is the BNF given by the ANSI and ISO Pascal standards,
 * and so, is PUBLIC DOMAIN. The grammar is for ISO Level 0 Pascal.
 * The grammar has been massaged somewhat to make it LALR, and added
 * the following extensions.
 *
 * constant expressions
 * otherwise statement in a case
 * productions to correctly match else's with if's
 * beginnings of a separate compilation facility
 */

 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include "node-type.h"
     /* Called by yyparse on error.  */
     void
     yyerror (char const *s)
     {
        extern char *yytext;
        extern int lineCount;
        fprintf (stderr, "%s: at line %d symbol'%s'\n", s,lineCount,yytext);
     }
     struct node * ASTROOT;
%}

%token <string> ARRAY DO ELSE END FUNCTION IF NOT OF PROCEDURE  
%token <string> PROGRAM THEN VAR WHILE 
%token <string> IDENTIFIER 
%token <string> ASSIGNMENT COLON 
%token <string> COMMA 
%token <number> DIGSEQ 
%token <string> DOT DOTDOT EQUAL GE GT LBRAC LE LPAREN LT 
%token <string> MINUS PLUS RBRAC 
%token <fval> REALNUMBER  
%token <string> RPAREN SEMICOLON SLASH  STAR  
%token <string> notEQUAL 
%token <string> STRING  
%token <string> real integer  begin 

%start prog
%union 
{ 
    struct node * node_t ;
    int number ;
    double fval;
    char * string;

}
%type <node_t> prog identifier_list standard_type optional_var procedure_statement relop term factor
%type <node_t> subprogram_declaration subprogram_declarations subprogram_head parameter_list expression
%type <node_t> expression_list   arguments   declarations type
%type <node_t> variable tail addop mulop compound_statement optional_statements 
%type <node_t> statement statement_list  simple_expression 

%%


prog : PROGRAM IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON
     declarations
     subprogram_declarations
     compound_statement
     DOT {
            printf("reduce rule 1\n"); 
            $$ = newNode(NODE_PROGRAM);
            struct node  * tmp = newNode(NODE_ID) ;
            tmp->string = $2;
            addChild($$ , tmp);
            addChild($$ , newNode(NODE_LP));
            addChild($$ , $4);
            addChild($$ , newNode(NODE_RP));
            addChild($$ , newNode(NODE_SEMI));
            addChild($$ , $7);
            addChild($$ , $8);
            addChild($$ , $9);
            addChild($$ , newNode(NODE_DOT)); //check point
            ASTROOT = $$;
         };

identifier_list : IDENTIFIER {
                         printf("reduce rule 2\n");  
                         $$ = newNode(NODE_ID);
                         $$->string = $1;                       
                    };
                    | identifier_list COMMA IDENTIFIER {  
                                                            printf("reduce rule 3\n" ); 
                                                            addChild($1  , newNode(NODE_COMMA));
                                                            struct node  * tmp = newNode(NODE_ID) ;
                                                            tmp->string = $3;
                                                            addChild($1 , tmp);     //check point 
                                                            $$ = $1;                                                   
                                                       };

declarations : declarations VAR identifier_list COLON type SEMICOLON {
                                                                        printf("reduce rule 4\n");
                                                                        //addChild($$ , $1);
                                                                        addChild($1 , newNode(NODE_VAR));
                                                                        addChild($1 , $3);
                                                                        addChild($1 , newNode(NODE_COLON));
                                                                        addChild($1 , $5);
                                                                        addChild($1 , newNode(NODE_SEMI)); // check point
                                                                        $$ = $1;
                                                                     }; 
                | lambda {
                        printf("reduce rule 5\n");
                        $$ = newNode(NODE_lambda);
                    };

type : standard_type {
            printf("reduce rule 6\n"); 
            $$ = newNode(NODE_TYPE);
            addChild($$ , $1);
        };
        | ARRAY LBRAC DIGSEQ DOTDOT DIGSEQ RBRAC OF type {
            printf("reduce rule 7\n");
            $$ = newNode(NODE_TYPE);
            addChild($$ , newNode(NODE_ARRAY));
            addChild($$ , newNode(NODE_LB));
            struct node * tmp = newNode(NODE_DIGSEQ);
            tmp->iValue = $3;
            addChild($$ , tmp);
            addChild($$ , newNode(NODE_DOTDOT));
            struct node * tmp1 = newNode(NODE_DIGSEQ);
            tmp1->iValue = $5;
            addChild($$ , tmp1);
            addChild($$ , newNode(NODE_RB));
            addChild($$ , newNode(NODE_OF));
            addChild($$ , $8); //check point
        };

standard_type : integer {
                            printf("reduce rule 8\n"); 
                            $$ = newNode(NODE_integer);
                            $$->string = $1;
                        };
                | real   {
                            printf("reduce rule 9\n");  
                            $$ = newNode(NODE_real);
                            $$->string = $1;
                         };
                | STRING {
                            printf("reduce rule 10\n");
                            $$ = newNode(NODE_STRING);
                            $$->string = $1; 
                         };


subprogram_declarations :
	subprogram_declarations subprogram_declaration SEMICOLON {
                                                                printf("reduce rule 11\n");
                                                                addChild($1 , $2);
                                                                addChild($1 , newNode(NODE_SEMI)); //check point
                                                                $$ = $1;
                                                             };
	| lambda {
        printf("reduce rule 12\n");
        $$ = newNode(NODE_lambda);
        };

subprogram_declaration : subprogram_head
                             declarations
                            compound_statement {
                                                    printf("reduce rule 13\n");
                                                    $$ = newNode(NODE_SUB_PRO_declas);
                                                    addChild($$ , $1);
                                                    addChild($$ , $2);
                                                    addChild($$ , $3); //check point 
                                               };

subprogram_head : FUNCTION IDENTIFIER arguments COLON standard_type SEMICOLON {
                                                                                    printf("reduce rule 14\n");
                                                                                    $$ = newNode(NODE_SUB);
                                                                                    addChild($$ , newNode(NODE_FUNCTION));
                                                                                    struct node * tmp = newNode(NODE_ID);
                                                                                    tmp->string = $2;
                                                                                    addChild($$ , tmp);
                                                                                    addChild($$ , $3);
                                                                                    addChild($$ , newNode(NODE_COLON));
                                                                                    addChild($$ , $5);
                                                                                    addChild($$ , newNode(NODE_SEMI)); //check point
                                                                              };
	| PROCEDURE IDENTIFIER arguments SEMICOLON {
                                                    printf( "reduce rule 15\n");
                                                    $$ = newNode(NODE_SUB);
                                                    addChild($$ , newNode(NODE_PROCEDURE));
                                                    struct node * tmp = newNode(NODE_ID);
                                                    tmp->string = $2;
                                                    addChild($$ , tmp);
                                                    addChild($$ , $3);
                                                    addChild($$ , newNode(NODE_SEMI)); //check point 
                                                };

arguments : LPAREN parameter_list RPAREN {
                                            printf("reduce rule 16\n");
                                            $$ = newNode(NODE_ARG);
                                            addChild($$ , newNode(NODE_LP));
                                            addChild($$ , $2);
                                            addChild($$ , newNode(NODE_RP));
                                        };
	| lambda {
            printf("reduce rule 17\n");
            $$ = newNode(NODE_lambda);
            };


parameter_list : optional_var identifier_list COLON type {
                                                            printf("reduce rule 18\n");
                                                            $$ = newNode(NODE_PARAMETER);
                                                            addChild($$ , $1);
                                                            addChild($$ , $2);
                                                            addChild($$ , newNode(NODE_COLON));
                                                            addChild($$ , $4);//check point
                                                         };
	| optional_var identifier_list COLON type SEMICOLON parameter_list {
                                                                            printf("reduce rule 19\n");
                                                                            addChild($6 , $1);
                                                                            addChild($6 , $2);
                                                                            addChild($6 , newNode(NODE_COLON));
                                                                            addChild($6 , $4);
                                                                            addChild($6 , newNode(NODE_SEMI));
                                                                            //addChild($$ , $6);
                                                                            $$ = $6;
                                                                        };



optional_var   : VAR {
                        printf("reduce rule 20\n");
                        $$ = newNode(NODE_VAR);
                        $$->string = $1;
                     };
        | lambda {printf("reduce rule 21\n");$$ = newNode(NODE_lambda);};


compound_statement : begin
		       optional_statements
		       END {
                        printf("reduce rule 22\n");
                        $$ = newNode(NODE_COM);
                        addChild($$ , newNode(NODE_BEGIN));
                        addChild($$ , $2);
                        addChild($$ , newNode(NODE_END));
                    };


optional_statements : statement_list {
                                        printf("reduce rule 23\n");
                                        $$ = newNode(NODE_OPT);
                                        addChild($$ , $1); 
                                     };


statement_list : statement {
                                printf("reduce rule 25\n");
                                $$ = newNode(NODE_STAT_LIST);
                                addChild($$ , $1);
                           };
	| statement_list SEMICOLON statement {
                                            printf("reduce rule 26\n");
                                            //$$ = newNode(NODE_STAT_LIST);
                                            //addChild($$ , $1);
                                            addChild($1 , newNode(NODE_SEMI));
                                            addChild($1 , $3);
                                            $$ = $1;
                                         };


statement : variable ASSIGNMENT expression {
                                                printf("reduce rule 27\n");
                                                $$ = newNode(NODE_STAT);
                                                addChild($$ , $1);
                                                addChild($$ , newNode(NODE_ASSIGNMENT));
                                                addChild($$ , $3);
                                           };
	| procedure_statement {
                                printf("reduce rule 28\n");
                                $$ = newNode(NODE_STAT);
                                addChild($$ , $1);
                          };
	| compound_statement {
                            printf("reduce rule 29\n");
                            $$ = newNode(NODE_STAT);
                            addChild($$ , $1);
                         };
	| IF expression THEN statement ELSE statement {
                                                        printf("reduce rule 30\n");
                                                        $$ = newNode(NODE_STAT);
                                                        addChild($$ , newNode(NODE_IF));
                                                        addChild($$ , $2);
                                                        addChild($$ , newNode(NODE_THEN));
                                                        addChild($$ , $4);
                                                        addChild($$ , newNode(NODE_ELSE));
                                                        addChild($$ , $6);
                                                  };
	| WHILE expression DO statement {
                                        printf("reduce rule 31\n");
                                        $$ = newNode(NODE_STAT);
                                        addChild($$ , newNode(NODE_WHILE));
                                        addChild($$ , $2);
                                        addChild($$ , newNode(NODE_DO));
                                        addChild($$ , $4);
                                    };
	| lambda {printf("reduce rule 32\n");$$ = newNode(NODE_lambda);};


variable : IDENTIFIER tail {
                                printf("reduce rule 33\n");
                                struct node * tmp = newNode(NODE_ID);
                                tmp->string = $1;
                                $$ = newNode(NODE_variable);
                                addChild($$ , tmp);
                                addChild($$ , $2);
                           };

tail     : LBRAC expression RBRAC tail { 
                                            printf("reduce rule 34\n");
                                            //$$ = newNode(NODE_tail);
                                            addChild($4 , newNode(NODE_LB));
                                            addChild($4 , $2);
                                            addChild($4 , newNode(NODE_RB));
                                            //addChild($$ , $4);
                                            $$ = $4;
                                       };

	| lambda {printf("reduce rule 35\n"); $$ = newNode(NODE_lambda);};


procedure_statement : IDENTIFIER {
                                    printf("reduce rule 35\n" );
                                    $$ = newNode(NODE_ID);
                                    $$->string = $1;
                                 };
	| IDENTIFIER LPAREN expression_list RPAREN {
                                                    printf("reduce rule 36\n");
                                                    $$ = newNode(NODE_Pro);
                                                    struct node * tmp = newNode(NODE_ID);
                                                    tmp->string = $1;
                                                    addChild($$ , tmp);
                                                    addChild($$ , newNode(NODE_LP));
                                                    addChild($$ , $3);
                                                    addChild($$ , newNode(NODE_RP));
                                               };


expression_list : expression {
                                printf("reduce rule 37\n"); 
                                $$ = newNode(NODE_EXP_LIST);
                                addChild($$ , $1);
                             };
	| expression_list COMMA expression {
                                            printf("reduce rule 38\n");
                                            //$$ = newNode(NODE_EXP_LIST);
                                            //addChild($$ , $1);
                                            addChild($1 , newNode(NODE_COMMA));
                                            addChild($1 , $3);
                                            $$ = $1;
                                        };


expression : simple_expression {
                                    printf( "reduce rule 39\n"); 
                                    $$ = newNode(NODE_EXP);
                                    addChild($$ , $1);
                               };
	| simple_expression relop simple_expression {
                                                    printf("reduce rule 40\n");
                                                    $$ = newNode(NODE_EXP);
                                                    addChild($$ , $1);
                                                    addChild($$ , $2);
                                                    addChild($$ , $3);
                                                };


simple_expression : term {
                            printf( "reduce rule 41\n");
                            $$ = newNode(NODE_SMP);
                            addChild($$ , $1); 
                         };
	| simple_expression addop term {
                                         printf("reduce rule 42\n");
                                         addChild($1 , $2);
                                         addChild($1 , $3);
                                         $$ = $1;
                                   };


term : factor {
                    printf("reduce rule 43\n"); 
                    $$ = newNode(NODE_term);
                    addChild($$ , $1);
              };
	| term mulop factor {
                            printf("reduce rule 44\n");
                            //$$ = newNode(NODE_term);
                            //addChild($$ , $1);
                            addChild($1 , $2);
                            addChild($1 , $3);
                            $$ = $1;
                        };


factor : IDENTIFIER tail {
                            printf("reduce rule 45\n");
                            $$ = newNode(NODE_factor);
                            struct node * tmp = newNode(NODE_ID);
                            tmp->string = $1;
                            addChild($$ , tmp);
                            addChild($$ , $2);
                         };
	| IDENTIFIER LPAREN expression_list RPAREN {
                                                    printf("reduce rule 46\n");
                                                    $$ = newNode(NODE_factor);
                                                    struct node * tmp1 =newNode(NODE_ID);
                                                    tmp1->string = $1;
                                                    addChild($$ , tmp1);
                                                    addChild($$ , newNode(NODE_LP));
                                                    addChild($$ , $3);
                                                    addChild($$ , newNode(NODE_RP));
                                               };
	| DIGSEQ {
                printf("reduce rule 47\n");
                $$ = newNode(NODE_DIGSEQ);
                $$->iValue = $1;
             };
    | addop DIGSEQ {
                        printf("reduce rule 48\n");
                        $$ = newNode(NODE_factor);
                        addChild($$ , $1);
                        struct node * tmp = newNode(NODE_ID);
                        tmp->iValue = $2;
                        addChild($$ , tmp);
                   };
    | REALNUMBER {
                    printf("reduce rule 49\n");
                    $$ = newNode(NODE_REALNUMBER);
                    $$->rValue = $1;
                 };
    | addop REALNUMBER {
                            printf("reduce rule 50\n");
                            $$ = newNode(NODE_factor);
                            addChild($$ , $1);
                            struct node * tmp = newNode(NODE_REALNUMBER);
                            tmp->rValue = $2;
                            addChild($$ , tmp);
                       };
	| LPAREN expression RPAREN {
                                    printf("reduce rule 51\n");
                                    $$ = newNode(NODE_factor);
                                    addChild($$ , newNode(NODE_LP));
                                    addChild($$ , $2);
                                    addChild($$ , newNode(NODE_RP));
                               };
	| NOT factor {
                        printf("reduce rule 52\n");
                        $$ = newNode(NODE_factor);
                        addChild($$ , newNode(NODE_NOT));
                        addChild($$ , $2);
                 };


addop : PLUS {
                printf("reduce rule 53\n" );
                $$ = newNode(NODE_PLUS);
                $$->string = $1;
             };| MINUS {
                        printf("reduce rule 54 \n");
                        $$ = newNode(NODE_MINUS);
                        $$->string = $1;
                       };


mulop : STAR {
                printf("reduce rule 55\n" );
                $$ = newNode(NODE_STAR);
                $$->string = $1;
             };| SLASH {
                            printf( "reduce rule 56\n" );
                            $$ = newNode(NODE_SLASH);
                            $$->string = $1;
                        };

relop : LT {
            printf("reduce rule 57 \n" ); 
            $$ = newNode(NODE_LT);
            $$->string = $1;
        };
	| GT {
            printf("reduce rule 58 \n" );   
            $$ = newNode(NODE_GT);
            $$->string = $1;    
        };
	| EQUAL {
                printf("reduce rule 59 \n" );
                $$ = newNode(NODE_EQUAL);
                $$->string = $1;
            };
	| LE {
            printf("reduce rule 60\n"); 
            $$ = newNode(NODE_LE);
            $$->string = $1;
         };
	| GE {
            printf("reduce rule 61\n" );  
            $$ = newNode(NODE_GE);
            $$->string = $1;    
        };
	| notEQUAL {
                    printf("reduce rule 62\n" );  
                    $$ = newNode(NODE_notEQUAL);
                    $$->string = $1;
               };

lambda : ;

%%
int main(int argc, char** argv) {
    int res;
    
    fprintf(stderr, "open file.\n");
    if(argc>1 && freopen(argv[1],"r",stdin)==NULL){
        exit(1);
    }
    
    fprintf(stderr, "call yyparse\n");
    res = yyparse();
    fprintf(stderr, "after call yyparse, res = %d.\n", res);
    
    if (res==0)
        fprintf(stderr, "SUCCESS\n");
    else
        fprintf(stderr, "ERROR\n");
    printf("-----------------------------------------------\n");
    printTree(ASTROOT, 0);
}

 #include "lex.yy.c"
