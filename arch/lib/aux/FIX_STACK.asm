FIX_STACK:
//     printf("************************************\n");

//     printf(" \t\t staring SP = %ld  %ld\n", SP ,FP);
    PUSH(FP);
    MOV(FP,SP);
    
    PUSH(R1);
    PUSH(R2);
    PUSH(R3);
    /*
    long i;
    for (i=-7; i<16; i++)
        printf("FPARG(%ld)=%ld\n",i,FPARG(i));
    */
    //R1 = expected argc
    MOV(R1, FPARG(0));
    //R2 = given argc
    MOV(R2, FPARG(4));
//     printf("expected(R1)=%ld given(R2)=%ld\n",R1,R2);
    //R0 = empty list
    MOV(R0, SOB_NIL)
    //check fix direction
    CMP(R1, R2);
    JUMP_GT(FIX_STACK_UP);

FIX_STACK_DOWN:
//     printf("\nFIX_STACK_DOWN\n");
    //create list at R0
    //R1 = index of first list member
    ADD(R1, IMM(4));
    //R2 = index of last list member
    ADD(R2, IMM(4));
//     printf("index of first(R1)=%ld, index of last(R2)=%ld\n",R1,R2);
    MOV(R3,R2);
    
FIX_STACK_DOWN_LOOP1:
    CMP(R3, R1);
    JUMP_LT(FIX_STACK_DOWN_AFTER_LOOP1);
    PUSH(R0);
    PUSH(FPARG(R3));
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    DECR(R3);
    JUMP(FIX_STACK_DOWN_LOOP1);
    
FIX_STACK_DOWN_AFTER_LOOP1:    
    //shrink stack
    //fix argc
    MOV(FPARG(4), FPARG(0));
    //R3 = num of free cells
    MOV(R3,R2);
    SUB(R3,R1);
//     printf("num of freed cells(R3)=%ld\n",R3);
    //place list as last arg
    MOV(FPARG(R2), R0);
    DECR(R2);
    DECR(R1);
    //move rest of args (-2-3 (pushed R1,2,3) )
FIX_STACK_DOWN_LOOP2:    
    CMP(R1, IMM(-5));
    JUMP_LT(FIX_STACK_DOWN_AFTER_LOOP2);
//  printf("move(%ld,%ld)\n",R2, R1);
    MOV(FPARG(R2), FPARG(R1));
    DECR(R2);
    DECR(R1);
    JUMP(FIX_STACK_DOWN_LOOP2);

FIX_STACK_DOWN_AFTER_LOOP2:
    //R0= num of freed cells
    MOV(R0,R3);
//     for (i=-2; i<20; i++)
//         printf("FPARG(%ld)=%ld\n",i,FPARG(i));
//     printf("R0=%ld\n",R0);
    DROP(R0);
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    //fix FP
    SUB(FP,R0);
//     MOV(SP,FP);
//     ADD(SP,IMM(2));
    JUMP(FIX_STACK_EXIT);

FIX_STACK_UP:
//     printf("FIX_STACK_UP\n");
    //R2 = last member of frame
    MOV(R2, IMM(4));
    ADD(R2, FPARG(R2));
    //R3 = top of frame + 4 pushed values R's + FP
    MOV(R3, IMM(-2));
    SUB(R3, IMM(4));
    //R0 = top of expanded frame + 4 pushed values R's + FP
    MOV(R0, IMM(-3));
    SUB(R0, IMM(4));
    //update SP
    INCR(SP);
    
FIX_STACK_UP_LOOP1:
    CMP(R3, R2);
    JUMP_GT(FIX_STACK_UP_AFTER_LOOP1);
    MOV(FPARG(R0),FPARG(R3));
    INCR(R0);
    INCR(R3);
    JUMP(FIX_STACK_UP_LOOP1);

FIX_STACK_UP_AFTER_LOOP1:
    //empty list as last arg
    MOV(FPARG(R2),SOB_NIL);
    //fix argc
    MOV(FPARG(IMM(3)), R1);
  /*  for (i=-7; i<16; i++)
        printf("FPARG(%ld)=%ld\n",i,FPARG(i));
  */  
    
    POP(R3);
    POP(R2);
    POP(R1);
    POP(FP);
    //fix FP
    INCR(FP);

FIX_STACK_EXIT:
    
//     printf(" \t\t ending SP = %ld  %ld\n", SP, FP);
    RETURN;