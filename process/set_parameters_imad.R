####################################################################################
####### Object:  Prepare names of all intermediate products                 
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/02/05                                        
####################################################################################

################################################################################
## Create an output master directory
tiledir  <- paste0(result_dir,tile,"_",time1,"_",time2,"/")
system(sprintf("mkdir %s",tiledir))

################################################################################
## Create an output directory for the change products
imaddir  <- paste0(tiledir,"imad/")
system(sprintf("mkdir %s",imaddir))

################################################################################
## Name of inputs
imad     <- paste0(imaddir,"tile_",tile,"_imad.tif")   # imad output name
noch_msk <- paste0(imaddir,"tile_",tile,"_no_change_mask.tif")   # no change mask
chdt_msk <- paste0(imaddir,"tile_",tile,"_chdt.tif")   # thresholded imad product

imad_mm  <- paste0(imaddir,"tile_",tile,"imad_minmax.txt") # imad min max values
imad_info<- paste0(imaddir,"tile_",tile,"imad_info.txt")   # imad gdalinfo values

norm_imad<-paste0(imaddir,"tile_",tile,"_normimad.tif")

t1_input   <- paste0(imaddir,"tile_",tile,"_t1.tif")
t2_input   <- paste0(imaddir,"tile_",tile,"_t2.tif")
