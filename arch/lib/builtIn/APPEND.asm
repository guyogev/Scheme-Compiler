APPEND:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),80000);
    MOV(INDD(R0,2),LABEL(APPEND_CODE));
    JUMP(APPEND_EXIT);
    
APPEND_CODE:
    PUSH(FP);
    MOV(FP, SP);     
//     long i;
//     printf("APPEND_CODE \n");
//     for (i=0; i<10; i++){
//         printf("FPARG(%ld) = %ld\n",i,FPARG(i));
//     }
    //special cases
    CMP(FPARG(1), IMM(0));
    JUMP_EQ(APPEND_CODE_CASE_NO_ARGS);
    CMP(FPARG(1), IMM(1));
    JUMP_EQ(APPEND_CODE_CASE_ONE_ARG);
    PUSH(FPARG(2));
    CALL(IS_SOB_PAIR);
    DROP(1);
    CMP(R0, IMM(0));
    JUMP_EQ(APPEND_CODE_CASE_IMPROPER_LIST);
    
//general case, 2+ args. merge lists from last to first
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    PUSH(R4);
    
    MOV(R0, SOB_NIL); 
    MOV(R1, FPARG(1));//number of lists
    MOV(R2, IMM(2));//index of first list
    MOV(R4, IMM(0));//push counter 
    
//loop over lists    
APPEND_CODE_LISTS_LOOP:
//     printf("APPEND_CODE_LISTS_LOOP\n");    
    CMP(R1, IMM(0));
    JUMP_EQ(APPEND_CODE_CREATE_LIST);
    CMP(FPARG(R2), SOB_NIL);
    JUMP_NE(APPEND_CODE_SCAN_LIST);
    //skip empty lists
    JUMP(APPEND_CODE_SCAN_LIST_END);

//push list members    
APPEND_CODE_SCAN_LIST:
//     printf("APPEND_CODE_SCAN_LIST\n");
    //R3 = current list
    MOV(R3, FPARG(R2));
    
APPEND_CODE_MEMBERS_LOOP:
//     printf("APPEND_CODE_MEMBERS_LOOP\n");
    //case end of list
    CMP(R3, SOB_NIL);
    JUMP_EQ(APPEND_CODE_SCAN_LIST_END);
    //case not a list
    PUSH(R3);
    CALL(IS_SOB_PAIR);
    CMP(R0, IMM(0));
    DROP(1);
    JUMP_EQ(APPEND_CODE_SCAN_LIST_END_IMPROPER);
    MOV(R0, SOB_NIL);//restore R0
    //append member
    PUSH(INDD(R3,1));
    INCR(R4);
    MOV(R3, INDD(R3,2));
    JUMP(APPEND_CODE_MEMBERS_LOOP);

APPEND_CODE_SCAN_LIST_END:
//     printf("APPEND_CODE_SCAN_LIST_END\n");
    DECR(R1);
    INCR(R2);
    JUMP(APPEND_CODE_LISTS_LOOP);
  
//last arg is not a list
APPEND_CODE_SCAN_LIST_END_IMPROPER:
//     PUSH(R3);
//     INCR(R4);
//     DECR(R1);
//     INCR(R2);
    MOV(R0, R3);
//     JUMP(APPEND_CODE_LISTS_LOOP);
   

APPEND_CODE_CREATE_LIST:
//     printf("APPEND_CODE_CREATE_LIST\n");
    //R1 = first pushed index
    MOV(R1, R4);
    DECR(R1);
    //R2 = last pushed index
    MOV(R2, IMM(0));
    
    //PUSH(STARG(3));
    //CALL(WRITE_SOB);
    //CALL(NEWLINE);
    //exit(0);
    
APPEND_CODE_REVERSE_PUSHED_LOOP:
    JUMP(APPEND_CODE_END);
//     printf("APPEND_CODE_REVERSE_PUSHED_LOOP\n");
//     printf("R1=%ld R2=%ld\n", R1,R2);
    CMP(R2, R1);
    JUMP_GE(APPEND_CODE_END);
    MOV(R3, STARG(R1));
    MOV(STARG(R1), STARG(R2));
    MOV(STARG(R2), R3);
    INCR(R2);
    DECR(R1);
    JUMP(APPEND_CODE_REVERSE_PUSHED_LOOP);
    
APPEND_CODE_END:   
//     printf("APPEND_CODE_END:\n");
//     printf("R4=%ld\n", R4);
    CMP(R4, IMM(0));
    JUMP_EQ(APPEND_CLEAN_AND_EXIT);
    POP(R1);
    PUSH(R0);
    PUSH(R1);
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    DECR(R4);
    JUMP(APPEND_CODE_END);

APPEND_CLEAN_AND_EXIT:
//     printf("APPEND_CLEAN_AND_EXIT\n");
    POP(R4);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);

APPEND_EXIT:
    RETURN;
    
APPEND_CODE_CASE_NO_ARGS:
//     printf("APPEND_CODE_CASE_NO_ARGS\n");
    MOV(R0, SOB_NIL);
    POP(FP);
    JUMP(APPEND_EXIT);
    
APPEND_CODE_CASE_ONE_ARG:
//     printf("APPEND_CODE_CASE_ONE_ARG\n");
    MOV(R0, FPARG(2));
    POP(FP);
    JUMP(APPEND_EXIT);
    
APPEND_CODE_CASE_IMPROPER_LIST:
//     printf("APPEND_CODE_CASE_IMPROPER_LIST\n");
    CMP(FPARG(2), SOB_NIL);
    JUMP_EQ(APPEND_CODE_RETURN_SECOND);
    PUSH(FPARG(3));
    PUSH(FPARG(2));
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    POP(FP);
    JUMP(APPEND_EXIT);
    
APPEND_CODE_RETURN_SECOND:    
    MOV(R0, FPARG(3));
    POP(FP);
    JUMP(APPEND_EXIT);
    