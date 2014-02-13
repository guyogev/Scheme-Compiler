MAP2:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),121212);
    MOV(INDD(R0,2),LABEL(MAP2_CODE));
    JUMP(MAP2_EXIT);
    
MAP2_CODE:
//  printf(" \t\t*************************** MAP staring R1 = %ld %ld\n", FPARG(-1), R1);

//     printf("MAP2_CODE\n");
    PUSH(FP);
    MOV(FP, SP);
    /*long i;
    printf("MAP2_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    */
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    
    //R11 = lists length
    PUSH(FPARG(3));
    CALL(MAP2_FIND_LIST_LEN);
    DROP(1);
    MOV(R11, R0);
    DECR(R11);
//     printf("lists length (max index) = %ld\n", R11);
    //R12 = number of lists
    MOV(R12, FPARG(1));
    DECR(R12);
//     printf("number of lists = %ld\n", R12);
    //
    
    //R3=result 
    MOV(R3, SOB_NIL);
    //R1 = func
    MOV(R1, FPARG(2));
    //members index
    MOV(R13, R11);
MAP2_CODE_LOOP:
//     printf("MAP2_CODE_LOOP\n");
    CMP(R13, IMM(0));
    JUMP_LT(MAP2_CODE_AFTER_LOOP);
    //R2 = choose list index, from last to 0
    MOV(R2, IMM(0));
//     DECR(R2);
    //push arg form each list
    MOV(R14, SOB_NIL);
MAP2_CODE_LOOP_PUSH_ARGS:
//     printf("\tMAP2_CODE_LOOP_PUSH_ARGS:\n");    
    CMP(R2, R12);
    JUMP_GE(MAP2_CODE_LOOP_AFTER_PUSH_ARGS);
    PUSH(R2);//choose list
    PUSH(R13);//choose arg index
    CALL(MAP2_GET_LIST_MEMBER);
    DROP(2);
    
    PUSH(R14);
    PUSH(R0);
    CALL(MAKE_SOB_PAIR);
    MOV(R14,R0);
    DROP(2);
//     PUSH(R0);
//     CALL(WRITE_SOB);
//     CALL(NEWLINE);
//     DROP(1);
    
    INCR(R2);
    JUMP(MAP2_CODE_LOOP_PUSH_ARGS);

MAP2_CODE_LOOP_AFTER_PUSH_ARGS:
//     printf("\tMAP2_CODE_LOOP_AFTER_PUSH_ARGS:\n");    
//     INCR(R2);
UNWRAP_R14:
    CMP(R2, IMM(0));
    JUMP_EQ(AFTER_UNWRAP_R14);
    PUSH(INDD(R14,1));
//     CALL(WRITE_SOB);
//     CALL(NEWLINE);
    MOV(R14, INDD(R14,2));
    DECR(R2);
    JUMP(UNWRAP_R14);

AFTER_UNWRAP_R14:    
    //call func on pushed args
    PUSH(R12);//argc
    PUSH(INDD(R1,1));//env
    CALLA(INDD(R1,2));
    DROP(R12);
    DROP(2);
    //make pair
    PUSH(R3);
    PUSH(R0);
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    MOV(R3, R0);
    DECR(R13);
    JUMP(MAP2_CODE_LOOP);

MAP2_CODE_AFTER_LOOP:
//     printf("\tMAP2_CODE_AFTER_LOOP:\n");
    MOV(R0, R3);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);

MAP2_EXIT:
//    printf(" \t\t MAP ending R1 = %ld %ld\n", FPARG(-1), R1);
    RETURN;






//gets the FPARG(0) member from the FPARG(1) list    
MAP2_GET_LIST_MEMBER:
    PUSH(FP);
    MOV(FP, SP);
    PUSH(R1);
//     printf("list number %ld, arg number %ld \n",FPARG(1), FPARG(0));
    //FPARG(8) = argc, FPARG(10)=frist list, FPARG(1) = list number, FPARG(0) = member index 
/*
    printf("MAP2_GET_LIST_MEMBER \n");
    for (i=0; i<20; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    
    PUSH(FPARG(10));
    CALL(WRITE_SOB);
    CALL(NEWLINE);
    DROP(1);
    */
    
    //R0=list number FPARG(1);
    MOV(R0, IMM(10));
    ADD(R0, FPARG(1));
    MOV(R0, FPARG(R0));
//     printf("R0=%ld\n",R0);
    //R1= member index
    MOV(R1, FPARG(0));

MAP2_GET_LIST_MEMBER_LOOP:    
    CMP(R1, IMM(0));
    JUMP_EQ(MAP2_GET_LIST_MEMBER_AFTER_LOOP);
    //cdr
    MOV(R0, INDD(R0,2));
    DECR(R1);
    JUMP(MAP2_GET_LIST_MEMBER_LOOP);
  
MAP2_GET_LIST_MEMBER_AFTER_LOOP:
//     printf("R0=%ld\n",R0);
    MOV(R0, INDD(R0,1));
    POP(R1);
    POP(FP);
    RETURN;




    
MAP2_FIND_LIST_LEN:
    PUSH(FP);
    MOV(FP,SP);
    PUSH(R1);
    
    MOV(R0, IMM(0));
    MOV(R1, FPARG(0));
 
//return list length
MAP2_FIND_LIST_LEN_LOOP:
    CMP(R1, SOB_NIL);
    JUMP_EQ(MAP2_FIND_LIST_LEN_AFTER_LOOP);
    INCR(R0);
    MOV(R1, INDD(R1,2));
    JUMP(MAP2_FIND_LIST_LEN_LOOP);

MAP2_FIND_LIST_LEN_AFTER_LOOP:    
    POP(R1);
    POP(FP);
    RETURN;