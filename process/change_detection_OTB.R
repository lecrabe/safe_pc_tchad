####################################################################################
####### Object:  Run change detection between two dates             
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2016/11/06                                           
####################################################################################
imad_start_time <- Sys.time()

####################################################################################################################
########### Run change detection
###################################################################################################################
system(sprintf("oft-clip.pl %s %s %s",
               t2_input,
               t1_input,
               paste0(imaddir,"tmp_input_1.tif")
               ))


r1         <- brick(paste0(imaddir,"tmp_input_1.tif"))
origin(r1) <- origin(raster(t2_input))
writeRaster(r1,t1_input_o,overwrite=T)


## Perform change detection
system(sprintf("otbcli_MultivariateAlterationDetector -in1 %s -in2 %s -out %s",
               t1_input_o,
               t2_input,
               imad
               ))

################################################################################
## Create a no change mask
system(sprintf("gdal_calc.py -A %s  --A_band=4 -B %s  --B_band=1 --outfile=%s --calc=\"%s\"",
               imad,
               imad,
               paste0(imaddir,"tmp_noch.tif"),
               paste0("(A > -0.5)*(A < 0.5)*(B > -0.5)*(B < 0.5)")
               ))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(imaddir,"tmp_noch.tif"),
               noch_msk))

system(sprintf("rm %s",
               paste0(imaddir,"*tmp*.*")
))

(imad_time <- Sys.time() - imad_start_time)
