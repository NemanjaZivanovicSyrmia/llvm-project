#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Module.h"

#include <map>
#include <iterator>

using namespace llvm;

namespace {
struct DebugInstRemove : public FunctionPass {
  static char ID;
  DebugInstRemove() : FunctionPass(ID) {}

  bool doInitialization(Module &M) override{
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
  
  bool runOnFunction(Function &F) override {
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
}; 
}

char DebugInstRemove::ID = 0;
static RegisterPass<DebugInstRemove> X("debuginstremove", "Debug Instruction Remove",
                             false /* Only looks at CFG */,
                             false /* Analysis Pass */);

static RegisterStandardPasses Y(
    PassManagerBuilder::EP_EarlyAsPossible,
    [](const PassManagerBuilder &Builder,
       legacy::PassManagerBase &PM) { PM.add(new DebugInstRemove()); });
