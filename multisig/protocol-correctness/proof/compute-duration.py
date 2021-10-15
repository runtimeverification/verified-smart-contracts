#!/usr/bin/env python3
import sys

def main(argv):
  with open(argv[0], 'rt') as f:
    contents = f.read()
  lines = contents.strip('\r\n').split('\n')
  assert len(lines) == 2, lines
  start = float(lines[0])
  end = float(lines[1])
  seconds = end - start
  minutes = seconds / 60
  hours = minutes / 60
  minutes = minutes % 60
  seconds = seconds % 60
  if hours > 0:
    message = '%dh %dm %ds' % (hours, minutes, seconds)
  elif minutes > 0:
    message = '%dm %ds' % (minutes, seconds)
  else:
    message = '%ds' % seconds
  print(message)


if __name__ == '__main__':
  main(sys.argv[1:])