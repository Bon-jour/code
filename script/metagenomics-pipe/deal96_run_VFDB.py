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
outdir = 'VFDBout'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))


def run_VFDB(indir,outdir):
    cmds = []
    sample_info_dic = {}
    if os.path.exists(outdir):
        pass
    else:
        os.mkdir(outdir)
    
    cmd = f"/root/miniconda3/envs/Rdoc/bin/diamond  blastp   \
    --db /data/db/VFDB/setA.dmnd \
    --query {indir}/all.protein.fa   \
    --out {outdir}/all.vf.txt"
    execCmd(cmd)
            
run_VFDB(indir,outdir)
