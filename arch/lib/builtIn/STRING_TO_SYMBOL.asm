STRING_TO_SYMBOL:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),50004);
    MOV(INDD(R0,2),LABEL(STRING_TO_SYMBOL_CODE));
    JUMP(STRING_TO_SYMBOL_EXIT);
    
STRING_TO_SYMBOL_CODE:
    PUSH(FP);
    MOV(FP, SP);
    /*
    printf("STRING_TO_SYMBOL_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    */
    //create bucket
    PUSH(IMM(2));
    CALL(MALLOC);
    DROP(1);
    //place string at bucket
    MOV(IND(R0), FPARG(2));
    //create symbol
    PUSH(R0);
    CALL(MAKE_SOB_SYMBOL);
    DROP(1);

STRING_TO_SYMBOL_CLEAN_AND_EXIT:
    POP(FP);

STRING_TO_SYMBOL_EXIT:
    RETURN;