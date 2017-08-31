####################################################################################
####### Object:  generate training data polygons through unsupervised classification
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2016/10/31                                           
####################################################################################

training_start <- Sys.time()

################################################################################
## Perform unsupervised classification
################################################################################
## Generate a systematic grid point
system(sprintf("oft-gengrid.bash %s %s %s %s",im_input,spacing_km,spacing_km,grid))

## Extract spectral signature
system(sprintf("(echo 2 ; echo 3) | oft-extr -o %s %s %s",sg_km,grid,im_input))

## Run k-means unsupervised classification
system(sprintf("(echo %s; echo %s) | oft-kmeans -o %s -i %s",
               sg_km,
               nb_clusters,
               paste0(outdir,"/","tmp_km_se.tif"),
               im_input
               ))

## Sieve results with a 8 connected component rule: 
mmu <- 1

mmu <- mmu *2
system(sprintf("gdal_sieve.py -st %s -8 %s %s",
               mmu,
               paste0(outdir,"/","tmp_km_se.tif"),
               paste0(outdir,"/","tmp_sieve_km_se.tif")
))

mmu <- mmu *2
system(sprintf("gdal_sieve.py -st %s -8 %s %s",
               mmu,
               paste0(outdir,"/","tmp_sieve_km_se.tif"),
               paste0(outdir,"/","tmp_tmp_sieve_km_se.tif")
))

mmu <- mmu *2
system(sprintf("gdal_sieve.py -st %s -8 %s %s",
               mmu,
               paste0(outdir,"/","tmp_tmp_sieve_km_se.tif"),
               paste0(outdir,"/","tmp_sieve_km_se.tif")
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(outdir,"/","tmp_sieve_km_se.tif"),
               all_sg_km))

system(sprintf(paste0("rm ",outdir,"/","tmp_*.tif")))


################################################################################
## Clump the classification results : the IDs of the final classification zones
################################################################################
system(sprintf("oft-clump -i %s -o %s -um %s",
               all_sg_km,
               paste0(outdir,"/","tmp_all_seg_id.tif"),
               all_sg_km))

system(sprintf("gdal_translate -ot UInt32 -co COMPRESS=LZW %s %s",
               paste0(outdir,"/","tmp_all_seg_id.tif"),
               all_sg_id))

system(sprintf(paste0("rm ",outdir,"/","tmp_*.*")))

###################################################################################
#######          RASTERIZE training data
###################################################################################
system(sprintf("oft-rasterize_attr.py -v %s -i %s -o %s -a %s",
               train_man_shp,
               im_input,
               train_man_tif,
               "id"
))

sel_sg_train <- train_man_tif
################################################################################
## Clump again the selected segments to get unique real IDs
system(sprintf("oft-clump -i %s -o %s -um %s",
               train_man_tif,
               paste0(outdir,"/","tmp_sel_seg_id.tif"),
               train_man_tif))

sel_sg_train <- train_man_tif

system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
               paste0(outdir,"/","tmp_sel_seg_id.tif"),
               sel_sg_id))

system(sprintf(paste0("rm ",outdir,"/","tmp_*.*")))

(training_time <- Sys.time() - training_start)


