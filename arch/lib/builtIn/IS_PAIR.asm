IS_PAIR:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),10008);
    MOV(INDD(R0,2),LABEL(IS_PAIR_CODE));
    JUMP(IS_PAIR_EXIT);
    
IS_PAIR_CODE:
//  printf("### in label: IS_PAIR_CODE \n");
//  printf("Arg = %lu\n",STARG(2));
    MOV(R0,STARG(2));
    PUSH(IMM(R0));
    CALL(IS_SOB_PAIR);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(IS_PAIR_FALSE);
    MOV(R0, IMM(SOB_TRUE));
    JUMP(IS_PAIR_EXIT);

IS_PAIR_FALSE:
    MOV(R0, IMM(SOB_FALSE));

IS_PAIR_EXIT:
    RETURN;