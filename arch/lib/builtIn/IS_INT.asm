IS_INT:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),10003);
    MOV(INDD(R0,2),LABEL(IS_INT_CODE));
    JUMP(IS_INT_EXIT);
    
IS_INT_CODE:
//  printf("### in label: IS_INT_CODE \n");
//  printf("Arg = %lu\n",STARG(2));
    MOV(R0,STARG(2));
    PUSH(IMM(R0));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(IS_INT_FALSE);
    MOV(R0, SOB_TRUE);
    JUMP(IS_INT_EXIT);

IS_INT_FALSE:
    MOV(R0, SOB_FALSE);

IS_INT_EXIT:
    RETURN;