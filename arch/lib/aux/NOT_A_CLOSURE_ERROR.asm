NOT_A_CLOSURE_ERROR:
    PUSH(IMM('N'));
    CALL(PUTCHAR);
    PUSH(IMM('O'));
    CALL(PUTCHAR);
    PUSH(IMM('T'));
    CALL(PUTCHAR);
    PUSH(IMM('_'));
    CALL(PUTCHAR);
    PUSH(IMM('A'));
    CALL(PUTCHAR);
    PUSH(IMM('_'));
    CALL(PUTCHAR);
    PUSH(IMM('C'));
    CALL(PUTCHAR);
    PUSH(IMM('L'));
    CALL(PUTCHAR);
    PUSH(IMM('O'));
    CALL(PUTCHAR);
    PUSH(IMM('S'));
    CALL(PUTCHAR);
    PUSH(IMM('U'));
    CALL(PUTCHAR);
    PUSH(IMM('R'));
    CALL(PUTCHAR);
    PUSH(IMM('E'));
    CALL(PUTCHAR);
    PUSH(IMM('_'));
    CALL(PUTCHAR);
    PUSH(IMM('E'));
    CALL(PUTCHAR);
    PUSH(IMM('R'));
    CALL(PUTCHAR);
    PUSH(IMM('R'));
    CALL(PUTCHAR);
    PUSH(IMM('O'));
    CALL(PUTCHAR);
    PUSH(IMM('R'));
    CALL(PUTCHAR);
    DROP(19);
    CALL(NEWLINE);
    HALT;