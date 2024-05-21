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
indir = 'Salmon_out'
outdir = 'Salmon_merge'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def merge(outdir):
    cmd = f"/root/miniconda3/envs/metadoc/bin/salmon quantmerge \
    --quants ./Salmon_out/* \
    -o {outdir}/gene.TPM && \
    /root/miniconda3/envs/metadoc/bin/salmon quantmerge \
    --quants ./Salmon_out/* \
    --column NumReads -o {outdir}/gene.count"
    execCmd(cmd)
        
merge(outdir)