WRITE_SOB_FRACTION:
  PUSH(FP);
  MOV(FP, SP);
  
  PUSH(R1);
//printf("WRITE_SOB_FRACTION\n");
  
  MOV(R1, FPARG(0));
  PUSH(INDD(R1, 1));
  CALL(WRITE_SOB);
  PUSH(IMM('/'));
  CALL(PUTCHAR);
  PUSH(INDD(R1, 2));
  CALL(WRITE_SOB);
  DROP(3);

WRITE_SOB_FRACTION_EXIT:
  POP(R1);
  POP(FP);
  RETURN;

