####################################################################################
####### Object:  Prepare names of all intermediate products                 
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/06/05                                           
####################################################################################

####################################################################################
#######          GLOBAL ENVIRONMENT VARIABLES
####################################################################################
options(stringsAsFactors=FALSE)

t1_dir    <- paste0(rootdir,"images/")
t2_dir    <- paste0(rootdir,"images/")

procimgdir   <- paste0(rootdir,"images/")
shift_dir    <- paste0(rootdir,"training_gcp_data_tchad/")#"shift_images/")
training_dir <- paste0(rootdir,"training_gcp_data_tchad/")#"training_manual/")
dem_dir      <- paste0(rootdir,"dem_aoi/")
result_dir   <- paste0(rootdir,"results_tiles/")
cloud_dir    <- paste0(rootdir,"cloud_mask/")
field_dir    <- paste0(rootdir,"field_data/")
comb_dir     <- paste0(rootdir,"results_merged/")

dir.create(training_dir)
dir.create(dem_dir)
dir.create(result_dir)
dir.create(cloud_dir)
dir.create(field_dir)
dir.create(procimgdir)
dir.create(comb_dir)

dem_input    <- paste0(dem_dir,"srtm_elev_30m_aoi.tif")
slp_input    <- paste0(dem_dir,"srtm_slope_30m_aoi.tif")
asp_input    <- paste0(dem_dir,"srtm_aspect_30m_aoi.tif")

plot_shp     <- paste0(field_dir,"")
agb_data     <- paste0(field_dir,"")

####################################################################################
#######          PARAMETERS
####################################################################################
spacing_km  <- 50   # UTM in meters, Point spacing in grid for unsupervised classification
minsg_size  <- 20   # Minimum segment size in numbers of pixels

nb_chdet_bands <- 4 # Number of common bands between imagery for change detection
nbbands        <- 4

nb_clusters <- 50   # Number of clusters in the KMEANS classification

class <- 1          # class for LOSS in mergedataset
size_morpho <- 2   # size of morphological closing to be applied

####################################################################################
#######          TRAINING DATA LEGEND
####################################################################################
legend <- read.table(paste0(training_dir,"legend.txt"),sep=" ")
names(legend) <- c("item","value","class")

legend$class <- gsub("label=","",x = legend$class)
legend$class <- gsub("/","",x = legend$class)
legend$class <- gsub(">","",x = legend$class)

legend$value <- gsub("value=","",x = legend$value)
legend$value <- gsub("\"","",x = legend$value)

legend <- legend[,2:3]

nbclass <- nrow(legend)

legend$value <- as.numeric(legend$value)
