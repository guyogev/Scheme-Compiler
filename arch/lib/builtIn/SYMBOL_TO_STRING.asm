SYMBOL_TO_STRING:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),50003);
    MOV(INDD(R0,2),LABEL(SYMBOL_TO_STRING_CODE));
    JUMP(SYMBOL_TO_STRING_EXIT);
    
SYMBOL_TO_STRING_CODE:
    PUSH(FP);
    MOV(FP, SP);
    /*
    printf("SYMBOL_TO_STRING_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }*/

    MOV(R0, FPARG(2));
    MOV(R0, INDD(R0, 1));
    MOV(R0, IND(R0));

SYMBOL_TO_STRING_CLEAN_AND_EXIT:
    POP(FP);

SYMBOL_TO_STRING_EXIT:
    RETURN;