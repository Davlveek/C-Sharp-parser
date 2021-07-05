%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>

%}

%option yylineno
%option stack

single_line_comment     "//".*

preprocessor           ^[ \t]*#.*

dec_digit               [0-9]
hex_digit               [0-9A-Fa-f]
bin_digit               [0-1]
int_suffix              [UuLl]|[Uu][Ll]|[Ll][Uu]
dec_literal             {dec_digit}+{int_suffix}?
hex_literal             0[xX]{hex_digit}+{int_suffix}?
bin_literal             0[bB]{bin_digit}+{int_suffix}?
integer_literal         {dec_literal}|{hex_literal}|{bin_literal}
 
real_suffix             [FfDdMm]
sign                    [+\-]
exponent_part           [eE]{sign}?{dec_digit}+
whole_real1             {dec_digit}+{exponent_part}{real_suffix}?
whole_real2             {dec_digit}+{real_suffix}
part_real               {dec_digit}*\.{dec_digit}+{exponent_part}?{real_suffix}?
real_literal            {whole_real1}|{whole_real2}|{part_real}
 
single_char             [^\\\']
simple_esc_seq          \\[\'\"\\0abfnrtv]
uni_esc_seq1            \\u{hex_digit}{4}
uni_esc_seq2            \\U{hex_digit}{8}
uni_esc_seq             {uni_esc_seq1}|{uni_esc_seq2}
hex_esc_seq             \\x{hex_digit}{1,4}
character               {single_char}|{simple_esc_seq}|{hex_esc_seq}|{uni_esc_seq}
character_literal       \'{character}\'
 
single_string_char      [^\\\"]
reg_string_char         {single_string_char}|{simple_esc_seq}|{hex_esc_seq}|{uni_esc_seq}
regular_string          \"{reg_string_char}*\"
single_verbatim_char    [^\"]
quote_esc_seq           \"\"
verb_string_char        {single_verbatim_char}|{quote_esc_seq}
verbatim_string         @\"{verb_string_char}*\"
string_literal          {regular_string}|{verbatim_string}

white_space            [ \t\n\r]
rank_specifier         "["{white_space}*(","{white_space}*)*"]"

%x COMMENT

%%

"abstract"              return TOKABSTRACT;
"as"                    return TOKAS;
"base"                  return TOKBASE;
"bool"                  return TOKBOOL;
"break"                 return TOKBREAK;
"byte"                  return TOKBYTE;
"case"                  return TOKCASE;
"catch"                 return TOKCATCH;
"char"                  return TOKCHAR;
"checked"               return TOKCHECKED;
"class"                 return TOKCLASS;
"const"                 return TOKCONST;
"continue"              return TOKCONTINUE;
"decimal"               return TOKDECIMAL;
"default"               return TOKDEFAULT;
"delegate"              return TOKDELEGATE;
"do"                    return TOKDO;
"double"                return TOKDOUBLE;
"else"                  return TOKELSE;
"else if"               return TOKELSEIF;
"enum"                  return TOKENUM;
"event"                 return TOKEVENT;
"explicit"              return TOKEXPLICIT;
"extern"                return TOKEXTERN;
"false"                 return TOKFALSE;
"finally"               return TOKFINALLY;
"fixed"                 return TOKFIXED;
"float"                 return TOKFLOAT;
"for"                   return TOKFOR;
"foreach"               return TOKFOREACH;
"goto"                  return TOKGOTO;
"if"                    return TOKIF;
"implicit"              return TOKIMPLICIT;
"in"                    return TOKIN;
"int"                   return TOKINT;
"interface"             return TOKINTERFACE;
"internal"              return TOKINTERNAL;
"is"                    return TOKIS;
"lock"                  return TOKLOCK;
"long"                  return TOKLONG;
"namespace"             return TOKNAMESPACE;
"new"                   return TOKNEW;
"null"                  return TOKNULL;
"object"                return TOKOBJECT;
"operator"              return TOKOPERATOR;
"out"                   return TOKOUT;
"override"              return TOKOVERRIDE;
"params"                return TOKPARAMS;
"private"               return TOKPRIVATE;
"protected"             return TOKPROTECTED;
"public"                return TOKPUBLIC;
"readonly"              return TOKREADONLY;
"ref"                   return TOKREF;
"return"                return TOKRETURN;
"sbyte"                 return TOKSBYTE;
"sealed"                return TOKSEALED;
"short"                 return TOKSHORT;
"sizeof"                return TOKSIZEOF;
"stackalloc"            return TOKSTACKALLOC;
"static"                return TOKSTATIC;
"string"                return TOKSTRING;
"struct"                return TOKSTRUCT;
"switch"                return TOKSWITCH;
"this"                  return TOKTHIS;
"throw"                 return TOKTHROW;
"true"                  return TOKTRUE;
"try"                   return TOKTRY;
"typeof"                return TOKTYPEOF;
"uint"                  return TOKUINT;
"ulong"                 return TOKULONG;
"unchecked"             return TOKUNCHECKED;
"unsafe"                return TOKUNSAFE;
"ushort"                return TOKUSHORT;
"using"                 return TOKUSING;
"virtual"               return TOKVIRTUAL;
"void"                  return TOKVOID;
"volatile"              return TOKVOLATILE;
"while"                 return TOKWHILE;
"get"                   return TOKGET;
"set"                   return TOKSET;
"yield"                 return TOKYIELD;
"var"                   return TOKVAR;
"partial"               return TOKPARTIAL;      

{integer_literal}       return INTEGER_LITERAL;
{real_literal}          return REAL_LITERAL;
{character_literal}     return CHARACTER_LITERAL;
{string_literal}        return STRING_LITERAL;

{preprocessor}          /*ignore*/;
{single_line_comment}   /*ignore*/;
"/*"                    { yy_push_state(COMMENT); }
<COMMENT>.              /*ignore*/;
<COMMENT>\n             /*ignore*/;
<COMMENT>"*/"           { yy_pop_state(); };

{rank_specifier}        return RANK_SPECIFIER;

[a-zA-Z_][a-zA-Z0-9_]*  return IDENT;

"{"                     return OBRACE;
"}"                     return EBRACE;
";"                     return SEMICOLON;
"("			            return OPENBRACKET;
")"			            return CLOSEBRACKET;
"["                     return OPENSQUARE;
"]"                     return CLOSESQUARE;

"<"                     return TOKLESS;
">"                     return TOKMORE;
"<="                    return TOKLESSEQ;
">="                    return TOKMOREEQ;
"=="                    return TOKEQUAL;
"!="                    return TOKNOTEQUAL;
"+="                    return PLUSEQ;
"-="                    return MINUSEQ;
"*="                    return MULTEQ;
"/="                    return DIVEQ;
"%="                    return MODEQ;
"^="                    return XOREQ;
"&="                    return ANDEQ;
"|="                    return OREQ;
"<<"                    return LTLT;
">>"                    return GTGT;
"<<="                   return LTLTEQ;
">>="                   return GTGTEQ;
"++"                    return PLUSPLUS;
"--"                    return MINUSMINUS;
"->"                    return ARROW;
"&"                     return AND;
"|"                     return OR;
"^"                     return XOR;
"!"                     return NOT;
"~"                     return INVERSION;             
"="                     return ASSIGN;
"+"                     return TOKSUM;
"-"                     return TOKMIN;
"*"                     return TOKMULTIPLY;
"/"                     return TOKDIV;
"%"                     return MOD;     
"||"                    return TOKOR;
"&&"                    return TOKAND;

","                     return COMMA;
"."                     return TOKDOT;
":"                     return COLON;

{white_space}           /* ignore */;

%%