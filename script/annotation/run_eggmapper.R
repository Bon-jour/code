eggmapper = function(obo, eggmapper){
    # download go-basic.obo from http://geneontology.org/docs/download-ontology/ and then
# download ko00001.json from https://www.genome.jp/kegg-bin/get_htext?ko00001
    library(reticulate)#
    library(openxlsx)
    library(clusterProfiler)
    library(dplyr)
    library(stringr)
    library(AnnotationForge)
    library(jsonlite)
    library(purrr)
    library(RCurl)
    source('./ko_json2data.R')
    system('python ./get_go_term.py  obo ')
    egg = read.csv(eggmapper)
    egg = egg;egg[egg==""]<-NA
    gene_info <- egg %>% dplyr::select(GID = query, EGGannot = seed_ortholog, SYMBOL=Preferred_name) %>% na.omit()
    gterms <- egg %>% dplyr::select(GID = query,GO_terms = GOs) %>% na.omit()
    gene_ids <- egg$query
    eggnog_lines_with_go <- egg$GOs!= ""
    eggnog_annoations_go <- str_split(egg[eggnog_lines_with_go,]$GOs, ",")
    gene_to_go <- data.frame(gene = rep(gene_ids[eggnog_lines_with_go],
                                       times = sapply(eggnog_annoations_go, length)),
                             term = unlist(eggnog_annoations_go))
    
    go_anno <- gene_to_go
    names(go_anno) <- c('gene_id','ID') 
    go_class <-read.delim('./go_term.list', header=FALSE, stringsAsFactors =FALSE) 
    names(go_class) <- c('ID','Description','Ontology')  
    go_anno <-merge(go_anno, go_class, by = 'ID', all.x = TRUE)
    go_anno = go_anno[,c(2,1,3,4)]
    go_anno2 = go_anno %>% na.omit()
    write.table(go_anno2,file = 'out.emapper.go.txt',sep = '\t',quote = F,col.names = F,row.names = F)
    gene2ko <- egg %>% dplyr::select(GID = query, Ko = KEGG_ko) %>%  na.omit()
    load('kegg_info.RData')
    gene_ids <- egg$query
    eggnog_lines_with_go <- egg$KEGG_ko!= ""
    eggnog_annoations_go <- str_split(egg[eggnog_lines_with_go,]$KEGG_ko, ",")
    gene_to_kegg <- data.frame(gene = rep(gene_ids[eggnog_lines_with_go],
                                       times = sapply(eggnog_annoations_go, length)),
                             term = unlist(eggnog_annoations_go))
    ko2pathway$Ko = paste0('ko:',ko2pathway$Ko)
    data = merge(gene_to_kegg,ko2pathway,by.x = 'term',by.y = 'Ko')
    data1 = merge(data,pathway2name,by='Pathway')
    data1 = data1[,c(3,1,4)]
    data1 = data1 %>% na.omit()
    write.table(data1,file = 'out.emapper.kegg.txt',sep = '\t',quote = F,col.names = F,row.names = F)
} 
eggmapper('./go-basic.obo','./egg.csv')