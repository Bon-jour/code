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
outdir = 'kneaddout'
def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(10)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def Run_Stats(outdir):
    StatsDir = outdir + '/readsinfo'
    if os.path.exists(StatsDir):
        pass
    else:
        os.mkdir(StatsDir)
    x= [item for item in os.walk('./'+outdir)]
    for path, dirs, files in x:
        for file in files:
            if file.endswith('.log'):
                shutil.copy(path+os.sep+file,StatsDir)
    cmd = f"cd {outdir} && kneaddata_read_count_table --input  readsinfo/ --output kneaddata_read_count_table.tsv && \
    cut -f 1-5,12-13 kneaddata_read_count_table.tsv | sed 's/_1_kneaddata//;s/pair//g' > kneaddata_report.txt "
    execCmd(cmd)
# Run_Stats(outdir)


indir = 'cleandata'
sampleinfo = 'sample.txt'
def run_Bowtie2(indir,outdir,sampleinfo):
    cmds = []
    sample_info_dic = {}
    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd = f"mkdir -p {outdir}/{line[0]} && /root/miniconda3/envs/Rdoc/bin/bowtie2 -p 3 -x /data/db/kneaddb/mouse_C57BL/mouse_C57BL_6NJ \
            -1 {indir}/{line[0]}_clean_R1.fq.gz -2 {indir}/{line[0]}_clean_R2.fq.gz \
            -S {outdir}/{line[0]}/{line[0]}.sam \
            --un-conc {outdir}/{line[0]}/{line[0]}_1_kneaddata_paired.fastq --very-sensitive"
            cmds.append(cmd)
    threads = []
    for cmd in cmds:
        print(cmd)
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)
run_Bowtie2(indir,outdir,sampleinfo)   









