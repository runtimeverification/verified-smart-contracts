#!/usr/bin/env python3
import sys

def isIdentifierChar(c):
  return c.isalnum() or c == '_' or c == '-'

class StringParser:
  DEFAULT = 0
  STRING = 1
  ESCAPE = 2
  def __init__(self):
    self.__state = StringParser.DEFAULT
    self.__terminator = '"'
    self.__contents = []

  def processCharImmediate(self, c):
    list(self.processChar(c))

  def processChar(self, c):
    if self.__state == StringParser.DEFAULT:
      if c == '"':
        self.__state = StringParser.STRING
        self.__terminator = '"'
        self.__contents = []
      elif c == "'":
        self.__state = StringParser.STRING
        self.__terminator = "'"
        self.__contents = []
      else:
        return c
    elif self.__state == StringParser.STRING:
      if c == self.__terminator:
        self.__state = StringParser.DEFAULT
        return ' '
      elif c == '\\':
        self.__state = StringParser.ESCAPE
        self.__contents.append(c)
      else:
        self.__contents.append(c)
    elif self.__state == StringParser.ESCAPE:
      self.__state = StringParser.STRING
      self.__contents.append(c)
    else:
      assert False
    return ''

  def inString(self):
    return self.__state != StringParser.DEFAULT
  
  def string(self):
    return ''.join(self.__contents)

class CommentParser:
  DEFAULT = 0
  SLASH = 1
  LINECOMMENT = 2
  MULTILINECOMMENT = 3
  MULTILINECOMMENTSTAR = 4

  def __init__(self):
    self.__state = CommentParser.DEFAULT

  def processChar(self, c):
    if self.__state == CommentParser.DEFAULT:
      if c == '/':
        self.__state = CommentParser.SLASH
      else:
        return c
    elif self.__state == CommentParser.SLASH:
      if c == '/':
        self.__state = CommentParser.LINECOMMENT
      elif c == '*':
        self.__state = CommentParser.MULTILINECOMMENT
      else:
        return ['/', c]
    elif self.__state == CommentParser.LINECOMMENT:
      if c == '\n':
        self.__state = CommentParser.DEFAULT
        return c
    elif self.__state == CommentParser.MULTILINECOMMENT:
      if c == '*':
        self.__state = CommentParser.MULTILINECOMMENTSTAR
    elif self.__state == CommentParser.MULTILINECOMMENTSTAR:
      if c == '*':
        pass
      elif c == '/':
        self.__state = CommentParser.DEFAULT
        return ' '
      else:
        self.__state = CommentParser.MULTILINECOMMENT
    else:
      assert False
    return ''

class ModuleParser:
  DEFAULT = 0
  MODULEPREFIX = 1
  MODULEPREFIXSPACE = 2
  MODULEPREFIXNAME = 3
  MODULE = 4
  MODULESUFFIX = 5
  INWORD = 6
  MODULEINWORD = 7
  
  PREFIX = 'module'
  SUFFIX = 'endmodule'
  
  def __init__(self):
    self.__state = ModuleParser.DEFAULT
    self.__processed = []

  def processChar(self, c):
    if self.__state == ModuleParser.DEFAULT:
      if c == ModuleParser.PREFIX[0]:
        self.__processed = [c]
        self.__state = ModuleParser.MODULEPREFIX
      elif isIdentifierChar(c):
        self.__state = ModuleParser.INWORD
        return c
      else:
        return c
    elif self.__state == ModuleParser.MODULEPREFIX:
      if len(self.__processed) == len(ModuleParser.PREFIX):
        if c.isspace():
          self.__state = ModuleParser.MODULEPREFIXSPACE
        else:
          self.__processed.append(c)
          if isIdentifierChar(c):
            self.__state = ModuleParser.INWORD
          else:
            self.__state = ModuleParser.DEFAULT
          return self.__processed
      else:
        assert len(self.__processed) < len(ModuleParser.PREFIX)
        if c == ModuleParser.PREFIX[len(self.__processed)]:
          self.__processed.append(c)
        else:
          self.__processed.append(c)
          if isIdentifierChar(c):
            self.__state = ModuleParser.INWORD
          else:
            self.__state = ModuleParser.DEFAULT
          return self.__processed
    elif self.__state == ModuleParser.MODULEPREFIXSPACE:
      if c.isspace():
        pass
      elif isIdentifierChar(c):
        self.__state = ModuleParser.MODULEPREFIXNAME
      else:
        assert False, [c]
    elif self.__state == ModuleParser.MODULEPREFIXNAME:
      if isIdentifierChar(c):
        pass
      else:
        self.__state = ModuleParser.MODULE
    elif self.__state == ModuleParser.MODULE:
      if c == ModuleParser.SUFFIX[0]:
        self.__processed = [c]
        self.__state = ModuleParser.MODULESUFFIX
      elif isIdentifierChar(c):
        self.__state = ModuleParser.MODULEINWORD
    elif self.__state == ModuleParser.MODULESUFFIX:
      if len(self.__processed) == len(ModuleParser.SUFFIX):
        if c.isspace() or c == '[':
          self.__state = ModuleParser.DEFAULT
          return c
        else:
          if isIdentifierChar(c):
            self.__state = ModuleParser.MODULEINWORD
          else:
            self.__state = ModuleParser.MODULE
      else:
        assert len(self.__processed) < len(ModuleParser.SUFFIX)
        if c == ModuleParser.SUFFIX[len(self.__processed)]:
          self.__processed.append(c)
        else:
          if isIdentifierChar(c):
            self.__state = ModuleParser.MODULEINWORD
          else:
            self.__state = ModuleParser.MODULE
    elif self.__state == ModuleParser.INWORD:
      if not isIdentifierChar(c):
        self.__state = ModuleParser.DEFAULT
      return c
    elif self.__state == ModuleParser.MODULEINWORD:
      if not isIdentifierChar(c):
        self.__state = ModuleParser.MODULE
    else:
      assert False
    return ''

class AttributeParser:
  DEFAULT = 0
  ATTRIBUTE = 1
  def __init__(self):
    self.__state = AttributeParser.DEFAULT

  def processChar(self, c):
    if self.__state == AttributeParser.DEFAULT:
      if c == '[':
        self.__state = AttributeParser.ATTRIBUTE
      else:
        return c
    elif self.__state == AttributeParser.ATTRIBUTE:
      if c == ']':
        self.__state = AttributeParser.DEFAULT
        return ' '
    else:
      assert False
    return ''

class RequireParser:
  DEFAULT = 0
  INWORD = 1
  INPREFIX = 2
  PREFIXSPACE = 3
  INSTRING = 4

  PREFIX = 'require'

  def __init__(self, dependencies):
    self.__state = RequireParser.DEFAULT
    self.__processed = []
    self.__string_parser = StringParser()
    self.__dependencies = dependencies

  def processChar(self, c):
    if self.__state == RequireParser.DEFAULT:
      if c == RequireParser.PREFIX[0]:
        self.__processed = [c]
        self.__state = RequireParser.INPREFIX
      elif isIdentifierChar(c):
        self.__state = RequireParser.INWORD
    elif self.__state == RequireParser.INWORD:
      if not isIdentifierChar(c):
        self.__state = RequireParser.DEFAULT
    elif self.__state == RequireParser.INPREFIX:
      if len(self.__processed) == len(RequireParser.PREFIX):
        if c.isspace():
          self.__state = RequireParser.PREFIXSPACE
        else:
          self.__string_parser.processCharImmediate(c)
          if self.__string_parser.inString():
            self.__state = RequireParser.INSTRING
          elif isIdentifierChar(c):
            self.__state = RequireParser.INWORD
          else:
            assert False
      else:
        assert len(self.__processed) < len(RequireParser.PREFIX)
        if c == RequireParser.PREFIX[len(self.__processed)]:
          self.__processed.append(c)
        elif isIdentifierChar(c):
          self.__state = RequireParser.INWORD
        else:
          self.state = RequireParser.DEFAULT
    elif self.__state == RequireParser.PREFIXSPACE:
      if not c.isspace():
        self.__string_parser.processCharImmediate(c)
        if self.__string_parser.inString():
          self.__state = RequireParser.INSTRING
        else:
          assert False, [c]
    elif self.__state == RequireParser.INSTRING:
      self.__string_parser.processCharImmediate(c)
      if not self.__string_parser.inString():
        self.__dependencies.append(self.__string_parser.string())
        self.__state = RequireParser.DEFAULT
    else:
      assert False
    return ''

  def inRequire(self):
    return not self.__state in [RequireParser.DEFAULT, RequireParser.INWORD]

  def inString(self):
    return self.__state == RequireParser.INSTRING

  def afterKeyword(self):
    return (
      self.__state in [RequireParser.PREFIXSPACE, RequireParser.INSTRING]
      or (
        self.__state == RequireParser.INPREFIX
        and len(self.__processed) == len(RequireParser.PREFIX))
    )

def conditionalProcessAndIterate(c, skip_condition, parser, next):
  if skip_condition():
    if next:
      next(c)
  else:
    for d in parser.processChar(c):
      if next:
        next(d)

def extractRequire(chars):
  extracted = []
  string_parser = StringParser()
  comment_parser = CommentParser()
  module_parser = ModuleParser()
  attribute_parser = AttributeParser()
  require_parser = RequireParser(extracted)
  for c in chars:
    conditionalProcessAndIterate(c, lambda: string_parser.inString() or require_parser.inString(), comment_parser,
      lambda d: conditionalProcessAndIterate(d, require_parser.afterKeyword, string_parser,
        lambda e: conditionalProcessAndIterate(e, require_parser.inString, attribute_parser,
          lambda f: conditionalProcessAndIterate(f, require_parser.inRequire, module_parser,
            lambda g: conditionalProcessAndIterate(g, lambda: False, require_parser, None)
          )
        )
      )
    )
  return extracted

def printRequire(rule_name, identifying_prefix, prefix_to_add, required):
  required = [r for r in required if r.startswith(identifying_prefix)]
  if required:
    print('%s : \\' % rule_name)
    for r in required[:-1]:
      print('\t%s%s \\' % (prefix_to_add, r))
    print('\t%s%s' % (prefix_to_add, required[-1]))


def assertEquals(expected, actual):
  assert expected == actual, "Expected '%s' but got '%s'." % (expected, actual)

def runTests():
  assertEquals([], extractRequire(''))
  assertEquals(['f.k'], extractRequire('require "f.k"'))
  assertEquals(['f.k'], extractRequire('require/**/"f.k"'))
  assertEquals(['f.k'], extractRequire('require/*/*/"f.k"'))
  assertEquals(['f.k'], extractRequire('require/***/"f.k"'))
  assertEquals([], extractRequire('// require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m require "g.k" endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m /*endmodule*/ require "g.k" endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m // endmodule\n require "g.k" endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m require "g.k/*" endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m endmodules require "g.k" endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m endmodulesendmodule require "g.k" endmodule require "f.k"'))
  assertEquals(['f.k'], extractRequire('module m endmodule[require "g.k"]require "f.k"'))

USAGE = '''Wrong number of arguments, expected:
* an input file
* a Makefile rule name
* a prefix that identifies dependencies
* a prefix to be added to all dependencies.
'''

def main(argv):
  runTests()
  if len(argv) != 4:
    raise Exception(USAGE)
  with open(argv[0], 'r') as f:
    printRequire(argv[1], argv[2], argv[3], extractRequire(f.read()))

if __name__ == '__main__':
  main(sys.argv[1:])