MAKE_VECTOR:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),60003);
    MOV(INDD(R0,2),LABEL(MAKE_VECTOR_CODE));
    JUMP(MAKE_VECTOR_EXIT);
    
MAKE_VECTOR_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("MAKE_VECTOR_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    PUSH(R1);
    PUSH(R2);
    
    //R1 = vector length
    MOV(R1, FPARG(2));
    MOV(R1, INDD(R1,1));
    
    //R0 = obj pointer
    CMP(FPARG(1), IMM(2));
    JUMP_NE(MAKE_VECTOR_CODE_DEFULT_ZEROS);
    MOV(R0, FPARG(3));
    JUMP(MAKE_VECTOR_CODE_CREATE_VEC);
    
MAKE_VECTOR_CODE_DEFULT_ZEROS:
    PUSH(IMM(0));
    CALL(MAKE_SOB_INTEGER);
    DROP(1);

MAKE_VECTOR_CODE_CREATE_VEC:
    //push obj
    MOV(R2,R1);
MAKE_VECTOR_CODE_LOOP:
    CMP(R2,IMM(0));
    JUMP_LE(MAKE_VECTOR_CODE_AFTER_LOOP)
    PUSH(R0);
    DECR(R2);
    JUMP(MAKE_VECTOR_CODE_LOOP);
    
MAKE_VECTOR_CODE_AFTER_LOOP:
    PUSH(R1);
    CALL(MAKE_SOB_VECTOR);
    INCR(R1);
    DROP(R1);

MAKE_VECTOR_CLEAN_AND_EXIT:
    POP(R2);
    POP(R1);
    POP(FP);

MAKE_VECTOR_EXIT:
    RETURN;