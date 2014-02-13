DIV_VARIADIC:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),20006);
    MOV(INDD(R0,2),LABEL(DIV_VARIADIC_CODE));
    JUMP(DIV_VARIADIC_EXIT);
    
DIV_VARIADIC_CODE:
    PUSH(FP);
    MOV(FP, SP);
 /*printf("### in label: DIV_VARIADIC_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
 */   
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);
    //R1=1 is defult numerator
    MOV(R1, IMM(1));
    //R2=1 is defult divider
    MOV(R2, IMM(1));
    //R3=argc
    MOV(R3,FPARG(1));
    //R4= sec arg index
    MOV(R4,IMM(3));
//special cases:
    CMP(R3, IMM(1));
    JUMP_EQ(DIV_VARIADIC_CASE_ONE_ARGS);

//general case. loop mul arg_2...arg_n    
DIV_VARIADIC_LOOP:    
    CMP(R3, IMM(1));
    JUMP_EQ(DIV_VARIADIC_AFTER_LOOP);
    //check if fraction
    PUSH(FPARG(R4));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(DIV_CASE_FRAC);
//DIV_CASE_INT:
//     printf("DIV_CASE_INT:\n");
    PUSH(IMM(1));
    PUSH(INDD(FPARG(R4),1));
    CALL(MUL_FRAC_FRAC);
    DROP(2);
    JUMP(DIV_CONTINUE_LOOP);

DIV_CASE_FRAC:
//     printf("DIV_CASE_FRAC:\n");
    MOV(R0,INDD(FPARG(R4),2));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    MOV(R0,INDD(FPARG(R4),1));
    MOV(R0,INDD(R0,1));
    PUSH(R0);
    CALL(MUL_FRAC_FRAC);
    DROP(2);

DIV_CONTINUE_LOOP:
//     printf("DIV_CONTINUE_LOOP:\n");
    INCR(R4);
    DECR(R3);
    JUMP(DIV_VARIADIC_LOOP);
//loop end

// R1/R2 = (+ arg_2... arg_n)
DIV_VARIADIC_AFTER_LOOP:  
//     printf("DIV_VARIADIC_AFTER_LOOP:\n");
    //check arg_1 type
    PUSH(FPARG(2));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(1));
    JUMP_NE(DIV_VARIADIC_END_ARG1_FRAC);
//case arg_1 = int
//     printf("DIV_VARIADIC_END_ARG1_INT:\n");
//compute  R1/R2 = (arg_1 / R1/R2) =(arg_1 / (arg_1 * R2/R1)
    PUSH(R1);
    PUSH(R2);
    MOV(R1, INDD(FPARG(2),1));
    MOV(R2, IMM(1));
    CALL(MUL_FRAC_FRAC);
    DROP(2);
    
DIV_CREATE_ANS:
//check which ans type to create
    CMP(R2, IMM(1));
    JUMP_NE(DIV_VARIADIC_END_CREATE_FRAC);
//     printf("DIV_VARIADIC_END_CREATE_INT\n");
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    DROP(1);
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    JUMP(DIV_VARIADIC_EXIT)

DIV_VARIADIC_END_CREATE_FRAC:
    PUSH(R2);
    CALL(MAKE_SOB_INTEGER);
    MOV(R2,R0);
    PUSH(R1);
    CALL(MAKE_SOB_INTEGER);
    PUSH(R2);
    PUSH(R0);
    CALL(MAKE_SOB_FRACTION);
    DROP(4);

DIV_CLEAR_AND_EXIT:    
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    JUMP(DIV_VARIADIC_EXIT)

DIV_VARIADIC_END_ARG1_FRAC:
//case arg_1 = fraction
//     printf("DIV_VARIADIC_END_ARG1_FRAC\n");
//compute  R1/R2 = (arg_1 / R1/R2) =(arg_1 / (arg_1 * R2/R1)
    PUSH(R1);
    PUSH(R2);
    MOV(R1, INDD(FPARG(2),1));
    MOV(R1, INDD(R1,1));
    MOV(R2, INDD(FPARG(2),2));
    MOV(R2, INDD(R2,1));
    CALL(MUL_FRAC_FRAC);
    DROP(2);
    JUMP(DIV_CREATE_ANS);
    
DIV_VARIADIC_EXIT:
    RETURN;
        
DIV_VARIADIC_CASE_ONE_ARGS:
    PUSH(FPARG(2));
    CALL(IS_SOB_INTEGER);
    DROP(1);
    CMP(R0, IMM(1));
    JUMP_NE(DIV_VARIADIC_CASE_ONE_ARGS_FRAC)
//     printf("DIV_VARIADIC_CASE_ONE_ARGS_INT\n");
    //arg_1 = int. create 1/arg_1
    PUSH(IMM(1));
    CALL(MAKE_SOB_INTEGER);
    PUSH(FPARG(2));
    PUSH(R0);
    CALL(MAKE_SOB_FRACTION);
    DROP(3);
    JUMP(DIV_CLEAR_AND_EXIT);
    
DIV_VARIADIC_CASE_ONE_ARGS_FRAC:
//     printf("DIV_VARIADIC_CASE_ONE_ARGS_FRAC\n");
    //arg_1 = fraction. flip numerator/divider
    MOV(R1, FPARG(2));
    //R2=divider
    MOV(R2,INDD(R1,2));
    //R1=numerator
    MOV(R1,INDD(R1,1));
    //create fraction
    PUSH(R1);
    PUSH(R2);
    CALL(MAKE_SOB_FRACTION);
    DROP(2);
    JUMP(DIV_CLEAR_AND_EXIT);    