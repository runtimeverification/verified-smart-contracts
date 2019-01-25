import csv
import subprocess as sp
import multiprocessing as mp
from concurrent.futures import ThreadPoolExecutor
from threading import Lock
import gen_spec
import os
import datetime


fallback_safe_spec_tmpls = ["fallback-payable", "fallback-fail"]
fallback_unsafe_spec_tmpls = ["fallback-call", "fallback-delegatecall"]

kprove = ".build/k/k-distribution/target/release/k/bin/kprove"
kprove_opts = [
        "-v",
        "-d", ".build/evm-semantics/.build/java",
        "-m", "VERIFICATION",
        "--z3-impl-timeout", "500",
        "--smt-prelude", "evm.smt2",
        "--deterministic-functions",
        "--cache-func-optimized"
        ]
kprove_env = {
        "K_OPTS": "-Xmx8G"
        }

THIS_PATH = os.path.abspath(__file__)


# TODO: spec_tmpl, address
def run_spec(item, addr):
    # item: fallback-payable, addr: "0x..."
    name = item + '-' + addr
    print('[run_spec]', name)
    spec = "../specs/mass/" + name + "-spec.k"
    try:
        ret = sp.run(
                [kprove] + kprove_opts + [spec],
                env=kprove_env, timeout=210,
                stdout=sp.PIPE, stderr=sp.PIPE)
        print('[run_spec]', name, 'returned', ret.returncode)
        return (name, True if ret.returncode == 0 else False, ret)
        #  print(ret.stderr.decode('utf-8'))
    except sp.TimeoutExpired as e:
        #  return (name, False, e.stdout.decode('utf-8'), e.stderr.decode('utf-8'))
        print('[run_spec]', name, 'timed out')
        return (name, False, e)

def collect_contracts():
    pass

def gen_specs(contracts, item):
    # item: e.g. 'fallback-payable'
    spec_tmpl = open('../specs/mass/' + item + '-spec.k').read()
    for addr, code in contracts.items():
        spec_name = item + '-' + addr
        spec = gen_spec.subst(spec_tmpl, 'code', code)
        spec = gen_spec.subst(spec, 'contract_address_str', addr.upper())
        spec = gen_spec.subst(spec, 'contract_address', str(int(addr,16)))
        with open('../specs/mass/' + spec_name + '-spec.k', 'w') as spec_file:
            spec_file.write(spec)

ok_results = {} # item -> [addr]
next_batch = {}
error_log = {}
result_lock = Lock()

def check_result(f):
    global ok_results, next_batch
    name, ok, e = f.result()
    item = "-".join(name.split("-")[:-1])
    addr = name.split("-")[-1]
    # check if succeeded
    # check why it failed
    # kprove crash -> rerun
    # timeout: probably #False spec -> run next spec
    result_lock.acquire()
    print('[check_result]', name)
    if ok:
        print('ok')
        ok_results[item].append(addr)
    else:
        msg = e.stderr.decode('utf-8')
        print('...')
        print('\n'.join(filter(lambda s: "Error" in s, msg.split('\n'))))
        print('...')
        next_batch[item].append(addr)
        error_log[name] = msg
    print('-------------------------------------------------')
    result_lock.release()

class SpecItem(object):
    def __init__(self, name="", next=[]):
        self.name = name
        self.next = next

if __name__ == '__main__':
    contracts = {}
    with open('../mass/contracts.csv') as f:
       reader = csv.DictReader(f)
       for row in reader:
           contracts[row['address']] = row['bytecode']

    # spec_tree = SpecItem("fallback-payable", [
    #     SpecItem("fallback-fail")
    #     ])

    # gen_specs(contracts, "fallback-payable")
    gen_specs(contracts, "fallback-fail")

    ok_results['fallback-fail'] = []
    next_batch['fallback-fail'] = []

    with ThreadPoolExecutor(7) as pool:
        for c in contracts.keys():
            # future = pool.submit(run_spec, "fallback-payable", c)
            future = pool.submit(run_spec, "fallback-fail", c)
            future.add_done_callback(check_result)

    cur_time = datetime.datetime.now().isoformat()
    with open('../mass/non_payable-' + cur_time, 'w') as f:
        f.write("\n".join(ok_results['fallback-fail']))
    with open('../mass/next_batch-' + cur_time, 'w') as f:
        f.write("\n".join(next_batch['fallback-fail']))
    with open('../mass/error_log-' + cur_time, 'w') as f:
        for n, l in error_log.items():
            f.write(name + ':\n')
            f.write(l)
            f.write('----------------------------')

