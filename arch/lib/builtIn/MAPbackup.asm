MAP:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),121212);
    MOV(INDD(R0,2),LABEL(MAP_CODE));
    JUMP(MAP_EXIT);
    
MAP_CODE:
//     printf("MAP_CODE\n");
    PUSH(FP);
    MOV(FP, SP);
    long i;
    printf("MAP_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    
    //R11 = lists length
    PUSH(FPARG(3));
    CALL(MAP_FIND_LIST_LEN);
    DROP(1);
    MOV(R11, R0);
    DECR(R11);
    printf("lists length (max index) = %ld\n", R11);
    //R12 = number of lists
    MOV(R12, FPARG(1));
    DECR(R12);
    printf("number of lists = %ld\n", R12);
    //
    
    //R3=result 
    MOV(R3, SOB_NIL);
    //R1 = func
    MOV(R1, FPARG(2));
    //members index
    MOV(R13, IMM(0));
MAP_CODE_LOOP:
    printf("MAP_CODE_LOOP\n");
    CMP(R13, R11);
    JUMP_GT(MAP_CODE_AFTER_LOOP);
    //R2 = number of lists
    MOV(R2, IMM(0));
    //R14 saves pushed values as pairs.
    MOV(R14, SOB_NIL);
    //push arg form each list
MAP_CODE_LOOP_PUSH_ARGS:
    printf("\tMAP_CODE_LOOP_PUSH_ARGS:\n");    
    CMP(R2, R12);
    JUMP_GE(MAP_CODE_LOOP_AFTER_PUSH_ARGS);
    PUSH(R2);//choose list
    PUSH(R13);//choose arg index
    CALL(MAP_GET_LIST_MEMBER);
    DROP(2);
    PUSH(R14);//saves pushed values as pairs.
    PUSH(R0);
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    CALL(WRITE_SOB);
    CALL(NEWLINE);
    INCR(R2);
    JUMP(MAP_CODE_LOOP_PUSH_ARGS);

MAP_CODE_LOOP_AFTER_PUSH_ARGS:
    printf("\tMAP_CODE_LOOP_AFTER_PUSH_ARGS:\n");    
    //call func on pushed args
UNWRAP_R14:
    CMP(R14, SOB_NIL);
    JUMP_EQ(AFTER_UNWRAP_R14)
    PUSH(INDD(R14, 1));
    MOV(R14, INDD(R14, 2));
    JUMP(UNWRAP_R14);

AFTER_UNWRAP_R14:    
    CALLA(INDD(R1,2));
    DROP(R12);
    //make pair
    PUSH(R3);
    PUSH(R0);
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    MOV(R3, R0);
    INCR(R13);
    JUMP(MAP_CODE_LOOP);

MAP_CODE_AFTER_LOOP:
    printf("\tMAP_CODE_AFTER_LOOP:\n");
    MOV(R0, R3);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);

MAP_EXIT:
    RETURN;


//gets the FPARG(0) member from the FPARG(1) list    
MAP_GET_LIST_MEMBER:
    PUSH(FP);
    MOV(FP, SP);
    PUSH(R1);
    printf("list number %ld, arg number %ld \n",FPARG(1), FPARG(0));
    //FPARG(8) = argc, FPARG(10)=frist list, FPARG(1) = list number, FPARG(0) = member index 

    printf("MAP_GET_LIST_MEMBER \n");
    for (i=0; i<20; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
    /*
    PUSH(FPARG(10));
    CALL(WRITE_SOB);
    CALL(NEWLINE);
    DROP(1);
    */
    
    //R0=list number FPARG(1);
    MOV(R0, IMM(10));
    ADD(R0, FPARG(1));
    MOV(R0, FPARG(R0));
    printf("R0=%ld\n",R0);
    //R1= member index
    MOV(R1, FPARG(0));

MAP_GET_LIST_MEMBER_LOOP:    
    CMP(R1, IMM(0));
    JUMP_EQ(MAP_GET_LIST_MEMBER_AFTER_LOOP);
    //cdr
    MOV(R0, INDD(R0,2));
    DECR(R1);
    JUMP(MAP_GET_LIST_MEMBER_LOOP);
  
MAP_GET_LIST_MEMBER_AFTER_LOOP:
//     printf("R0=%ld\n",R0);
    MOV(R0, INDD(R0,1));
    POP(R1);
    POP(FP);
    RETURN;




    
MAP_FIND_LIST_LEN:
    PUSH(FP);
    MOV(FP,SP);
    PUSH(R1);
    
    MOV(R0, IMM(0));
    MOV(R1, FPARG(0));
 
//return list length
MAP_FIND_LIST_LEN_LOOP:
    CMP(R1, SOB_NIL);
    JUMP_EQ(MAP_FIND_LIST_LEN_AFTER_LOOP);
    INCR(R0);
    MOV(R1, INDD(R1,2));
    JUMP(MAP_FIND_LIST_LEN_LOOP);

MAP_FIND_LIST_LEN_AFTER_LOOP:    
    POP(R1);
    POP(FP);
    RETURN;