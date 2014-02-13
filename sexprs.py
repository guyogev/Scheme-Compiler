"""
sexpers.py
written by: Guy yogev

takes a String as input and returns an AST of Scheme expretions.

"""


import reader, aux

#********************************** visitors ********************************

class AbstractVisitor(object):
  def visit(self, obj):pass

class StrVisitor(AbstractVisitor):
  def __init__(self,n):
      # n==1: general, n==2:Pair, n=='f': Fraction, n=='v':Vector 
      self.argsNumber = n
  
  def visit(self,obj):
    if (self.argsNumber == 1):
        return self.genVisit(obj)
    if (self.argsNumber == 2):
        return self.visitPair(obj)
    if (self.argsNumber == 'f'):
        return self.visitFractrion(obj)
    if (self.argsNumber == 'v'):
        return self.visitVector(obj)
    raise Exception('sexpers.py - StrVisitor Failed')
    
  #general form 
  def genVisit(self,obj):
    #print('genVisit')
    if obj.__class__.__name__ == 'Boolean':
        if obj.value:
            return '#t'
        return '#f'
    if obj.__class__.__name__ == 'String':
        return '"' + str(obj.value) + '"'
    if obj.__class__.__name__ == 'Char':
        return '#\\' + str(obj.value)
    
    return str(obj.value)
  
  def visitPair(self,obj):
    #print('VisitPair')
    if obj.value[1].__class__.__name__ =='Nil':
        return '(' + str(obj.value[0]) + ')'
    return '(' + str(obj.value[0]) +' . '+ str(obj.value[1])+ ')'

  def visitFractrion(self,obj):
    #print('visitFractrion')
    return str(obj.value[0]) + '/' + str(obj.value[1])

  def visitVector(self, obj):
      res = ''
      for o in obj.value:
          res += str(o)+' '
      return '#(' + res + ')'
#********************************** sexpers ********************************
class AbstractSexpr(object):
  @staticmethod
  def readFromString(s):
    return reader.pSexpr.match(s)

  def __init__(self, value):
    self.value = value
    self.strVisitor = StrVisitor(1)
  
  def __str__(self):
    return self.strVisitor.visit(self)
  
class Void(AbstractSexpr):
    def __init__(self):
        super().__init__('')

class Nil(AbstractSexpr):
    def __init__(self):
        super().__init__("()")

class Boolean(AbstractSexpr):
  def __init__(self, value):
    if value in ('F', 'f'): 
        super().__init__(False)
    else:
        super().__init__(True)

class Char(AbstractSexpr):
    pass

class AbstractNumber(AbstractSexpr):
    pass
  
class Integer(AbstractNumber):
  def addSign(self, sign):
    if sign=='-':
        self.value = -self.value
    return self
  
    
class Fraction(AbstractNumber):
  def __init__(self, num, den):
    super().__init__([num,den])
    self.strVisitor = StrVisitor('f')
    
class String(AbstractSexpr):
    pass

class Symbol(AbstractSexpr):
    def __init__(self, value):
        super().__init__(value)
        aux.addSym(value) #save for future symTable


class Pair(AbstractSexpr):
    def __init__(self,a,b):
        super().__init__([a,b])
        self.strVisitor = StrVisitor(2)

class Vector(AbstractSexpr):
    def __init__(self,obj):
        def f(lst,obj):
            if obj.__class__.__name__ == 'Nil':
                return lst
            if obj.__class__.__name__ != 'Pair':
                lst.append(obj)
            else:
                lst.append(obj.value[0])
                f(lst, obj.value[1])
            return lst
         
        lst = f([],obj)
        super().__init__(lst)
        self.strVisitor = StrVisitor('v')

    def semantic_analysis(self):
        return self
