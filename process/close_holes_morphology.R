####################################################################################
####### Object:  core buffer periphery
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/02/13                                          
####################################################################################

class <- 1
size_morpho <- 10

# ################################################################################
# ## Extract binary product for losses
# ################################################################################
system(sprintf("gdal_calc.py -A %s --outfile=%s --calc=\"%s\"",
               chg_class,
               paste0(mergedir,"/","tmp_binary_reclass_loss.tif"),
               paste0("A==",class))
)

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(mergedir,"/","tmp_binary_reclass_loss.tif"),
               paste0(mergedir,"/","binary_reclass_loss.tif")
))


################################################################################
## Morphological closing
################################################################################

  system(sprintf("otbcli_BinaryMorphologicalOperation -in %s -out %s -structype.ball.xradius %s -structype.ball.yradius %s -filter %s",
                 paste0(mergedir,"/","binary_reclass_loss.tif"),
                 paste0(mergedir,"/","tmp_closing_binary_reclass_loss.tif"),
                 size_morpho,
                 size_morpho,
                 "closing"
  ))

  system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
                 paste0(mergedir,"/","tmp_closing_binary_reclass_loss.tif"),
                 paste0(mergedir,"/","closing_binary_reclass_loss.tif")
  ))

  
################################################################################
## Recombine masks 
################################################################################
system(sprintf("gdal_calc.py -A %s -B %s --outfile=%s --calc=\"%s\"",
               chg_class,
               paste0(mergedir,"/","closing_binary_reclass_loss.tif"),
               paste0(mergedir,"/","tmp_closed_binary_reclass_loss.tif"),
               paste0("(B==0)*A+(B==1)*",class)
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(mergedir,"/","tmp_closed_binary_reclass_loss.tif"),
               paste0(mergedir,"/","closed_binary_reclass_loss.tif")
))


system(sprintf("rm %s",
               paste0(mergedir,"/","tmp_*")
))


(time <- Sys.time() - start)


