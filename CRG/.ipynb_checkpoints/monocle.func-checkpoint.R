run_monocle <- function(obj = bb,method = method,idents = idents,root = NULL){
	print('monocle 2')
	library('Seurat')
	library(monocle)
    library(dplyr)
    library(RColorBrewer)
	Idents(bb) = idents
	DefaultAssay(bb) ='RNA'
	data <- as(as.matrix(bb@assays$RNA@counts), 'sparseMatrix')
	pd <- new('AnnotatedDataFrame', data = bb@meta.data)
	fData <- data.frame(gene_short_name = row.names(data), row.names = row.names(data))
	fd <- new('AnnotatedDataFrame', data = fData)
	#Construct monocle cds
	monocds <- newCellDataSet(data,
								  phenoData = pd,
								  featureData = fd,
								  lowerDetectionLimit = 0.5,
								  expressionFamily = negbinomial.size())

	print("format data done , filter select genes ")
	#pData(monocds)$Cluster<-as.factor(pData(monocds)$celltype) 
	pData(monocds)['Cluster']=bb@active.ident	
	monocds <- estimateSizeFactors(monocds)
	monocds <- estimateDispersions(monocds)
	monocds <- detectGenes(monocds, min_expr = 0.1)
	print(head(fData(monocds)))
	expressed_genes <- row.names(subset(fData(monocds), num_cells_expressed >= 10)) # nolint
	monocds <- monocds[expressed_genes, ]
	
	if(method == 'method1'){
	Idents(bb) = idents
	deg.cluster <- FindAllMarkers(bb)
	deg.cluster1= deg.cluster %>%
		group_by(cluster) %>%
		top_n(n = 50, wt = avg_log2FC)	
	express_genes <- subset(deg.cluster1,p_val_adj<0.05)$gene
	dir=paste0(rootdir,'/','FAM_outpt')
	}else if(method == 'method2'){
		express_genes <- VariableFeatures(bb)
		dir=paste0(rootdir,'/','HVG_output')
	}else if(method == 'method3'){
		disp_table <- dispersionTable(monocds)
		express_genes <- subset(disp_table, mean_expression >= 0.1 & dispersion_empirical >= 1 * dispersion_fit)$gene_id
		dir=paste0(rootdir,'/','monocle_output')
	}else if(method == 'method4'){
		diff <- differentialGeneTest(monocds[expressed_genes,],fullModelFormulaStr="~Cluster",cores=1)
		deg <- subset(diff, qval < 0.01) 
		deg <- deg[order(deg$qval,decreasing=F),]
		express_genes <- rownames(deg) 
		dir=paste0(rootdir,'/','dpFeature_output')
	}
	
	trajectory_cluster_dir=paste('./',dir,sep="")
	if(!file.exists(trajectory_cluster_dir)){
	   dir.create(trajectory_cluster_dir)
	}

	monocds <- setOrderingFilter(monocds, express_genes)
	monocds <- reduceDimension(
		monocds,
		max_components = 2,
		method = "DDRTree"
	)
    
    ### 调整root 
    if(is.null(root)){
	monocds <- orderCells(monocds)
        }else{
        monocds <- orderCells(monocds)
        monocds <- orderCells(monocds,root = root)
    }
	saveRDS(monocds,file=paste(trajectory_cluster_dir,"monocle.rds",sep="/"))
    A = monocds@featureData@data %>% filter(use_for_ordering == 'TRUE')
    write.csv(A,file = paste0(trajectory_cluster_dir,'/','genes_for_order.csv'))
    
    ## plot 
    colour=c("#DC143C","#0000FF","#20B2AA","#FFA500","#9370DB","#98FB98","#F08080","#1E90FF","#7CFC00","#FFFF00",  
            "#808000","#FF00FF","#FA8072","#7B68EE","#9400D3","#800080","#A0522D","#D2B48C","#D2691E","#87CEEB","#40E0D0","#5F9EA0",
            "#FF1493","#0000CD","#008B8B","#FFE4B5","#8A2BE2","#228B22","#E9967A","#4682B4","#32CD32","#F0E68C","#FFFFE0","#EE82EE",
            "#FF6347","#6A5ACD","#9932CC","#8B008B","#8B4513","#DEB887")
    
    print('plot ！！！！')
    

	if(idents =='seurat_clusters'){
        if('celltype' %in% colnames(bb@meta.data) | 'cluster_anno' %in% colnames(bb@meta.data)){
            p01<-plot_cell_trajectory(monocds, color_by = "celltype")+ scale_color_manual(values = colour)
            ggsave(p01,file=paste(trajectory_cluster_dir,"monocle_celltype.pdf",sep="/"),width=12)
            ggsave(p01,file=paste(trajectory_cluster_dir,"monocle_celltype.png",sep="/"),width=12)

            plot_cell_trajectory(monocds,color_by="celltype", size=1,show_backbone=TRUE)+ facet_wrap("~celltype", nrow = 2)+ scale_color_manual(values = colour)
            ggsave(paste0(trajectory_cluster_dir,'/','celltype.pdf'),width = 12,height = 8) 
            ggsave(paste0(trajectory_cluster_dir,'/','celltype.png'),width = 12,height = 8, dpi = 300,bg = 'white')
        }else{
            print('no celltype id in datasets')
        }
    }else{
        	plot_cell_trajectory(monocds,color_by="seurat_clusters", size=1,show_backbone=TRUE)+ facet_wrap("~seurat_clusters", nrow = 2)+ scale_color_manual(values = colour)
            ggsave(paste0(trajectory_cluster_dir,'/','seurat_clusters.pdf'),width = 12,height = 8) 
            ggsave(paste0(trajectory_cluster_dir,'/','seurat_clusters.png'),width = 12,height = 8, dpi = 300,bg = 'white')
        
            p02=plot_cell_trajectory(monocds, color_by = "seurat_clusters")+ scale_color_manual(values = colour)
            ggsave(p02,file=paste(trajectory_cluster_dir,"monocle_seurat_clusters.pdf",sep="/"),width=12)
            ggsave(p02,file=paste(trajectory_cluster_dir,"monocle_seurat_clusters.png",sep="/"),width=12)

        
    }
    

	p1<-plot_cell_trajectory(monocds, color_by = "Cluster")+ scale_color_manual(values = colour)
	ggsave(p1,file=paste(trajectory_cluster_dir,"monocle_Cluster.pdf",sep="/"),width=12)
	ggsave(p1,file=paste(trajectory_cluster_dir,"monocle_Cluster.png",sep="/"),width=12)

	p2<-plot_cell_trajectory(monocds, color_by = "State")+ scale_color_manual(values = colour)
	ggsave(p2,file=paste(trajectory_cluster_dir,"monocle_State.pdf",sep="/"))
	ggsave(p2,file=paste(trajectory_cluster_dir,"monocle_State.png",sep="/"))

	p3<-plot_cell_trajectory(monocds, color_by = "Pseudotime")
	ggsave(p3,file=paste(trajectory_cluster_dir,"monocle_Pseudotime.pdf",sep="/"))
	ggsave(p3,file=paste(trajectory_cluster_dir,"monocle_Pseudotime.png",sep="/"))

	# p<-plot_cell_trajectory(monocds, color_by = "sample")+ scale_color_manual(values = colour)
	# ggsave(p,file=paste(trajectory_cluster_dir,"monocle_sample.pdf",sep="/"),width=10)
	# ggsave(p,file=paste(trajectory_cluster_dir,"monocle_sample.png",sep="/"),width=10)

	pn1<-plot_cell_trajectory(monocds, color_by = "State")+facet_wrap(~State, nrow = 1)+ scale_color_manual(values = colour)
	ggsave(pn1,file=paste(trajectory_cluster_dir,"monocle_State_split.pdf",sep="/"))
	ggsave(pn1,file=paste(trajectory_cluster_dir,"monocle_State_split.png",sep="/"))

	cluster_num=length(unique(bb$seurat_clusters))
	if(cluster_num <=10){
	width=10
	height=8
	nrow=1
	}else if(cluster_num >10 && cluster_num <=20){
	nrow=3
	width=10
	height=9
	}else if(cluster_num >20 && cluster_num <=30){
	nrow=4
	width=10
	height=12
	}else{
	nrow=5
	width=10
	height=14
	}
	pn2<-plot_cell_trajectory(monocds, color_by = "Cluster")+facet_wrap(~Cluster, nrow = nrow)+ scale_color_manual(values = colour)
	ggsave(pn2,file=paste(trajectory_cluster_dir,"monocle_Cluster_split.pdf",sep="/"),width=width,height=height)
	ggsave(pn2,file=paste(trajectory_cluster_dir,"monocle_Cluster_split.png",sep="/"),width=width,height=height)
	pn3<-plot_cell_trajectory(monocds, color_by = "sample")+facet_wrap(~sample, nrow = nrow)+ scale_color_manual(values = colour)
	ggsave(pn3,file=paste(trajectory_cluster_dir,"monocle_sample_split.pdf",sep="/"),width=10)
	ggsave(pn3,file=paste(trajectory_cluster_dir,"monocle_sample_split.png",sep="/"),width=10)

        pn4<-plot_cell_trajectory(monocds, color_by = "group")+facet_wrap(~group, nrow = nrow)+ scale_color_manual(values = colour)
        ggsave(pn4,file=paste(trajectory_cluster_dir,"monocle_group_split.pdf",sep="/"),width=10)
        ggsave(pn4,file=paste(trajectory_cluster_dir,"monocle_group_split.png",sep="/"),width=10)
	

#
	print("do differentialGeneTest accroding Pseudotime")
	diff_test_Pseudotime <- differentialGeneTest(monocds[expressed_genes,],fullModelFormulaStr = "~sm.ns(Pseudotime)")
	diff_order <- diff_test_Pseudotime[order(diff_test_Pseudotime$qval),]  ###??q?????
	diff_order <- diff_order[,c("gene_short_name", "pval", "qval")]
	write.table(diff_order,paste(trajectory_cluster_dir,"diff_test_Pseudotime.txt",sep="/"),sep="\t",row.names=F,quote=F)

	select.gene=rownames(diff_order)[1:6]
	cds_subset <- monocds[select.gene,]
	p4<-plot_genes_in_pseudotime(cds_subset, color_by = "State")+ scale_color_manual(values = colour)
	ggsave(p4,file=paste(trajectory_cluster_dir,"monocle_gene_State_top6.pdf",sep="/"))
	ggsave(p4,file=paste(trajectory_cluster_dir,"monocle_gene_State_top6.png",sep="/"))
	p7<-plot_genes_in_pseudotime(cds_subset, color_by = "Cluster")+ scale_color_manual(values = colour)
	ggsave(p7,file=paste(trajectory_cluster_dir,"monocle_gene_Cluster_top6.pdf",sep="/"))
	ggsave(p7,file=paste(trajectory_cluster_dir,"monocle_gene_Cluster_top6.png",sep="/"))
	select.gene.top50=rownames(diff_order)[1:50]
	cds_subset_top50=monocds[select.gene.top50,]
	p5<-plot_pseudotime_heatmap(cds_subset_top50,num_clusters = 3,cores = 1,show_rownames = T,return_heatmap=TRUE)
	ggsave(p5,file=paste(trajectory_cluster_dir,"monocle_gene_heatmap_top50.pdf",sep="/"))
	ggsave(p5,file=paste(trajectory_cluster_dir,"monocle_gene_heatmap_top50.png",sep="/"))

	p8<-plot_complex_cell_trajectory(monocds,color_by = "Cluster")+ scale_color_manual(values = colour)
	ggsave(file=paste(trajectory_cluster_dir,"cell_trajectory_cluster.pdf",sep="/"),p8)
	ggsave(file=paste(trajectory_cluster_dir,"cell_trajectory_cluster.png",sep="/"),p8)

	p9<-plot_complex_cell_trajectory(monocds,color_by = "State")+ scale_color_manual(values = colour)
	ggsave(file=paste(trajectory_cluster_dir,"cell_trajectory_state.pdf",sep="/"),p9)
	ggsave(file=paste(trajectory_cluster_dir,"cell_trajectory_state.png",sep="/"),p9)

	p10<-plot_complex_cell_trajectory(monocds,color_by = "Pseudotime")
	ggsave(file=paste(trajectory_cluster_dir,"cell_trajectory_Pseudotime.pdf",sep="/"),p10)
	ggsave(file=paste(trajectory_cluster_dir,"cell_trajectory_Pseudotime.png",sep="/"),p10)  

	


	# cores can not 1
    
    BEAM_test=BEAM(monocds,branch_point = 1,cores = 2)  #
    #会返回每个基因的显著性，显著的基因就是那些随不同branch变化的基因
    #这一步很慢
    BEAM_order <- BEAM_test[order(BEAM_test$qval),]
    BEAM_order=BEAM_order[,c("gene_short_name","pval","qval")]
	write.table(BEAM_order,paste(trajectory_cluster_dir,"BEAM_order.txt",sep="/"),sep="\t",row.names=F,quote=F)

    tmp1=plot_genes_branched_heatmap(monocds[row.names(subset(BEAM_order,qval<1e-4)),],
                                     branch_point = 1,
                                     num_clusters = 4, #这些基因被分成几个group
                                     cores = 3,
                                     branch_labels = c("Cell fate 1", "Cell fate 2"),
                                     #hmcols = NULL, #默认值
                                     hmcols = colorRampPalette(rev(brewer.pal(9, "PRGn")))(62),
                                     branch_colors = c("#979797", "#F05662", "#7990C8"), #pre-branch, Cell fate 1, Cell fate 2分别用什么颜色
                                     use_gene_short_name = T,
                                     show_rownames = F,
                                     return_heatmap = T #是否返回一些重要信息
    )
    
    
    
    ggsave(file=paste(trajectory_cluster_dir,"genes_branched_heatmap_top100.pdf",sep="/"),tmp1$ph_res)
    ggsave(file=paste(trajectory_cluster_dir,"genes_branched_heatmap_top100.pdf",sep="/"),tmp1$ph_res)
	return(monocds)
	}	
