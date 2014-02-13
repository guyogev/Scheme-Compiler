LIST_VARIADIC:
    PUSH(IMM(3));
    CALL(MALLOC);
    DROP(1);
    MOV(IND(R0), T_CLOSURE);
    MOV(INDD(R0,1),30000);
    MOV(INDD(R0,2),LABEL(LIST_VARIADIC_CODE));
    JUMP(LIST_VARIADIC_EXIT);
    
LIST_VARIADIC_CODE:
    PUSH(FP);
    MOV(FP, SP);    
/*    
     printf("LIST_VARIADIC_CODE \n");
    for (i=0; i<10; i++){
        printf("FPARG(%ld) = %ld\n",i,FPARG(i));
    }
*/    
    PUSH(R1);
    //R1 = last arg index
    MOV(R1, FPARG(1));
    INCR(R1);
    //R0 = empty list
    MOV(R0, SOB_NIL);
 
    // create pairs
LIST_VARIADIC_CODE_LOOP:
//  printf("LIST_VARIADIC_CODE_LOOP\n");
    CMP(R1, IMM(1));
    JUMP_EQ(LIST_VARIADIC_CLEAN_AND_EXIT);
    PUSH(R0);
    PUSH(FPARG(R1));
    CALL(MAKE_SOB_PAIR);
    DROP(2);
    DECR(R1);
    JUMP(LIST_VARIADIC_CODE_LOOP);
        
LIST_VARIADIC_CLEAN_AND_EXIT:
    POP(R1);
    POP(FP);

LIST_VARIADIC_EXIT:
    RETURN;