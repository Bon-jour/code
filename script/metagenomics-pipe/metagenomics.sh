ARGS=`getopt -a -o :s:m:d:h --long species:,metadata:,datadir: -- "$@"`
if [ $? != 0 ];then   # 判断上一条命令执行情况，正常返回0，异常则返回非零
        echo ""
        exit 1
fi

eval set -- "${ARGS}"
while :
do
    case $1 in
        -s|--species)    
            species=$2
            shift
            ;;
        -m|--metadata)  
            metadata=$2
            shift
            ;;
        -d|--datadir)   
            datadir=$2
            shift
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
shift
done

echo "$species"
echo "$metadata"
echo "$datadir"
cp /data/script/deal1_runkneaddata.py ./ && python deal1_runkneaddata.py --species "$species" --metadata "$metadata" --datadir "$datadir"
wait
cp /data/script/deal2_runstats.py ./ && python deal2_runstats.py
wait
cp /data/script/deal3_runkraken2.py ./ && python deal3_runkraken2.py 
wait
cp /data/script/deal4_Runbracken.py ./ && python deal4_Runbracken.py 
wait
cp /data/script/deal5_Run_tobiom.py ./ && python deal5_Run_tobiom.py 
wait
cp /data/script/deal6_Runspades.py ./ && python deal6_Runspades.py 
wait
cp /data/script/deal7_Run_prodigal.py ./ && python deal7_Run_prodigal.py 
wait
cp /data/script/deal8_Rename.py ./ && python deal8_Rename.py 
wait
cp /data/script/deal9_Run_cdhit.py ./ && python deal9_Run_cdhit.py 
wait
cp /data/script/deal92_Run_Salmon.py ./ && python deal92_Run_Salmon.py 
wait
cp /data/script/deal92.2_Run_Salmon.py ./ && python deal92.2_Run_Salmon.py 
wait
cp /data/script/deal91_Run_seqkit.py ./ && python deal91_Run_seqkit.py 
wait
cp /data/script/deal93_eggnog.py ./ && python deal93_eggnog.py 
wait
cp /data/script/deal94_run_dbCAN2.py ./ && python deal94_run_dbCAN2.py 
wait
cp /data/script/deal95_run_CARD.py ./ && python deal95_run_CARD.py 
wait
cp /data/script/deal96_run_VFDB.py ./ && python deal96_run_VFDB.py 
wait
mkdir log && mv ./*.py log