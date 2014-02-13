EQ_VARIADIC:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),20000);
    MOV(INDD(R0,2),LABEL(EQ_VARIADIC_CODE));
    JUMP(EQ_VARIADIC_EXIT);
    
EQ_VARIADIC_CODE:
//  printf("### in label: EQ_VARIADIC_CODE \n");
    PUSH(FP);
    MOV(FP,SP);
    PUSH(R1);
    PUSH(R2)
    PUSH(R3);
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    //R1 = argc
    MOV(R1, FPARG(1))
    //R2 = first arg index
    MOV(R2, IMM(2));
    //R2 = sec arg index
    MOV(R3, IMM(3))
EQ_VARIADIC_LOOP:
    //break cond R1 == 0
    CMP(R1, IMM(1));
    JUMP_LE(EQ_VARIADIC_TRUE);
    // FPARG(R2) == FPARG(R3)
    PUSH(FPARG(R3));
    PUSH(FPARG(R2));
    CALL(CMP_SOB_NUMBERS);
    DROP(2);
    CMP(R0, 0);
    JUMP_NE(EQ_VARIADIC_FALSE);
    //next interation
    DECR(R1);
    INCR(R2);
    INCR(R3);
    JUMP(EQ_VARIADIC_LOOP);

EQ_VARIADIC_TRUE:
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    MOV(R0, IMM(SOB_TRUE));
    JUMP(EQ_VARIADIC_EXIT);

EQ_VARIADIC_FALSE:
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    MOV(R0, IMM(SOB_FALSE));

EQ_VARIADIC_EXIT:
    RETURN;