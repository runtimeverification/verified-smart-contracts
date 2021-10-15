#!/usr/bin/env python3
import sys

def naturalNumbers():
  i = 1
  while True:
    yield i
    i += 1

DEFAULT = 0
PROOF = 1
TRUSTED = 2

def makeTrusted(file_name, lines):
  state = DEFAULT
  for (line_number, line) in lines:
    normalized = line.strip()
    if normalized.startswith('//@'):
      if state == DEFAULT:
        if normalized == '//@ proof':
          state = PROOF
        else:
          raise Exception(
            "Unexpected trusted directive, only '//@ proof' allowed here.\n%s:%d"
            % (file_name, line_number))
      elif state == PROOF:
        if normalized == '//@ trusted':
          state = TRUSTED
        else:
          raise Exception(
            "Unexpected trusted directive, only '//@ trusted' allowed here.\n%s:%d"
            % (file_name, line_number))
      elif state == TRUSTED:
        if normalized == '//@ end':
          state = DEFAULT
        else:
          raise Exception(
            "Unexpected trusted directive, only '//@ end' allowed here.\n%s:%d"
            % (file_name, line_number))
    else:
      if state == DEFAULT:
        pass
      else:
        unindented = line.lstrip()
        indentation = ' ' * (len(line) - len(unindented))
        if state == PROOF:
          line = indentation + '// ' + unindented
        elif state == TRUSTED:
          if unindented.startswith('// '):
            line = indentation + unindented[3:]
          else:
            raise Exception(
              "Expected trusted lines to be commented.\n%s:%d"
              % (file_name, line_number))
    yield line

def main(argv):
  if len(argv) != 2:
    raise Exception('Wrong number of arguments, expected an input and an output file name.')
  with open(argv[0], 'r') as f:
    with open(argv[1], 'w') as g:
      g.writelines(makeTrusted(argv[0], zip(naturalNumbers(), f)))

if __name__ == '__main__':
  main(sys.argv[1:])
