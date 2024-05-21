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

def Run_seqkit(indir):
    cmd = f'/root/miniconda3/envs/metadoc/bin/seqkit translate {indir}/all.fa \
    --trim >{indir}/all.protein.fa'
    execCmd(cmd)
Run_seqkit(indir) 
        
Run_seqkit(indir)