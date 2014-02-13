REMAINDER:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),70000);
    MOV(INDD(R0,2),LABEL(REMAINDER_CODE));
    JUMP(REMAINDER_EXIT);
    
REMAINDER_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("REMAINDER_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    PUSH(R1);
    
    //R1 = abs(arg_2)
    MOV(R1, FPARG(3));
    MOV(R1, INDD(R1,1));
    PUSH(R1);
    CALL(ABS);
    MOV(R1, R0);
    //R0 = abs(arg_1)
    MOV(R0, FPARG(2));
    MOV(R0, INDD(R0,1));
    PUSH(R0);
    CALL(ABS);
//     printf("|R0| =  %ld\n",R0);
//     printf("|R1| =  %ld\n",R1);
    DROP(2);

REMAINDER_CODE_LOOP:
//  printf("REMAINDER_CODE_LOOP \n");    
//     printf("%ld - %ld\n",R0,R1);
    CMP(R0, R1);
    JUMP_LT(REMAINDER_CODE_END)
    SUB(R0, R1);
    JUMP(REMAINDER_CODE_LOOP);
    
REMAINDER_CODE_END:
//  printf("REMAINDER_CODE_END\n");
    //match to FPARG(2) sign
    MOV(R1, FPARG(2));
    MOV(R1, INDD(R1,1));
    PUSH(R1);
    MOV(R1,R0);
    CALL(IS_NEGATIVE);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(REMAINDER_CLEAN_AND_EXIT);
    //converte to negative
    MUL(R1, IMM(-1));
    
REMAINDER_CLEAN_AND_EXIT:    
//  printf("REMAINDER_CLEAN_AND_EXIT\n");
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    POP(R1);
    POP(FP);

REMAINDER_EXIT:
    RETURN;