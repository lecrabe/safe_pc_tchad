####################################################################################
####### Object:  Processing chain - MASTER script             
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/08/22                                       
####################################################################################
master_time <- Sys.time()

################################################################################
## Run the change detection
source(paste0(scriptdir,"change_detection_OTB.R"),echo=TRUE)

# ################################################################################
# ## Run the classification for time 1
outdir  <- paste0(tiledir,"/time1/")
im_input      <- t1_input
train_man_shp <- t1_train

source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
source(paste0(scriptdir,"prepare_training_data.R"),echo=TRUE)
source(paste0(scriptdir,"supervised_classification.R"),echo=TRUE)

################################################################################
## Run the classification for time 2
outdir  <- paste0(tiledir,"/time2/")
im_input <- t2_input
train_man_shp <- t2_train

source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
source(paste0(scriptdir,"prepare_training_data.R"),echo=TRUE)
source(paste0(scriptdir,"supervised_classification.R"),echo=TRUE)

################################################################################
## Parameters for merge using t1 segments
segs_id <- t1_segs
time    <- time1

source(paste0(scriptdir,"set_parameters_merge.R"),echo=TRUE)
source(paste0(scriptdir,"merge_datasets.R"),echo=TRUE)
source(paste0(scriptdir,"close_holes_morphology.R"),echo=TRUE)

################################################################################
## Parameters for merge using t2 segments
segs_id <- t2_segs
time    <- time2

source(paste0(scriptdir,"set_parameters_merge.R"),echo=TRUE)
source(paste0(scriptdir,"merge_datasets.R"),echo=TRUE)
source(paste0(scriptdir,"close_holes_morphology.R"),echo=TRUE)

################################################################################
## Call field data and inject into LCC map to generate statistics and biomass maps
# source(paste0(scriptdir,"inject_field_data.R"),echo=TRUE)

(overall_time <- (master_time - Sys.time()))
