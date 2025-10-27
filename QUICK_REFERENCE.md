# 🎯 MYA Compiler - Quick Reference Card

## ⚡ **Right Now: Fix Build Error**

```cmd
fix_build_error.bat
build.bat
x64\Release\MYACompiler.exe --test --tokens
```

✅ **Done! Compiler working.**

---

## 🚀 **Later: Full ANTLR Integration**

```cmd
integrate_antlr.bat
```

✅ **Done! Full features enabled.**

---

## 📋 **All Commands**

| Task | Command |
|------|---------|
| **Fix build error** | `fix_build_error.bat` |
| **Build project** | `build.bat` |
| **Run compiler** | `x64\Release\MYACompiler.exe --test` |
| **Show tokens** | `x64\Release\MYACompiler.exe --test --tokens` |
| **Show scope ledger** | `x64\Release\MYACompiler.exe --test --scope-ledger` |
| **Install ANTLR** | `integrate_antlr.bat` |
| **Switch to ANTLR** | `enable_antlr_compiler.bat` |
| **Show AST** | `x64\Release\MYACompiler.exe --test --ast` |
| **Show parse tree** | `x64\Release\MYACompiler.exe --test --parse-tree` |
| **Compile file** | `x64\Release\MYACompiler.exe file.mya --ast` |

---

## 📚 **Documentation**

| File | Purpose |
|------|---------|
| `FIX_NOW.md` | Quick fix for build error |
| `BUILD_FIX.md` | Detailed build troubleshooting |
| `START_HERE.md` | Complete overview |
| `ANTLR_INTEGRATION.md` | Full integration guide |
| `PHASE2_SUMMARY.md` | What was implemented |

---

## 🎓 **Features**

### **Available Now** (After fix)
- ✅ Indentation preprocessing
- ✅ Token generation
- ✅ Scope ledger
- ✅ Figurative indentation
- ✅ Lateral parsing context

### **After ANTLR Integration**
- ⭐ Full lexical analysis
- ⭐ Complete parsing
- ⭐ Parse tree generation
- ⭐ AST building
- ⭐ Error recovery

---

## 🔧 **Troubleshooting**

| Problem | Solution |
|---------|----------|
| "main already defined" | `fix_build_error.bat` |
| Build fails | Check Visual Studio settings |
| Java not found | Install Java JDK 8+ |
| Git not found | Install Git |
| CMake not found | Install CMake |
| Tests fail | Check console output |

---

## 💡 **Two Compilers**

### **MYACompiler.cpp** (Active Now)
- No ANTLR needed
- Preprocessor only
- Quick testing

### **MYACompilerANTLR.cpp** (After Integration)
- Requires ANTLR
- Full features
- Production ready

---

**TL;DR**: 
1. `fix_build_error.bat` → Fixes build
2. `build.bat` → Builds project  
3. `integrate_antlr.bat` → Full setup

🚀 **Start Here**: Run `fix_build_error.bat`
