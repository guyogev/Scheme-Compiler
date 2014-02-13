MUL_VARIADIC:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),20005);
    MOV(INDD(R0,2),LABEL(MUL_VARIADIC_CODE));
    JUMP(MUL_VARIADIC_EXIT);
    
MUL_VARIADIC_CODE:
    PUSH(FP);
    MOV(FP, SP);
 /*printf("### in label: MUL_VARIADIC_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
 */   
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);
    //R1=0 is defult numerator
    MOV(R1, IMM(1));
    //R2=1 is defult devider
    MOV(R2, IMM(1));
    //R3=argc
    MOV(R3,FPARG(1));
    //R4=first arg index
    MOV(R4,IMM(2));
    
MUL_VARIADIC_LOOP:    
    CMP(R3, IMM(0));
    JUMP_EQ(MUL_VARIADIC_END);
    //check if fraction
    PUSH(FPARG(R4));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(MUL_CASE_FRAC);
//CASE_INT:
//     printf("CASE_INT:\n");
    PUSH(IMM(1));
    PUSH(INDD(FPARG(R4),1));
    CALL(MUL_FRAC_FRAC);
    DROP(2);
    JUMP(MUL_CONTINUE_LOOP);

MUL_CASE_FRAC:
//     printf("MUL_CASE_FRAC:\n");
    MOV(R0,INDD(FPARG(R4),2));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    MOV(R0,INDD(FPARG(R4),1));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    CALL(MUL_FRAC_FRAC);
    DROP(2);

MUL_CONTINUE_LOOP:
//     printf("MUL_CONTINUE_LOOP:\n");
    INCR(R4);
    DECR(R3);
    JUMP(MUL_VARIADIC_LOOP);

MUL_VARIADIC_END:    
    CMP(R2, IMM(1));
    JUMP_NE(MUL_VARIADIC_END_FRAC);
//     printf("MUL_VARIADIC_END_INT:\n");
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    JUMP(MUL_VARIADIC_EXIT)

MUL_VARIADIC_END_FRAC:
//     printf("MUL_VARIADIC_END_FRAC:\n");
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
    
MUL_VARIADIC_EXIT:
    RETURN;

//  R1/R2 <- R1/R2 * FPARG(0)/FPARG(1)   
MUL_FRAC_FRAC:
    PUSH(FP);
    MOV(FP, SP);
//     printf("MUL_FRAC_FRAC: %ld\\%ld+%ld\\%ld\n",R1,R2,FPARG(0),FPARG(1));
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    //R1 =numerator
    MUL(R1, FPARG(0));
    //R2 = devider
    MUL(R2, FPARG(1));
//     printf("%ld \\ %ld\n", R1,R2);
    POP(FP)
    RETURN;