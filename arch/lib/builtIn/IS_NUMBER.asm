IS_NUMBER:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),10005);
    MOV(INDD(R0,2),LABEL(IS_NUMBER_CODE));
    JUMP(IS_NUMBER_EXIT);
    
IS_NUMBER_CODE:
    PUSH(FP);
    MOV(FP, SP);
    /*
    printf("IS_NUMBER_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }*/
    PUSH(FPARG(2));
    CALL(IS_SOB_FRACTION);
    CMP(R0, IMM(1));
    JUMP_EQ(IS_NUMBER_TRUE);
    CALL(IS_SOB_INTEGER);
    CMP(R0, IMM(1));
    JUMP_EQ(IS_NUMBER_TRUE);
    MOV(R0, SOB_FALSE);
    JUMP(IS_NUMBER_CLEAR_AND_EXIT);
    
IS_NUMBER_TRUE:
    MOV(R0, SOB_TRUE);

IS_NUMBER_CLEAR_AND_EXIT:
    DROP(1);
    POP(FP);

IS_NUMBER_EXIT:
    RETURN;