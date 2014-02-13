EXPAND_ENV:
//     PUSH(FP);
//     MOV(FP,SP);
    PUSH(R1);
    POP(R1);/*
    long i;
    printf("\nEXPAND_EN vvvvvvvvvvvvvvvvvv \n");
    for (i=-2; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }*/
    
    
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);

//  R1=old env arr
    MOV(R1, FPARG(0));
//     printf("old env  = %ld\n", R1);
//  R2= old env arr size
    MOV(R2, IND(R1));
//     printf("old env array size = %ld\n", R2);
    INCR(R2);
//  create new env arr    
    PUSH(R2);
    CALL(MALLOC);
    DROP(1);
//     printf("new env  = %ld\n", R0);
    MOV(IND(R0), R2); //  first cell indicate arr size

//  copy envs    
    MOV(R3,IMM(1));//index for old env
    MOV(R4,IMM(2));//index for new env
    DECR(R2);//stop cond
EXPAND_ENV_COPY_ENVS_LOOP:
    CMP(R3, R2);
    JUMP_EQ(EXPAND_ENV_AFTER_COPY_ENVS_LOOP);
    MOV(INDD(R0,R4), INDD(R1, R3));
    INCR(R3);
    INCR(R4);
    JUMP(EXPAND_ENV_COPY_ENVS_LOOP);

//  copy params A_1...A_n into new array   
EXPAND_ENV_AFTER_COPY_ENVS_LOOP:
    //save env at R1
    MOV(R1,R0);
    //R2 = argc == n
    MOV(R2, FPARG(1));
    //create new array
    INCR(R2);
    PUSH(R2);
    CALL(MALLOC);
    DROP(1);
//     printf("new params array  = %ld\n", R0);
    MOV(IND(R0), R2); //  first cell indicate arr size
    //R3 = A_1 index
    MOV(R3, IMM(2));
    DECR(R2);
    //R4=loop index
    MOV(R4, IMM(1));

EXPAND_ENV_COPY_PARAMS_LOOP:
    CMP(R2, IMM(0));
    JUMP_EQ(EXPAND_ENV_AFTER_COPY_PARAMS_LOOP);
    MOV(INDD(R0,R4), FPARG(R3));
    DECR(R2);
    INCR(R3);
    INCR(R4);
    JUMP(EXPAND_ENV_COPY_PARAMS_LOOP);
    
EXPAND_ENV_AFTER_COPY_PARAMS_LOOP:
//put new array as first env    
    MOV(INDD(R1,1), R0);
    MOV(R0, R1);
    
EXPAND_ENV_EXIT:    
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);/*
    printf("\n");
    for (i=-2; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    printf("\nEXPAND_ENV ^^^^^^^^^^^^^^^^^^^^^^ \n");
    */
//     POP(FP);
    RETURN;
   