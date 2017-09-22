####################################################################################
####### Object:  Processing chain - MASTER script for parameters           
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/09/01                                       
####################################################################################

####### SET WHERE YOUR SCRIPTS ARE CLONED
clonedir  <- paste0("/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/tchad/scripts_tchad/")

####### SET WHERE YOUR IMAGE DIRECTORY IS
rawimgdir   <- "/media/dannunzio/hdd_remi/tchad/"

####### DATA WILL BE CREATED AND STORED HERE
rootdir    <- "/media/dannunzio/hdd_remi/tchad/"


#############################################################################
#############################################################################
#############################################################################
#############################################################################

####### Sub-directories
scriptdir  <- paste0(clonedir,"process/")
p_procdir  <- paste0(clonedir,"pre-processing/")

####################################################################################
#######          PACKAGES
####################################################################################
source(paste0(scriptdir,"load_packages.R"),echo=TRUE)

####################################################################################
#######          SET PARAMETERS GENERAL
####################################################################################
source(paste0(scriptdir,"set_parameters_master.R"),echo=TRUE)

####################################################################################
#######          CHANGE ACCORDINGLY TO PERIOD OF INTEREST
####################################################################################
time1       <- "2004"
time2       <- "2016"
tile        <- "aoi2_tile4"

t1_file  <- paste0(t1_dir,"aoi2_2004_tile4_utm_shift.tif")
t2_file  <- paste0(t2_dir,"aoi2_2016_spot_utm.tif")

t1_train <- paste0(training_dir,"tchad_merge_training_data_2004.shp")
t2_train <- paste0(training_dir,"tchad_merge_training_data_2016.shp")

####################################################################################
#######          SET PARAMETERS FOR THE IMAGES OF INTEREST
####################################################################################
source(paste0(scriptdir,"set_parameters_imad.R"),echo=TRUE)

################################################################################
## Parameters for classification for time 1
outdir        <- paste0(tiledir,"/time1/")
dir.create(outdir)
im_input      <- t1_input
train_man_shp <- t1_train
source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)

t1_file_m   <-  output_rf   # time 1 file
t1_segs     <- all_sg_id
segs_id     <- t1_segs
time        <- time1
change_t1   <- chg_closed

################################################################################
## Parameters for merge
source(paste0(scriptdir,"set_parameters_merge.R"),echo=TRUE)


################################################################################
## Parameters for classification for time 2
outdir  <- paste0(tiledir,"/time2/")
dir.create(outdir)
im_input <- t2_input
source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)

t2_file_m   <-  output_rf  # time 2 file
t2_segs     <- all_sg_id
segs_id     <- t2_segs
time        <- time2
change_t2   <- chg_closed

################################################################################
## Parameters for merge
source(paste0(scriptdir,"set_parameters_merge.R"),echo=TRUE)


