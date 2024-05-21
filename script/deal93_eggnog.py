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
indir = 'protein';outdir = 'eggnog'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def eggnog(indir,outdir):
    if os.path.exists(outdir):
        pass
    else:
        os.mkdir(outdir)  
    cmd = f"/root/miniconda3/envs/py2doc/bin/emapper.py  \
    --override --data_dir /data/db/eggnog5 \
    -i {indir}/all.protein.fa \
    --cpu 36 -m diamond \
    -o {outdir}/"
    execCmd(cmd)

eggnog(indir,outdir)  