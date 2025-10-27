 __  ____   _____ 
|  \/  \ \ / /   |
| |\/| |\ V / /| |
| |  | | | | ___ |
|_|  |_| |_|_|  |_|

"Where code assembles itself, one lateral thought at a time."

# MYA Language Compiler

**Machine You Assemble** - A modern systems programming language with recursive linear and non-linear lateral parsing.

## Overview

MYA is a new programming language designed with a unique parsing model that combines:

- **Recursive Linear Parsing**: Sequential processing of syntactic units (statements, functions, blocks)
- **Non-Linear Lateral Recursion**: Cross-scope communication and contextual awareness between sibling scopes
- **Figurative Indentation**: Indentation suggests hierarchy without strict scope enforcement

## Project Structure

```
MYA PROGRAMMING/
├── MYA.g4             # ANTLR4 grammar definition
├── MYAIndentationPreprocessor.h    # Indentation -> INDENT/DEDENT token converter
├── MYACompiler.cpp               # Main compiler driver
└── README.md        # This file
```

## Language Features

### Core Constructs

- **Functions**: `fn name(params) -> returnType:`
- **Main Entry**: `Main() fn:`
- **Variables**: `let name: type = value;`
- **Control Flow**: `if`, `for in range`
- **Error Handling**: `filter expression pass expression`
- **Structures**: `struct Name: ... end`
- **Assembly Blocks**: `asm: ... end`
- **Virtual Rendering**: `render: ... end`

### Example MYA Code

```mya
$ Comment: Calculate factorial
Main() fn:
    let n: int = 5;
    let result: int = factorial(n);
    print "Factorial of", n, "is", result;

fn factorial(n: int) -> int:
    filter n <= 1 pass:
        return 1;
    
    return n * factorial(n - 1);

fn multiply(a: int, b: int) -> int:
    let result: int = a * b;
    return result;

struct Vector3:
  x: float
    y: float
    z: float
end

render:
    viewport: 1920x1080
    camera:
        position: 0, 5, 10
        target: 0, 0, 0
end

asm:
    mov rax, 42
    ret
end
```

## Grammar Highlights (MYA.g4)

The ANTLR4 grammar supports:

1. **Program Structure**: Functions, structs, render blocks, asm blocks
2. **Statements**: Variable declarations, assignments, control flow
3. **Expressions**: Binary/unary operations, function calls, literals
4. **Operators**: Arithmetic (`+`, `-`, `*`, `/`), logical (`and`, `or`, `not`), comparison
5. **Types**: `int`, `float`, `str`, `bool`, `list`, `map`, `tuple`, `any`
6. **Comments**: Single-line (`$`) and multi-line (`$$ ... $$`)
7. **Indentation**: Symbolic `<INDENT>` and `<DEDENT>` tokens

### Key Grammar Rules

```antlr
program: (statement | functionDef | structDef | renderBlock | asmBlock)* EOF;

functionDef: 'fn' Identifier '(' paramList? ')' returnType? ':' block;

block: INDENT (statement | functionDef | ...)* DEDENT;

expression
    : literal      # literalExpr
    | Identifier               # identifierExpr
    | callExpr # callExpression
    | expression operator expression       # binaryExpression
    | operator expression           # unaryExpression
    | '(' expression ')'                  # groupExpression
    ;
```

## Indentation Preprocessing

The `MYAIndentationPreprocessor` converts whitespace-based indentation into explicit tokens:

```
Original Source:        Preprocessed:
-----------------  ---------------
Main() fn:            Main() fn:
    let x = 10;      <INDENT>
    print x;    let x = 10;
         print x;
      <DEDENT>
```

### Scope Ledger

The preprocessor maintains a **scope ledger** that tracks all scopes for lateral navigation:

```cpp
struct ScopeInfo {
    int indentLevel;
    int line;
    std::string scopeType;  // "function", "block", "render", "asm"
};
```

This enables the parser to:
- Navigate between sibling scopes
- Maintain contextual relationships
- Support non-linear lateral recursion

## Recursive Linear + Lateral Parsing Model

### Recursive Linear Parsing

Processes code sequentially, maintaining a call stack for nested structures:

```
Main() fn
 ├─ statement 1
 ├─ statement 2
 └─ if condition
     ├─ statement 3
   └─ statement 4
```

### Non-Linear Lateral Recursion

Allows cross-communication between sibling scopes at the same depth:

```
Program
 ├─ fn multiply()     ← Can reference context from divide()
 │   └─ block
 ├─ fn divide() ← Can reference context from multiply()
 │   └─ block
 └─ Main() fn
     └─ block
```

This is conceptually different from traditional depth-first parsing - scopes can be "aware" of their siblings without strict sequential dependency.

## Building the Compiler

### Prerequisites

- Visual Studio 2022 (C++14 support)
- ANTLR4 C++ runtime (for future integration)
- CMake or MSBuild

### Current Status

**Phase 1: Indentation Preprocessing** ✅ Complete
- Whitespace to INDENT/DEDENT conversion
- Scope ledger tracking
- Token stream generation

**Phase 2: Lexical Analysis** ⏳ Pending
- ANTLR4 lexer generation from `MYA.g4`
- Token classification

**Phase 3: Parsing** ⏳ Pending
- ANTLR4 parser generation
- Recursive linear parsing implementation
- Lateral recursion context handling

**Phase 4: AST Generation** ⏳ Pending
- Visitor pattern implementation
- Semantic tree construction

**Phase 5: Semantic Analysis** 📋 Planned
- Type checking
- Symbol table management
- Scope resolution

**Phase 6: Code Generation** 📋 Planned
- WASM intermediate representation
- NASM assembly generation
- PE executable output

### Compilation

1. **Add files to Visual Studio project**:
   - Add `MYACompiler.cpp` to Source Files
   - Add `MYAIndentationPreprocessor.h` to Header Files
   - Add `MYA.g4` to Resource Files (for reference)

2. **Build the project**:
   ```
   MSBuild "MYA PROGRAMMING.vcxproj" /p:Configuration=Release
   ```

3. **Run with test code**:
   ```
   MYA.exe --test --tokens --scope-ledger
   ```

4. **Compile a MYA file**:
   ```
   MYA.exe program.mya --tokens
   ```

## Usage

```
MYA.exe [options] <source_file>

Options:
  --test           Run with built-in test code
  --tokens         Display preprocessed tokens
  --scope-ledger   Display scope ledger for lateral parsing
  --help           Display help message
```

## Next Steps

### Integrating ANTLR4

1. **Install ANTLR4 C++ Runtime**:
   ```bash
   git clone https://github.com/antlr/antlr4.git
   cd antlr4/runtime/Cpp
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```

2. **Generate Parser/Lexer**:
   ```bash
   antlr4 -Dlanguage=Cpp -visitor -no-listener MYA.g4
   ```

3. **Integrate with Preprocessor**:
   - Feed preprocessed tokens to ANTLR lexer
   - Custom token stream that includes INDENT/DEDENT
   - Implement lateral context tracking in parser

4. **Build AST Visitor**:
   ```cpp
class MYAASTVisitor : public MYABaseVisitor {
       // Override visit methods for each grammar rule
   };
   ```

### Future Enhancements

- **Standard Library**: Built-in functions and data structures
- **Type Inference**: Reduce explicit type annotations
- **Module System**: Import/export mechanisms
- **Optimization Passes**: Dead code elimination, constant folding
- **LLVM Backend**: Alternative to WASM for better optimization
- **Debugging Support**: Source maps, breakpoints, stack traces
- **IDE Integration**: LSP server for syntax highlighting, autocomplete

## Language Philosophy

MYA is designed around these principles:

1. **Clarity over Cleverness**: Code should be obvious
2. **Lateral Thinking**: Scopes can be contextually aware of siblings
3. **Figurative Structure**: Indentation guides but doesn't dictate
4. **Direct Hardware Access**: `asm` blocks for system-level programming
5. **Visual Rendering**: First-class support for graphics (`render` blocks)
6. **Error Handling as Flow**: `filter` and `pass` integrate naturally

## Contributing

This is a prototype implementation. Areas for contribution:

- ANTLR4 integration
- AST visitor implementation
- Type system design
- Code generation backend
- Standard library functions
- Test suite development
- Documentation and examples

## License

[Specify your license here]

## Contact

[Your contact information]

---

**MYA** - *Where code assembles itself, one lateral thought at a time.* ⚙️
