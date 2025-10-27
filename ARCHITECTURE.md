# MYA Compiler Architecture - Visual Guide

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│           MYA COMPILER SYSTEM  │
│          Version 0.1     │
└─────────────────────────────────────────────────────────────────────┘

    Input: .mya source file
       │
 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 1: INDENTATION PREPROCESSING             ✅   │
│  Class: MYAIndentationPreprocessor  │
│  File: MYAIndentationPreprocessor.h    │
├─────────────────────────────────────────────────────────────────────┤
│  • Read source code line-by-line    │
│  • Calculate indentation levels (spaces/tabs)              │
│  • Generate INDENT/DEDENT tokens       │
│  • Build scope ledger for lateral navigation       │
│  • Detect scope types (function, block, render, etc.)            │
└─────────────────────────────────────────────────────────────────────┘
       │
       │ Token Stream with <INDENT>/<DEDENT>
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 2: LEXICAL ANALYSIS       ⏳   │
│  Tool: ANTLR4 Generated Lexer     │
│  Grammar: MYA.g4          │
├─────────────────────────────────────────────────────────────────────┤
│  • Tokenize preprocessed code     │
│  • Classify tokens (keywords, identifiers, operators)    │
│  • Handle comments and whitespace        │
│  • Recognize literals (numbers, strings, booleans)     │
└─────────────────────────────────────────────────────────────────────┘
     │
  │ Classified Token Stream
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 3: PARSING  ⏳   │
│  Tool: ANTLR4 Generated Parser       │
│  Grammar: MYA.g4   │
│  Model: Recursive Linear + Non-Linear Lateral              │
├─────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Recursive Linear Parsing: │ │
│  │  • Sequential statement processing    │ │
│  │  • Nested block handling              │ │
│  │  • Function call stack management │ │
│  └────────────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Non-Linear Lateral Recursion:       │ │
│  │  • Cross-scope context awareness  │ │
│  │  • Sibling scope communication   │ │
│  │  • Scope ledger consultation      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│  • Build parse tree       │
│  • Handle operator precedence  │
│  • Resolve ambiguities        │
└─────────────────────────────────────────────────────────────────────┘
       │
       │ Parse Tree
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 4: AST GENERATION        ⏳   │
│  Pattern: Visitor Pattern            │
│  Base: MYABaseVisitor (ANTLR Generated)     │
├─────────────────────────────────────────────────────────────────────┤
│  • Traverse parse tree  │
│  • Build Abstract Syntax Tree              │
│  • Simplify structure              │
│  • Remove redundant nodes         │
└─────────────────────────────────────────────────────────────────────┘
       │
       │ Abstract Syntax Tree (AST)
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 5: SEMANTIC ANALYSIS            📋   │
│  Components: Type Checker, Symbol Table, Scope Resolver    │
├─────────────────────────────────────────────────────────────────────┤
│  • Type checking and inference    │
│  • Symbol table construction  │
│  • Scope resolution  │
│  • Variable usage validation         │
│  • Function signature verification │
│  • Error detection and reporting            │
└─────────────────────────────────────────────────────────────────────┘
   │
       │ Validated AST + Symbol Table
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 6: CODE GENERATION      📋   │
│  Pipeline: WASM → NASM → PE    │
├─────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Step 1: WASM Generation      │ │
│  │  • Convert AST to WebAssembly IR        │ │
│  │  • Platform-independent intermediate code     │ │
│  └────────────────────────────────────────────────────────────────┘ │
│┌────────────────────────────────────────────────────────────────┐ │
│  │ Step 2: NASM Assembly     │ │
│  │  • Translate WASM to x86-64 assembly      │ │
│  │  • Handle inline asm blocks           │ │
│  │  • Optimize for target architecture          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Step 3: PE Executable           │ │
│  │  • Assemble NASM to object code             │ │
│  │  • Link with runtime library     │ │
│  │  • Generate Windows PE executable       │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
       │
       │ Executable Binary
     ▼
    Output: .exe file
```

---

## Data Flow Diagram

```
Source Code (.mya)
     │
     │ [Raw text]
     ▼
┌─────────────┐
│Indentation  │
│Preprocessor │ → Scope Ledger
└─────────────┘
     │
     │ [Token stream with INDENT/DEDENT]
 ▼
┌─────────────┐
│ANTLR Lexer  │
└─────────────┘
     │
     │ [Classified tokens]
     ▼
┌─────────────┐
│ANTLR Parser │ ← Scope Ledger (lateral context)
└─────────────┘
     │
     │ [Parse tree]
     ▼
┌─────────────┐
│AST Builder  │
│(Visitor)    │
└─────────────┘
     │
     │ [Abstract Syntax Tree]
▼
┌─────────────┐
│Semantic     │ → Symbol Table
│Analyzer     │ → Error List
└─────────────┘
     │
 │ [Validated AST]
     ▼
┌─────────────┐
│Code Gen:    │
│ 1. WASM     │
│ 2. NASM     │
│ 3. PE       │
└─────────────┘
     │
     │ [Binary code]
     ▼
Executable (.exe)
```

---

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│   MYACompiler.cpp         │
│            (Main Controller)        │
└───────────┬──────────────────────────────────────────────────────┘
  │
            ├─► MYAIndentationPreprocessor.h
   │   └─► Token generation
        │   └─► Scope ledger building
            │
   ├─► MYALexer (ANTLR generated)
     │   └─► Token classification
   │
         ├─► MYAParser (ANTLR generated)
            │   └─► Parse tree construction
            │   └─► Lateral context queries
        │
      ├─► MYAASTBuilder (Custom visitor)
   │   └─► AST generation
         │
            ├─► MYATypeChecker
     │   └─► Type validation
            │
   ├─► MYASymbolTable
 │   └─► Symbol management
    │
     └─► MYACodeGenerator
              ├─► WASMGenerator
    ├─► NASMGenerator
         └─► PEGenerator
```

---

## Parsing Model: Recursive Linear + Lateral

### Traditional Recursive Descent (Depth-First)

```
program
  │
  ├─ fn1()
  │   ├─ stmt1
  │   ├─ stmt2
  │   └─ block
  │     ├─ stmt3
  │   └─ stmt4
  │
  ├─ fn2()
  │   └─ block
  │
└─ Main()
      └─ block
```

*Each function is completely processed before moving to the next*

### MYA's Lateral Model

```
program
  │
  ├─ fn1() ←────────┐
  │   ├─ stmt1      │ Lateral
  │   └─ block      │ Context
  │              │ Sharing
  ├─ fn2() ←────────┤
  │ └─ block      │
  │     │
  └─ Main() ←───────┘
      └─ block
```

*Functions can query lateral context during parsing*

### Scope Ledger Structure

```
Ledger Entry:
┌──────────────────────────┐
│ Scope ID: 0              │
│ Indent Level: 4          │
│ Line Number: 5           │
│ Scope Type: "function"   │
│ Parent Scope: null       │
│ Sibling Scopes: [1, 2]   │
└──────────────────────────┘
```

---

## Token Flow Example

### Input MYA Code:
```mya
Main() fn:
    let x: int = 10;
    print x;
```

### After Preprocessing:
```
Line 1: [CODE] Main() fn:
Line 2: [INDENT]
Line 2: [CODE] let x: int = 10;
Line 3: [CODE] print x;
Line 4: [DEDENT]
Line 4: [EOF]
```

### After Lexical Analysis:
```
IDENTIFIER(Main) LPAREN RPAREN KEYWORD(fn) COLON
INDENT
KEYWORD(let) IDENTIFIER(x) COLON KEYWORD(int) EQUALS NUMBER(10) SEMICOLON
KEYWORD(print) IDENTIFIER(x) SEMICOLON
DEDENT
EOF
```

### Parse Tree:
```
program
 └─ functionDef
     ├─ KEYWORD(fn)
     ├─ IDENTIFIER(Main)
     ├─ paramList (empty)
     ├─ returnType (none)
     └─ block
         ├─ INDENT
         ├─ variableDecl
         │   ├─ KEYWORD(let)
   │ ├─ IDENTIFIER(x)
     │   ├─ typeName(int)
  │   └─ expression(10)
         ├─ printStmt
         │   └─ expression(x)
         └─ DEDENT
```

### AST:
```
Program
 └─ Function(Main)
     └─ Block
 ├─ VarDecl(x: int = 10)
         └─ Print(x)
```

---

## File Organization

```
MYA PROGRAMMING/
│
├─ Grammar & Compiler
│  ├─ MYA.g4  # ANTLR4 grammar
│  ├─ MYAIndentationPreprocessor.h    # Preprocessor
│  └─ MYACompiler.cpp  # Main driver
│
├─ Documentation
│  ├─ README.md    # Overview
│  ├─ QUICKSTART.md            # Getting started
│  ├─ GRAMMAR.md        # Grammar reference
│  └─ IMPLEMENTATION_SUMMARY.md       # Project status
│
├─ Examples
│  └─ example.mya# Sample program
│
├─ Build System
│  ├─ build.bat        # Build script
│  ├─ update_project.bat   # Project updater
│  └─ update_project.ps1  # PowerShell updater
│
└─ Project Files
   ├─ MYA PROGRAMMING.sln      # Solution file
   ├─ MYA PROGRAMMING.vcxproj         # Project file
   └─ MYA PROGRAMMING.vcxproj.filters # Filters file
```

---

## Technology Stack

```
┌─────────────────────────────────────┐
│         Application Layer  │
│      MYA Compiler (C++14)           │
└─────────────────────────────────────┘
  │
┌─────────────────────────────────────┐
│        Parsing Framework           │
│  ANTLR4 C++ Runtime     │
└─────────────────────────────────────┘
               │
┌─────────────────────────────────────┐
│       Code Generation          │
│  WASM → NASM → PE Pipeline      │
└─────────────────────────────────────┘
            │
┌─────────────────────────────────────┐
│     Build System          │
│  MSBuild / Visual Studio 2022        │
└─────────────────────────────────────┘
     │
┌─────────────────────────────────────┐
│       Operating System         │
│       Windows 10/11     │
└─────────────────────────────────────┘
```

---

## Compilation Phases Timeline

```
Time →

[Preprocessing]──→[Lexing]──→[Parsing]──→[AST Build]──→[Semantic]──→[CodeGen]
     100ms         50ms       200ms      100ms150ms  300ms
    ↓
      [Executable]
```

*Estimated times for a 1000-line MYA program*

---

## Error Handling Flow

```
Error Detected
     │
     ├─ Syntax Error (Parser)
     │  ├─ Log error with line/column
     │  ├─ Attempt recovery
     │  └─ Continue parsing if possible
     │
     ├─ Semantic Error (Type Checker)
     │  ├─ Type mismatch
     │  ├─ Undefined variable
   │  └─ Invalid operation
     │
     └─ Code Generation Error
        ├─ Unsupported feature
        └─ Target platform limitation

All errors collected in Error List
     │
     ▼
Display to user with:
 • File name
 • Line number
 • Column number
 • Error message
 • Suggested fix
```

---

## Future Architecture Enhancements

```
┌─────────────────────────────────────────┐
│     MYA Compiler (Current)    │
└─────────────────────────────────────────┘
         │
  ▼
┌─────────────────────────────────────────┐
│    Standard Library Integration         │
│  • Memory management              │
│  • String operations             │
│  • Collections (list, map, etc.)        │
│  • I/O operations      │
└─────────────────────────────────────────┘
        │
               ▼
┌─────────────────────────────────────────┐
│    Optimization Passes         │
│  • Dead code elimination         │
│  • Constant folding    │
│  • Inline expansion      │
│  • Loop unrolling │
└─────────────────────────────────────────┘
     │
            ▼
┌─────────────────────────────────────────┐
│    IDE Integration (LSP)                │
│  • Syntax highlighting│
│  • Autocomplete       │
│  • Error checking            │
│  • Refactoring tools   │
└─────────────────────────────────────────┘
            │
   ▼
┌─────────────────────────────────────────┐
│    Debugger Support         │
│  • Breakpoints           │
│  • Variable inspection    │
│  • Stack traces      │
│  • Source mapping         │
└─────────────────────────────────────────┘
```

---

## Scope Ledger Visualization

```
Source Code:        Scope Ledger:

Main() fn:  ┌─────────────────┐
    stmt1           │ Scope 0         │
    stmt2│ Level: 0     │
          │ Type: function  │
fn add():         │ Line: 1 │
    stmt3       └─────────────────┘
    stmt4    │
     ├─ Sibling
fn multiply():        │
    stmt5   ┌─────────────────┐
      │ Scope 1         │
render:            │ Level: 0        │
    object1   │ Type: function  │
  │ Line: 5         │
   └─────────────────┘
     │
           ├─ Sibling
    │
 ┌─────────────────┐
                │ Scope 2         │
            │ Level: 0        │
 │ Type: function  │
   │ Line: 9         │
    └─────────────────┘
      │
       ├─ Sibling
         │
   ┌─────────────────┐
   │ Scope 3         │
│ Level: 0        │
       │ Type: render    │
      │ Line: 12        │
                └─────────────────┘
```

*Lateral navigation allows querying sibling scopes during parsing*

---

**MYA Compiler Architecture** - v0.1  
*Designed for clarity, built for performance* ⚙️
