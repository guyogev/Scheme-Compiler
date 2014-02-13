IS_EQ:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),10013);
    MOV(INDD(R0,2),LABEL(IS_EQ_CODE));
    JUMP(IS_EQ_EXIT);
    
IS_EQ_CODE:
    PUSH(FP);
    MOV(FP, SP);     
/*    
    printf("IS_EQ_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    */
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);
    
    MOV(R1, FPARG(2));
    MOV(R2, FPARG(3));
    //address cmp. (nil, void, bool, pair, string)
//     printf("R1=%ld ,R2=%ld\n", R1, R2);
    CMP(R1,R2);
    JUMP_EQ(IS_EQ_CODE_TRUE);   //same obj
    //cmp types
    CMP(IND(R1),IND(R2));       // diffrent types
    JUMP_NE(IS_EQ_CODE_FALSE);
    
    //cmp value cell
    CMP(IND(R1), T_FRACTION);   //case fraction
    JUMP_EQ(IS_EQ_CODE_CMP_FRAC);
    CMP(IND(R1), T_VECTOR);     //case vector
    JUMP_EQ(IS_EQ_CODE_CMP_VECTOR);
    CMP(INDD(R1,1),INDD(R2,1));// case int, char, symbol
    JUMP_NE(IS_EQ_CODE_FALSE);
    JUMP(IS_EQ_CODE_TRUE);

IS_EQ_CODE_CMP_FRAC:
//     printf("IS_EQ_CODE_CMP_FRAC\n");
    //fractions = R1/R3 R2/R4
    MOV(R3, INDD(R1,2));
    MOV(R1, INDD(R1,1));
    MOV(R1, INDD(R1,1));
    MOV(R3, INDD(R3,1));
//     printf("R1/R3 = %ld/%ld\n", R1, R3);
    MOV(R4, INDD(R2,2));
    MOV(R2, INDD(R2,1));
    MOV(R2, INDD(R2,1));
    MOV(R4, INDD(R4,1));
//     printf("R2/R4 = %ld/%ld\n", R2, R4);
    MUL(R1, R4);
    MUL(R2, R3);
//     printf("R1=%ld ,R2=%ld\n", R1, R2);
    CMP(R1,R2);
    JUMP_NE(IS_EQ_CODE_FALSE);
    JUMP(IS_EQ_CODE_TRUE);

IS_EQ_CODE_CMP_VECTOR:
//     printf("IS_EQ_CODE_CMP_VECTOR\n");
    CMP(INDD(R1,2),INDD(R2,2));
    JUMP_NE(IS_EQ_CODE_FALSE);
    JUMP(IS_EQ_CODE_TRUE);

IS_EQ_CODE_TRUE:
    MOV(R0, SOB_TRUE);
    JUMP(IS_EQ_CLEAN_AND_EXIT);

IS_EQ_CODE_FALSE:
    MOV(R0, SOB_FALSE);
    
IS_EQ_CLEAN_AND_EXIT:
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);

IS_EQ_EXIT:
    RETURN;
    
/*
#define T_VOID      937610
#define T_NIL       722689
#define T_BOOL      741553
#define T_CHAR      181048
#define T_INTEGER   945311
#define T_FRACTION  945312
#define T_STRING    799345
#define T_SYMBOL    368031
#define T_PAIR      885397
#define T_VECTOR    335728
#define T_CLOSURE   276405    
*/