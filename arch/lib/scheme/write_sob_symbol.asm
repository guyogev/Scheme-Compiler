WRITE_SOB_SYMBOL:
    PUSH(FP);
    MOV(FP,SP);
    long t;
/*
    for (t=0; t<10; t++){
        printf("FPARG(%ld) = %ld\n",t,FPARG(t));
    }
*/
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    
//R3 = string obj
    MOV(R3, INDD(FPARG(0),1));
    MOV(R3, IND(R3));
//R1=str length
    MOV(R1, INDD(R3,1));
//R2 = index to first char
    MOV(R2, IMM(2));
    
WRITE_SOB_SYMBOL_LOOP:
    CMP(R1, IMM(0));
    //printf("WRITE_SOB_SYMBOL_LOOP\n");
    //printf("R1=%ld\n", R1);
    JUMP_EQ(WRITE_SOB_SYMBOL_EXIT);
    PUSH(INDD(R3, R2));
    CALL(PUTCHAR)
    DROP(1);
    INCR(R2);
    DECR(R1);
    JUMP(WRITE_SOB_SYMBOL_LOOP);

WRITE_SOB_SYMBOL_EXIT:    
//    CALL(NEWLINE);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    RETURN;