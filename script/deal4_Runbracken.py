import argparse
import os
from pickle import FALSE
import threading
import shutil
import datetime
import json
import time
import subprocess
dbdir='/data/db'
KrakenDB ='/data/db/minikraken_8GB_20200312'
indir = 'kraken2out'
outdir = 'bracken_out'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Run_bracken(indir,outdir,sampleinfo):
    cmds = []
    sample_info_dic = {}
    BrackenDir = './' + outdir
    if os.path.exists(BrackenDir):
        pass
    else:
        os.mkdir(BrackenDir)
    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd  = f" bracken -d {KrakenDB} \
            -i {indir}/{line[0]}.report \
            -o {BrackenDir}/{line[0]}.S.bracken \
            -w {BrackenDir}/{line[0]}.S.bracken.report \
            -r 150 -l S"
            cmds.append(cmd)
    threads = []
    for cmd in cmds:
        print(cmd)
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)
        
Run_bracken(indir,outdir,sampleinfo)