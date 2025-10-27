/**
 * MYA Language - Compiler Main Entry Point
 * 
 * This is the main driver for the MYA compiler demonstrating:
 * - Indentation preprocessing
 * - Recursive linear parsing
 * - Non-linear lateral recursion support
 * - AST generation (placeholder for future ANTLR integration)
 */

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include "MYAIndentationPreprocessor.h"

using namespace MYA;

/**
 * Read file contents into string
 */
std::string readFile(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("Could not open file: " + filename);
    }
    
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

/**
 * Example MYA source code for testing
 */
const char* EXAMPLE_MYA_CODE = R"(
$ MYA Language Example
$ Demonstrates recursive linear and lateral parsing

Main() fn:
    let x: int = 10;
    let y: int = 20;
    print "Starting MYA program";
    
 filter x > 0 pass:
        print "X is positive";
    
  for i in range 0 to 5:
        print "Iteration:", i;
        multiply(x, i);

fn multiply(a: int, b: int) -> int:
    let result: int = a * b;
    print "Result:", result;
    return result;

fn divide(a: int, b: int) -> int:
  filter b == 0 pass:
        print "Error: Division by zero";
   return 0;
    
let result: int = a / b;
    return result;

struct Point:
    x: int
    y: int
    z: int
end

render:
    viewport: 800x600
    camera:
      position: 0, 0, 10
  target: 0, 0, 0
    
    object: cube
        position: 0, 0, 0
        scale: 1, 1, 1
end

asm:
    mov eax, 0
    mov ebx, 1
    add eax, ebx
end
)";

/**
 * Display usage information
 */
void printUsage() {
    std::cout << "MYA Compiler v0.1 - Machine You Assemble\n";
    std::cout << "========================================\n\n";
    std::cout << "Usage:\n";
    std::cout << "MYA.exe [options] <source_file>\n\n";
    std::cout << "Options:\n";
    std::cout << "  --test           Run with built-in test code\n";
    std::cout << "  --tokens    Display preprocessed tokens\n";
    std::cout << "  --scope-ledger   Display scope ledger for lateral parsing\n";
    std::cout << "  --help       Display this help message\n\n";
    std::cout << "Features:\n";
    std::cout << "  - Recursive Linear Parsing: Sequential syntactic processing\n";
    std::cout << "  - Non-Linear Lateral Recursion: Cross-scope communication\n";
    std::cout << "  - Figurative Indentation: Context-aware scope tracking\n";
    std::cout << "  - ANTLR4 Grammar: Ready for AST generation\n\n";
}

/**
 * Main compiler entry point
 */
int main(int argc, char* argv[]) {
    try {
    bool showTokens = false;
     bool showScopeLedger = false;
        bool useTestCode = false;
        std::string sourceFile;
        
        // Parse command line arguments
   for (int i = 1; i < argc; i++) {
            std::string arg = argv[i];
   
   if (arg == "--help" || arg == "-h") {
        printUsage();
      return 0;
   } else if (arg == "--test") {
       useTestCode = true;
         } else if (arg == "--tokens") {
    showTokens = true;
            } else if (arg == "--scope-ledger") {
           showScopeLedger = true;
     } else if (arg[0] != '-') {
        sourceFile = arg;
 }
  }
 
        // Get source code
        std::string sourceCode;
        if (useTestCode) {
            std::cout << "Running with built-in test code...\n\n";
        sourceCode = EXAMPLE_MYA_CODE;
      } else if (!sourceFile.empty()) {
    std::cout << "Compiling: " << sourceFile << "\n\n";
            sourceCode = readFile(sourceFile);
 } else {
            printUsage();
            return 1;
   }
        
        // Phase 1: Indentation Preprocessing
        std::cout << "=== Phase 1: Indentation Preprocessing ===\n";
    IndentationPreprocessor preprocessor(4);  // 4 spaces per indent
        auto tokens = preprocessor.process(sourceCode);
        
        std::cout << "Preprocessed " << tokens.size() << " tokens.\n\n";
        
        if (showTokens) {
     preprocessor.printTokens();
          std::cout << std::endl;
        }
        
        if (showScopeLedger) {
 preprocessor.printScopeLedger();
            std::cout << std::endl;
  }
        
        // Phase 2: Lexical Analysis (Future: ANTLR4 Lexer)
        std::cout << "=== Phase 2: Lexical Analysis ===\n";
        std::cout << "Status: Awaiting ANTLR4 lexer integration\n";
      std::cout << "Grammar file: MYA.g4\n\n";
     
        // Phase 3: Parsing (Future: ANTLR4 Parser)
        std::cout << "=== Phase 3: Recursive Linear + Lateral Parsing ===\n";
   std::cout << "Status: Awaiting ANTLR4 parser integration\n";
std::cout << "Parser features:\n";
     std::cout << "  - Recursive linear parsing (sequential)\n";
        std::cout << "  - Non-linear lateral recursion (sibling scopes)\n";
        std::cout << "  - Scope ledger for context awareness\n\n";
   
        // Phase 4: AST Generation (Future)
        std::cout << "=== Phase 4: AST Generation ===\n";
        std::cout << "Status: Pending parser completion\n\n";
   
   // Phase 5: Semantic Analysis (Future)
      std::cout << "=== Phase 5: Semantic Analysis ===\n";
        std::cout << "Status: Pending AST generation\n\n";
        
    // Phase 6: Code Generation (Future: WASM -> NASM -> PE)
  std::cout << "=== Phase 6: Code Generation ===\n";
     std::cout << "Status: Planned\n";
     std::cout << "Target pipeline: WASM -> NASM -> PE\n\n";
 
        std::cout << "Preprocessing completed successfully!\n";
    std::cout << "\nNext steps:\n";
     std::cout << "1. Install ANTLR4 runtime for C++\n";
        std::cout << "2. Generate lexer/parser from MYA.g4\n";
        std::cout << "3. Integrate with IndentationPreprocessor\n";
      std::cout << "4. Implement AST visitor pattern\n";
        std::cout << "5. Build semantic analyzer\n";
        std::cout << "6. Implement WASM codegen backend\n";
  
        return 0;
 
    } catch (const std::exception& e) {
     std::cerr << "Error: " << e.what() << std::endl;
     return 1;
    }
}
