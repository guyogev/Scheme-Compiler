STRING_LENGTH:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),50000);
    MOV(INDD(R0,2),LABEL(STRING_LENGTH_CODE));
    JUMP(STRING_LENGTH_EXIT);
    
STRING_LENGTH_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("STRING_LENGTH_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    
    MOV(R0, FPARG(2));
    MOV(R0, INDD(R0,1));
    PUSH(R0);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    POP(FP);

STRING_LENGTH_EXIT:
    RETURN;