# MYA Grammar Reference

Complete ANTLR4 grammar specification for the MYA (Machine You Assemble) language.

## Grammar Overview

**File**: `MYA.g4`  
**Language Target**: C++  
**Parser Type**: LL(*) with labeled alternatives  
**Special Features**: Indentation-based syntax with INDENT/DEDENT tokens

## Entry Points

### program
Top-level rule for a complete MYA program.

```antlr
program
    : (statement | functionDef | structDef | renderBlock | asmBlock)* EOF
    ;
```

**Components**:
- Zero or more statements, function definitions, structure definitions, render blocks, or assembly blocks
- Must end with EOF (End of File)

## Statements

### statement
General statement rule - matches any valid statement type.

```antlr
statement
    : variableDecl
    | assignment
    | conditional
    | loop
    | filterPass
  | printStmt
    | callExpr
    | freeStmt
    ;
```

### variableDecl
Variable declaration with type annotation.

```antlr
variableDecl
    : 'let' Identifier ':' typeName '=' expression ';'
    ;
```

**Example**:
```mya
let x: int = 42;
let name: str = "MYA";
let pi: float = 3.14159;
```

### assignment
Variable assignment (must be previously declared).

```antlr
assignment
 : Identifier '=' expression ';'
    ;
```

**Example**:
```mya
x = 100;
name = "Updated";
```

### freeStmt
Memory deallocation statement.

```antlr
freeStmt
    : 'free' Identifier ';'
    ;
```

**Example**:
```mya
free ptr;
```

## Functions

### functionDef
Function definition with optional parameters and return type.

```antlr
functionDef
    : 'fn' Identifier '(' paramList? ')' returnType? ':' block
    ;
```

**Example**:
```mya
fn add(a: int, b: int) -> int:
    return a + b;

fn greet(name: str):
    print "Hello,", name;
```

### MainFn
Special main entry point function (lexer rule, currently).

```antlr
MainFn
    : 'Main' '(' ')' 'fn' ':' block
    ;
```

**Note**: Should be converted to parser rule for consistency:
```antlr
mainFn
    : 'Main' '(' ')' 'fn' ':' block
    ;
```

### paramList & param
Function parameter definitions.

```antlr
paramList
 : param (',' param)*
  ;

param
    : Identifier ':' typeName
    ;
```

### returnType
Optional return type specification.

```antlr
returnType
    : '->' typeName
    ;
```

## Control Flow

### conditional
If-else conditional statement.

```antlr
conditional
    : 'if' expression ':' block ('else' ':' block)?
    ;
```

**Example**:
```mya
if x > 10:
    print "Greater than 10";
else:
    print "Less than or equal to 10";
```

### loop
For-in-range loop construct.

```antlr
loop
    : 'for' Identifier 'in' 'range' expression 'to' expression ':' block
    ;
```

**Example**:
```mya
for i in range 0 to 10:
    print "Iteration:", i;
```

## Error Handling

### filterPass
MYA's unique error handling construct.

```antlr
filterPass
    : 'filter' expression ( 'pass' expression )? ';'?
    ;
```

**Semantics**:
- `filter condition pass: <block>` - Execute block if condition is true
- Acts as guard clause or early return mechanism

**Example**:
```mya
filter x > 0 pass:
    print "x is positive";

filter divisor == 0 pass:
    return 0;  $ Early return

let result: int = dividend / divisor;
```

## I/O Operations

### printStmt
Print statement for output.

```antlr
printStmt
    : 'print' expression (',' expression)* ';'
    ;
```

**Example**:
```mya
print "Hello, World!";
print "x =", x, "y =", y;
```

## Data Structures

### structDef
Structure/record type definition.

```antlr
structDef
    : 'struct' Identifier ':' structBody 'end'
    ;

structBody
    : (Identifier ':' typeName)+
    ;
```

**Example**:
```mya
struct Point:
    x: int
    y: int
    z: int
end

struct Person:
    name: str
    age: int
    height: float
end
```

## Special Blocks

### renderBlock
Virtual rendering layer for graphics.

```antlr
renderBlock
    : 'render' ':' renderBody 'end'
    ;

renderBody
    : (renderStatement | renderBlock)*
 ;

renderStatement
    : Identifier (':' expression)? ';'?
    ;
```

**Example**:
```mya
render:
    viewport: 1920x1080
    camera:
   position: 0, 5, 10
        target: 0, 0, 0
    
    object: cube
        position: 0, 0, 0
     scale: 1, 1, 1
end
```

### asmBlock
Inline assembly block.

```antlr
asmBlock
    : 'asm' ':' ASM_CODE* 'end'
    ;

ASM_CODE
    : ~('end')+ 
    ;
```

**Example**:
```mya
asm:
    mov rax, 42
    add rax, 8
    ret
end
```

## Expressions

### expression
Expression with labeled alternatives for AST generation.

```antlr
expression
    : literal  # literalExpr
    | Identifier    # identifierExpr
    | callExpr        # callExpression
    | expression operator expression   # binaryExpression
    | operator expression # unaryExpression
    | '(' expression ')' # groupExpression
    ;
```

**Alternative Labels**:
- `literalExpr` - Literal values (numbers, strings, booleans)
- `identifierExpr` - Variable references
- `callExpression` - Function calls
- `binaryExpression` - Binary operations (a + b, x == y)
- `unaryExpression` - Unary operations (-x, not flag)
- `groupExpression` - Parenthesized expressions

### callExpr
Function call expression.

```antlr
callExpr
: Identifier '(' (expression (',' expression)*)? ')'
    ;
```

**Example**:
```mya
add(10, 20)
factorial(5)
printf("Value: %d", x)
```

### operator
All operators supported by MYA.

```antlr
operator
    : '+' | '-' | '*' | '/' | '%' 
    | '==' | '!=' | '<' | '>' | '<=' | '>='
    | 'and' | 'or' | 'not'
    ;
```

**Categories**:
- **Arithmetic**: `+`, `-`, `*`, `/`, `%`
- **Comparison**: `==`, `!=`, `<`, `>`, `<=`, `>=`
- **Logical**: `and`, `or`, `not`

## Blocks & Indentation

### block
Indented code block.

```antlr
block
    : INDENT (statement | functionDef | conditional | loop | filterPass | printStmt | renderBlock)* DEDENT
    ;
```

**Note**: `INDENT` and `DEDENT` are synthetic tokens generated by the `MYAIndentationPreprocessor`.

## Terminals

### literal
Literal value terminals.

```antlr
literal
    : String
    | Number
    | Boolean
  ;
```

### typeName
Built-in type names.

```antlr
typeName
    : 'int' | 'float' | 'str' | 'bool' | 'list' | 'map' | 'tuple' | 'any'
    ;
```

**Types**:
- `int` - Integer numbers
- `float` - Floating-point numbers
- `str` - Strings
- `bool` - Boolean values
- `list` - Dynamic arrays
- `map` - Hash maps/dictionaries
- `tuple` - Fixed-size heterogeneous collections
- `any` - Dynamic type (type erasure)

### Identifier
Valid identifier names.

```antlr
Identifier
    : [a-zA-Z_][a-zA-Z0-9_]*
    ;
```

**Rules**:
- Must start with letter or underscore
- Can contain letters, digits, underscores
- Case-sensitive

**Valid**: `x`, `myVar`, `_private`, `counter123`  
**Invalid**: `123var`, `my-var`, `@symbol`

### Boolean
Boolean literal values.

```antlr
Boolean
    : 'true' | 'false'
    ;
```

### String
String literals.

```antlr
String
    : '"' (~["\r\n])* '"'
    ;
```

**Rules**:
- Enclosed in double quotes
- Cannot contain newlines (single-line strings)
- No escape sequences currently (future enhancement)

**Example**: `"Hello, World!"`, `"MYA Language"`

### Number
Numeric literals (integer or float).

```antlr
Number
    : '-'? [0-9]+ ('.' [0-9]+)?
    ;
```

**Format**:
- Optional minus sign for negatives
- One or more digits
- Optional decimal point with fractional part

**Examples**: `42`, `-17`, `3.14159`, `0.5`, `-273.15`

## Comments

### COMMENT_LINE
Single-line comments.

```antlr
COMMENT_LINE
    : '$' ~[\r\n]* -> skip
    ;
```

**Syntax**: `$ This is a comment`

### COMMENT_BLOCK
Multi-line comments.

```antlr
COMMENT_BLOCK
    : '$$' .*? '$$' -> skip
    ;
```

**Syntax**:
```mya
$$
This is a
multi-line comment
$$
```

## Whitespace & Indentation

### INDENT & DEDENT
Synthetic indentation tokens.

```antlr
INDENT  : '<INDENT>';
DEDENT  : '<DEDENT>';
```

**Note**: These are generated by `MYAIndentationPreprocessor`, not directly matched in source.

### NEWLINE
Newline characters (skipped).

```antlr
NEWLINE : [\r\n]+ -> skip;
```

### WS
Whitespace characters (skipped).

```antlr
WS : [ \t]+ -> skip;
```

## Grammar Improvements

### Recommended Changes

1. **Convert MainFn to parser rule**:
   ```antlr
   mainFn
       : 'Main' '(' ')' 'fn' ':' block
    ;
   ```

2. **Add return statement**:
   ```antlr
   returnStmt
       : 'return' expression? ';'
       ;
   ```

3. **Add array/member access**:
   ```antlr
   expression
       : ...
       | expression '[' expression ']'    # arrayAccess
       | expression '.' Identifier          # memberAccess
       ;
   ```

4. **Add break/continue**:
   ```antlr
   breakStmt : 'break' ';' ;
   continueStmt : 'continue' ';' ;
   ```

5. **Improve ASM_CODE lexer rule**:
   ```antlr
   ASM_CODE
       : ~[\r\n]+
  ;
   ```
   Current rule `~('end')+` may have issues.

6. **Add operator precedence**:
   Use precedence climbing or separate expression rules for different precedence levels.

7. **Add string escape sequences**:
   ```antlr
   String
       : '"' (ESC | ~["\\\r\n])* '"'
     ;
   
   fragment ESC
       : '\\' ['"\\nrt]
       ;
   ```

## Usage in C++

### Generate Parser/Lexer

```bash
antlr4 -Dlanguage=Cpp -visitor -no-listener MYA.g4
```

**Generated files**:
- `MYALexer.h` / `MYALexer.cpp`
- `MYAParser.h` / `MYAParser.cpp`
- `MYABaseVisitor.h`
- `MYAVisitor.h`

### Integration Example

```cpp
#include "antlr4-runtime.h"
#include "MYALexer.h"
#include "MYAParser.h"
#include "MYABaseVisitor.h"
#include "MYAIndentationPreprocessor.h"

using namespace antlr4;

int main() {
    // Preprocess indentation
    MYA::IndentationPreprocessor preprocessor;
    auto tokens = preprocessor.process(sourceCode);
    
    // Create custom token stream with INDENT/DEDENT
    // ... (implementation needed)
    
    // Parse
    MYAParser parser(&tokenStream);
  auto tree = parser.program();
    
    // Visit AST
    MyVisitor visitor;
    visitor.visit(tree);
    
    return 0;
}
```

## See Also

- `MYAIndentationPreprocessor.h` - Indentation token generation
- `MYACompiler.cpp` - Main compiler driver
- `README.md` - Full compiler documentation
- `QUICKSTART.md` - Getting started guide
- `example.mya` - Example MYA programs

---

**Grammar Version**: 0.1  
**Last Updated**: 2024  
**Status**: Prototype - Ready for ANTLR4 generation
