"""
tag_parser.py
written by: Guy yogev

takes an AST, analize it and return an AST readey for CISC Assmbly Code generation. 

"""

import reader, aux

#******************************** Env ******************************** 

class Env(object):
    def __init__(self):
        self.env = {}
        self.encloseEnv = None
    
    def add(self, var, index):
        self.env.setdefault(var,index)
    
    def setEncloseEnv(self, encloseEnv):
        self.encloseEnv = encloseEnv
    
    def lookup(self, var):
        def search(e ,var, major):
            #print('search '+ str(var) +  ' at env '+ str(e.env))
            if var in e.env.keys():
                #found var at current level
                return (major, e.env[var] )
            if e.encloseEnv == None:
                #var isnt found, VarFree
                return None
            #lookup at encloseEnv with updated major index
            return search(e.encloseEnv,var,major+1)
        
        return search(self, var, -1)
        
        

#******************************** SchemeExpr ******************************** 
class SchemeSyntacticError(Exception):
    pass

class AbstractSchemeExpr(object):
    def __init__(self, obj):
        self.value = obj
    
    def __str__(self):
        return str(self.value)
    
    @staticmethod
    def parse(s):
        sexpr_ast, remaining = reader.pSexpr.match(s)
        scheme_expr_ast = tagParse(sexpr_ast)
        return (scheme_expr_ast, remaining)
   
    #str Aux. checks if lst is a singal obj or list. adds '.' for improper list
    def strSorter(self, lst):
        if type(lst) == list:
            #str all members except last
            if len(lst) > 1:
                ans = ''.join(list(map((lambda x: self.strSorter(x) + ' '), lst[0:len(lst)-1])))
                if clsName(lst[-1]) != 'Nil':
                    #improper list
                    ans = ans + '. ' + self.strSorter(lst[-1])
            else:
                #singalton List
                ans = self.strSorter(lst[0])
            return '(' + ans + ')'
        #singal obj
        if clsName(lst) != 'Nil':
            return str(lst)
        #fix - ignor Nil? how should str(Nil) should be? 
        return ''
    
    def debruijn(self):        
        def scan(ast,env):
            #print (clsName(ast))
            #Variable
            if clsName(ast) == 'Variable':
                res=(env.lookup(str(ast)))
                if res == None:
                    #VarFree
                    return VarFree(ast.value)
                if res[0] == -1:
                    #VarParam
                    return VarParam(ast.value, res[1])
                #VarBound
                return VarBound(ast.value, res[0], res[1])
            
            #IfThenElse
            if clsName(ast) == 'IfThenElse':
                return IfThenElse(scan(ast.value[0], env), scan(ast.value[1], env), scan(ast.value[2], env))
            
            #Or
            if clsName(ast) == 'Or':
                tests = list(map(lambda x: scan(x,env), ast.value))
                return Or(tests)
            
            #Def
            if clsName(ast) == 'Def': 
                return Def(VarFree(ast.value[0].value), scan(ast.value[1], env) ) 
            
            #Applic
            if clsName(ast) == 'Applic':
                op = list(map(lambda x: scan(x, env), ast.value))
                return Applic(op)
            
            #Lambda
            if clsName(ast) in ('LambdaSimple', 'LambdaOpt'):
                #create new env for lambda
                newEnv = Env() 
                params = ast.value[0]
                body = ast.value[1]
                #add parameters to newEnv
                i=0;
                for p in params:
                    newEnv.add(str(p), i)
                    i+=1
                #wrap newEnv with env    
                newEnv.setEncloseEnv(env)
                
                if clsName(ast)=='LambdaSimple':
                    return LambdaSimple(params, scan(body, newEnv))
                return LambdaOpt(params, scan(body, newEnv))
            
            if clsName(ast) == 'LambdaVar':
                #create new env for lambda
                newEnv = Env() 
                p = ast.value[0]
                body = ast.value[1]
                #add p to newEnv
                newEnv.add(str(p), 0)
                #wrap newEnv with env    
                newEnv.setEncloseEnv(env)
                return LambdaVar(p, scan(body, newEnv))
                
            #nothing to do with node, leave unchanged
            return ast
        
        #print('~~~~~~~debruijn~~~~~~~~~~')
        env = Env()
        return scan(self,env)
    
    def annotateTC(self):
        def annotate(ast, tp):
            #Or
            if clsName(ast) == 'Or':
                if len(ast.value)<=1:
                    return ast
                #annotate every tests exept last with False
                tests = list(map(lambda x: annotate(x,False), ast.value[:-2])) 
                #annotate last
                tests.append(annotate(ast.value[-2],tp))
                #restore ending Nil
                tests.append(ast.value[-1])
                return Or(tests)
            
            #IfThenElse
            if clsName(ast) == 'IfThenElse':
                return IfThenElse(annotate(ast.value[0],False), annotate(ast.value[1],tp), annotate(ast.value[2],tp))
            
            #Def
            if clsName(ast) == 'Def':
                return Def(ast.value[0], annotate(ast.value[1], False) )
            
            #Lambda
            if clsName(ast) == 'LambdaOpt':
                return LambdaOpt(ast.value[0], annotate(ast.value[1], True))
            if clsName(ast) == 'LambdaVar':
                return LambdaVar(ast.value[0], annotate(ast.value[1], True))
            if clsName(ast) == 'LambdaSimple':
                return LambdaSimple(ast.value[0], annotate(ast.value[1], True))           
            
            #Applic
            if clsName(ast) == 'Applic':
                op = list(map(lambda x: annotate(x, False), ast.value))
                if tp:
                    return ApplicTP(op)
                return Applic(op)
            
            return ast
        
        #print('~~~~~~~annotateTC~~~~~~~~~~')
        return annotate(self, False)
    
    def code_gen(self):
        return '/*\t' + str(self) + '\t~~~~~~ code_gen() not emplemented! ~~~~~~*/\n'
    
    def semantic_analysis(self):
        return self.debruijn().annotateTC()
        
#************************ SubClasses ************************

class Constant(AbstractSchemeExpr):
    
    def __init__(self, obj):
        super().__init__(obj)
        aux.addConst(obj) #save for future constTable

    def __str__(self):
        if clsName(self.value) in self_evaluated:
            return str(self.value)
        return "'"+str(self.value)

    def code_gen(self):
        res=[]
        s = str(self)
        if s=='':
            s = 'Void'                
        if s[0] == "'":
            s = s[1:]
        res.append('/** Constant Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv")
        #u = makeLable("^^^^^^^^^^^^^^^^^^^")
        #res.append('printf("{}\\n");'.format(d))
        res.append('MOV(R0,IMM({}));\n'.format(aux.constTable[s]))
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** Constant End: {} **/'.format(str(self)))
        return '\n'.join(res)
        

class Variable(AbstractSchemeExpr):
    pass

class VarFree(Variable):
    def code_gen(self):
        var = str(self)
        res = []
        res.append('/** VarFree Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv")
        #u = makeLable("^^^^^^^^^^^^^^^^^^^")
        #res.append('printf("{}\\n");'.format(d))
        #get symbol obj from mem
        res.append('MOV(R0, IND({}));'.format(aux.symTable[var]))
        #get bucket
        res.append('MOV(R0, INDD(R0,1));')
        #get value
        res.append('MOV(R0, INDD(R0,1));\n')
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** VarFree End: {} **/'.format(str(self)))
        return '\n'.join(res)

    #def __str__(self):
        #return str(self.value) + 'f'

class VarParam(Variable):
    def __init__(self,obj, minor):
        super().__init__(obj)
        self.minor = minor
        
    #def __str__(self):
        #return str(self.value) + '_p' + str(self.minor)

    def code_gen(self):
        res=[]
        res.append('/** VarParam Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv")
        #u = makeLable("^^^^^^^^^^^^^^^^^^^")
        #res.append('printf("{}\\n");'.format(d))
        
        res.append('MOV(R0, FPARG({}));\n'.format(aux.firstParamDelta + self.minor))
        
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** VarParam end: {} **/'.format(str(self))) 
        return '\n'.join(res)

class VarBound(Variable):
    def __init__(self,obj, major, minor):
        super().__init__(obj)
        self.minor = minor
        self.major = major
    
    #def __str__(self):
        #return str(self.value) + '_b' + str(self.major) +','+ str(self.minor)
    
    def code_gen(self):
        res = []
        res.append('/** VarBound Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        
        res.append('MOV(R0, FPARG(0));')
        res.append('MOV(R0, INDD(R0,{major}));'.format(major=self.major+1))
        res.append('MOV(R0, INDD(R0,{minor}));\n'.format(minor=self.minor+1))
       
       #res.append('printf("{}\\n");'.format(u))
        res.append('/** VarBound End: {} **/'.format(str(self)))
        return '\n'.join(res)
    
class IfThenElse(AbstractSchemeExpr):
    def __init__(self,condPar, thenPar,elsePar):
        obj = [condPar, thenPar, elsePar]
        super().__init__(obj)

    def __str__(self):
        return '(if '+ ''.join(list(map(lambda x: self.strSorter(x) + ' ', self.value))) + ')'
    
    def code_gen(self):
        endLabel = makeLable('END_IF')
        difLabel = makeLable('DIF')
        res = []
        res.append('/** IF Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        
        res.append('{TEST}'.format(TEST = self.value[0].code_gen()))
        res.append('CMP(R0, SOB_FALSE);')
        res.append('JUMP_EQ({DIF_LABEL});'.format(DIF_LABEL = difLabel) )
        res.append('{DIT}'.format(DIT = self.value[1].code_gen()))
        res.append('JUMP({END_IF});'.format(END_IF = endLabel))
        res.append('{DIF_LABEL}:'.format(DIF_LABEL = difLabel))
        #if clsName(self.value[2].value) != 'Void':
        res.append('{DIF}'.format(DIF = self.value[2].code_gen()))
        res.append('{END_IF}:\n'.format(END_IF = endLabel))
        
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** If End: {} **/'.format(str(self)))
        return '\n'.join(res)

class AbstractLambda(AbstractSchemeExpr):
    def __init__(self, params, body): 
        obj = [params, body]
        super().__init__(obj)
        
    def __str__(self):
        return '(lambda ' + ''.join(list(map(lambda x: self.strSorter(x) + ' ', self.value)))+ ')'
                  
class LambdaSimple(AbstractLambda):
    def code_gen(self):
        res = []
        argc = len(self.value[0])-1 #last arg is nil
        cLabel = makeLable('L_CLUS_CODE')
        exitLable = makeLable('L_CLUS_EXIT')
        body = self.value[1].code_gen()
        
        res.append('/** LambdaSimple Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        
        #R1 holds result
        res.append('PUSH(R1);') 
        #create 3 cells and place at R1
        res.append('PUSH(IMM(3));')
        res.append('CALL(MALLOC);')
        res.append('MOV(R1,R0);')
        res.append('DROP(1);')
        #1 - tag
        res.append('MOV(IND(R1), T_CLOSURE);')
        #2 - expand env
        #res.append('PUSH(IMM({}));'.format(argc))
        #res.append('printf("Expanding {}");\n'.format(str(self)))
        res.append('CALL(EXPAND_ENV);')
        #res.append('DROP(1);')
        res.append('MOV(INDD(R1,1), R0);')
        #3 - code
        res.append('MOV(INDD(R1,2), LABEL({}));'.format(cLabel))
        res.append('MOV(R0,R1);')
        res.append('POP(R1);')
        res.append('JUMP({});'.format(exitLable))
        #B part - code label
        res.append('{}:'.format(cLabel))
        res.append('PUSH(FP);')
        res.append('MOV(FP, SP);')
        res.append('{}'.format(body))
        #can add testing here
        res.append('POP(FP);')
        res.append('RETURN;')
        #exit label
        res.append('{}:'.format(exitLable))        
        res.append('/** LambdaSimple End: {} **/'.format(str(self)))
        #res.append('printf("{}\\n");'.format(u))
        return '\n'.join(res)

class LambdaOpt(AbstractLambda):
    def code_gen(self):
        res = []
        cLabel = makeLable('L_CLUS_CODE')
        exitLable = makeLable('L_CLUS_EXIT')
        body = self.value[1].code_gen()
        argc = len(self.value[0])
        
        res.append('/** LambdaOpt Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        #R1 holds result
        res.append('PUSH(R1);') 
        #create 3 cells and place at R1
        res.append('PUSH(IMM(3));')
        res.append('CALL(MALLOC);')
        res.append('MOV(R1,R0);')
        res.append('DROP(1);')
        #1 - tag
        res.append('MOV(IND(R1), T_CLOSURE);')
        #2 - expand env
        #res.append('PUSH(IMM({}));'.format(argc))
        #res.append('printf("Expanding {}");\n'.format(str(self)))
        res.append('CALL(EXPAND_ENV);')
        #res.append('DROP(1);')
        res.append('MOV(INDD(R1,1), R0);')
        #3 - code
        res.append('MOV(INDD(R1,2), LABEL({}));'.format(cLabel))
        res.append('MOV(R0,R1);')
        res.append('POP(R1);')
        res.append('JUMP({});'.format(exitLable))
        #B part - code label
        res.append('{}:'.format(cLabel))
        res.append('PUSH(FP);')
        res.append('MOV(FP, SP);')
        #fix stack
        res.append('PUSH(IMM({}));'.format(argc))
        res.append('CALL(FIX_STACK);')
        res.append('DROP(1);')
        #run body with fixed stack
        res.append('{}'.format(body))
        #can add testing here
        res.append('POP(FP);')
        res.append('RETURN;')
        #exit label
        res.append('{}:'.format(exitLable))        
        #res.append('printf("{}\\n");'.format(u))
        
        res.append('/** LambdaOpt End: {} **/'.format(str(self)))
        return '\n'.join(res)


class LambdaVar(AbstractLambda) :
    def code_gen(self):
        res = []
        cLabel = makeLable('L_CLUS_CODE')
        exitLable = makeLable('L_CLUS_EXIT')
        body = self.value[1].code_gen()
        argc = 1
        
        res.append('/** LambdaVar Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        
        #R1 holds result
        #R1 holds result
        res.append('PUSH(R1);') 
        #create 3 cells and place at R1
        res.append('PUSH(IMM(3));')
        res.append('CALL(MALLOC);')
        res.append('MOV(R1,R0);')
        res.append('DROP(1);')
        #1 - tag
        res.append('MOV(IND(R1), T_CLOSURE);')
        #2 - expand env
        #res.append('PUSH(IMM({}));'.format(argc))
        #res.append('printf("Expanding {}");\n'.format(str(self)))
        res.append('CALL(EXPAND_ENV);')
        #res.append('DROP(1);')
        res.append('MOV(INDD(R1,1), R0);')
        #3 - code
        res.append('MOV(INDD(R1,2), LABEL({}));'.format(cLabel))
        res.append('MOV(R0,R1);')
        res.append('POP(R1);')
        res.append('JUMP({});'.format(exitLable))
        #B part - code label
        res.append('{}:'.format(cLabel))
        res.append('PUSH(FP);')
        res.append('MOV(FP, SP);')
        #fix stack
        res.append('PUSH(IMM({}));'.format(argc))
        res.append('CALL(FIX_STACK);')
        res.append('DROP(1);')
        #run body with fixed stack
        res.append('{}'.format(body))
        #can add testing here
        res.append('POP(FP);')
        res.append('RETURN;')
        #exit label
        res.append('{}:'.format(exitLable))        
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** LambdaVar End: {} **/'.format(str(self)))
        return '\n'.join(res)

class Applic(AbstractSchemeExpr):
    def __str__(self):
       return '(' + ''.join(list(map(lambda x: self.strSorter(x) + ' ', self.value)))+ ')'

    def code_gen(self):
        res = []
        opCount = len(self.value)-2
        res.append('/** Applic Start: {} **/'.format(str(self)))
        
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        
        #save R1
        res.append('PUSH(R1);')
        #push operands
        if opCount > 0:     
            op = self.value[1:-1]
            for o in reversed(op):
                res.append(o.code_gen()) 
                res.append('PUSH(R0);')
        #push argc
        res.append('PUSH(IMM({argc}));'.format(argc = opCount))
        #save operator clouse at R1
        res.append(self.value[0].code_gen())
        res.append('MOV(R1,R0);')
        #check if clouse type
        res.append('PUSH(R1);')
        res.append('CALL(IS_SOB_CLOSURE);')
        res.append('DROP(1);')
        res.append('CMP(R0, IMM(0));')
        res.append('JUMP_EQ(NOT_A_CLOSURE_ERROR);')
        #push env
        res.append('PUSH(INDD(R1, 1));')
        #call application
        res.append('CALLA(INDD(R1, 2));')
        #Stack cleanup
        res.append('DROP(1);//env')#env
        res.append('POP(R1);//argc')#argc
        #res.append('printf("\\t\\tdroped R1 = {}{}\\n", R1);'.format('%','ld'))
        res.append('DROP(R1);\n')#
        #restore R1
        res.append('POP(R1);')
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** Applic End: {} **/'.format(str(self)))
        return '\n'.join(res)

class ApplicTP(Applic):
    pass
'''    def code_gen(self):
        res = []
        opCount = len(self.value)-2
        res.append('/** ApplicTC Start: {} **/'.format(str(self)))
        
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        
        if opCount > 0:     
            op = self.value[1:-1]
            for o in reversed(op):
                res.append(o.code_gen()) 
                res.append('PUSH(R0);')
        #push argc
        res.append('PUSH(IMM({argc}));'.format(argc = opCount))
        #operator
        res.append(self.value[0].code_gen())
        #check if clouse type
        res.append('CMP(IND(R0), T_CLOSURE);')
        res.append('JUMP_NE(NOT_A_CLOSURE_ERROR);')
        #push env
        res.append('PUSH(INDD(R0, 1));')
        #reuse return addres
        res.append('PUSH(FPARG(-1));')
        #R3 will calculate new SP. point to bottom of old frame
        res.append('PUSH(R3);')
        res.append('MOV(R3, FP);')
        res.append('SUB(R3, FPARG(1));')
        res.append('DECR(R3);')
        #reuse old FP
        res.append('PUSH(FPARG(-2));')
        #overwrite old frame 
        res.append('PUSH(R1);')
        res.append('PUSH(R2);')        
        #R2 index to bottom of old frame
        res.append('MOV(R2, FPARG(1));')
        res.append('INCR(R2);')
        #R1 index to bottom of new frame
        res.append('MOV(R1, IMM(-3));')
        
        #i=new frame size + saved R + FP 
        i= opCount + 7;
        while i > 0:
            res.append('MOV(FPARG(R2), FPARG(R1));')
            #res.append('printf("copied {}ld \\n", FPARG(R1));'.format('%'))
            res.append('DECR(R1);')
            res.append('DECR(R2);')
            res.append('INCR(R3);')
            i-=1
         #restore values
        res.append('MOV(SP,R3);')
        res.append('POP(R2);')
        res.append('POP(R1);')
        res.append('POP(FP);')
        res.append('POP(R3);')
        res.append('INCR(SP);')
        #res.append('MOV(SP, FP);')
        #res.append('ADD(SP, IMM(3));')
        #res.append('printf("!!!!!!!!!!!!!\\n");')
        #call application
        res.append('JUMPA(INDD(R0, 2));')
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** ApplicTC End: {} **/'.format(str(self)))
        return '\n'.join(res)
'''
class Or(AbstractSchemeExpr):
    def __str__(self):
        return '(or '+ ''.join(list(map(lambda x: self.strSorter(x) + ' ', self.value))) + ')'
    
    def code_gen(self):
        eLst = list(map(lambda x: x.code_gen(), self.value[:-1]))
        res = []
        endLable = makeLable('END_OR')
        res.append('/** Or Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        
        #res.append('printf("{}\\n");'.format(d))
        res.append('MOV(R0, SOB_FALSE);')#case (or)
        i = 1
        while i <= len(eLst):
            res.append(eLst[i-1])
            res.append('CMP(R0, SOB_FALSE);')
            res.append('JUMP_NE({END_OR});'.format(END_OR=endLable))
            i += 1
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** Or End: {} **/'.format(str(self)))
        res.append(endLable +':\n')
        return '\n'.join(res)
    
class Def(AbstractSchemeExpr):
    def __init__(self, name, expr):
        obj = [name, expr]
        super().__init__(obj)

    def __str__(self):
        return'(define '+ ''.join(list(map(lambda x: self.strSorter(x) + ' ', self.value))) + ')'
        
    def code_gen(self):
        res = []
        name = str(self.value[0])
        #print(self.value[1])
        val = self.value[1].code_gen()
        memIndex = aux.symTable[name]
        #print('{} index = {}'.format(name,memIndex))
        res.append('/** Def Start: {} **/'.format(str(self)))
        #d = makeLable("vvvvvvvvvvvvvvvvvvvvv");
        #u = makeLable("^^^^^^^^^^^^^^^^^^^");
        #res.append('printf("{}\\n");'.format(d))
        #save R1
        res.append('PUSH(R1);')
        #R0 holds new value
        res.append('{}'.format(val))
        #R1 points to sym obj
        res.append('MOV(R1,IND({}));'.format(memIndex))
        #R1 points to bucket
        res.append('MOV(R1, INDD(R1,1));')
        #bind new value
        res.append('MOV(INDD(R1,1),R0);')
        #return Void
        res.append('POP(R1);\n')
        #res.append('printf("{}\\n");'.format(u))
        res.append('/** Def End: {} **/'.format(str(self)))
        return '\n'.join(res)
#************************ Aux methods & variables ************************

#parse according to class-name of given ast.
def tagParse(ast):
    #print('tagParse(%s)' % ast)
    className = clsName(ast)
    #Constant
    if (className in self_evaluated):
        return Constant(ast)
    if className == 'Vector':
        ast.value = tagParse(ast.value)
        return ast
    #variable
    if className =='Symbol':
        return Variable(ast)
    #process Pair, check first word
    if (className == 'Pair'):
        fst = ast.value[0]
        sec = ast.value[1]
        if clsName(fst) == 'Pair':
            #Pair as first element can be only Applic
            return createApplic(ast)
        #some string is first element
        #look in synSuger words
        if fst.value in synSuger:
            #print('SG')
            return synSuger.get(fst.value)(sec)
        #look in reserved words
        if fst.value in reservedWords:
            #print('RW')
            return reservedWords.get(fst.value)(sec)
        #unknown string, Applic. Fix-(f 1), should f be Symbol or Variable?
        if clsName(fst) in ('Symbol', 'Integer'):
            return createApplic(ast)
        #memders of vector/list. fix - not sure if ever used...
        return tagParsePair(ast)
    #nothing to tagParse
    return ast

def clsName(obj):
    return obj.__class__.__name__

#checks if last member of nested pairs is Nil
def isProperList(l):
    if clsName(l) != 'Pair':
        if clsName(l) == 'Nil':
            return True
        else:
            return False
    else:
        return isProperList(l.value[1])

#tagParse nested Pairs. converts (QUOTE a) into Constant(a). called by expand_qq 
def tagParsePair(ast):
    #print('\t tagParsePair: ' ,ast) 
    if clsName(ast) != 'Pair':
        return tagParse(ast)
    
    fst = ast.value[0]
    rest = ast.value[1]
    if clsName(fst) != 'Pair':
        if str(fst) == 'QUOTE':
            #case (QUOTE a)
            return Constant(tagParse(rest))
        #case (a . (...))
        return reader.sexprs.Pair( tagParse(fst), tagParsePair(rest) )
    if str(fst.value[0]) == 'QUOTE':
        #case ((QUOTE . a) . (...))
        return reader.sexprs.Pair( Constant(fst.value[1]), tagParsePair(rest) )
    else:
        #case ((f . a) . (...))
        return reader.sexprs.Pair( tagParse(fst), tagParsePair(rest) )
    
#tagParse and flatten elements of nested Pairs. returns a list  
def tagParseFlattenPair(lst,p):
    if clsName(p) != 'Pair':
        #last element of list
        lst.append( (tagParse(p)) )
    else:
        lst.append( (tagParse(p.value[0])) )
        tagParseFlattenPair(lst, p.value[1])

#flatten elements of nested Pairs
def flattenPair(lst,p):
    if clsName(p) != 'Pair':
        #last element of list
        lst.append(p)
    else:
        lst.append( p.value[0] )
        flattenPair(lst, p.value[1])

#************ SubClasses aux - creation methods ************

#wraps qoute content in Constant
def processQuote(ast):
    #print(clsName(ast))
    if isProperList(ast):
        #print('!!!!')
        return Constant(ast.value[0])
    return Constant(ast)
'''
def processQuote(ast):
    def f(ast):
        if clsName(ast) in self_evaluated:
            return Constant(ast, False)
        if clsName(ast) == 'Vector':
            return reader.sexprs.Vector( f(ast.value))
        if clsName(ast) in ('Nil', 'Symbol'):
            return ast
        #wrap first elemet in Constant and Pair with rest of list
        fst = Constant(ast.value[0] , True)
        return reader.sexprs.Pair(fst, f(ast.value[1]))
    
    
    if clsName(ast) in self_evaluated:
        return Constant(ast, False)
    if isProperList(ast):
        #print(clsName(ast.value[0]))
        if clsName(ast.value[0]) in ('Symbol', 'Integer'):
            return Constant(ast.value[0], False)
        if clsName(ast.value[0]) == 'Vector':
            return Constant(f(ast.value[0]), True)
        return Constant(f(ast.value[0]), False)
    return Constant(f(ast.value), False)
'''
def createIf(ast):
    condPar = tagParse( ast.value[0] )
    thenPar = tagParse( ast.value[1].value[0] )
    if clsName(ast.value[1].value[1]) == 'Nil':
        #No else parameter, parse as Constant(void)
        elsePar = Constant(reader.sexprs.Void())
    else:
        #parse only first element of the pair
        elsePar = tagParse( ast.value[1].value[1].value[0])
    return IfThenElse(condPar, thenPar, elsePar)

def createLambda(ast):
    paramsClassName = clsName(ast.value[0]) 
    body = tagParse( ast.value[1].value[0] )
    #lambdaVar
    if paramsClassName =='Symbol':
        return LambdaVar( tagParse(ast.value[0]) , body )
    if paramsClassName in ('Pair', 'Nil'):
        params=[]
        tagParseFlattenPair(params, ast.value[0])
        #lambdaSimple
        if isProperList(ast.value[0]):
            return LambdaSimple( params, body )
        #lambdaOpt
        else:
            return LambdaOpt( params, body )

def createDefine(ast):
    fst = ast.value[0]
    #regular form
    if clsName(fst) == 'Symbol':
        name = tagParse( ast.value[0] )
        expr = tagParse( ast.value[1].value[0] )
        return Def(name, expr)
    #MIT form
    if clsName(fst) == 'Pair':
        name = tagParse( ast.value[0].value[0] )
        argl = ast.value[0].value[1]
        expr = ast.value[1]
        return Def(name, createLambda(reader.sexprs.Pair(argl, expr)))
    
def createOr(ast):
    tests = []
    tagParseFlattenPair(tests, ast)
    return Or(tests)

def createApplic(ast):
    obj = []
    tagParseFlattenPair( obj ,ast )
    return Applic(obj)

#**************************** Syntactic Suger Expanders ****************************

def expandCond(ast):
    #aux method, break Cond into nested IfThenElse according to last condition
    def f(c, rest):
        condPar = tagParse(c.value[0])
        thenPar = tagParse(c.value[1].value[0])
        #rest = Nil, no else condition
        if str(rest.value) == '()':
            elsePar = Constant(reader.sexprs.Void())
        #rest = 'else'
        else:
            if str(rest.value[0].value[0]) == 'ELSE':
                elsePar = tagParse(rest.value[0].value[1].value[0])
            #rest = more conds 
            else:
                elsePar = f(rest.value[0], rest.value[1])
        return IfThenElse(condPar, thenPar, elsePar)
    return f(ast.value[0], ast.value[1])

#tag parse let parts. return params and values in lists, body as is(Fix - can dismiss body Pair form).
#assumes let inner pairs are proper list (ignors ending Nil)
def extractLetParts(ast):
    applcPairs = []
    flattenPair(applcPairs,ast.value[0])
    params = list(map(lambda x: tagParse(x.value[0]), applcPairs[:-1] ))
    values = list(map(lambda x: tagParse(x.value[1].value[0]), applcPairs[:-1] ))
    #restore ignored Nils for corrct printing
    nil, r = AbstractSchemeExpr.parse('()')
    params.append(nil)
    values.append(nil)
    #extract main body, assumes body is a singl expr
    #print(clsName(ast.value[1].value[0]))
    if clsName(ast.value[1].value[0]) in self_evaluated:
        body = tagParse(ast.value[1])
    else:
        body = body = tagParse(ast.value[1].value[0])
    #print(body)
    return (params, values, body)

#tagParse Let during expandind process
def expandLet(ast):
    #extract let parameters and values
    params, values, body = extractLetParts(ast)
    #create lambda
    l = LambdaSimple(params, body)
    #craete Applic of lambda & values
    obj = [l] + values
    return Applic(obj)
    
#extract Let* -> nested Lets. tagParse result
def expandLetStar(ast):
    #creates (let ((v1 e1) (let ...))
    def createNestedLet(v_e_lsts,e):
        #recursive let creation
        if len(v_e_lsts) == 1:
            return createLet(v_e_lsts[0], e)
        #final (let ((v_n e_n)) E)
        return createLet(v_e_lsts[0], createNestedLet(v_e_lsts[1:], e))
   
   #create (let ((v e)) E) in pairs form   
    def createLet(p, body):
        innerPair = reader.sexprs.Pair( p, body )
        #add outer let
        nestedLet =  reader.sexprs.Pair( reader.sexprs.Symbol('LET'), innerPair)
        #print('nested:' ,nestedLet)
        return nestedLet
    
    #extract pairs without tagParse
    v_e_lsts =[]
    flattenPair(v_e_lsts, ast.value[0])
    if len(v_e_lsts) == 1:
        #empty let* is the same as empty let
        return expandLet(ast)
    #create Pairs from v_e_lsts members
    v_e_lsts = list(map(lambda x: reader.sexprs.Pair(x, reader.sexprs.Nil() ), v_e_lsts) ) 
    body = ast.value[1].value[0]
    nestedLet = createNestedLet(v_e_lsts[:-1], body)
    return tagParse(nestedLet)

#extract Letrec -> Yag form. tagParse result.
#fix - assumes letrec is not empty. (letrec () ...) will give error
def expandLetrec(ast):
    #creates singal (lambda (g_0 ... g_n) E_i) in Pairs form
    def createLambdaList(g_lst, le_n):
        l = reader.sexprs.Symbol('LAMBDA')
        p = reader.sexprs.Pair( g_lst, le_n )
        return reader.sexprs.Pair(l,p)
    
    #converts lst into nested Pair form
    def createPairs(lst):
        if len(lst) == 0:
            #empty lst
            return lst
        if len(lst) == 1:
            #final Pair, end with Nil
            return reader.sexprs.Pair(lst[0],reader.sexprs.Nil())
        return reader.sexprs.Pair(lst[0], createPairs(lst[1:]))
    
    #get (v_i le_i) pairs without parsing     
    g_le_lsts =[]
    flattenPair(g_le_lsts,ast.value[0])
    #separate pairs into 2 lists
    g_lst = list(map(lambda x: x.value[0], g_le_lsts[:-1]))
    g_lst = createPairs(g_lst) 
    le_lst = list(map(lambda x: x.value[1], g_le_lsts[:-1]))
    #print('#########',g_lst)
    #get body. Fix - can dismiss Pair form
    body = ast.value[1]
    #create g_0. get fresh symbol and append to begining of g_lst 
    freshSym = reader.sexprs.Symbol(GenSym.gen())
    g_lst = reader.sexprs.Pair(freshSym, g_lst)
    
    #create Lambdas as { Pair(LAMBDA (PAIR (g_le_lst, le_n))) }. gives a list of inner lambdas
    lmb_lst = [createLambdaList(g_lst, body)]
    for le in le_lst:
        lmb_lst.append( createLambdaList( g_lst, le ) )
    #convert lambdas to nested Pair
    lmb_lst = createPairs(lmb_lst)
    
    #create Yag variable
    yag = reader.sexprs.Symbol('YAG')
    #pair ans tagParse as application
    return tagParse( reader.sexprs.Pair(yag , lmb_lst) )
    
def expandAnd(ast):
    #aux method, and with 2+ members
    def f(c,rest):
        condPar = tagParse(c)
        elsePar = Constant(reader.sexprs.Boolean('f'))
        #rest.value[0] is last member
        if clsName(rest.value[1]) == "Nil":
            thenPar = tagParse(rest.value[0])
        #create embedded IfThenElse
        else:
            thenPar = f(rest.value[0], rest.value[1])
            
        return IfThenElse(condPar,thenPar,elsePar)
    
    #empty (and) is allways True
    if clsName(ast) == 'Nil':
        ans, r = AbstractSchemeExpr.parse('#t')
        return ans
    # singalton (and a) = a
    if clsName(ast.value[1]) == 'Nil':
        ans = tagParse(ast.value[0])
        return ans
    #more the 2 members (and a b ...)
    return f(ast.value[0], ast.value[1])

#expands quasiquote. 
#unquote & spliceQuote memebers are expanded to applictions of CONS & APPEND. other members are wrap as (QUOTE m)
#calls tagParsePair, wraps result in Constant
def expand_qq(ast):
    #id methods
    def isUnq(ast):
        return (clsName(ast) == 'Pair' and str(ast.value[0]) == 'UNQUOTE')
    def isUnqSpl(ast):
        return (clsName(ast) == 'Pair' and str(ast.value[0]) == 'UNQUOTE-SPLICING')
    def f(ast):
        if isUnq(ast):
            return ast.value[1].value[0]
        if isUnqSpl(ast):
            raise SchemeSyntacticError('illegal quasiquote: `,@x form make no sense')
        #print(clsName(ast))
        if clsName(ast) =='Pair':
            a = ast.value[0]
            b = ast.value[1]
            if isUnqSpl(a):
                #print('@@@@@@ UqSpl A @@@@@@')
                apnd = reader.sexprs.Symbol('APPEND')
                p = reader.sexprs.Pair( a.value[1].value[0], f(b) )
                return reader.sexprs.Pair(apnd, p)
            if isUnqSpl(b):
                #print('@@@@@@ UqSpl B @@@@@@')
                #q = reader.sexprs.Symbol('QUOTE')
                cons = reader.sexprs.Symbol('CONS')
                p = reader.sexprs.Pair( f(a) , b.value[1].value[0] )
                return reader.sexprs.Pair(cons, p)
            #else
            return reader.sexprs.Pair( f(a) , f(b) )
                        
        #skiped vector?
        #print(ast)
        #print(clsName(ast))
        if clsName(ast) in ('Symbol', 'Integer'):
            return (reader.sexprs.Pair( reader.sexprs.Symbol('QUOTE'), ast)) 
        if clsName(ast) == 'Nil':
            return reader.sexprs.Nil()
        return ast
    
    #main 
    #print(clsName(ast.value[0]))
    if clsName(ast.value[0]) == 'Vector':
        #expand_qq on  vec members
        ast.value[0].value = f(ast.value[0].value)
        return ast.value[0]
    if clsName(ast.value[0]) == 'Symbol':
        return tagParse((reader.sexprs.Pair( reader.sexprs.Symbol('QUOTE'), ast)))
    if isUnq(ast.value[0]):
        #case `,(...). canceled qq
        return Constant( tagParse(ast.value[0].value[1].value[0]))
    return Constant( tagParsePair(f(ast.value[0])))

#creates fresh variable name. assumes user cant use ~ char.
class GenSym(object):
    i = 0
    def gen():
        sym = '~genSym_' + str(GenSym.i)
        GenSym.i += 1
        return sym

LABELS = {}
def makeLable(name):
    if name in LABELS:
        LABELS[name] += 1
    else:
        LABELS.setdefault(name, 0)
    l = '{}_{}'.format(name, LABELS[name])
    #print('fresh label: {}\n'.format(l))
    return l

#**************** tagParse aux dics ****************
self_evaluated = ('Boolean', 'Char', 'Integer', 'Fraction', 'String', 'Void')
reservedWords = {'IF':createIf,'LAMBDA':createLambda, 'DEFINE':createDefine, 'OR': createOr, 'QUOTE': processQuote }
synSuger = {'COND': expandCond, 'LET': expandLet, 'LET*': expandLetStar, 'LETREC':expandLetrec, 'AND':expandAnd, 'QUASIQUOTE':expand_qq}


#************ testing ************
'''
s = (string-ref "\n" 0)

a,r = reader.pSexpr.match(s)
b,r = AbstractSchemeExpr.parse(s)
c = b.semantic_analysis()
print(c)

print('consts', aux.constLst)
print('symbols', aux.symLst)

d = c.code_gen()

x = d.split('\n')
res = ''
for line in x:
    if ';' in line:
        res += '\t'+line + '\n'
    else:
        res += line + '\n'
#print(a)

#print(c)
print(res)
'''