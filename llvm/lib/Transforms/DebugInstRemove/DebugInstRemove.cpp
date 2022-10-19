#include "llvm/Transforms/DebugInstRemove/DebugInstRemove.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Pass.h"
#include "llvm/InitializePasses.h"
#include "llvm/IR/IntrinsicInst.h"

#include <map>
#include <iterator>

using namespace llvm;

namespace {
struct DebugInstRemove : public FunctionPass {
  static char ID;
  DebugInstRemove() : FunctionPass(ID) {
      initializeDebugInstRemovePass(*PassRegistry::getPassRegistry());
  }
  
  bool doInitialization(Module &M) override;
  bool runOnFunction(Function &F) override;
};
}

bool DebugInstRemove::doInitialization(Module &M){
    std::vector<Function*> removal_list;

    for(Function &F : M){
        if(F.isIntrinsic()){
            removal_list.push_back(&F);
        }
    }

    bool has_changes = !removal_list.empty();

    while(!removal_list.empty()){
        auto F = removal_list.back();
        removal_list.pop_back();
        F->eraseFromParent();
    }
        
    return has_changes;
}
  
bool DebugInstRemove::runOnFunction(Function &F) {
    std::vector<DbgInfoIntrinsic*> removal_list;

    for (BasicBlock &BB : F){
        for (Instruction &I : BB){
            auto intrinsicInst = dyn_cast<DbgInfoIntrinsic>(&I);
            if(intrinsicInst != nullptr){
                removal_list.push_back(intrinsicInst);
            }
        }
    }

    while(!removal_list.empty()){
        auto inst = removal_list.back();
        inst->replaceAllUsesWith(UndefValue::get(inst->getType()));
        removal_list.pop_back();
        inst->eraseFromParent();
    }

    return true;
}

char DebugInstRemove::ID = 0;

INITIALIZE_PASS(DebugInstRemove, "debuginstremove",
                "Debug Instruction Remove", false, false)

FunctionPass *llvm::createDebugInstRemovePass(){
    return new DebugInstRemove();
}   
