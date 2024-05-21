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
outdir = 'Salmon_out'
sampleinfo = './sample.txt'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Run_Salmon(indir,outdir,sample_info_dic):
    cmds = []
    sample_info_dic = {}
    if os.path.exists(outdir):
        pass
    else:
        os.mkdir(outdir)
    cmd1 = f"cat  {indir}/*.out.fa >> {indir}/all.fa"
    execCmd(cmd1)
    time.sleep(10)
    cmd2 = f" /root/miniconda3/envs/metadoc/bin/salmon index -t {indir}/all.fa -i {indir}/meta_index2 -k 31 -p 25"
    execCmd(cmd2)
    time.sleep(10)

    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd = f"/root/miniconda3/envs/metadoc/bin/salmon quant --libType IU \
            -i {indir}/meta_index2 \
            -1 ./kneaddout/{line[0]}/{line[0]}_1_kneaddata_paired_1.fastq \
            -2 ./kneaddout/{line[0]}/{line[0]}_1_kneaddata_paired_2.fastq \
            -o {outdir}/{line[0]} -p 20"
            cmds.append(cmd)
    threads = []
    for cmd in cmds:
        print(cmd)
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)
        
Run_Salmon(indir,outdir,sampleinfo)