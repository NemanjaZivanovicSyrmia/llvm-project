#ifndef LLVM_TRANSFORMS_DEBUGINSTREMOVE_DEBUGINSTREMOVE_H
#define LLVM_TRANSFORMS_DEBUGINSTREMOVE_DEBUGINSTREMOVE_H

#include "llvm/IR/PassManager.h"

namespace llvm {

class FunctionPass;

FunctionPass *createDebugInstRemovePass();
}

#endif
