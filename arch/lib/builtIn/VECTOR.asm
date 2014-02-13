VECTOR:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),60000);
    MOV(INDD(R0,2),LABEL(VECTOR_CODE));
    JUMP(VECTOR_EXIT);
    
VECTOR_CODE:
    PUSH(FP);
    MOV(FP, SP);     
/*
    printf("VECTOR_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
*/
    PUSH(R1);
    PUSH(R2);
//R1=R0=argc
    MOV(R1, FPARG(1));
    MOV(R0,R1);
//R2=first arg index
    MOV(R2, IMM(2));

//push v_1 ... v_n    
VECTOR_CODE_LOOP:
    CMP(R1, IMM(0));
    JUMP_EQ(VECTOR_CODE_AFTER_LOOP);
    PUSH(FPARG(R2));
    INCR(R2);
    DECR(R1);
    JUMP(VECTOR_CODE_LOOP);
    
VECTOR_CODE_AFTER_LOOP:
//push n
    MOV(R1,R0);
    PUSH(R0);
    CALL(MAKE_SOB_VECTOR);
//empty stack    
    INCR(R1);
    DROP(R1);
       
VECTOR_CLEAN_AND_EXIT:
    POP(R2);
    POP(R1);
    POP(FP);

VECTOR_EXIT:
    RETURN;