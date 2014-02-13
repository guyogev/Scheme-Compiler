IS_NULL:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),10002);
    MOV(INDD(R0,2),LABEL(IS_NULL_CODE));
    JUMP(IS_NULL_EXIT);
    
IS_NULL_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("IS_NULL_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    CMP(FPARG(2), SOB_NIL);
    JUMP_EQ(IS_NULL_TRUE);
    MOV(R0, SOB_FALSE);
    JUMP(IS_NULL_CLEAR_AND_EXIT);
    
IS_NULL_TRUE:
    MOV(R0, SOB_TRUE);

IS_NULL_CLEAR_AND_EXIT:
    POP(FP);

IS_NULL_EXIT:
    RETURN;