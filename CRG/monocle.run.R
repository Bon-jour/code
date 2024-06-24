options(bitmapType='cairo')
library("optparse")
library('Seurat')
option_list <- list(
        make_option(c("-r", "--rds"), help="rds 瀵硅薄"),
        make_option(c("-i", "--idents"), help=" the colnames in sce@meta.data "),
        make_option(c("-n", "--nselect"), help=" select some cells for analysis"),
        make_option(c("-m", "--method"), help="eg:findallmarkers,VariableFeatures,dispersionTable"),
        make_option(c("-p", "--pcount"), help="downsample = count",default = 100000),
        make_option(c("-d", "--droot"),help='after got first result, droot can revise root according previous results ')
    
)
opt_parser=OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)
project_dir = './'
source('/import/code/CRG/monocle.func.R')


rootdir=paste0(project_dir,'06_trajectory_analysis',sep="")
    if(!file.exists(rootdir)){
    dir.create(rootdir)
    }
    aa = readRDS(opt$rds)
    if(is.null(opt$nselect)){
    seurat_obj = aa
    print('no deal')
    }else{
    Idents(aa) = opt$idents
    cluster <- unlist(strsplit(opt$nselect,split=","))
    seurat_obj <-subset(aa,idents =  cluster)
    }
    #seurat_obj = aa
    print('celltype---------------------------------------')
    table(seurat_obj$celltype)
    bb = subset(seurat_obj,downsample = opt$p)
    print("downsample was done !")
    run_monocle(bb,method = opt$m,idents = opt$i,root = opt$d)

