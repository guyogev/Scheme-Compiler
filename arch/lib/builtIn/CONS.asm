CONS:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),30003);
    MOV(INDD(R0,2),LABEL(CONS_CODE));
    JUMP(CONS_EXIT);
    
CONS_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("CONS_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    
    PUSH(FPARG(3));
    PUSH(FPARG(2));
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    POP(FP);

CONS_EXIT:
    RETURN;