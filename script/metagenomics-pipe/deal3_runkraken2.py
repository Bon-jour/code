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
indir = 'kneaddout'
outdir = 'kraken2out'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Run_Kraken2(indir,outdir,sampleinfo):
    cmds = []
    sample_info_dic = {}
    KrakenDir = './' + outdir
    if os.path.exists(KrakenDir):
        pass
    else:
        os.mkdir(KrakenDir)
    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd = f"kraken2 --db {KrakenDB}  --threads 5 \
            --report kraken2out/{line[0]}.report --output kraken2out/{line[0]}.output \
            --paired ./{indir}/{line[0]}/{line[0]}_1_kneaddata_paired.1.fastq ./{indir}/{line[0]}/{line[0]}_1_kneaddata_paired.2.fastq"
            cmds.append(cmd)
    threads = []
    for cmd in cmds:
        print(cmd)
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)
        
Run_Kraken2(indir,outdir,sampleinfo)