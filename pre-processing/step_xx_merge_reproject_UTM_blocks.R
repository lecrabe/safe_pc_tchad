####################################################################################
####### Object:  Reproject and Merge same date blocks              
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/09/08                                     
####################################################################################

##########################################################################################
#### Shift is VISUALLY ASSESSED (GCP in QGIS)

#################### DETERMINE DATASET DIR FOR EACH SAME DATE ACQUISITIONS
aoi <- "aoi2"

qb04_tile1_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P003_PSH/")
qb04_tile2_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P001_PSH/")
qb04_tile3_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P004_PSH/")
qb04_tile4_dir  <- paste0(rawimgdir,"GSI_MDA/056880814020_01/056880814020_01_P002_PSH/")
spot_dir        <- paste0(rawimgdir,"SPOT_AIRBUS/Chad-AOI2_SO17013364-4-01_DS_SPOT6_201611300905012_FR1_FR1_FR1_FR1_E017N08_02926/PROD_SPOT6_001/VOL_SPOT6_001_A/IMG_SPOT6_PMS_001_A/")


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

dir <- spot_dir

#################### MERGE SAME DATES ACQUISITIONS INTO MOSAICS
system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
               paste0(procimgdir,"tmp_",aoi,"_2016_spot.tif"),
               paste0(dir,"*.TIF")
))

#################### COMPRESS
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
               paste0(procimgdir,"tmp_",aoi,"_2016_spot.tif"),
               paste0(procimgdir,aoi,"_2016_spot.tif")
))

#################### REPROJECT IN UTM 
system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
               paste0(procimgdir,aoi,"_2016_spot.tif"),
               paste0(procimgdir,aoi,"_2016_spot_utm.tif")
))

#################### CLEAN TMP FILES
system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_",aoi,"_2016_*.tif")
))