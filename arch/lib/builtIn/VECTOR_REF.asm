VECTOR_REF:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),60002);
    MOV(INDD(R0,2),LABEL(VECTOR_REF_CODE));
    JUMP(VECTOR_REF_EXIT);
    
VECTOR_REF_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     printf("VECTOR_REF_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }

    //R0 = needed element index
    MOV(R0, INDD(FPARG(3),1));
    ADD(R0,2);
    MOV(R0, INDD(FPARG(2), R0));
    
    
    
VECTOR_REF_CLEAN_AND_EXIT:
    POP(FP);

VECTOR_REF_EXIT:
    RETURN;