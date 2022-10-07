#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"


#include "llvm/IR/IntrinsicInst.h"

#include <map>
#include <iterator>

using namespace llvm;

namespace {
struct DebugInstCount : public FunctionPass {
  static char ID;
  DebugInstCount() : FunctionPass(ID) {}
  
  bool doInitialization(Module &M) override{
    errs() << "== DebugInstCount ==\n";
    return false;
  }

  bool runOnFunction(Function &F) override {
    
    std::map<int, int> map;
    for(auto id = (int)Intrinsic::dbg_addr; id <= (int)Intrinsic::dbg_value; ++id){
        map.insert({id, 0});
    }
    
    errs() << "Function: ";
    errs().write_escaped(F.getName()) << '\n';
    for (BasicBlock &BB : F){
        for (Instruction &I : BB){
            auto intrinsicInst = dyn_cast<DbgInfoIntrinsic>(&I);
            if(intrinsicInst != nullptr){
                auto id = intrinsicInst->getIntrinsicID();
                map[id]++;
            }
        }
    }
    
    for(auto it = std::begin(map); it != std::end(map); it++){
        errs() << Intrinsic::getName(it->first) << ": " << it->second << "\n";
    }
    
/*    
    dbg_addr,                                  // llvm.dbg.addr
    dbg_declare,                               // llvm.dbg.declare
    dbg_label,                                 // llvm.dbg.label
    dbg_value,                                 // llvm.dbg.value*/
    
    return false;
  }
  
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }
}; 
}

char DebugInstCount::ID = 0;
static RegisterPass<DebugInstCount> X("debuginstcount", "Debug Instruction Count",
                             false /* Only looks at CFG */,
                             false /* Analysis Pass */);

static RegisterStandardPasses Y(
    PassManagerBuilder::EP_EarlyAsPossible,
    [](const PassManagerBuilder &Builder,
       legacy::PassManagerBase &PM) { PM.add(new DebugInstCount()); });
