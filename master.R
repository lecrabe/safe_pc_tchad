####################################################################################
####### Object:  Processing chain - MASTER script             
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/08/22                                       
####################################################################################
master_time <- Sys.time()
####### SET WHERE YOUR SCRIPTS ARE CLONED
clonedir  <- paste0("/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/tchad/scripts_tchad/")
scriptdir <- paste0(clonedir,"process/")
p_procdir <- paste0(clonedir,"pre-processing/")

####### SET WHERE YOUR IMAGE DIRECTORY IS
rawimgdir   <- "/media/dannunzio/hdd_remi/tchad/"

####### PRE-PROCESSING DATA WILL BE CREATED AND STORED HERE
procimgdir <- "/media/dannunzio/hdd_remi/tchad/images/"
#procimgdir  <- "/home/dannunzio/Documents/tchad/images/"
#dir.create(procimgdir)

####### YOUR PROCESSING DATA WILL BE CREATED AND STORED HERE
#rootdir   <- "/media/dannunzio/hdd_remi/tchad/"
rootdir    <- rawimgdir #"/home/dannunzio/Documents/tchad/"
setwd(scriptdir)

####################################################################################
#######          PACKAGES
####################################################################################
source(paste0(scriptdir,"load_packages.R"),echo=TRUE)

####################################################################################
#######          CHANGE ACCORDINGLY TO PERIOD OF INTEREST
####################################################################################
time1       <- "2004"
time2       <- "2016"
tile        <- "aoi1_clip"

####################################################################################
#######          SET PARAMETERS
####################################################################################
source(paste0(scriptdir,"set_parameters_master.R"),echo=TRUE)

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

####################################################################################
##              RUN PRE-PROCESSING STEPS
####################################################################################
t1_bands <- c(4,1,2) # NIR, RED, GREEN for QuickBird data
t2_bands <- c(4,1,2) # NIR, RED, GREEN for SPOT      data

source(paste0(scriptdir,"set_parameters_imad.R"),echo=TRUE)

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
t1_file_m   <-  output_rf   # time 1 file

segs_id     <- all_sg_id
# 
# ################################################################################
# ## Run the classification for time 2
outdir  <- paste0(tiledir,"/time2/")
dir.create(outdir)
im_input <- t2_input

source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
source(paste0(scriptdir,"prepare_training_data.R"),echo=TRUE)
source(paste0(scriptdir,"supervised_classification.R"),echo=TRUE)
t2_file_m   <-  output_rf  # time 2 file
# 
# ################################################################################
# ## Merge date 1 and date 2 (uncomment necessary script)
source(paste0(scriptdir,"set_parameters_merge.R"),echo=TRUE)
source(paste0(scriptdir,"merge_datasets.R"),echo=TRUE)
# 
# ################################################################################
# ## Call field data and inject into LCC map to generate statistics and biomass maps
# # source(paste0(scriptdir,"inject_field_data.R"),echo=TRUE)

(overall_time <- (master_time - Sys.time()))
