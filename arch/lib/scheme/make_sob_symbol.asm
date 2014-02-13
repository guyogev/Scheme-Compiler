/* scheme/make_sob_symbol.asm
 *linked List structure
 *Takes pointer to prev symbol, pointer to a bucket, and place the corresponding Scheme object in R0
 * 
 * Programmer: Mayer Goldberg, 2010
 */

 MAKE_SOB_SYMBOL:
  PUSH(FP);
  MOV(FP, SP);
/*
  printf("MAKE_SOB_SYMBOL \n");
    long r;
    for (r=0; r<10; r++){
        printf("FPARG(%ld) = %ld\n",r,FPARG(r));
    }
*/
  PUSH(IMM(2));
  CALL(MALLOC);
  DROP(1);
  MOV(IND(R0), T_SYMBOL);
  MOV(INDD(R0, 1), FPARG(0));
  POP(FP);
  RETURN;
