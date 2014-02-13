"""
reader.py
written by: Guy yogev

The reader using, a Parsing Combinator Stack, creates an AST of token's for given string.
The reader is used by by sexprs.py

"""

import pc
import sexprs
import fractions as F


#********************************* Parsers *********************************
ps = pc.ParserStack()
  
pAcceptAll = ps.const(lambda x: True)\
            .done()
pNewLine = ps.const(lambda x: x=='\n')\
            .done()

def hexRange(x):
  return (x>='0' and x<='9') or (x.lower()>='a' and x.lower()<='f')

#************ Comments ************

pWhiteSpace = ps.const(lambda x: x<=' ')\
    .plus()\
    .done()

#fix? - need to be after some element
pLineComment = ps.const(lambda x: x==';')\
            .parser(pAcceptAll)\
            .parser(pNewLine)\
            .butNot()\
            .star()\
            .parser(pNewLine)\
            .catens(3)\
            .done()

pSexprComment = ps.parser(pc.pcWord('#;'))\
    .delayed_parser(lambda: pSexpr)\
    .caten()\
    .done()

pSkip = ps.parser(pWhiteSpace)\
    .parser(pLineComment)\
    .parser(pSexprComment)\
    .disjs(3)\
    .star()\
    .done()

#************ sexprs ************

pBoolean = ps.const(lambda x: x=='#')\
        .const(lambda x: x in ('t','T','f','F') )\
        .caten()\
        .pack(lambda x: sexprs.Boolean(x[1]))\
        .done()

pDec = ps.const(lambda x: x>='0' and x<='9')\
    .plus()\
    .pack(lambda x: int(''.join(x)))\
    .done()

pHex = ps.const(lambda x: x=='0')\
        .const(lambda x: x in ('x','X','h','H'))\
        .const(lambda x: hexRange(x))\
        .plus()\
        .pack(lambda x: ''.join(x))\
        .catens(3)\
        .pack(lambda x: int(x[2],16))\
        .done()

pUnsignedInt = ps.parser(pHex)\
            .parser(pDec)\
            .disj()\
            .pack(lambda x: sexprs.Integer(x))\
            .done()

pSignedInt = ps.const(lambda x: x in ('-','+'))\
        .parser(pUnsignedInt)\
        .caten()\
        .pack(lambda x: x[1].addSign(x[0]) )\
        .done()

#aux func for pFraction
def createFraction(x):
    def minimaizeFraction(n,d):
        f = F.Fraction(n.value,d.value)
        return [f.numerator, f.denominator]
        
    if x[2].value == 0:
        raise pc.NoMatch
    else:
        [n,d] = minimaizeFraction(x[0], x[2])
        if d == 1:
            return sexprs.Integer(n)
        else:
            return sexprs.Fraction(sexprs.Integer(n),sexprs.Integer(d))

pFraction = ps.parser(pSignedInt)\
        .parser(pUnsignedInt)\
        .disj()\
        .const(lambda x: x=='/')\
        .parser(pUnsignedInt)\
        .catens(3)\
        .pack(lambda x: createFraction(x) )\
        .done()

pNumber = ps.parser(pFraction)\
    .parser(pSignedInt)\
    .parser(pUnsignedInt)\
    .disjs(3)\
    .done()

#aux tupple for pSymbol
punctuationMarks = ('!','$','^','*','_','=','+','-','<','>','/','?')

pSymbol = ps.const(lambda x: x>='a' and x<='z')\
        .const(lambda x: x>='A' and x<='Z')\
        .const(lambda x: x>='0' and x<='9')\
        .const(lambda x: x in punctuationMarks)\
        .disjs(4)\
        .pack(lambda x: x.upper() )\
        .plus()\
        .pack(lambda x: ''.join(x))\
        .pack(lambda x: sexprs.Symbol(x))\
        .done()

#aux, inuse with pString. fix '\\' \l ?
pStringMetaChar = ps.parser(pc.pcWordCI('\n'))\
                .pack(lambda x: chr(10))\
                .parser(pc.pcWordCI('\r'))\
                .pack(lambda x: chr(13))\
                .parser(pc.pcWordCI('\t'))\
                .pack(lambda x: chr(9))\
                .parser(pc.pcWordCI('\f'))\
                .pack(lambda x: chr(12))\
                .parser(pc.pcWordCI('\\'))\
                .pack(lambda x: chr(92))\
                .parser(pc.pcWordCI('\"'))\
                .pack(lambda x: chr(34))\
                .parser(pc.pcWordCI('\l'))\
                .pack(lambda x: unichr(0x03bb))\
                .disjs(7)\
                .done()

pString = ps.const(lambda x: x=='"')\
        .parser(pStringMetaChar)\
        .parser(pAcceptAll)\
        .disj()\
        .const(lambda x: x=='"')\
        .butNot()\
        .star()\
        .pack(lambda x: ''.join(x))\
        .const(lambda x: x=='"')\
        .catens(3)\
        .pack(lambda x: sexprs.String(x[1]))\
        .done()

pNamedChar = ps.parser(pc.pcWordCI('newline'))\
            .pack(lambda x: chr(10))\
            .parser(pc.pcWordCI('return'))\
            .pack(lambda x: chr(13))\
            .parser(pc.pcWordCI('tab'))\
            .pack(lambda x: chr(9))\
            .parser(pc.pcWordCI('page'))\
            .pack(lambda x: chr(12))\
            .parser(pc.pcWordCI('lambda'))\
            .pack(lambda x: unichr(0x03bb))\
            .disjs(5)\
            .done()

pHexChar = ps.const(lambda x: x=='x')\
        .const(lambda x: hexRange(x) )\
        .const(lambda x: hexRange(x) )\
        .const(lambda x: hexRange(x) )\
        .const(lambda x: hexRange(x) )\
        .catens(4)\
        .pack(lambda x: ''.join(x))\
        .const(lambda x: hexRange(x) )\
        .const(lambda x: hexRange(x) )\
        .caten()\
        .disj()\
        .caten()\
        .pack(lambda x: ''.join(x))\
        .pack(lambda x: unichr(int('0'+x,16)))\
        .done()

pVisibleChar = ps.const(lambda x: x>' ')\
        .done()

pChar = ps.parser(pc.pcWord('#\\'))\
    .parser(pNamedChar)\
    .parser(pHexChar)\
    .parser(pVisibleChar)\
    .disjs(3)\
    .caten()\
    .pack(lambda x: sexprs.Char(x[1]))\
    .done()

#aux for properList / improperList / Nil
def breakToPairs(s,a):
    if s:
        return sexprs.Pair(s[0], breakToPairs(s[1:],a) )
    else:
        return a

pProperList = ps.const(lambda x: x== '(')\
    .delayed_parser(lambda: pSexpr)\
    .star()\
    .const(lambda x: x== ')')\
    .catens(3)\
    .pack(lambda x: breakToPairs(x[1], sexprs.Nil() ) )\
    .done()

pImproperList = ps.const(lambda x: x== '(')\
    .delayed_parser(lambda: pSexpr)\
    .plus()\
    .const(lambda x: x=='.')\
    .delayed_parser(lambda: pSexpr)\
    .const(lambda x: x== ')')\
    .catens(5)\
    .pack(lambda x: breakToPairs(x[1], x[3]) )\
    .done()

pPair = ps.parser(pImproperList)\
    .parser(pProperList)\
    .disj()\
    .done()

pVector = ps.const(lambda x: x== '#')\
        .parser(pPair)\
        .caten()\
        .pack(lambda x: sexprs.Vector(x[1]) )\
        .done()

pProparQuate = ps.const(lambda x: x== "'")\
        .delayed_parser(lambda: pSexpr)\
        .caten()\
        .pack(lambda x: sexprs.Pair( sexprs.Symbol('QUOTE'), sexprs.Pair( x[1], sexprs.Nil() ) ))\
        .done()

pQuasiQuote = ps.const(lambda x: x== "`")\
        .delayed_parser(lambda: pSexpr)\
        .caten()\
        .pack(lambda x: sexprs.Pair( sexprs.Symbol('QUASIQUOTE'), sexprs.Pair( x[1], sexprs.Nil() ) ))\
        .done()

pUnquoate = ps.const(lambda x: x== ",")\
        .delayed_parser(lambda: pSexpr)\
        .caten()\
        .pack(lambda x: sexprs.Pair( sexprs.Symbol('UNQUOTE'), sexprs.Pair( x[1], sexprs.Nil() ) ))\
        .done()

pUnquoateSplicing = ps.parser(pc.pcWord(',@') )\
        .delayed_parser(lambda:  pSexpr)\
        .caten()\
        .pack(lambda x: sexprs.Pair( sexprs.Symbol('UNQUOTE-SPLICING'), sexprs.Pair( x[1], sexprs.Nil() ) ))\
        .done()

pQuote = ps.parser(pUnquoateSplicing)\
        .parser(pUnquoate)\
        .parser(pQuasiQuote)\
        .parser(pProparQuate)\
        .disjs(4)\
        .done()

pSexpr = ps.parser(pSkip)\
        .parser(pVector)\
        .parser(pPair)\
        .parser(pChar)\
        .parser(pString)\
        .parser(pNumber)\
        .parser(pBoolean)\
        .parser(pQuote)\
        .parser(pSymbol)\
        .disjs(8)\
        .parser(pSkip)\
        .catens(3)\
        .pack(lambda x: x[1])\
        .done()\