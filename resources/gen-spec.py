#!/usr/bin/env python3

import sys
import re
import configparser

def app(specs, spec):
    if not specs:
       return spec
    else:
       delimiter = "\n\n"
       return delimiter.join((specs, spec))

# TODO: for Python 3.5 or higher: z = {**x, **y}
def merge_two_dicts(x, y):
    z = dict(x)
    z.update(y)
    return z

def subst(text, key, val):
    return text.replace('{' + key.upper() + '}', val)

def safe_get(config, section):
    if section in config:
        return config[section]
    else:
        return {}

def inherit_get(config, section):
    if not section:
        return safe_get(config, 'root')
    else:
        parent = inherit_get(config, '-'.join(section.split('-')[:-1]))
        current = safe_get(config, section)
        merged = merge_two_dicts(parent, current) # TODO: for Python 3.5 or higher: {**parent, **current}
        for key in list(merged.keys()):
            if key.startswith('+'):
                merged[key[1:]] += merged[key]
                del merged[key]
        return merged

def gen(spec_template, rule_template, spec_ini, spec_name, rule_name_list):
    spec_config = configparser.ConfigParser(comment_prefixes=(';'))
    spec_config.read(spec_ini)
    if 'pgm' not in spec_config:
        print('''Must specify a "pgm" section in the .ini file.''')
        sys.exit(1)
    pgm_config = spec_config['pgm']
    rule_spec_list = []
    for name in rule_name_list:
        rule_spec = rule_template
        for config in [ inherit_get(spec_config, name)
                      , pgm_config
                      ]:
            rule_spec = subst_all(rule_spec, config)
#           for key in config:
#               rule_spec = subst(rule_spec, key, config[key].strip())
        rule_spec = subst(rule_spec, "rulename", name)
        rule_spec_list.append(rule_spec)
    delimeter = "\n"
    rules = delimeter.join(rule_spec_list)
    genspec = subst(spec_template, 'module', spec_name.upper())
    genspec = subst(genspec, 'rules', rules)
    print(genspec)
#   genspec = template
#   for config in [ inherit_get(spec_config, name)
#                 , {'module': name.upper()}
#                 , pgm_config['DEFAULT']
#                 ]:
#       for key in config:
#           genspec = subst(genspec, key, config[key].strip())
#   print(genspec)

def subst_all(init_rule_spec, config):
    rule_spec = init_rule_spec
    for key in config:
        rule_spec = subst(rule_spec, key, config[key].strip())
    if rule_spec != init_rule_spec:
        return subst_all(rule_spec, config)
    else:
        return rule_spec

if __name__ == '__main__':
    if len(sys.argv) < 6:
        print("usage: <cmd> <spec-template> <rule-template> <spec_ini> <spec_name> <rule_name_list>")
        sys.exit(1)
    spec_template = open(sys.argv[1], "r").read()
    rule_template = open(sys.argv[2], "r").read()
    gen(spec_template, rule_template, sys.argv[3], sys.argv[4], sys.argv[5:])
