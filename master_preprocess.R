####################################################################################
####### Object:  Processing chain - MASTER script             
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/08/22                                       
####################################################################################

####################################################################################
##              RUN PRE-PROCESSING STEPS
####################################################################################
# source(paste0(p_procdir,"step_xx_transform_by_GCP.R"),echo=TRUE)
# source(paste0(p_procdir,"step_xx_histogram_match.R"),echo=TRUE)
# source(paste0(p_procdir,"step_xx_prepare_DEM.R"),echo=TRUE)
# 
# system(sprintf("gdal_translate -projwin 658069.905745 905973.274773 661849.521913 902760.601031 -co COMPRESS=LZW %s %s",
#                paste0(procimgdir,"/merge_aoi1_2004.tif"),
#                paste0(procimgdir,"/merge_aoi1_clip_2004.tif")
#       ))
# 
# system(sprintf("gdal_translate -projwin 658069.905745 905973.274773 661849.521913 902760.601031 -co COMPRESS=LZW %s %s",
#                paste0(procimgdir,"/merge_aoi1_2016.tif"),
#                paste0(procimgdir,"/merge_aoi1_clip_2016.tif")))

