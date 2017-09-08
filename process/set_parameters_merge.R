####################################################################################
####### Object:  Prepare names for merging of intermediate products                 
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/03/12           
##                                                                      UNFINISHED
####################################################################################

################################################################################
## Create an output directory for the change products
imaddir       <- paste0(tiledir,"/imad/")
res_time1_dir <- paste0(tiledir,"/time1/")
res_time2_dir <- paste0(tiledir,"/time2/")
mergedir      <- paste0(tiledir,"/change",time,"/")

dir.create(mergedir)

####################################################################################
#######          INPUTS FROM IMAD AND CLASSIFICATIONS
####################################################################################
imad        <-  paste0(imaddir,"/tile_",tile,"_imad.tif")           # imad name

########################################
## OUTPUTS OF MERGE

#segs_id   <- paste0(mergedir,"/tile_",tile,"_all_segs_id.tif")    # id of each objects (sentinel base)

t2_cl_st  <- paste0(mergedir,"/tile_",tile,"_t2_class_stats.txt") # stats of time 2 
t1_cl_st  <- paste0(mergedir,"/tile_",tile,"_t1_class_stats.txt") # stats of time 1
im_cl_st  <- paste0(mergedir,"/tile_",tile,"_im_class_stats.txt") # stats of IMAD change detection 

reclass    <- paste0(mergedir,"/tile_",tile,"_reclass.txt")        # reclassified stats
chg_class  <- paste0(mergedir,"/tile_",tile,"_change_reclass.tif") # reclassified tif
chg_closed <- paste0(mergedir,"/tile_",tile,"_change_closed.tif") # reclassified tif