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
indir = 'prodigalout';outdir = 'protein'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Rename(indir,outdir,sample_info_dic):
    cmds = []
    sample_info_dic = {}
    if os.path.exists(outdir):
        pass
    else:
        os.mkdir(outdir)
    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd = f"cd {indir} && perl  /data/script/rename.pl {line[0]}.dna.fa && \
             perl  /data/script/rename.pl {line[0]}.protein.fa  && \
            cp {line[0]}.dna_rename.fa ../protein"
            cmds.append(cmd)
    threads = []
    for cmd in cmds:
        print(cmd)
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)
        
Rename(indir,outdir,sampleinfo)