/**
 * MYA Language - Compiler with ANTLR Integration
 * 
 * This version integrates ANTLR4 lexer/parser with the indentation preprocessor.
 * 
 * NOTE: This file requires ANTLR4 to be installed.
 * Run integrate_antlr.bat to set up ANTLR before compiling.
 */

// Only compile ANTLR-dependent code if available
#ifdef MYA_ANTLR_AVAILABLE

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

// ANTLR4 includes
#include "antlr4-runtime.h"
#include "generated/MYALexer.h"
#include "generated/MYAParser.h"
#include "generated/MYABaseVisitor.h"

// MYA includes
#include "MYAIndentationPreprocessor.h"
#include "MYACustomTokenStream.h"

using namespace antlr4;
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
$ MYA Language Example with ANTLR
Main() fn:
    let x: int = 10;
    let y: int = 20;
    print "Sum:", add(x, y);

fn add(a: int, b: int) -> int:
    let result: int = a + b;
    return result;
)";


/**
 * Custom error listener for better error reporting
 */
class MYAErrorListener : public BaseErrorListener {
public:
    void syntaxError(
        Recognizer* /*recognizer*/,
        Token* /*offendingSymbol*/,
        size_t line,
        size_t charPositionInLine,
        const std::string& msg,
      std::exception_ptr /*e*/) override {
        
    std::cerr << "Syntax error at line " << line << ":" << charPositionInLine 
    << " - " << msg << std::endl;
}
};

/**
 * Simple AST printer visitor
 */
class MYAASTPrinter : public MYABaseVisitor {
private:
    int indentLevel = 0;
    
void printIndent() {
        for (int i = 0; i < indentLevel; i++) {
            std::cout << "";
        }
    }

public:
    antlrcpp::Any visitProgram(MYAParser::ProgramContext* ctx) override {
   std::cout << "Program:" << std::endl;
        indentLevel++;
        visitChildren(ctx);
        indentLevel--;
        return nullptr;
    }

    antlrcpp::Any visitFunctionDef(MYAParser::FunctionDefContext* ctx) override {
 printIndent();
        std::cout << "Function: " << ctx->Identifier()->getText() << std::endl;
        indentLevel++;
    visitChildren(ctx);
 indentLevel--;
        return nullptr;
    }

    antlrcpp::Any visitVariableDecl(MYAParser::VariableDeclContext* ctx) override {
  printIndent();
        std::cout << "VarDecl: " << ctx->Identifier()->getText() 
            << " : " << ctx->typeName()->getText() << std::endl;
      indentLevel++;
        visitChildren(ctx);
  indentLevel--;
        return nullptr;
    }

    antlrcpp::Any visitPrintStmt(MYAParser::PrintStmtContext* ctx) override {
        printIndent();
        std::cout << "Print Statement" << std::endl;
indentLevel++;
        visitChildren(ctx);
      indentLevel--;
 return nullptr;
    }

    antlrcpp::Any visitCallExpr(MYAParser::CallExprContext* ctx) override {
        printIndent();
        std::cout << "Call: " << ctx->Identifier()->getText() << std::endl;
        indentLevel++;
        visitChildren(ctx);
        indentLevel--;
        return nullptr;
    }

    antlrcpp::Any visitConditional(MYAParser::ConditionalContext* ctx) override {
    printIndent();
        std::cout << "If Statement" << std::endl;
        indentLevel++;
        visitChildren(ctx);
        indentLevel--;
  return nullptr;
    }

    antlrcpp::Any visitLoop(MYAParser::LoopContext* ctx) override {
 printIndent();
      std::cout << "For Loop: " << ctx->Identifier()->getText() << std::endl;
        indentLevel++;
   visitChildren(ctx);
   indentLevel--;
        return nullptr;
    }
};

/**
 * Display usage information
 */
void printUsage() {
    std::cout << "MYA Compiler v0.2 - Machine You Assemble (with ANTLR)\n";
    std::cout << "======================================================\n\n";
    std::cout << "Usage:\n";
    std::cout << "  MYACompiler.exe [options] <source_file>\n\n";
 std::cout << "Options:\n";
    std::cout << "  --test   Run with built-in test code\n";
  std::cout << "  --tokens         Display preprocessed tokens\n";
    std::cout << "  --parse-tree     Display parse tree\n";
    std::cout << "  --ast            Display AST\n";
    std::cout << "  --scope-ledger   Display scope ledger\n";
    std::cout << "  --help         Display this help message\n\n";
    std::cout << "Examples:\n";
    std::cout << "  MYACompiler.exe --test --ast\n";
    std::cout << "  MYACompiler.exe program.mya --parse-tree\n\n";
}

/**
 * Main compiler entry point
 */
int main(int argc, char* argv[]) {
    try {
 bool showTokens = false;
        bool showParseTree = false;
        bool showAST = false;
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
     } else if (arg == "--parse-tree") {
        showParseTree = true;
 } else if (arg == "--ast") {
        showAST = true;
         } else if (arg == "--scope-ledger") {
          showScopeLedger = true;
            } else if (arg[0] != '-') {
     sourceFile = arg;
     }
        }
    
        // Get source code
        std::string sourceCode;
        std::string sourceName;
        
        if (useTestCode) {
       std::cout << "Running with built-in test code...\n\n";
            sourceCode = EXAMPLE_MYA_CODE;
   sourceName = "<test>";
        } else if (!sourceFile.empty()) {
       std::cout << "Compiling: " << sourceFile << "\n\n";
        sourceCode = readFile(sourceFile);
            sourceName = sourceFile;
  } else {
            printUsage();
            return 1;
        }
      
  // Phase 1: Indentation Preprocessing
        std::cout << "=== Phase 1: Indentation Preprocessing ===\n";
     MYAParserIntegration integration(4);
        
        // Create token stream
        auto tokenStream = integration.createTokenStream(sourceCode, sourceName);
        
    std::cout << "Preprocessing complete.\n\n";
        
        if (showTokens) {
integration.getPreprocessor().printTokens();
            std::cout << std::endl;
        }
  
 if (showScopeLedger) {
          integration.getPreprocessor().printScopeLedger();
    std::cout << std::endl;
  }
        
 // Phase 2: Lexical Analysis & Phase 3: Parsing
        std::cout << "=== Phase 2-3: Lexical Analysis & Parsing ===\n";
        
   // Create parser
      MYAParser parser(tokenStream);
      
        // Add custom error listener
        MYAErrorListener errorListener;
    parser.removeErrorListeners();
        parser.addErrorListener(&errorListener);
    
        // Parse the program
        auto tree = parser.program();
     
        std::cout << "Parsing complete.\n\n";
        
  if (showParseTree) {
            std::cout << "=== Parse Tree ===\n";
            std::cout << tree->toStringTree(&parser) << "\n\n";
        }
        
     // Phase 4: AST Generation
        if (showAST) {
  std::cout << "=== Phase 4: AST Generation ===\n";
       MYAASTPrinter astPrinter;
            astPrinter.visit(tree);
            std::cout << "\n";
      }
  
        // Summary
        std::cout << "=== Compilation Summary ===\n";
        std::cout << "✓ Indentation preprocessing\n";
        std::cout << "✓ Lexical analysis\n";
        std::cout << "✓ Parsing\n";
        std::cout << "✓ Parse tree generation\n";
        if (showAST) {
            std::cout << "✓ AST generation\n";
        }
std::cout << "\nNext phases:\n";
        std::cout << "  ⏳ Semantic analysis\n";
std::cout << "  ⏳ Code generation\n\n";
        
        std::cout << "Compilation successful!\n";
  return 0;
   
    } catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}

#else // MYA_ANTLR_AVAILABLE not defined

#include <iostream>

int main() {
    std::cerr << "ERROR: This executable was compiled without ANTLR support.\n\n";
    std::cerr << "To enable ANTLR integration:\n";
    std::cerr << "1. Run: integrate_antlr.bat\n";
    std::cerr << "2. Rebuild the project\n";
 std::cerr << "3. Compile with MYA_ANTLR_AVAILABLE defined\n\n";
 std::cerr << "For now, use the standard MYACompiler.exe instead.\n";
    return 1;
}

#endif // MYA_ANTLR_AVAILABLE
