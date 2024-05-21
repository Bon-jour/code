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
outdir = 'kneaddout'

def execCmd(cmd):
    try:
        print("命令{}开始运行{}".format(cmd, datetime.datetime.now()))
        time.sleep(5)
        os.system(cmd)
        print("命令{}结束运行{}" .format(cmd, datetime.datetime.now()))
    except:
        print("{}\t运行失败".format(cmd))

def run_kneaddata(species,sampleinfo,datadir):
    kneaddata_database = dbdir + '/kneaddb/'
    if species == 'human':
        kneaddb = kneaddata_database + '/human_hg19/hg19'
    elif species == 'mouse':
        kneaddb = kneaddata_database + '/mouse_C57BL/mouse_C57BL_6NJ'
    else:
        pass
    sample_info_dic = {}
    cmds = []
    for line in open(sampleinfo):
        if not line.startswith("sample"):
            line=line.strip().split()
            sample_info_dic[line[0]]=line[1]
            cmd= f'''/root/miniconda3/envs/Rdoc/bin/kneaddata -t 4 -v \
                -i1 {datadir}/{line[0]}_R1.fastq.gz \
                -i2 {datadir}/{line[0]}_R2.fastq.gz \
                -o  {outdir}/{line[0]} -db {kneaddb} \
                --trimmomatic /data/soft/Trimmomatic-0.39/ \
                --trimmomatic-options 'SLIDINGWINDOW:4:20 MINLEN:50' \
                --bowtie2 /root/miniconda3/envs/Rdoc/bin/ \
                --bowtie2-options '--very-sensitive --dovetail' \
                --remove-intermediate-output \
                --fastqc /root/miniconda3/envs/Rdoc/bin/ \
                --trf /root/miniconda3/envs/Rdoc/bin/ \
                --run-fastqc-start \
                --run-fastqc-end '''
        cmds.append(cmd)
        threads = []
    for cmd in cmds:
        th = threading.Thread(target=execCmd, args=(cmd,))
        th.start()
        time.sleep(5)
        threads.append(th)

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--species',required=True,type=str,
                            default='mouse',
                            help='choose species,related to genome and database to use ')

    parser.add_argument('--metadata', type=str,default="sample.txt",required=True,
                        help='metadata')
    parser.add_argument('--datadir', required=True,default='rawdata',type=str,
                        help='raw data dir')

    args = parser.parse_args()
    run_kneaddata(args.species,args.metadata,args.datadir)
    
if __name__ == '__main__':
    main()
