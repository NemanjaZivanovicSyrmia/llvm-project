; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -ppc-asm-full-reg-names -verify-machineinstrs -disable-lsr \
; RUN:   -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr10 < %s | FileCheck %s
; RUN: llc -ppc-asm-full-reg-names -verify-machineinstrs -disable-lsr \
; RUN:   -mtriple=powerpc64-unknown-linux-gnu -mcpu=pwr10 < %s | FileCheck %s \
; RUN:   --check-prefix=CHECK-BE

; This test checks the PPCLoopInstrFormPrep pass supports the lxvp and stxvp
; intrinsics so we generate more dq-form instructions instead of x-forms.

%_elem_type_of_x = type <{ double }>
%_elem_type_of_y = type <{ double }>

define void @foo(i64* %.n, [0 x %_elem_type_of_x]* %.x, [0 x %_elem_type_of_y]* %.y, <2 x double>* %.sum) {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld r5, 0(r3)
; CHECK-NEXT:    cmpdi r5, 0
; CHECK-NEXT:    blelr cr0
; CHECK-NEXT:  # %bb.1: # %_loop_1_do_.lr.ph
; CHECK-NEXT:    addi r3, r4, 1
; CHECK-NEXT:    addi r4, r5, -1
; CHECK-NEXT:    lxv vs0, 0(r6)
; CHECK-NEXT:    rldicl r4, r4, 60, 4
; CHECK-NEXT:    addi r4, r4, 1
; CHECK-NEXT:    mtctr r4
; CHECK-NEXT:    .p2align 5
; CHECK-NEXT:  .LBB0_2: # %_loop_1_do_
; CHECK-NEXT:    #
; CHECK-NEXT:    lxvp vsp34, 0(r3)
; CHECK-NEXT:    lxvp vsp36, 32(r3)
; CHECK-NEXT:    addi r3, r3, 128
; CHECK-NEXT:    xvadddp vs0, vs0, vs35
; CHECK-NEXT:    xvadddp vs0, vs0, vs34
; CHECK-NEXT:    xvadddp vs0, vs0, vs37
; CHECK-NEXT:    xvadddp vs0, vs0, vs36
; CHECK-NEXT:    bdnz .LBB0_2
; CHECK-NEXT:  # %bb.3: # %_loop_1_loopHeader_._return_bb_crit_edge
; CHECK-NEXT:    stxv vs0, 0(r6)
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: foo:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    ld r5, 0(r3)
; CHECK-BE-NEXT:    cmpdi r5, 0
; CHECK-BE-NEXT:    blelr cr0
; CHECK-BE-NEXT:  # %bb.1: # %_loop_1_do_.lr.ph
; CHECK-BE-NEXT:    addi r3, r4, 1
; CHECK-BE-NEXT:    addi r4, r5, -1
; CHECK-BE-NEXT:    lxv vs0, 0(r6)
; CHECK-BE-NEXT:    rldicl r4, r4, 60, 4
; CHECK-BE-NEXT:    addi r4, r4, 1
; CHECK-BE-NEXT:    mtctr r4
; CHECK-BE-NEXT:    .p2align 5
; CHECK-BE-NEXT:  .LBB0_2: # %_loop_1_do_
; CHECK-BE-NEXT:    #
; CHECK-BE-NEXT:    lxvp vsp34, 0(r3)
; CHECK-BE-NEXT:    lxvp vsp36, 32(r3)
; CHECK-BE-NEXT:    addi r3, r3, 128
; CHECK-BE-NEXT:    xvadddp vs0, vs0, vs34
; CHECK-BE-NEXT:    xvadddp vs0, vs0, vs35
; CHECK-BE-NEXT:    xvadddp vs0, vs0, vs36
; CHECK-BE-NEXT:    xvadddp vs0, vs0, vs37
; CHECK-BE-NEXT:    bdnz .LBB0_2
; CHECK-BE-NEXT:  # %bb.3: # %_loop_1_loopHeader_._return_bb_crit_edge
; CHECK-BE-NEXT:    stxv vs0, 0(r6)
; CHECK-BE-NEXT:    blr
entry:
  %_val_n_2 = load i64, i64* %.n, align 8
  %_grt_tmp7 = icmp slt i64 %_val_n_2, 1
  br i1 %_grt_tmp7, label %_return_bb, label %_loop_1_do_.lr.ph

_loop_1_do_.lr.ph:                                ; preds = %entry
  %x_rvo_based_addr_5 = getelementptr inbounds [0 x %_elem_type_of_x], [0 x %_elem_type_of_x]* %.x, i64 0, i64 -1
  %.sum.promoted = load <2 x double>, <2 x double>* %.sum, align 16
  br label %_loop_1_do_

_loop_1_do_:                                      ; preds = %_loop_1_do_.lr.ph, %_loop_1_do_
  %_val_sum_9 = phi <2 x double> [ %.sum.promoted, %_loop_1_do_.lr.ph ], [ %_add_tmp49, %_loop_1_do_ ]
  %i.08 = phi i64 [ 1, %_loop_1_do_.lr.ph ], [ %_loop_1_update_loop_ix, %_loop_1_do_ ]
  %x_ix_dim_0_6 = getelementptr %_elem_type_of_x, %_elem_type_of_x* %x_rvo_based_addr_5, i64 %i.08
  %x_ix_dim_0_ = bitcast %_elem_type_of_x* %x_ix_dim_0_6 to i8*
  %0 = getelementptr i8, i8* %x_ix_dim_0_, i64 1
  %1 = tail call <256 x i1> @llvm.ppc.vsx.lxvp(i8* %0)
  %2 = tail call { <16 x i8>, <16 x i8> } @llvm.ppc.vsx.disassemble.pair(<256 x i1> %1)
  %.fca.0.extract1 = extractvalue { <16 x i8>, <16 x i8> } %2, 0
  %.fca.1.extract2 = extractvalue { <16 x i8>, <16 x i8> } %2, 1
  %3 = getelementptr i8, i8* %x_ix_dim_0_, i64 33
  %4 = tail call <256 x i1> @llvm.ppc.vsx.lxvp(i8* %3)
  %5 = tail call { <16 x i8>, <16 x i8> } @llvm.ppc.vsx.disassemble.pair(<256 x i1> %4)
  %.fca.0.extract = extractvalue { <16 x i8>, <16 x i8> } %5, 0
  %.fca.1.extract = extractvalue { <16 x i8>, <16 x i8> } %5, 1
  %6 = bitcast <16 x i8> %.fca.0.extract1 to <2 x double>
  %_add_tmp23 = fadd contract <2 x double> %_val_sum_9, %6
  %7 = bitcast <16 x i8> %.fca.1.extract2 to <2 x double>
  %_add_tmp32 = fadd contract <2 x double> %_add_tmp23, %7
  %8 = bitcast <16 x i8> %.fca.0.extract to <2 x double>
  %_add_tmp40 = fadd contract <2 x double> %_add_tmp32, %8
  %9 = bitcast <16 x i8> %.fca.1.extract to <2 x double>
  %_add_tmp49 = fadd contract <2 x double> %_add_tmp40, %9
  %_loop_1_update_loop_ix = add nuw nsw i64 %i.08, 16
  %_grt_tmp = icmp sgt i64 %_loop_1_update_loop_ix, %_val_n_2
  br i1 %_grt_tmp, label %_loop_1_loopHeader_._return_bb_crit_edge, label %_loop_1_do_

_loop_1_loopHeader_._return_bb_crit_edge:         ; preds = %_loop_1_do_
  store <2 x double> %_add_tmp49, <2 x double>* %.sum, align 16
  br label %_return_bb

_return_bb:                                       ; preds = %_loop_1_loopHeader_._return_bb_crit_edge, %entry
  ret void
}

declare <256 x i1> @llvm.ppc.vsx.lxvp(i8*)
declare { <16 x i8>, <16 x i8> } @llvm.ppc.vsx.disassemble.pair(<256 x i1>)
