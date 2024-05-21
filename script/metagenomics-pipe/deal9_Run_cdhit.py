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
indir = 'protein'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Run_cdhit(indir,sample_info_dic):
    cmds = []
    sample_info_dic = {}
    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd = f'/root/miniconda3/envs/metadoc/bin/cd-hit-est -i  {indir}/{line[0]}.dna_rename.fa \
            -o {indir}/{line[0]}.out.fa -c 0.95 -G 0 -aS 0.9 -g 0 -M 0 -T 15 '
            cmds.append(cmd)
    threads = []
    for cmd in cmds:
        print(cmd)
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)
        
Run_cdhit(indir,sampleinfo)