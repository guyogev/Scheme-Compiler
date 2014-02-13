CDR:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),30002);
    MOV(INDD(R0,2),LABEL(CDR_CODE));
    JUMP(CDR_EXIT);
    
CDR_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("CDR_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    
    MOV(R0, FPARG(2));
    MOV(R0, INDD(R0,2));
    POP(FP);

CDR_EXIT:
    RETURN;