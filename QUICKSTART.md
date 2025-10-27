# MYA Language Quick Start Guide

## Getting Started with MYA

This guide will help you get up and running with the MYA (Machine You Assemble) compiler.

## Installation & Setup

### 1. Project Files

The MYA compiler project includes:

- `MYA.g4` - ANTLR4 grammar definition
- `MYAIndentationPreprocessor.h` - Indentation preprocessor
- `MYACompiler.cpp` - Main compiler driver
- `example.mya` - Example MYA program
- `README.md` - Full documentation

### 2. Build the Compiler

#### Using Visual Studio

1. Open `MYA PROGRAMMING.sln` in Visual Studio 2022
2. Run the PowerShell script to update the project:
   ```powershell
.\update_project.ps1
   ```
3. Reload the project in Visual Studio (right-click solution ? Reload)
4. Build the solution: `Build ? Build Solution` (Ctrl+Shift+B)

#### Using MSBuild (Command Line)

```cmd
MSBuild "MYA PROGRAMMING.vcxproj" /p:Configuration=Release /p:Platform=x64
```

### 3. Run the Compiler

#### Test with Built-in Example

```cmd
cd "C:\Users\420up\source\repos\MYA PROGRAMMING\x64\Release"
MYACompiler.exe --test --tokens --scope-ledger
```

#### Compile a MYA File

```cmd
MYACompiler.exe example.mya --tokens
```

## Writing Your First MYA Program

### Hello World

Create a file `hello.mya`:

```mya
$ Hello World in MYA
Main() fn:
    print "Hello, World!";
```

### Basic Calculator

Create `calculator.mya`:

```mya
$ Simple Calculator

Main() fn:
    let a: int = 10;
    let b: int = 5;
    
    print "Addition:", add(a, b);
    print "Subtraction:", subtract(a, b);
    print "Multiplication:", multiply(a, b);
    print "Division:", divide(a, b);

fn add(x: int, y: int) -> int:
    return x + y;

fn subtract(x: int, y: int) -> int:
    return x - y;

fn multiply(x: int, y: int) -> int:
    return x * y;

fn divide(x: int, y: int) -> int:
    filter y == 0 pass:
        print "Error: Division by zero";
        return 0;
    
    return x / y;
```

### Factorial Calculator

```mya
$ Factorial Calculator

Main() fn:
    let n: int = 5;
    let result: int = factorial(n);
    print "Factorial of", n, "is", result;

fn factorial(n: int) -> int:
    filter n <= 1 pass:
        return 1;
    
 return n * factorial(n - 1);
```

## Language Features

### 1. Variables

```mya
let x: int = 42;
let name: str = "MYA";
let pi: float = 3.14159;
let flag: bool = true;
```

### 2. Functions

```mya
fn greet(name: str) -> str:
    return "Hello, " + name;

fn calculate(a: int, b: int) -> int:
    let result: int = a + b;
    return result;
```

### 3. Control Flow

#### If Statements

```mya
if x > 10:
    print "x is greater than 10";
else:
    print "x is less than or equal to 10";
```

#### For Loops

```mya
for i in range 0 to 10:
    print "Iteration:", i;
```

### 4. Error Handling

```mya
filter condition pass:
    $ Code runs if condition is true
    print "Condition passed";
```

### 5. Structures

```mya
struct Person:
    name: str
    age: int
    height: float
end

$ Usage:
let person: Person = Person("John", 30, 1.75);
```

### 6. Comments

```mya
$ Single-line comment

$$
Multi-line
comment
block
$$
```

## Command Line Options

```
MYACompiler.exe [options] <source_file>

Options:
  --test      Run with built-in test code
  --tokens  Display preprocessed tokens
  --scope-ledger   Display scope ledger for lateral parsing
  --help           Display help message
```

## Understanding the Compilation Process

### Phase 1: Indentation Preprocessing ?

Converts whitespace indentation to symbolic INDENT/DEDENT tokens:

```
Source Code: Preprocessed:
-----------       -------------
Main() fn:         Main() fn:
    print "Hello";   <INDENT>
    print "Hello";
         <DEDENT>
```

### Phase 2: Lexical Analysis (Upcoming)

Will use ANTLR4 to tokenize the preprocessed code.

### Phase 3: Parsing (Upcoming)

- **Recursive Linear Parsing**: Sequential processing
- **Non-Linear Lateral Recursion**: Cross-scope awareness

### Phase 4: AST Generation (Planned)

Build an Abstract Syntax Tree for semantic analysis.

### Phase 5: Code Generation (Planned)

Target pipeline: `MYA ? WASM ? NASM ? PE`

## Debugging Tips

### View Preprocessed Tokens

```cmd
MYACompiler.exe program.mya --tokens
```

Output shows how indentation is converted:
```
Line 1: [CODE] Main() fn:
Line 2: [INDENT]
Line 2: [CODE] print "Hello";
Line 3: [DEDENT]
Line 3: [EOF]
```

### View Scope Ledger

```cmd
MYACompiler.exe program.mya --scope-ledger
```

Shows the scope hierarchy for lateral parsing:
```
=== Scope Ledger (Lateral Navigation Map) ===
Scope 0: Level=4, Line=2, Type=function
Scope 1: Level=4, Line=5, Type=block
```

## Example Programs

### Fibonacci Sequence

```mya
Main() fn:
    for i in range 0 to 10:
        print "fib(", i, ") =", fibonacci(i);

fn fibonacci(n: int) -> int:
    filter n <= 1 pass:
        return n;
    
    return fibonacci(n - 1) + fibonacci(n - 2);
```

### Prime Number Checker

```mya
Main() fn:
    for i in range 2 to 20:
      if isPrime(i):
            print i, "is prime";

fn isPrime(n: int) -> bool:
    filter n <= 1 pass:
        return false;
    
    for i in range 2 to n:
        if n % i == 0:
    return false;
    
    return true;
```

## Next Steps

1. **Explore the example.mya file** - See all language features in action
2. **Read the full README.md** - Understand the compiler architecture
3. **Study the MYA.g4 grammar** - Learn the formal language specification
4. **Experiment with code** - Write your own MYA programs
5. **Install ANTLR4** - Prepare for full compiler integration

## Getting Help

### Grammar Reference

See `MYA.g4` for the complete ANTLR4 grammar definition.

### Architecture Documentation

See `README.md` for detailed information about:
- Recursive linear parsing
- Non-linear lateral recursion
- Scope ledger system
- Future development roadmap

### Common Issues

**Issue**: "Could not open file"
**Solution**: Make sure the file path is correct and the file exists.

**Issue**: "Indentation error"
**Solution**: Check that your indentation is consistent (use spaces or tabs, not both).

**Issue**: Project won't build
**Solution**: Run `update_project.ps1` to ensure all files are included in the project.

## Contributing

This is a prototype compiler. Areas for contribution:
- ANTLR4 integration
- Standard library functions
- Code optimization
- Error messages
- Test suite
- Documentation

## Resources

- ANTLR4: https://www.antlr.org/
- C++14 Standard: https://isocpp.org/
- Compiler Design Theory: Dragon Book (Compilers: Principles, Techniques, and Tools)

---

**Happy Coding with MYA!** ??

*Where code assembles itself, one lateral thought at a time.*
