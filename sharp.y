%{
#include <stdio.h>
#include <string.h>

FILE *yyin;
extern int yylineno;

void yyerror(const char *str)
{
    fprintf(stderr, "%d:%s\n", yylineno, str);
}
 
int yywrap()
{
    return 1;
} 
  
int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yyparse();

    return 0;
} 

%}

%token TOKABSTRACT TOKAS TOKBASE TOKBOOL TOKBREAK TOKBYTE TOKCASE TOKCATCH TOKCHAR TOKCHECKED TOKCLASS TOKCONST TOKCONTINUE TOKDECIMAL TOKDEFAULT TOKDELEGATE TOKDO TOKDOUBLE TOKELSE TOKELSEIF
%token TOKENUM TOKEVENT TOKEXPLICIT TOKEXTERN TOKFALSE TOKFINALLY TOKFIXED TOKFLOAT TOKFOR TOKFOREACH TOKGOTO TOKIF TOKIMPLICIT TOKIN TOKINT TOKINTERFACE TOKINTERNAL TOKIS TOKLOCK TOKLONG
%token TOKNAMESPACE TOKNEW TOKNULL TOKOBJECT TOKOPERATOR TOKOUT TOKOVERRIDE TOKPARAMS TOKPRIVATE TOKPROTECTED TOKPUBLIC TOKREADONLY TOKREF TOKRETURN TOKSBYTE TOKSEALED TOKSHORT TOKSIZEOF 
%token TOKSTACKALLOC TOKSTATIC TOKSTRING TOKSTRUCT TOKSWITCH TOKTHIS TOKTHROW TOKTRUE TOKTRY TOKTYPEOF TOKUINT TOKULONG TOKUNCHECKED TOKUNSAFE TOKUSHORT TOKUSING TOKVIRTUAL TOKVOID TOKVOLATILE
%token TOKWHILE IDENT OBRACE EBRACE SEMICOLON OPENBRACKET CLOSEBRACKET TOKLESS TOKMORE TOKLESSEQ TOKMOREEQ TOKEQUAL TOKNOTEQUAL ASSIGN TOKSUM TOKMIN TOKMULTIPLY TOKDIV MOD TOKOR TOKAND
%token TOKDOT COLON COMMA TOKSET TOKGET OPENSQUARE CLOSESQUARE PLUSEQ MINUSEQ MULTEQ DIVEQ MODEQ XOREQ ANDEQ OREQ LTLT GTGT LTLTEQ GTGTEQ PLUSPLUS MINUSMINUS ARROW AND OR XOR NOT INVERSION
%token INTEGER_LITERAL REAL_LITERAL CHARACTER_LITERAL STRING_LITERAL TOKYIELD TOKVAR RANK_SPECIFIER TOKPARTIAL

%define parse.error verbose

%% 

code_zone:
    using_section global_layer;

global_layer:
    /*empty*/
    |
    global_layer global_layer_action
    ;

global_layer_action:
    namespace_declare
    |
    type_declare
    ;

type_declare:
    enum_declare
    |
    struct_declare
    |
    class_declare
    |
    interface_declare
    |
    delegate_declate
    ;

delegate_declate:
    modifiers_opt TOKDELEGATE type IDENT OPENBRACKET parameter_list_opt CLOSEBRACKET SEMICOLON;

// ---------------using------------------

using_section:
    /*empty*/
    |
    using_section one_using;

one_using:
    TOKUSING qual_ident SEMICOLON;

// -------namespace declare---------------

namespace_declare:
    /*attribs_opt*/ TOKNAMESPACE qual_ident OBRACE namespace_body EBRACE comma_opt;

namespace_body:
    /*empty*/
    |
    namespace_body namespace_member_declare
    ;

namespace_member_declare:   
    type_declare
    |
    namespace_declare
    ;

// -------------enum declare-------------

enum_declare:
    /*attribs*/ modifiers_opt TOKENUM IDENT enum_type_opt enum_body comma_opt;

enum_type_opt:
    /*empty*/ 
    | 
    COLON integral_type
    ;

enum_body:
    OBRACE enum_member_declares end_enum_member EBRACE;

enum_member_declares:
    /*empty*/
    |
    enum_member_declares IDENT enum_member_declare COMMA
    ;

end_enum_member:
    /*empty*/
    |
    IDENT enum_member_declare
    ;

enum_member_declare:
    /*empty*/ | enum_assign;

enum_assign:
    ASSIGN literal;

// ------------struct declare------------ 

struct_declare:
    /*attribs*/ modifiers_opt TOKSTRUCT IDENT struct_interfaces_opt struct_body comma_opt;

struct_interfaces_opt:
    /*empty*/ 
    | 
    COLON interface_type_list;

struct_body:
    OBRACE struct_member_declarations EBRACE;

struct_member_declarations:
    struct_member_declarations struct_member_declaration
    |
    /*empty*/
    ;

struct_member_declaration: 
    type_declare
    |
    method_declare
    |
    constructor_declare
    |
    const_field_declare
    |
    field_declare
    |
    property_declare
    ;

property_declare:
    /*attribs*/ modifiers_opt type qual_ident get_set;

field_declare:
    /*attribs*/ modifiers_opt variable_declare SEMICOLON;

const_field_declare:
    /*attribs*/ modifiers_opt const_declare SEMICOLON;

// -----------class declare--------------

class_declare:
    /*attribs*/ modifiers_opt TOKCLASS IDENT class_base_opt class_body comma_opt;

class_base_opt:
    /*empty*/ | class_base;

class_base:
    COLON class_type
    |
    COLON interface_type_list
    |
    COLON class_type COMMA interface_type_list
    ;

class_body:
    OBRACE class_member_declarations EBRACE;

class_member_declarations:
    class_member_declarations class_member_declaration
    |
    /*empty*/
    ;

class_member_declaration:
    type_declare
    |
    method_declare
    |
    constructor_declare
    |
    const_field_declare
    |
    field_declare
    |
    property_declare
    |
    destructor_declare
    ;

destructor_declare:
    /*attribs*/ modifiers_opt '~' IDENT OPENBRACKET CLOSEBRACKET block;

// ----------interface declare-----------

interface_declare:
   /*attribs*/ modifiers_opt TOKINTERFACE interface_base_opt interface_body comma_opt;

interface_base_opt:
    /*empty*/
    |
    COLON interface_type_list
    ;

interface_body:
    OBRACE interface_member_declarations EBRACE;

interface_member_declarations:
    interface_member_declarations interface_member_declaration
    |
    /*empty*/
    ;

interface_member_declaration:
    interface_method_declare
    |
    interface_field_declare
    |
    interface_index_declare
    |
    interface_event_declare
    ;

interface_event_declare:
    /*attribs*/ new_opt TOKEVENT type IDENT SEMICOLON;

interface_index_declare:
    /*attribs*/ new_opt type TOKTHIS OPENSQUARE parameter_list CLOSESQUARE get_set;

interface_field_declare:
    /*attribs*/ new_opt type IDENT get_set;

interface_method_declare:
    /*attribs*/ new_opt type IDENT OPENBRACKET parameter_list_opt CLOSEBRACKET SEMICOLON;

new_opt:
    /*empty*/ | TOKNEW;

get_set:
    OBRACE get_set_body EBRACE;

get_set_body:
    TOKSET SEMICOLON
    |
    TOKGET SEMICOLON
    |
    TOKSET SEMICOLON TOKGET SEMICOLON
    |
    TOKGET SEMICOLON TOKSET SEMICOLON
    ;

// ------------method declare-------------

method_declare:
   method_header method_body;

method_header:
    /*attribs_opt*/ modifiers_opt type qual_ident OPENBRACKET parameter_list_opt CLOSEBRACKET
    |
    /*attribs_opt*/ modifiers_opt TOKVOID qual_ident OPENBRACKET parameter_list_opt CLOSEBRACKET
    ;

method_body:
    block | SEMICOLON;

// -----------method params-----------------

parameter_list_opt:
    /*empty*/ | parameter_list;

parameter_list:
    parameter_list COMMA parameter
    |
    parameter
    ;

parameter:
    fixed_parameter | array_parameter;

fixed_parameter:
    /*attribs*/ parameter_modifier_opt type IDENT default_param_opt;

default_param_opt:
    ASSIGN expr
    |
    ASSIGN TOKDEFAULT
    |
    /*empty*/
    ;

array_parameter:
    /*attribs*/ TOKPARAMS array_type IDENT;

parameter_modifier_opt:
    /*empty*/ | TOKIN | TOKREF | TOKOUT;

// ----------constructor declare----------

constructor_declare:
    /*attribs*/ modifiers_opt constructor_head constructor_body;

constructor_head:
    IDENT OPENBRACKET parameter_list_opt CLOSEBRACKET constructor_init_opt;

constructor_init_opt:
    /*empty*/ | constructor_init;

constructor_init:
    COLON TOKBASE OPENBRACKET argument_list_opt CLOSEBRACKET
    |
    COLON TOKTHIS OPENBRACKET argument_list_opt CLOSEBRACKET
    ;

constructor_body:
    block | SEMICOLON;

// -------------statements----------------

block:
    OBRACE statement_list_opt EBRACE;

statement_list_opt:
    /*empty*/ | statement_list;

statement_list:
    statement_list statement
    |
    statement
    ;

statement:
    block
    |
    variable_declare SEMICOLON
    |
    checked_state
    |
    unchecked_state
    |
    label_state
    |
    const_declare SEMICOLON
    |
    SEMICOLON
    |
    expr_state SEMICOLON
    |
    jump_state SEMICOLON
    |
    while_state
    |
    do_while_state
    |
    for_state
    |
    foreach_state
    |
    if_state
    |
    switch_state
    |
    try_state
    |
    lock_state
    |
    using_state
    ;

using_state:
    TOKUSING OPENBRACKET using_a CLOSEBRACKET statement;

using_a:
    expr | variable_declare;

lock_state:
    TOKLOCK OPENBRACKET expr CLOSEBRACKET statement;

try_state:
    TOKTRY block catch_state_opt finally_state_opt;

finally_state_opt:
    /*empty*/ | finally_state;

finally_state:
    TOKFINALLY block;

catch_state_opt:
    /*empty*/ | catch_states;

catch_states:
    catch_states catch_state
    |
    catch_state
    ;

catch_state:
    TOKCATCH OPENBRACKET class_type ident_opt CLOSEBRACKET block
    |
    TOKCATCH OPENBRACKET qual_ident ident_opt CLOSEBRACKET block
    |
    TOKCATCH block
    ;

ident_opt:
    /*empty*/ | IDENT;

switch_state:
    TOKSWITCH OPENBRACKET expr CLOSEBRACKET switch_body;

switch_body:
    OBRACE switch_cond_opt EBRACE;

switch_cond_opt:
    /*empty*/ | switch_conds;

switch_conds:
    switch_conds switch_cond
    |
    switch_cond
    ;

switch_cond:
    TOKCASE expr COLON statement_list_opt
    |
    TOKDEFAULT COLON statement_list_opt
    ;

if_state:   
    TOKIF OPENBRACKET expr CLOSEBRACKET statement else_if_state else_state_opt;

else_if_state:
    /*empty*/ | else_ifs;

else_ifs:
    else_ifs else_if
    |
    else_if
    ;

else_if:
    TOKELSEIF OPENBRACKET expr CLOSEBRACKET statement;

else_state_opt:
    /*empty*/ | else_state;

else_state:
    TOKELSE statement;

foreach_state:
    TOKFOREACH OPENBRACKET type IDENT TOKIN expr CLOSEBRACKET statement;

for_state:
    TOKFOR OPENBRACKET for_init_opt SEMICOLON cond_opt SEMICOLON expr CLOSEBRACKET statement;

cond_opt:
    /*empty*/ | expr;

for_init_opt:
    /*empty*/ | for_init;

for_init:
    variable_declare /*| expr_state_list*/;

while_state:
    TOKWHILE OPENBRACKET expr CLOSEBRACKET statement;

do_while_state:
    TOKDO statement TOKWHILE OPENBRACKET expr CLOSEBRACKET SEMICOLON;

jump_state:
    TOKBREAK 
    | 
    TOKCONTINUE
    |
    TOKGOTO IDENT
    |
    TOKGOTO TOKCASE expr
    |
    TOKGOTO TOKDEFAULT
    |
    TOKTHROW expr_opt
    |
    TOKRETURN expr_opt
    |
    TOKYIELD TOKBREAK
    ;

expr_opt:
    /*empty*/ | expr;

expr_state:
    expr
    ;

const_declare:
    TOKCONST type const_declarators;

const_declarators:
    const_declarators COMMA const_declarator
    |
    const_declarator
    ;

const_declarator:
    IDENT ASSIGN expr;

label_state:
    IDENT COLON;

unchecked_state:
    TOKUNCHECKED block;

variable_declare:
    type variable_declarators;

variable_declarators:
    variable_declarators COMMA variable_declarator
    |
    variable_declarator
    ;

variable_declarator:
    IDENT ASSIGN variable_init
    |
    IDENT
    ;

checked_state:
    TOKCHECKED block;

// --------------expressions--------------

expr:
    cond_expr | assignment;

assignment:
    unary_expr assign_operator expr;

cond_expr:
    cond_logic_expr '?' expr COLON expr
    |
    cond_logic_expr
    ;

cond_logic_expr:
    cond_logic_expr TOKOR cond_bit_expr
    |
    cond_logic_expr TOKAND cond_bit_expr
    |
    cond_bit_expr
    ;

cond_bit_expr:
    cond_bit_expr OR cmp_expr
    |
    cond_bit_expr AND cmp_expr
    |
    cond_bit_expr XOR cmp_expr
    |
    cmp_expr
    ;

cmp_expr:
    cmp_expr TOKEQUAL shift_expr
    |
    cmp_expr TOKNOTEQUAL shift_expr
    |
    cmp_expr TOKLESS shift_expr
    |
    cmp_expr TOKMORE shift_expr
    |
    cmp_expr TOKLESSEQ shift_expr
    |
    cmp_expr TOKMOREEQ shift_expr
    |
    cmp_expr TOKIS type
    |
    cmp_expr TOKAS type
    |
    shift_expr
    ;

shift_expr:
    shift_expr LTLT arith_expr
    |
    shift_expr GTGT arith_expr
    |
    arith_expr
    ;

arith_expr:
    arith_expr TOKSUM unary_expr
    |
    arith_expr TOKMIN unary_expr
    |
    arith_expr TOKMULTIPLY unary_expr
    |
    arith_expr TOKDIV unary_expr
    |
    arith_expr MOD unary_expr
    |
    unary_expr
    ;

unary_expr:
    NOT unary_expr
    |
    INVERSION unary_expr
    |
    TOKSUM unary_expr /**/
    |
    TOKMIN unary_expr /**/
    |
    PLUSPLUS unary_expr /**/
    |
    MINUSMINUS unary_expr /**/
    |
    post_expr
    |
    cast_expr
    ;

cast_expr:
    OPENBRACKET expr CLOSEBRACKET unary_expr
    |
    OPENBRACKET qual_ident RANK_SPECIFIER type_quals_opt CLOSEBRACKET unary_expr
    |
    OPENBRACKET primitive_type type_quals_opt CLOSEBRACKET unary_expr
    |
    OPENBRACKET class_type type_quals_opt CLOSEBRACKET unary_expr
    |
    OPENBRACKET TOKVOID type_quals_opt CLOSEBRACKET unary_expr
    ;

type_quals_opt: 
    /*empty*/ | type_quals;

type_quals:
    type_qual
    | 
    type_quals type_qual
    ;

type_qual:
    RANK_SPECIFIER | TOKMULTIPLY;

post_expr:
    post_expr PLUSPLUS
    |
    post_expr MINUSMINUS
    |
    post_expr ARROW IDENT
    |
    qual_ident
    |
    prim_expr
    ;

prim_expr:
    OPENBRACKET expr CLOSEBRACKET
    |
    expr_unit
    ;

expr_unit:
    literal
    |
    checked_expr
    |
    unchecked_expr
    |
    sizeof_expr
    |
    typeof_expr
    |
    base_access
    |
    this_access
    |
    member_access
    |
    element_access
    |
    array_create_expr
    |
    object_create_expr 
    |
    call_expr
    ;

call_expr:
    expr_unit OPENBRACKET argument_list_opt CLOSEBRACKET
    |
    qual_ident OPENBRACKET argument_list_opt CLOSEBRACKET
    ;

object_create_expr:
    TOKNEW type OPENBRACKET argument_list_opt CLOSEBRACKET;

array_create_expr:
    TOKNEW non_array_type OPENSQUARE expr_list CLOSESQUARE rank_specifier_opt array_init_opt
    |
    TOKNEW array_type array_init
    ;

array_init_opt:
    /*empty*/ | array_init;   

array_init:
    OBRACE variable_init_list_opt EBRACE
    |
    OBRACE variable_init_list COMMA EBRACE
    ;

checked_expr:
    TOKCHECKED OPENBRACKET expr CLOSEBRACKET;

unchecked_expr:
    TOKUNCHECKED OPENBRACKET expr CLOSEBRACKET;

sizeof_expr:
    TOKSIZEOF OPENBRACKET type CLOSEBRACKET;

typeof_expr:
    TOKTYPEOF OPENBRACKET type CLOSEBRACKET
    |
    TOKTYPEOF OPENBRACKET TOKVOID CLOSEBRACKET
    ;

base_access:
    TOKBASE TOKDOT IDENT
    |
    TOKBASE OPENSQUARE expr_list CLOSESQUARE
    ;

this_access:
    TOKTHIS;

member_access:
    prim_expr TOKDOT IDENT
    |
    primitive_type TOKDOT IDENT
    |
    class_type TOKDOT IDENT
    ;

element_access:
    prim_expr OPENSQUARE expr_list CLOSESQUARE
    |
    qual_ident OPENSQUARE expr_list CLOSESQUARE
    ;

variable_init_list_opt:
    /*empty*/ | variable_init_list;

variable_init_list:
    variable_init
    |
    variable_init_list COMMA variable_init
    ;

variable_init:
    expr | array_init | stackallock_init;

stackallock_init:
    TOKSTACKALLOC type OPENSQUARE expr CLOSESQUARE;

argument_list_opt:
    /*empty*/ | argument_list;

argument_list:
    argument_list COMMA argument
    |
    argument
    ;

argument:
    expr
    |
    TOKREF variable
    |
    TOKOUT variable
    |
    TOKIN variable
    ;

expr_list:
    expr_list COMMA expr
    |
    expr
    ;

variable:
    expr;

// ------------types + literals----------

literal:
    TOKNULL | CHARACTER_LITERAL | INTEGER_LITERAL |  REAL_LITERAL | STRING_LITERAL | bool_literal;

bool_literal:
    TOKTRUE | TOKFALSE;

class_type: 
    TOKOBJECT | TOKSTRING;

integral_type:
    TOKSBYTE | TOKBYTE | TOKSHORT | TOKUSHORT | TOKINT | TOKUINT | TOKLONG | TOKULONG | TOKCHAR;

type_name:
    qual_ident;

type:
    non_array_type | array_type | TOKVAR;

array_type:
    array_type RANK_SPECIFIER
    |
    simple_type RANK_SPECIFIER
    |
    qual_ident RANK_SPECIFIER
    ;

non_array_type:
    simple_type | type_name;

simple_type:
    primitive_type | class_type;

primitive_type:
    numeric_type | TOKBOOL;

numeric_type:
    integral_type | floating_point_type | TOKDECIMAL;

floating_point_type: 
  TOKFLOAT | TOKDOUBLE;

// ---------------modifiers---------------

modifiers_opt:
    /*empty*/ | modifiers;

modifiers:
    modifiers modifier
    |
    modifier
    ;

modifier:
    TOKABSTRACT | TOKEXTERN | TOKINTERNAL | TOKNEW | TOKOVERRIDE | TOKPRIVATE | TOKPROTECTED | TOKPUBLIC | TOKREADONLY
    |
    TOKSEALED | TOKSTATIC | TOKUNSAFE | TOKVIRTUAL | TOKVOLATILE | TOKPARTIAL
    ;

// --------------------------------------

assign_operator:
    ASSIGN | PLUSEQ | MINUSEQ | MULTEQ | DIVEQ | MODEQ | XOREQ | ANDEQ | OREQ | LTLTEQ | GTGTEQ;

rank_specifier_opt:
    rank_specifier_opt RANK_SPECIFIER
    |
    /*empty*/
    ;

interface_type_list:
    interface_type_list COMMA qual_ident
    |
    qual_ident
    ;

comma_opt:
    /*empty*/ | COMMA;

qual_ident:
    IDENT
    |
    qual IDENT
    ;

qual:
    IDENT TOKDOT
    |
    qual IDENT TOKDOT
    ;

%%