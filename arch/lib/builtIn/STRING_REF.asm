STRING_REF:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),50002);
    MOV(INDD(R0,2),LABEL(STRING_REF_CODE));
    JUMP(STRING_REF_EXIT);
    
STRING_REF_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("STRING_REF_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }

    //R0 = needed char index
    MOV(R0, INDD(FPARG(3),1));
    ADD(R0,2);
    MOV(R0, INDD(FPARG(2), R0));
    
    //create char object
    PUSH(R0);
    CALL(MAKE_SOB_CHAR);
    DROP(1);
    
STRING_REF_CLEAN_AND_EXIT:
    POP(FP);

STRING_REF_EXIT:
    RETURN;