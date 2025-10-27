/**
 * MYA Language - Indentation Preprocessor
 * 
 * This preprocessor converts leading whitespace into symbolic INDENT/DEDENT tokens
 * for the MYA language's figurative indentation model.
 * 
 * Supports:
 * - Recursive linear parsing (sequential processing)
 * - Non-linear lateral recursion (sibling scope exploration)
 * - Scope ledger tracking for contextual awareness
 */

#ifndef MYA_INDENTATION_PREPROCESSOR_H
#define MYA_INDENTATION_PREPROCESSOR_H

#include <string>
#include <vector>
#include <stack>
#include <sstream>
#include <iostream>

namespace MYA {

/**
 * Token types for the indentation preprocessor
 */
enum class TokenType {
    INDENT,
    DEDENT,
    NEWLINE,
    CODE,
    END_OF_FILE
};

/**
 * Represents a single preprocessed token
 */
struct Token {
    TokenType type;
    std::string value;
    int line;
    int column;
    
    Token(TokenType t, const std::string& v = "", int l = 0, int c = 0)
        : type(t), value(v), line(l), column(c) {}
};

/**
 * Scope information for lateral parsing
 */
struct ScopeInfo {
    int indentLevel;
    int line;
    std::string scopeType;  // "function", "block", "render", "asm", etc.
    
    ScopeInfo(int level, int ln, const std::string& type = "block")
      : indentLevel(level), line(ln), scopeType(type) {}
};

/**
 * IndentationPreprocessor - Handles conversion of whitespace to INDENT/DEDENT tokens
 * 
 * This preprocessor maintains a scope ledger for lateral recursion support,
 * allowing sibling scopes to be processed non-linearly while maintaining
 * contextual relationships.
 */
class IndentationPreprocessor {
private:
    std::vector<Token> tokens;
    std::stack<int> indentStack;
    std::vector<ScopeInfo> scopeLedger;  // Tracks all scopes for lateral navigation
int currentLine;
    int tabWidth;
    
    /**
     * Calculate indentation level from leading whitespace
     */
    int calculateIndentLevel(const std::string& line) {
   int level = 0;
     for (char c : line) {
 if (c == ' ') {
       level++;
 } else if (c == '\t') {
        level += tabWidth;
            } else {
       break;
            }
        }
  return level;
    }
    
    /**
     * Detect scope type from line content
     */
    std::string detectScopeType(const std::string& line) {
        std::string trimmed = line;
        // Remove leading whitespace
    size_t start = trimmed.find_first_not_of(" \t");
        if (start != std::string::npos) {
         trimmed = trimmed.substr(start);
  }
        
     if (trimmed.find("fn ") == 0 || trimmed.find("Main") == 0) {
return "function";
    } else if (trimmed.find("render") == 0) {
     return "render";
        } else if (trimmed.find("asm") == 0) {
            return "asm";
     } else if (trimmed.find("struct") == 0) {
       return "struct";
        } else if (trimmed.find("if ") == 0) {
     return "conditional";
        } else if (trimmed.find("for ") == 0) {
      return "loop";
  } else if (trimmed.find("filter") == 0) {
            return "filter";
        }
  return "block";
    }
    
    /**
     * Check if line is empty or whitespace only
     */
    bool isEmptyLine(const std::string& line) {
        return line.find_first_not_of(" \t\r\n") == std::string::npos;
    }
    
    /**
     * Check if line is a comment
     */
    bool isComment(const std::string& line) {
std::string trimmed = line;
     size_t start = trimmed.find_first_not_of(" \t");
        if (start != std::string::npos) {
    trimmed = trimmed.substr(start);
            return trimmed[0] == '$';
        }
        return false;
    }
 
public:
    IndentationPreprocessor(int tabWidth = 4)
        : currentLine(1), tabWidth(tabWidth) {
     indentStack.push(0);  // Base indentation level
    }
    
    /**
     * Process source code and generate tokens with INDENT/DEDENT markers
     */
    std::vector<Token> process(const std::string& source) {
      tokens.clear();
   scopeLedger.clear();
        currentLine = 1;
   
      std::istringstream stream(source);
    std::string line;
 int previousIndent = 0;
     
        while (std::getline(stream, line)) {
    // Skip empty lines and comments
     if (isEmptyLine(line) || isComment(line)) {
currentLine++;
      continue;
   }
            
            int currentIndent = calculateIndentLevel(line);
         std::string scopeType = detectScopeType(line);
      
    // Handle indentation changes
if (currentIndent > previousIndent) {
     // Entering new scope - INDENT
     indentStack.push(currentIndent);
     tokens.push_back(Token(TokenType::INDENT, "<INDENT>", currentLine, 0));
                scopeLedger.push_back(ScopeInfo(currentIndent, currentLine, scopeType));
   } else if (currentIndent < previousIndent) {
// Exiting scope(s) - DEDENT
    while (!indentStack.empty() && indentStack.top() > currentIndent) {
        indentStack.pop();
            tokens.push_back(Token(TokenType::DEDENT, "<DEDENT>", currentLine, 0));
      }
    
        // Verify indent level matches a previous level
    if (indentStack.empty() || indentStack.top() != currentIndent) {
      std::cerr << "Indentation error at line " << currentLine << std::endl;
      }
   }
          
     // Add the actual code line
  std::string code = line.substr(currentIndent);
tokens.push_back(Token(TokenType::CODE, code, currentLine, currentIndent));
          
            previousIndent = currentIndent;
      currentLine++;
        }
   
    // Close all remaining scopes
        while (indentStack.size() > 1) {
indentStack.pop();
            tokens.push_back(Token(TokenType::DEDENT, "<DEDENT>", currentLine, 0));
        }
        
        tokens.push_back(Token(TokenType::END_OF_FILE, "<EOF>", currentLine, 0));
        return tokens;
    }
    
 /**
     * Get the scope ledger for lateral navigation
     * This allows the parser to perform non-linear lateral recursion
     */
    const std::vector<ScopeInfo>& getScopeLedger() const {
        return scopeLedger;
    }
    
    /**
     * Pretty print tokens for debugging
     */
    void printTokens() const {
        for (const auto& token : tokens) {
 std::cout << "Line " << token.line << ": ";
       switch (token.type) {
   case TokenType::INDENT:
               std::cout << "[INDENT]";
      break;
           case TokenType::DEDENT:
   std::cout << "[DEDENT]";
      break;
case TokenType::CODE:
          std::cout << "[CODE] " << token.value;
          break;
        case TokenType::NEWLINE:
            std::cout << "[NEWLINE]";
       break;
                case TokenType::END_OF_FILE:
         std::cout << "[EOF]";
     break;
            }
            std::cout << std::endl;
        }
    }
    
    /**
     * Print scope ledger for lateral parsing visualization
     */
    void printScopeLedger() const {
        std::cout << "\n=== Scope Ledger (Lateral Navigation Map) ===" << std::endl;
 for (size_t i = 0; i < scopeLedger.size(); i++) {
const auto& scope = scopeLedger[i];
      std::cout << "Scope " << i << ": ";
     std::cout << "Level=" << scope.indentLevel 
    << ", Line=" << scope.line 
   << ", Type=" << scope.scopeType << std::endl;
        }
    }
};

} // namespace MYA

#endif // MYA_INDENTATION_PREPROCESSOR_H
