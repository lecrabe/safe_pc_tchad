####################################################################################
####### Object:  Run change detection between two dates             
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2016/11/06                                           
####################################################################################
tile_start_time <- Sys.time()


####################################################################################################################
########### Run change detection
###################################################################################################################
r1 <- brick(t1_input)
origin(r1) <- origin(raster(t2_input))
writeRaster(r1,t1_input_o,overwrite=T)

## Perform change detection
system(sprintf("otbcli_MultivariateAlterationDetector -in1 %s -in2 %s -out %s",
               t1_input_o,
               t2_input,
               imad
               ))



# ## Multiply bands
# system(sprintf("gdal_calc.py -A %s  --A_band 1 -B %s  --B_band 2  -C %s  --C_band 3  --outfile=%s --calc=\"%s\"",
#                paste0(imaddir,"tmp_chdet.tif"),
#                paste0(imaddir,"tmp_chdet.tif"),
#                paste0(imaddir,"tmp_chdet.tif"),
#                paste0(imaddir,"tmp_prod_chdet.tif"),
#                paste0("A*B*C*1000")
# )
# )

# ## Compress results
# system(sprintf("gdal_translate -ot Float32 -co COMPRESS=LZW -co BIGTIFF=YES -a_nodata none %s %s",
#                paste0(imaddir,"tmp_prod_chdet.tif"),
#                imad
# ))




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

(time <- Sys.time() - tile_start_time)
