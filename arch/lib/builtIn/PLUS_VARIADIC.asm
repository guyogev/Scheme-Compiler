PLUS_VARIADIC:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),20003);
    MOV(INDD(R0,2),LABEL(PLUS_VARIADIC_CODE));
    JUMP(PLUS_VARIADIC_EXIT);
    
PLUS_VARIADIC_CODE:
    PUSH(FP);
    MOV(FP, SP);
 /*printf("### in label: PLUS_VARIADIC_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
 */   
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);
    //R1=0 is defult numerator
    MOV(R1, IMM(0));
    //R2=1 is defult devider
    MOV(R2, IMM(1));
    //R3=argc
    MOV(R3,FPARG(1));
    //R4=first arg index
    MOV(R4,IMM(2));
    
PLUS_VARIADIC_LOOP:    
    CMP(R3, IMM(0));
    JUMP_EQ(PLUS_VARIADIC_END);
    //check if fraction
    PUSH(FPARG(R4));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(PLUS_CASE_FRAC);
//CASE_INT:
//     printf("CASE_INT:\n");
    PUSH(IMM(1));
    PUSH(INDD(FPARG(R4),1));
    CALL(PLUS_FRAC_FRAC);
    DROP(2);
    JUMP(PLUS_CONTINUE_LOOP);

PLUS_CASE_FRAC:
//     printf("PLUS_CASE_FRAC:\n");
    MOV(R0,INDD(FPARG(R4),2));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    MOV(R0,INDD(FPARG(R4),1));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    CALL(PLUS_FRAC_FRAC);
    DROP(2);

PLUS_CONTINUE_LOOP:
//     printf("PLUS_CONTINUE_LOOP:\n");
    INCR(R4);
    DECR(R3);
    JUMP(PLUS_VARIADIC_LOOP);

PLUS_VARIADIC_END:    
    CMP(R2, IMM(1));
    JUMP_NE(PLUS_VARIADIC_END_FRAC);
//     printf("PLUS_VARIADIC_END_INT:\n");
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    JUMP(PLUS_VARIADIC_EXIT)

PLUS_VARIADIC_END_FRAC:
//     printf("PLUS_VARIADIC_END_FRAC:\n");
    PUSH(R2);
    CALL(MAKE_SOB_INTEGER);
    MOV(R2,R0);
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    PUSH(R2);
    PUSH(R0);
    CALL(MAKE_SOB_FRACTION);
    DROP(4);
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    
PLUS_VARIADIC_EXIT:
    RETURN;

//R1/R2 + FPARG(0)/FPARG(1) = [R1*FPARG(1) + R2*FPARG(0)]/R2*FPARG(1)   
PLUS_FRAC_FRAC:
    PUSH(FP);
    MOV(FP, SP);
//     printf("PLUS_FRAC_FRAC: %ld\\%ld+%ld\\%ld\n",R1,R2,FPARG(0),FPARG(1));
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    //R1 =numerator
    MUL(R1, FPARG(1));
    MOV(R0, R2);
    MUL(R0,FPARG(0));
    ADD(R1, R0);
    //R2 = devider
    MUL(R2, FPARG(1));
//     printf("%ld \\ %ld\n", R1,R2);
    POP(FP)
    RETURN;