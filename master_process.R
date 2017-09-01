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
dir.create(outdir)
im_input <- t1_input

source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
source(paste0(scriptdir,"prepare_training_data.R"),echo=TRUE)
source(paste0(scriptdir,"supervised_classification.R"),echo=TRUE)

################################################################################
## Run the classification for time 2
outdir  <- paste0(tiledir,"/time2/")
dir.create(outdir)
im_input <- t2_input

source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
source(paste0(scriptdir,"prepare_training_data.R"),echo=TRUE)
source(paste0(scriptdir,"supervised_classification.R"),echo=TRUE)

################################################################################
## Merge date 1 and date 2 (uncomment necessary script)
source(paste0(scriptdir,"merge_datasets.R"),echo=TRUE)
 
################################################################################
## Call field data and inject into LCC map to generate statistics and biomass maps
# source(paste0(scriptdir,"inject_field_data.R"),echo=TRUE)

(overall_time <- (master_time - Sys.time()))
