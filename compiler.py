"""
compiler.py
written by: Guy yogev

input:  Scheme file name.
        Output file name.

output: CISC Assembly file

assumes Scheme syntax correctness.
"""


import tag_parser, aux, sys

def compile_scheme_file(source, target):
    def build_Const_Table():
        aux.createConstTable()
        res = []
        res.append('/**** Const Table Start ****/')
        res.append('//Global consts:')
        res.append('CALL(MAKE_SOB_VOID);')
        res.append('CALL(MAKE_SOB_NIL);')
        res.append('PUSH(IMM(0));')
        res.append('CALL(MAKE_SOB_BOOL);')
        res.append('PUSH(IMM(1));')
        res.append('CALL(MAKE_SOB_BOOL);')
        res.append('DROP(2);')
        
        i = aux.cIndex
        userConstsCount = len(aux.constTable)
        #print('old constTable:\n\t', aux.constTable)
        aux.constTable['Void'] = 1
        aux.constTable['()'] = 2
        aux.constTable['#f'] = 3
        aux.constTable['#t'] = 5
        res.append('//Users consts:')
        #if there are user consts
        while userConstsCount > 0:
            c = aux.constTable[i]
            del aux.constTable[i]
            # symTableIndex = next avalible mem cell
            aux.constTable[str(c)] = aux.symTableIndex
            #print(i,c, str(c))
            if aux.clsName(c)=='Integer':
                res.append('PUSH(IMM({}));'.format(c.value))
                res.append('CALL(MAKE_SOB_INTEGER);')
                res.append('DROP(1);')
                #takes 2 cells at mem
                aux.updateSymTableIndex(2)
                #res.append('MOV(IND({}),R0);'.format(i))
            elif aux.clsName(c)=='Fraction':
                a = aux.constTable[str(c.value[0])]
                b = aux.constTable[str(c.value[1])]
                res.append('PUSH(IMM({}));'.format(b))
                res.append('PUSH(IMM({}));'.format(a))
                res.append('CALL(MAKE_SOB_FRACTION);')
                res.append('DROP(2);')
                #fraction takes 3 cells at mem
                aux.updateSymTableIndex(3)
            elif aux.clsName(c)=='Char':
                res.append('PUSH(IMM({}));'.format(ord(c.value)))
                res.append('CALL(MAKE_SOB_CHAR);')
                res.append('DROP(1);')
                #takes 2 cells at mem
                aux.updateSymTableIndex(2)
                #res.append('MOV(IND({}),R0);'.format(i))
            elif aux.clsName(c)=='String':
                for char in c.value:
                    res.append("PUSH(IMM('{}'));".format(char))
                res.append('PUSH(IMM({}));'.format(len(c.value)))
                res.append('CALL(MAKE_SOB_STRING);')
                res.append('DROP({});'.format(len(c.value)+1))
                #takes FPARG(0)+2 cells at mem
                aux.updateSymTableIndex(2 + len(c.value))
            elif aux.clsName(c)=='Symbol':
                #a = address of string
                a = aux.constTable['"{}"'.format(c.value)] 
                #create symbol obj with empty val. palce at R1
                res.append('PUSH(0);')
                res.append('CALL(MAKE_SOB_SYMBOL);')
                res.append('DROP(1);')
                res.append('MOV(R1,R0);')
                #create value bucket with val=0
                res.append('PUSH(IMM(2));')
                res.append('CALL(MALLOC);')
                res.append('DROP(1);')
                res.append('MOV(IND(R0),IMM({}));'.format(a))
                res.append('MOV(INDD(R0,1),0);')
                #place bucket as symbol value
                res.append('MOV(INDD(R1,1),R0);')
                
                #new bucket takes 2 cells, symbol 2 more
                aux.updateSymTableIndex(4)
            elif aux.clsName(c)=='Pair':
                a = aux.constTable[str(c.value[0])]
                b = aux.constTable[str(c.value[1])]
                res.append('PUSH(IMM({}));'.format(b))
                res.append('PUSH(IMM({}));'.format(a))
                res.append('CALL(MAKE_SOB_PAIR);')
                res.append('DROP(2);')
                #takes 3 cells at mem
                aux.updateSymTableIndex(3)
            elif aux.clsName(c)=='Vector':
                #push v_1...v_n
                for e in c.value:
                    #print(str(e))
                    res.append('PUSH(IMM({}));'.format(aux.constTable[str(e)]))
                #push n
                res.append('PUSH(IMM({}));'.format(len(c.value)))
                res.append('CALL(MAKE_SOB_VECTOR);')
                res.append('DROP({});'.format(len(c.value)+1))
                #takes n+2 cells at mem
                aux.updateSymTableIndex(len(c.value)+2)
            elif aux.clsName(c)=='list':
                pass
            else:
                print(aux.clsName(c), '= ' + str(c) + ' should in constTable?')
                sys.exit()
            i +=1
            userConstsCount -=1
        #print('new constTable:\n\t', aux.constTable)
        res.append('/**** Const Table End ****/')
        return '\n'.join(res)
    
    def build_Sym_Table():
        res = []
        
        def reserveMem():
            res.append('\n/**** SymTable Start: mem[{}] ****/'.format(aux.symTableIndex))
            res.append('// reserve memory for builtIn Methods + users defined Syms')
            #reserve memory. index at R1
            res.append('PUSH(IMM({}));'.format(len(aux.symTable)))
            res.append('CALL(MALLOC);')
            res.append('DROP(1);')
            res.append('MOV(R1, R0);\n')
            # symTable index at R15
            res.append('MOV(R15, IMM({}));'.format(aux.symTableIndex))
            #res.append('printf("symTable Index = %ld", R15);')
            #res.append('CALL(NEWLINE);')
             
        def build_builtIn_methods():
            res.append('// built In Methods')
            #create buckets and put in memory
            i=0
            for sym in aux.builtInMethods.keys():
                res.append('// {}'.format(aux.builtInMethods[sym]))
                #create string, save in R2
                for c in sym:
                    res.append("PUSH(IMM('{}'));".format(c))
                res.append('PUSH(IMM({}));'.format(len(sym)))
                res.append('CALL(MAKE_SOB_STRING);')
                res.append('DROP({});'.format(len(sym)+1))
                res.append('MOV(R2, R0);\n')
                #create the closure, save in R3
                res.append('CALL({});'.format(aux.builtInMethods[sym]))
                res.append('MOV(R3, R0);\n')
                #create bucket
                res.append('PUSH(IMM(2));')
                res.append('CALL(MALLOC);')
                res.append('DROP(1);')
                res.append('MOV(IND(R0),R2);')
                res.append('MOV(INDD(R0,1),R3);')
                #save bucket at R2
                #res.append('MOV(R2,R0);\n')
                #create sym object
                res.append('PUSH(R0);')
                res.append('CALL(MAKE_SOB_SYMBOL);')
                res.append('DROP(1);')
                #put new sym at mem[R15]
                res.append('MOV(IND(R15), R0);')
                #update symTable index
                res.append('INCR(R15);\n')
                #next method
                i+=1
                
        def otherSyms():
            #print('symLst: ',aux.symLst)
            res.append('//user defined Syms')
            res.append('PUSH(R1);')
            #print('symLst', aux.symLst)
            for s in aux.symLst:
                
                #print("~~~~~~", s)
                #create empty bucket at R1
                res.append('PUSH(IMM(2));')
                res.append('CALL(MALLOC);')
                res.append('DROP(1);')
                res.append('MOV(R1,R0);')
                #create string
                for c in s:
                    res.append("PUSH(IMM('{}'));".format(c))
                res.append('PUSH(IMM({}));'.format(len(s)))
                res.append('CALL(MAKE_SOB_STRING);')
                res.append('DROP({});'.format(len(s)+1))
                #put string in bucket
                res.append('MOV(IND(R1),R0);')
                #create empty sym object
                res.append('PUSH(R1);')
                res.append('CALL(MAKE_SOB_SYMBOL);')
                res.append('DROP(1);')                
                #put sym at mem[R15]
                res.append('MOV(IND(R15), R0);')
                #update symTable index
                res.append('INCR(R15);\n')
            res.append('POP(R1);')
            res.append('/**** SymTable End ****/\n')
                
        def checkSymTable():
            res.append('printf("R15 = %ld, should be {}", R15);'.format(aux.symTableIndex + len(aux.symTable)))
            res.append('CALL(NEWLINE);')
            
        #aux.calcMemIndexes()
        aux.indexSymTable()
        #print('symTable:', aux.symTable, '\n')
        reserveMem()
        build_builtIn_methods()
        otherSyms()
        #checkSymTable()
        return '\n'.join(res)

    def init_stack_and_env():
        res = []
        res.append('//create first empty env')
        res.append('PUSH(IMM(2));')
        res.append('CALL(MALLOC);')
        res.append('DROP(1);')
        res.append('MOV(IND(R0), IMM(2));//size of new vector')
        res.append('MOV(INDD(R0,1), 0);//empty env')
        res.append('//initialize stack with fake frame')
        res.append('PUSH(IMM(999990)); //dummy first arg')
        res.append('PUSH(IMM(0)); //dummy argc')
        res.append('PUSH(R0);// empty env')
        res.append('PUSH(IMM(999991));//dummy ret')
        res.append('PUSH(IMM(999992));//dummy old FP')
        res.append('MOV(FP,SP);//reset FP\n')
        return '\n'.join(res)
   
    def initializeOutput(outputFile):
        print('2. initializing output file...')
        try:
            f = open('initAsm.txt', 'r')
            s = f.read()
            f.close()
        except:
            print('Failed to read initAsm.txt')
        outputFile.write(s)
        outputFile.write(prettyPrint(build_Const_Table()))
        outputFile.write(prettyPrint(build_Sym_Table()))
        outputFile.write(prettyPrint(init_stack_and_env()))
        outputFile.write('/************ START *************/\n')
        
    def printOutRes(outputFile):
        outputFile.write('\tPUSH(R0);\n')
        outputFile.write('\tCALL(WRITE_SOB);\n')
        outputFile.write('\tCALL(NEWLINE);\n')
        outputFile.write('\tDROP(1);\n')
    
    def finalizeOutput(outputFile):
        print('4. finalizing output file...')
        outputFile.write('/*********** FINSH **************/\n')
        ### TESTING
        #outputFile.write('CALL(EXPAND_ENV);')
        #outputFile.write('PUSH(R0);\n')
        #outputFile.write('CALL(WRITE_SOB);\n')
        #outputFile.write('CALL(NEWLINE);\n')
       
        ### TESTING
        outputFile.write('\tSTOP_MACHINE;\n')
        outputFile.write('\treturn 0;\n');
        outputFile.write('}\n')
        outputFile.close()
    
# ************************ Main Start ******************************** #   
    aux.resetData()
    print ('\n\n****** Compiling... ******\n')
    #IOsetup
    try:
        #read user code
        inputFile = open(source, 'r')
        expr = inputFile.read()
        inputFile.close()
        #print(expr.lower())
        if any(w in expr.lower() for w in ['letrec','yag']):
            print('appending predefined scheme methods to user code')
            expr = aux.yag.upper() +'\n'+ expr
            #print(expr)
            
    except IOError:
        print ('failed to open {} file'.format(source))
        sys.exit()
    except:
        print ('failed to read {} file'.format(source))
        sys.exit()
    try:
        output = open(target, 'w')
    except IOError:
        print ('failed to create {} file'.format(target))
        sys.exit()
    #parse expretions
    paresed = []
    p=""
    r=expr
    print('1. parsing expretions. this might take a while, please wait...')
    while(len(expr)):
        #parse
        try:
            [p, r] = tag_parser.AbstractSchemeExpr.parse(expr)
            paresed.append(p)
            #print('p=',p)
            expr = r
            #print('\tparesed: {}\n'.format(p))
        except:
            print ("\nError! failed to parse\n\t expretion:{} \n\t file:{}\n".format(r, source))
            sys.exit()
    
    #code gen
    initializeOutput(output)
    print('3. analyzing paresed expretions...')
    for p in paresed:
        analized = p.semantic_analysis()        
        #codegen
        output.write( prettyPrint(analized.code_gen()) )
        if (str(analized)[1:7] !='define'):
            printOutRes(output)
    finalizeOutput(output)
    print('\n****** Compilation finished! ******\n')

def prettyPrint(s):
    #print(s)
    res = []
    for l in s.split('\n'):
        if ';' in l:
            res.append('\t'+l + '\n')
        elif ':' in l:
            res.append('\n'+l + '\n') 
        else:
            res.append(l + '\n')
    return ''.join(res)

#compile_scheme_file('test.scm', 'test.asm')    