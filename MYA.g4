grammar MYA;

// ----------------------------
//  PARSER ENTRY POINTS
// ----------------------------

program
    : (mainFn | statement | functionDef | structDef | renderBlock | asmBlock)* EOF
    ;

statement
    : variableDecl
    | assignment
    | conditional
    | loop
    | filterPass
    | printStmt
    | returnStmt
    | breakStmt
    | continueStmt
    | callExpr
    | freeStmt
;

// ----------------------------
//  CORE LANGUAGE CONSTRUCTS
// ----------------------------

mainFn
    : 'Main' '(' ')' 'fn' ':' block
    ;

functionDef
    : 'fn' Identifier '(' paramList? ')' returnType? ':' block
    ;

paramList
    : param (',' param)*
    ;

param
: Identifier ':' typeName
    ;

returnType
    : '->' typeName
    ;

variableDecl
    : 'let' Identifier ':' typeName '=' expression ';'
    ;

assignment
    : Identifier '=' expression ';'
    ;

freeStmt
    : 'free' Identifier ';'
    ;

returnStmt
    : 'return' expression? ';'
    ;

breakStmt
    : 'break' ';'
    ;

continueStmt
    : 'continue' ';'
    ;

// ----------------------------
//  CONTROL FLOW
// ----------------------------

conditional
    : 'if' expression ':' block ('else' ':' block)?
    ;

loop
    : 'for' Identifier 'in' 'range' expression 'to' expression ':' block
    ;

// ----------------------------
//  ERROR HANDLING
// ----------------------------

filterPass
    : 'filter' expression ( 'pass' (':' block)? )? ';'?
    ;

// ----------------------------
//  PRINTING
// ----------------------------

printStmt
    : 'print' expression (',' expression)* ';'
 ;

// ----------------------------
//  STRUCTURES
// ----------------------------

structDef
    : 'struct' Identifier ':' structBody 'end'
    ;

structBody
    : (Identifier ':' typeName)+
    ;

// ----------------------------
//  ASM BLOCK
// ----------------------------

asmBlock
    : 'asm' ':' asmBody 'end'
    ;

asmBody
    : (~'end')*?
    ;

// ----------------------------
//  RENDER BLOCK (Virtual Rendering Layer)
// ----------------------------

renderBlock
    : 'render' ':' renderBody 'end'
    ;

renderBody
    : (renderStatement | renderBlock)*
    ;

renderStatement
    : Identifier (':' expression)? ';'?
    ;

// ----------------------------
//  EXPRESSIONS
// ----------------------------

expression
  : literal        # literalExpr
    | Identifier       # identifierExpr
    | callExpr # callExpression
    | expression '[' expression ']'         # arrayAccess
    | expression '.' Identifier        # memberAccess
    | expression operator expression        # binaryExpression
    | operator expression              # unaryExpression
    | '(' expression ')'            # groupExpression
    ;

callExpr
    : Identifier '(' (expression (',' expression)*)? ')'
    ;

// ----------------------------
//  OPERATORS
// ----------------------------

operator
    : '+' | '-' | '*' | '/' | '%' 
 | '==' | '!=' | '<' | '>' | '<=' | '>='
    | 'and' | 'or' | 'not'
   ;

// ----------------------------
//  BLOCKS
// ----------------------------

block
    : INDENT (statement | functionDef | conditional | loop | filterPass | printStmt | renderBlock)* DEDENT
    ;

// ----------------------------
//  TERMINALS
// ----------------------------

literal
    : String
    | Number
    | Boolean
    ;

typeName
    : 'int' | 'float' | 'str' | 'bool' | 'list' | 'map' | 'tuple' | 'any'
    ;

Identifier
    : [a-zA-Z_][a-zA-Z0-9_]*
    ;

Boolean
    : 'true' | 'false'
    ;

String
  : '"' (ESC | ~["\\\r\n])* '"'
    ;

fragment ESC
 : '\\' ['"\\nrt]
    ;

Number
    : '-'? [0-9]+ ('.' [0-9]+)?
    ;

// ----------------------------
//  COMMENTS
// ----------------------------

COMMENT_LINE
    : '$' ~[\r\n]* -> skip
    ;

COMMENT_BLOCK
    : '$$' .*? '$$' -> skip
    ;

// ----------------------------
//  WHITESPACE & INDENTATION
// ----------------------------

// Figurative indentation tracking
INDENT  : '<INDENT>';   // To be handled in a custom listener/tokenizer
DEDENT  : '<DEDENT>';
NEWLINE : [\r\n]+ -> skip;
WS      : [ \t]+ -> skip;

// ----------------------------
//  END OF FILE
// ----------------------------
