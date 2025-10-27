# Build Error Fix - Multiple main() Functions

## ❌ **Error**

```
error LNK2005: main already defined in MYACompiler.obj
fatal error LNK1169: one or more multiply defined symbols found
```

## 📋 **Cause**

Both `MYACompiler.cpp` and `MYACompilerANTLR.cpp` contain a `main()` function, and both are included in the build.

---

## ✅ **Solution**

You need to exclude one compiler from the build. Since ANTLR is not installed yet, exclude the ANTLR version.

### **Quick Fix (Automated)**

```cmd
REM Run this to fix the build error:
fix_build_error.bat
```

This will:
1. Exclude `MYACompilerANTLR.cpp` from the build
2. Keep `MYACompiler.cpp` active
3. Allow the project to build successfully

### **Manual Fix (Visual Studio)**

1. In **Solution Explorer**, right-click `MYACompilerANTLR.cpp`
2. Select **Properties**
3. Go to **Configuration Properties** → **General**
4. Set **Excluded From Build** to **Yes**
5. Click **OK**
6. Build the project

---

## 🔄 **After ANTLR Integration**

When you run `integrate_antlr.bat` and want to use the ANTLR compiler:

```cmd
REM Switch to ANTLR compiler:
enable_antlr_compiler.bat
```

This will:
1. Include `MYACompilerANTLR.cpp` in the build
2. Exclude `MYACompiler.cpp` from the build
3. Enable full ANTLR functionality

---

## 📊 **Compiler Versions**

| File | Status | Features |
|------|--------|----------|
| `MYACompiler.cpp` | ✅ **Active** (default) | Preprocessor only |
| `MYACompilerANTLR.cpp` | ⏸️ Excluded | Full ANTLR integration |

---

## 🎯 **Current Workflow**

### **Before ANTLR Installation**

```cmd
REM 1. Fix build error
fix_build_error.bat

REM 2. Build project
build.bat

REM 3. Run compiler
x64\Release\MYACompiler.exe --test --tokens
```

### **After ANTLR Installation**

```cmd
REM 1. Install ANTLR
integrate_antlr.bat

REM 2. Switch to ANTLR compiler
enable_antlr_compiler.bat

REM 3. Build project
build.bat

REM 4. Run ANTLR compiler
x64\Release\MYACompiler.exe --test --ast --parse-tree
```

---

## 🔍 **Verification**

### Check Which Compiler is Active

Look in the project file or check build output:

```cmd
REM Original compiler active:
MYACompiler.obj

REM ANTLR compiler active:
MYACompilerANTLR.obj
```

---

## 💡 **Why Two Compilers?**

- **MYACompiler.cpp**: Works without ANTLR, shows preprocessor functionality
- **MYACompilerANTLR.cpp**: Requires ANTLR, provides full parsing and AST generation

This allows you to:
1. ✅ Build and test the preprocessor immediately
2. ✅ Avoid ANTLR dependency until ready
3. ✅ Switch to full compiler after ANTLR integration

---

## 📝 **Build Configuration**

### Current Build (No ANTLR)
```
Sources:
  ✅ MYACompiler.cpp
  ❌ MYACompilerANTLR.cpp (excluded)
  ✅ MYAIndentationPreprocessor.h

Output:
  MYACompiler.exe (preprocessor only)
```

### After ANTLR Integration
```
Sources:
  ❌ MYACompiler.cpp (excluded)
  ✅ MYACompilerANTLR.cpp
  ✅ MYAIndentationPreprocessor.h
  ✅ MYACustomTokenStream.h
  ✅ generated/MYALexer.cpp
  ✅ generated/MYAParser.cpp

Output:
  MYACompiler.exe (full ANTLR support)
```

---

## 🚀 **Quick Reference**

| Task | Command |
|------|---------|
| Fix build error | `fix_build_error.bat` |
| Build project | `build.bat` |
| Run compiler | `x64\Release\MYACompiler.exe --test` |
| Install ANTLR | `integrate_antlr.bat` |
| Enable ANTLR compiler | `enable_antlr_compiler.bat` |

---

## ⚠️ **Important Notes**

1. **Don't delete either compiler file** - you'll need both
2. **Only one can be active** in the build at a time
3. **Run fix_build_error.bat first** to build successfully
4. **After ANTLR integration**, run `enable_antlr_compiler.bat`

---

## ✅ **Success Criteria**

After running `fix_build_error.bat`:

- [ ] Build completes without errors
- [ ] `MYACompiler.exe` is generated
- [ ] Can run `MYACompiler.exe --test --tokens`
- [ ] Preprocessor works correctly

---

**Status**: Fix Available  
**Next Step**: Run `fix_build_error.bat`
