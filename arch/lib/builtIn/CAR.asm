CAR:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),30001);
    MOV(INDD(R0,2),LABEL(CAR_CODE));
    JUMP(CAR_EXIT);
    
CAR_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("CAR_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    
    MOV(R0, FPARG(2));
    MOV(R0, INDD(R0,1));
    POP(FP);

CAR_EXIT:
    RETURN;