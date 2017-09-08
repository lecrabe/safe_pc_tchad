####################################################################################
####### Object:  Reproject and Merge same date blocks              
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/09/08                                     
####################################################################################

##########################################################################################
#### Shift is VISUALLY ASSESSED (GCP in QGIS)

#################### DETERMINE DATASET DIR FOR EACH SAME DATE ACQUISITIONS
qb04_tile1_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P003_PSH/")
qb04_tile2_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P001_PSH/")
qb04_tile3_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P004_PSH/")
qb04_tile4_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P002_PSH/")

aoi <- "aoi2"

for(i in 1:4){

  dir <-  get(paste0("qb04_tile",i,"_dir"))

#################### MERGE SAME DATES ACQUISITIONS INTO MOSAICS
system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
               paste0(procimgdir,"tmp_",aoi,"_2004_tile",i,".tif"),
               paste0(dir,"*.TIF")
))

#################### COMPRESS
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
               paste0(procimgdir,"tmp_",aoi,"_2004_tile",i,".tif"),
               paste0(procimgdir,aoi,"_2004_tile",i,".tif")
))

#################### REPROJECT IN UTM 
system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
               paste0(procimgdir,aoi,"_2004_tile",i,".tif"),
               paste0(procimgdir,aoi,"_2004_tile",i,"_utm.tif")
))
}

#################### CLEAN TMP FILES
system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_",aoi,"_2004_*.tif")
))
