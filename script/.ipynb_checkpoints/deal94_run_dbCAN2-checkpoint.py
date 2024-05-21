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
outdir = 'dbCAN2out'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def run_dbCAN2(indir,outdir):
    cmds = []
    sample_info_dic = {}
    if os.path.exists(outdir):
        pass
    else:
        os.mkdir(outdir)
    cmd = f"/root/miniconda3/envs/py2doc/bin/diamond blastp   \
    --db /data/db/dbCAN2/CAZyDB.07312020  \
    --query {indir}/all.protein.fa   \
    --threads 5 -e 1e-5 --outfmt 6 \
    --max-target-seqs 1 --quiet \
    --out dbCAN2out/all.dbcan2.txt"
    execCmd(cmd)
            
run_dbCAN2(indir,outdir)