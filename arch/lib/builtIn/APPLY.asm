APPLY:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),90000);
    MOV(INDD(R0,2),LABEL(APPLY_CODE));
    JUMP(APPLY_EXIT);
    
APPLY_CODE:
//       printf(" \t\t*************************** APPLY staring R1 = %ld %ld\n", FPARG(-1), R1);
    PUSH(FP);
    MOV(FP, SP);
//     long i;
//     printf("APPLY_CODE \n");
//     for (i=-2; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }    

    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
//  R2 = first arg index
    MOV(R2, IMM(3));
//  R1=number of params
    MOV(R1, FPARG(1));
    DECR(R1);
//  R3=number of pushed args
    MOV(R3, IMM(0));
    
//extract first argc-1 args
APPLY_CODE_GET_FST_PARAMS:
//     printf("APPLY_CODE_GET_FST_PARAMS\n");
    CMP(R1, IMM(1));
    JUMP_EQ(APPLY_CODE_AFTER_GET_FST_PARAMS);
    PUSH(FPARG(R2));
//     CALL(WRITE_SOB);
//     CALL(NEWLINE);
//     CALL(NEWLINE);
    INCR(R2);
    DECR(R1);
    INCR(R3);
    JUMP(APPLY_CODE_GET_FST_PARAMS);

//  get last param
APPLY_CODE_AFTER_GET_FST_PARAMS:
//     printf("APPLY_CODE_AFTER_GET_FST_PARAMS\n");
    //check last param type
    //R2 = index of last arg
    MOV(R2, FPARG(IMM(1)));
    INCR(R2);
    MOV(R1, FPARG(R2));
    PUSH(R1);
//     CALL(WRITE_SOB);
//     CALL(NEWLINE);
    CALL(IS_SOB_PAIR);
    DROP(1);
    CMP(R0, IMM(1));
    JUMP_EQ(APPLY_CODE_AFTER_GET_FST_PARAMS_CASE_LIST);
//last arg is not a list
//     printf("R1=%ld\n",R1);
    PUSH(R1);
    INCR(R3);
//     MOV(R0, IMM(1));
    JUMP(APPLY_CODE_AFTER_GET_PARAMS);

//last arg is a list
APPLY_CODE_AFTER_GET_FST_PARAMS_CASE_LIST:
//     printf("APPLY_CODE_AFTER_GET_FST_PARAMS_CASE_LIST\n");
   
APPLY_CODE_AFTER_GET_FST_PARAMS_CASE_LIST_LOOP:
//     printf("APPLY_CODE_AFTER_GET_FST_PARAMS_CASE_LIST_LOOP\n");
    CMP(R1, SOB_NIL);
    JUMP_EQ(APPLY_CODE_AFTER_GET_PARAMS);
    PUSH(INDD(R1,1));
    INCR(R3);
    MOV(R1, INDD(R1,2));
    JUMP(APPLY_CODE_AFTER_GET_FST_PARAMS_CASE_LIST_LOOP);

// reverse params order
APPLY_CODE_AFTER_GET_PARAMS:
//     printf("APPLY_CODE_AFTER_GET_PARAMS\n");
//     for (i=-1; i<10; i++){
//         printf("STARG(%ld) = %ld\n",i,STARG(i));
//     }   
    //R1=last pushed arg index
    MOV(R1, IMM(-1));
    //R2=first push arg index
    MOV(R2, R3);
    SUB(R2, IMM(2));
//     printf("R2=%ld\n",R2);
        
APPLY_CODE_REVERSE_PARAMS:
    CMP(R2,R1);
    JUMP_LE(APPLY_CODE_AFTER_REVERSE_PARAMS);
    //swap values using R0 as pivot
    MOV(R0, STARG(R1));
    MOV(STARG(R1), STARG(R2));
    MOV(STARG(R2), R0);
    INCR(R1);
    DECR(R2);
    JUMP(APPLY_CODE_REVERSE_PARAMS);

//call operator with params    
APPLY_CODE_AFTER_REVERSE_PARAMS:
//     printf("APPLY_CODE_AFTER_REVERSE_PARAMS\n");
    PUSH(R3);//argc
    //R2 = operator
    MOV(R2, FPARG(2));
    PUSH(INDD(R2, 1));//env
    CALLA(INDD(R2,2));//code
    DROP(1);//env
    POP(R3);//argc
    DROP(R3);//args

APPLY_CLEAN_AND_EXIT:
//     printf("APPLY_CLEAN_AND_EXIT\n");
    POP(R3);
    POP(R2);
    POP(R1);
//     for (i=-2; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    POP(FP);
//     printf(" \t\t*************************** APPLY ending R1 = %ld %ld\n", FPARG(-1), R1);

APPLY_EXIT:
    RETURN;