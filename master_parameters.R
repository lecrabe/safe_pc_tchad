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
#######          CHANGE ACCORDINGLY TO PERIOD OF INTEREST
####################################################################################
time1       <- "2004"
time2       <- "2016"
tile        <- "aoi1_clip"

####################################################################################
#######          SET PARAMETERS
####################################################################################
source(paste0(scriptdir,"set_parameters_master.R"),echo=TRUE)
source(paste0(scriptdir,"set_parameters_imad.R"),echo=TRUE)

################################################################################
## Parameters for classification for time 1
outdir   <- paste0(tiledir,"/time1/")
im_input <- t1_input
source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
t1_file_m   <-  output_rf   # time 1 file
segs_id     <- all_sg_id
 
################################################################################
## Parameters for classification for time 2
outdir  <- paste0(tiledir,"/time2/")
im_input <- t2_input
source(paste0(scriptdir,"set_parameters_classif.R"),echo=TRUE)
t2_file_m   <-  output_rf  # time 2 file

################################################################################
## Parameters for merge
source(paste0(scriptdir,"set_parameters_merge.R"),echo=TRUE)
