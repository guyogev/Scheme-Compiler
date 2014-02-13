/*takes INTEGERS/FRACTIONS n1, n2  and return R0>0 if n1>n2, R0<0 n2>n1, else R0==0 */ 
CMP_SOB_NUMBERS:
    PUSH(FP);
    MOV(FP,SP);
    /*
    int k;
    for (k=0; k<10; k++){
        printf("FPARG(%d) = %ld\n",k,FPARG(k));
    }*/
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);
// convert R1/R2=n1 
CMP_SOB_NUMBERS_CHECK_N1_TYPE:
//     printf("CMP_SOB_NUMBERS_CHECK_N1_TYPE\n");
    //check n1 type
    PUSH(FPARG(0));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(CMP_SOB_NUMBERS_N1_FRAC);
    MOV(R1, INDD(FPARG(0),1));
    MOV(R2, IMM(1));
    JUMP(CMP_SOB_NUMBERS_CHECK_N2_TYPE);

CMP_SOB_NUMBERS_N1_FRAC:
//     printf("CMP_SOB_NUMBERS_N1_FRAC\n");
    MOV(R1,FPARG(0));
    MOV(R2, INDD(R1,2));
    MOV(R1, INDD(R1,1));
    MOV(R1, INDD(R1,1));
    MOV(R2, INDD(R2,1));
    
// convert R3/R4=n2    
CMP_SOB_NUMBERS_CHECK_N2_TYPE:
//     printf("CMP_SOB_NUMBERS_CHECK_N2_TYPE\n");
    //check n2 type
    PUSH(FPARG(1));
    CALL(IS_SOB_INTEGER);
    CMP(R0, IMM(0));
    DROP(1);
    JUMP_EQ(CMP_SOB_NUMBERS_N2_FRAC);
    MOV(R3, INDD(FPARG(1),1));
    MOV(R4, IMM(1));
    JUMP(CMP_SOB_NUMBERS_COMPUTE);    

CMP_SOB_NUMBERS_N2_FRAC:
//     printf("CMP_SOB_NUMBERS_N2_FRAC\n");
    MOV(R3,FPARG(1));
    MOV(R4, INDD(R3,2));
    MOV(R3, INDD(R3,1));
    MOV(R3, INDD(R3,1));
    MOV(R4, INDD(R4,1));

CMP_SOB_NUMBERS_COMPUTE:
//     printf("CMP_SOB_NUMBERS_COMPUTE\n");
//     printf("R1/R2 = %ld/%ld\n",R1,R2);
//     printf("R3/R4 = %ld/%ld\n",R3,R4);
//R0 = (R1*R4 - R2*R3)/R2*R4
    MUL(R1,R4);
    MOV(R0,R2);
    MUL(R0,R3);
    SUB(R1,R0);
    MOV(R0,R1);
    
//     MUL(R2,R4);
//     DIV(R0,R2);
//     printf("R0 = %ld\n",R0);
    
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    RETURN;