import sexprs

constLst = [] #const created
symLst = [] #symbols created
symTable = {} #tuples of (sym, mem index)
constTable = {}

#index of first param on FPARG
firstParamDelta = 2 
# first const index (1:void, 2:nil, 3:#f, 5:#t)
cIndex = 7 
#first user defined symbol. updated during constTable construction
symTableIndex = 7 

yag = """
(define Yag
  (lambda fs
    ((lambda (ms )
      (apply (car ms) ms))
      (map
        (lambda (fi)
          (lambda ms
            (apply fi (map (lambda (mi)
                     (lambda args
                       (apply (apply mi ms) args))) ms))))
        fs))))
      """

def resetData():
    global symTableIndex 
    symTableIndex = 7 
    del constLst[:] 
    del symLst[:]
    symTable.clear()
    constTable.clear()

def updateSymTableIndex(n):
    global symTableIndex
    symTableIndex += n
#builtInMethodsIndex = 0 #index of first builtIn method on mem. cIndex + len(constTable)
builtInMethods = {'BOOLEAN?':'IS_BOOL', 'NULL?':'IS_NULL', 'INTEGER?':'IS_INT', 'STRING?':'IS_STRING', 'CHAR?':'IS_CHAR', 'PAIR?':'IS_PAIR', 'SYMBOL?':'IS_SYMBOL', 'ZERO?':'IS_ZERO_INT_FRAC', 'PROCEDURE?':'IS_PROCEDURE', 'FRACTION?':'IS_FRACTION', 'NUMBER?':'IS_NUMBER','=':'EQ_VARIADIC', '<':'LT_VARIADIC', '>':'GT_VARIADIC', '+':'PLUS_VARIADIC', '-':'MINUS_VARIADIC', '*':'MUL_VARIADIC', '/':'DIV_VARIADIC', 'CAR':'CAR', 'CDR':'CDR','CONS':'CONS', 'CHAR->INTEGER':'CHAR_TO_INTEGER', 'INTEGER->CHAR':'INTEGER_TO_CHAR', 'REMAINDER':'REMAINDER', 'STRING-LENGTH':'STRING_LENGTH', 'MAKE-STRING':'MAKE_STRING', 'STRING-REF':'STRING_REF', 'LIST':'LIST_VARIADIC', 'SYMBOL->STRING':'SYMBOL_TO_STRING', 'STRING->SYMBOL':'STRING_TO_SYMBOL', 'VECTOR?':'IS_VECTOR', 'VECTOR-LENGTH':'VECTOR_LENGTH', 'VECTOR-REF':'VECTOR_REF', 'MAKE-VECTOR':'MAKE_VECTOR', 'VECTOR':'VECTOR', 'EQ?':'IS_EQ', 'APPEND':'APPEND', 'APPLY':'APPLY', 'MAP':'MAP2'}
    
def addConst(c):
    if c not in constLst:
        constLst.append(c)
        
def addSym(s):
    if (s not in symLst) and (s not in builtInMethods.keys()):
        #print("\tadded '{}' to symLst".format(s))
        symLst.append(s)

def indexSymTable():
    #print('symTableIndex = ', symTableIndex)
    i = symTableIndex
    #add buildIn methods symbols
    for s in list(builtInMethods.keys()):
        symTable[s] = i
        i +=1
    #add user defined symbols
    for s in symLst:
        symTable[s] = i
        i += 1

def clsName(e):
    return e.__class__.__name__ 

def createConstTable():
    def topolSort(e):
        if clsName(e) == 'Pair':
            #print(e.value)
            a = topolSort(e.value[0])
            b = topolSort(e.value[1])
            return a+b+[e]
        if clsName(e) == 'Fraction':
            a = topolSort(e.value[0])
            b = topolSort(e.value[1])
            return a+b+[e]
        if clsName(e) == 'Symbol':
            a = [sexprs.String(str(e))]
            return a+[e]
        if clsName(e) == 'Vector':
            p = createPairs(e.value)
            a = topolSort(p)
            return a + [e]
        else:
            if clsName(e) in ('Void','Boolean', 'Nil'):
                return []
            return [e]
    i = cIndex
    #print('constLst:',constLst, '\n')
    repeatedValues = [] 
    for cLst in constLst:
        l = topolSort(cLst)
        for c in l:
            if str(c) not in repeatedValues:
                constTable[i] = c
                repeatedValues.append(str(c))
                i += 1

def createPairs(lst):
    if len(lst) == 0:
        #empty lst
        return lst
    if len(lst) == 1:
        #final Pair, end with Nil
        return sexprs.Pair(lst[0],sexprs.Nil())
    return sexprs.Pair(lst[0], createPairs(lst[1:]))
    
                