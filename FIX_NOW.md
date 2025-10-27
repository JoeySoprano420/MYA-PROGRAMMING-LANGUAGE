# 🔧 Build Error - Quick Fix Guide

## ❌ **Current Error**
```
error LNK2005: main already defined in MYACompiler.obj
```

---

## ⚡ **Quick Fix (30 seconds)**

### **Run this command:**
```cmd
fix_build_error.bat
```

Then build:
```cmd
build.bat
```

**Done!** ✅

---

## 📖 **What This Does**

Excludes `MYACompilerANTLR.cpp` from the build so only `MYACompiler.cpp` (the original compiler) builds.

---

## 🎯 **Two-Compiler Strategy**

Your project has **two versions** of the compiler:

### **1. MYACompiler.cpp** (Original)
- ✅ Works **without** ANTLR
- ✅ Shows preprocessor functionality
- ✅ Can build **right now**
- ⚠️ No parsing or AST generation

### **2. MYACompilerANTLR.cpp** (Enhanced)
- ⚠️ Requires ANTLR installation
- ✅ Full parsing support
- ✅ AST generation
- ✅ Parse tree visualization
- ⏳ Use **after** running `integrate_antlr.bat`

---

## 🔄 **Complete Workflow**

### **NOW: Build Without ANTLR**
```cmd
REM Fix the error
fix_build_error.bat

REM Build
build.bat

REM Test
x64\Release\MYACompiler.exe --test --tokens
```

### **LATER: After ANTLR Integration**
```cmd
REM Install ANTLR (does everything)
integrate_antlr.bat

REM The script will automatically:
REM   1. Download & build ANTLR
REM   2. Generate lexer/parser
REM   3. Switch to ANTLR compiler
REM   4. Build with full features
REM   5. Run tests
```

---

## 🎓 **Understanding the Files**

| File | Purpose | Active When |
|------|---------|-------------|
| `fix_build_error.bat` | Exclude ANTLR compiler | **Run now** |
| `enable_antlr_compiler.bat` | Switch to ANTLR | After ANTLR install |
| `integrate_antlr.bat` | Full setup | When ready for ANTLR |

---

## ✅ **After Running fix_build_error.bat**

You should be able to:
- ✅ Build the project
- ✅ Run the compiler
- ✅ See preprocessor output
- ✅ Test indentation processing
- ✅ View scope ledger

---

## 📞 **Still Having Issues?**

See `BUILD_FIX.md` for detailed troubleshooting.

---

**TL;DR**: Run `fix_build_error.bat` then `build.bat` 🚀
