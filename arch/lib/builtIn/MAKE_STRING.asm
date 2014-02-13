MAKE_STRING:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),50001);
    MOV(INDD(R0,2),LABEL(MAKE_STRING_CODE));
    JUMP(MAKE_STRING_EXIT);
    
MAKE_STRING_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("MAKE_STRING_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    PUSH(R1);
    PUSH(R2);
    
    //R1 = string length
    MOV(R1, FPARG(2));
    MOV(R1, INDD(R1,1));
    //R0 = char
    MOV(R0, FPARG(3));
    MOV(R0, INDD(R0,1));
    
    //push chars
    MOV(R2,R1);
MAKE_STRING_CODE_LOOP:
    CMP(R2,IMM(0));
    JUMP_LE(MAKE_STRING_CODE_AFTER_LOOP)
    PUSH(R0);
    DECR(R2);
    JUMP(MAKE_STRING_CODE_LOOP);
    
MAKE_STRING_CODE_AFTER_LOOP:
    PUSH(R1);
    CALL(MAKE_SOB_STRING);
    INCR(R1);
    DROP(R1);

MAKE_STRING_CLEAN_AND_EXIT:
    POP(R2);
    POP(R1);
    POP(FP);

MAKE_STRING_EXIT:
    RETURN;