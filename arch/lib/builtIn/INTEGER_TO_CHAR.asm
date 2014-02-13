INTEGER_TO_CHAR:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),40001);
    MOV(INDD(R0,2),LABEL(INTEGER_TO_CHAR_CODE));
    JUMP(INTEGER_TO_CHAR_EXIT);
    
INTEGER_TO_CHAR_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("INTEGER_TO_CHAR_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    
    MOV(R0, FPARG(2));
    MOV(R0, INDD(R0,1));
    PUSH(R0);
    CALL(MAKE_SOB_CHAR);
    DROP(1);
    POP(FP);

INTEGER_TO_CHAR_EXIT:
    RETURN;