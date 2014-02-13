MINUS_VARIADIC:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),20004);
    MOV(INDD(R0,2),LABEL(MINUS_VARIADIC_CODE));
    JUMP(MINUS_VARIADIC_EXIT);
    
MINUS_VARIADIC_CODE:
    PUSH(FP);
    MOV(FP, SP);
 /*printf("### in label: MINUS_VARIADIC_CODE \n");
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
    //R4= sec arg index
    MOV(R4,IMM(3));
//special cases:
    CMP(R3, IMM(0));
    JUMP_EQ(MINUS_VARIADIC_CASE_ZERO_ARGS);
    CMP(R3, IMM(1));
    JUMP_EQ(MINUS_VARIADIC_CASE_ONE_ARGS);

//general case. loop sums arg_2...arg_n    
MINUS_VARIADIC_LOOP:    
    CMP(R3, IMM(1));
    JUMP_EQ(MINUS_VARIADIC_AFTER_LOOP);
    //check if fraction
    PUSH(FPARG(R4));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(MINUS_CASE_FRAC);
//MINUS_CASE_INT:
//     printf("MINUS_CASE_INT:\n");
    PUSH(IMM(1));
    PUSH(INDD(FPARG(R4),1));
    CALL(PLUS_FRAC_FRAC);
    DROP(2);
    JUMP(MINUS_CONTINUE_LOOP);

MINUS_CASE_FRAC:
//     printf("MINUS_CASE_FRAC:\n");
    MOV(R0,INDD(FPARG(R4),2));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    MOV(R0,INDD(FPARG(R4),1));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    CALL(PLUS_FRAC_FRAC);
    DROP(2);

MINUS_CONTINUE_LOOP:
//     printf("MINUS_CONTINUE_LOOP:\n");
    INCR(R4);
    DECR(R3);
    JUMP(MINUS_VARIADIC_LOOP);
//loop end

// R1/R2 = (+ arg_2... arg_n)
MINUS_VARIADIC_AFTER_LOOP:  
//     printf("MINUS_VARIADIC_AFTER_LOOP:\n");
    MUL(R1,IMM(-1));
    //check arg_1 type
    PUSH(FPARG(2));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(1));
    JUMP_NE(MINUS_VARIADIC_END_ARG1_FRAC);
//case arg_1 = int
//     printf("MINUS_VARIADIC_END_ARG1_INT:\n");
//compute  R1/R2 = (arg_1 + R1/R2)
    PUSH(R2);
    PUSH(R1);
    MOV(R1, INDD(FPARG(2),1));
    MOV(R2, IMM(1));
    CALL(PLUS_FRAC_FRAC);
    DROP(2);
    
MINUS_CREATE_ANS:
//check which ans type to create
    CMP(R2, IMM(1));
    JUMP_NE(MINUS_VARIADIC_END_CREATE_FRAC);
//     printf("MINUS_VARIADIC_END_CREATE_INT\n");
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    JUMP(MINUS_VARIADIC_EXIT)

MINUS_VARIADIC_END_CREATE_FRAC:
    PUSH(R2);
    CALL(MAKE_SOB_INTEGER);
    MOV(R2,R0);
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    PUSH(R2);
    PUSH(R0);
    CALL(MAKE_SOB_FRACTION);
    DROP(4);

MINUS_CLEAR_AND_EXIT:    
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    JUMP(MINUS_VARIADIC_EXIT)

MINUS_VARIADIC_END_ARG1_FRAC:
//case arg_1 = fraction
//     printf("MINUS_VARIADIC_END_ARG1_FRAC\n");
//compute  R1/R2 = (arg_1 + R1/R2)
    PUSH(R2);
    PUSH(R1);
    MOV(R1, INDD(FPARG(2),1));
    MOV(R1, INDD(R1,1));
    MOV(R2, INDD(FPARG(2),2));
    MOV(R2, INDD(R2,1));
    CALL(PLUS_FRAC_FRAC);
    DROP(2);
    JUMP(MINUS_CREATE_ANS);
    
MINUS_VARIADIC_EXIT:
    RETURN;
    
MINUS_VARIADIC_CASE_ZERO_ARGS:
//RETURN 0    
    PUSH(IMM(0));
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    JUMP(MINUS_CLEAR_AND_EXIT)
    
MINUS_VARIADIC_CASE_ONE_ARGS:
    PUSH(FPARG(2));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(1));
    JUMP_NE(MINUS_VARIADIC_CASE_ONE_ARGS_FRAC)
//     printf("MINUS_VARIADIC_CASE_ONE_ARGS_INT\n");
    MOV(R0, FPARG(2));
    MOV(R0,INDD(R0,1));
    MUL(R0,IMM(-1));
    PUSH(R0);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    JUMP(MINUS_CLEAR_AND_EXIT);
    
MINUS_VARIADIC_CASE_ONE_ARGS_FRAC:
//     printf("MINUS_VARIADIC_CASE_ONE_ARGS_FRAC\n");
    MOV(R1, FPARG(2));
    //R2=devider
    MOV(R2,INDD(R1,2));
    //R1=numerator
    MOV(R1,INDD(R1,1));
    MOV(R1, INDD(R1,1));
    MUL(R1,IMM(-1));
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    //create fraction
    PUSH(R2);
    PUSH(R0);
    CALL(MAKE_SOB_FRACTION);
    DROP(2);
    JUMP(MINUS_CLEAR_AND_EXIT);    