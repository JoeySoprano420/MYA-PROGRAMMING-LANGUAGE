/**
 * MYA Custom Token Stream
 * 
 * Integrates MYAIndentationPreprocessor with ANTLR4 token stream.
 * Converts preprocessed tokens (with INDENT/DEDENT) into ANTLR tokens.
 * 
 * NOTE: This file requires ANTLR4 runtime to be installed.
 * Run setup_antlr.bat or integrate_antlr.bat first.
 */

#ifndef MYA_CUSTOM_TOKEN_STREAM_H
#define MYA_CUSTOM_TOKEN_STREAM_H

// Only compile this file if ANTLR is available
#ifdef MYA_ANTLR_AVAILABLE

#include "antlr4-runtime.h"
#include "generated/MYALexer.h"
#include "MYAIndentationPreprocessor.h"
#include <vector>
#include <memory>

namespace MYA {

/**
 * Custom token that wraps preprocessor tokens for ANTLR
 */
class MYACustomToken : public antlr4::CommonToken {
private:
    Token preprocessedToken;

public:
    MYACustomToken(const Token& ppToken, size_t type, const std::string& text)
        : antlr4::CommonToken(type, text), preprocessedToken(ppToken) {
        setLine(ppToken.line);
  setCharPositionInLine(ppToken.column);
    }

    const Token& getPreprocessedToken() const {
        return preprocessedToken;
    }
};

/**
 * Custom token source that feeds preprocessed tokens to ANTLR
 */
class MYATokenSource : public antlr4::TokenSource {
private:
    std::vector<std::unique_ptr<antlr4::Token>> tokens;
    size_t currentIndex;
    std::string sourceName;

    /**
     * Convert preprocessed tokens to ANTLR tokens
     */
    void convertPreprocessedTokens(const std::vector<Token>& preprocessedTokens) {
        for (const auto& ppToken : preprocessedTokens) {
            size_t tokenType;
          std::string tokenText;

       switch (ppToken.type) {
       case TokenType::INDENT:
    tokenType = MYALexer::INDENT;
  tokenText = "<INDENT>";
      break;

       case TokenType::DEDENT:
         tokenType = MYALexer::DEDENT;
        tokenText = "<DEDENT>";
      break;

     case TokenType::END_OF_FILE:
       tokenType = antlr4::Token::EOF;
           tokenText = "<EOF>";
     break;

              case TokenType::CODE:
       // CODE tokens need to be lexed by ANTLR lexer
        // We'll create a temporary input stream for each code line
  lexCodeToken(ppToken);
        continue; // Skip normal token creation

      case TokenType::NEWLINE:
      tokenType = MYALexer::NEWLINE;
            tokenText = "\n";
break;

    default:
                 continue; // Skip unknown tokens
}

       auto token = std::make_unique<MYACustomToken>(ppToken, tokenType, tokenText);
  tokens.push_back(std::move(token));
        }

        // Ensure EOF token exists
        if (tokens.empty() || tokens.back()->getType() != antlr4::Token::EOF) {
            Token eofToken(TokenType::END_OF_FILE, "<EOF>", 
     preprocessedTokens.empty() ? 0 : preprocessedTokens.back().line, 0);
            auto token = std::make_unique<MYACustomToken>(eofToken, antlr4::Token::EOF, "<EOF>");
   tokens.push_back(std::move(token));
        }
    }

    /**
     * Lex a code token using ANTLR lexer
     */
    void lexCodeToken(const Token& ppToken) {
    // Create a temporary input stream from the code line
        antlr4::ANTLRInputStream input(ppToken.value);
        MYALexer lexer(&input);

        // Get all tokens from this line
   lexer.reset();
  std::unique_ptr<antlr4::Token> token;
        
  while (true) {
            token.reset(lexer.nextToken());
            
            // Skip EOF from the temporary stream
            if (token->getType() == antlr4::Token::EOF) {
         break;
     }

            // Create a copy of the token with adjusted position
         auto copiedToken = std::make_unique<antlr4::CommonToken>(
      token->getType(), 
        token->getText()
   );
            
   // Adjust line and column numbers to match original source
          copiedToken->setLine(ppToken.line);
   copiedToken->setCharPositionInLine(ppToken.column + token->getCharPositionInLine());

     tokens.push_back(std::move(copiedToken));
        }
    }

public:
    MYATokenSource(const std::vector<Token>& preprocessedTokens, const std::string& source = "")
      : currentIndex(0), sourceName(source) {
        convertPreprocessedTokens(preprocessedTokens);
  }

    antlr4::Token* nextToken() override {
        if (currentIndex >= tokens.size()) {
         return tokens.back().get(); // Return EOF
        }
        return tokens[currentIndex++].get();
    }

  size_t getLine() const override {
        if (currentIndex > 0 && currentIndex <= tokens.size()) {
       return tokens[currentIndex - 1]->getLine();
     }
        return 0;
    }

    size_t getCharPositionInLine() override {
      if (currentIndex > 0 && currentIndex <= tokens.size()) {
 return tokens[currentIndex - 1]->getCharPositionInLine();
        }
        return 0;
    }

    antlr4::CharStream* getInputStream() override {
return nullptr; // Not used in our case
    }

 std::string getSourceName() override {
        return sourceName;
    }

    void setTokenFactory(antlr4::TokenFactory<antlr4::CommonToken>* /*factory*/) override {
        // Not needed for our implementation
    }

    antlr4::TokenFactory<antlr4::CommonToken>* getTokenFactory() override {
        return nullptr;
    }
};

/**
 * Custom token stream that uses MYATokenSource
 */
class MYATokenStream : public antlr4::CommonTokenStream {
public:
    MYATokenStream(MYATokenSource* tokenSource)
    : antlr4::CommonTokenStream(tokenSource) {
      // Constructor
    }

    /**
     * Static factory method to create stream from preprocessed tokens
     */
    static std::unique_ptr<MYATokenStream> fromPreprocessedTokens(
   const std::vector<Token>& preprocessedTokens,
        const std::string& sourceName = "") {
        
        auto tokenSource = new MYATokenSource(preprocessedTokens, sourceName);
        return std::make_unique<MYATokenStream>(tokenSource);
    }
};

/**
 * Helper class to integrate preprocessor with ANTLR parsing
 */
class MYAParserIntegration {
private:
IndentationPreprocessor preprocessor;
    std::unique_ptr<MYATokenSource> tokenSource;
    std::unique_ptr<MYATokenStream> tokenStream;

public:
    MYAParserIntegration(int tabWidth = 4) : preprocessor(tabWidth) {}

    /**
     * Process source code and create token stream for ANTLR parser
   */
    MYATokenStream* createTokenStream(const std::string& sourceCode, const std::string& sourceName = "") {
        // Preprocess indentation
        auto preprocessedTokens = preprocessor.process(sourceCode);

        // Create ANTLR token stream
      tokenSource = std::make_unique<MYATokenSource>(preprocessedTokens, sourceName);
  tokenStream = std::make_unique<MYATokenStream>(tokenSource.get());

        return tokenStream.get();
    }

    /**
     * Get the preprocessor (for debugging)
     */
    IndentationPreprocessor& getPreprocessor() {
        return preprocessor;
    }

    /**
     * Get scope ledger (for lateral parsing)
     */
  const std::vector<ScopeInfo>& getScopeLedger() const {
        return preprocessor.getScopeLedger();
    }
};

} // namespace MYA

#else // MYA_ANTLR_AVAILABLE not defined

// Provide stub declarations when ANTLR is not available
// This allows the file to be included without errors

#include "MYAIndentationPreprocessor.h"
#include <vector>
#include <string>

namespace MYA {

// Forward declarations / stubs for when ANTLR is not available
class MYATokenStream;

/**
 * Helper class to integrate preprocessor with ANTLR parsing
 * (Stub version - ANTLR not installed)
 */
class MYAParserIntegration {
private:
    IndentationPreprocessor preprocessor;

public:
    MYAParserIntegration(int tabWidth = 4) : preprocessor(tabWidth) {
        // Note: Full functionality requires ANTLR runtime
    // Run setup_antlr.bat or integrate_antlr.bat
    }

    /**
     * Get the preprocessor (for debugging)
     */
    IndentationPreprocessor& getPreprocessor() {
        return preprocessor;
    }

    /**
     * Get scope ledger (for lateral parsing)
     */
    const std::vector<ScopeInfo>& getScopeLedger() const {
     return preprocessor.getScopeLedger();
    }
    
    /**
     * Process source code and create token stream for ANTLR parser
     * NOTE: This stub version only runs the preprocessor
     */
    void* createTokenStream(const std::string& sourceCode, const std::string& /*sourceName*/ = "") {
        // Just run the preprocessor for now
     preprocessor.process(sourceCode);
  return nullptr; // Cannot create actual token stream without ANTLR
    }
};

} // namespace MYA

#endif // MYA_ANTLR_AVAILABLE

#endif // MYA_CUSTOM_TOKEN_STREAM_H
