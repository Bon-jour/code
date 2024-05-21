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
indir = 'bracken_out'
outdir = 'S.out'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Run_tobiom(indir,outdir):
    biomdir = './' + outdir
    if os.path.exists(biomdir):
        pass
    else:
        os.mkdir(biomdir)

    cmd = f"kraken-biom {indir}/*.report \
    --max S -o {biomdir}/S.biom "
    execCmd(cmd)
    time.sleep(10)
    cmd2 = f" biom convert -i {biomdir}/S.biom \
    -o {biomdir}/S.count.tsv.tmp --to-tsv --header-key taxonomy"
    execCmd(cmd2)
        
Run_tobiom(indir,outdir)