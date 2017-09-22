####################################################################################
####### Object:  core buffer periphery
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/02/13                                          
####################################################################################
closing_start_time <- Sys.time()

# ################################################################################
# ## Extract binary product for losses
# ################################################################################
system(sprintf("gdal_calc.py -A %s --outfile=%s --calc=\"%s\"",
               chg_class,
               paste0(mergedir,"/","tmp_binary_reclass_loss.tif"),
               paste0("A==",class))
)


################################################################################
## Morphological closing
################################################################################

  system(sprintf("otbcli_BinaryMorphologicalOperation -in %s -out %s -structype.ball.xradius %s -structype.ball.yradius %s -filter %s",
                 paste0(mergedir,"/","tmp_binary_reclass_loss.tif"),
                 paste0(mergedir,"/","tmp_closing_binary_reclass_loss.tif"),
                 size_morpho,
                 size_morpho,
                 "closing"
  ))


################################################################################
## Recombine masks 
################################################################################
system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --outfile=%s --calc=\"%s\"",
               chg_class,
               paste0(mergedir,"/","tmp_closing_binary_reclass_loss.tif"),
               paste0(mergedir,"/","tmp_closed_binary_reclass_loss.tif"),
               paste0("(B==0)*A+(B==1)*",class)
))


################################################################################
## Add pseudocolor Table
################################################################################
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(mergedir,"/color_table.txt"),
               paste0(mergedir,"/","tmp_closed_binary_reclass_loss.tif"),
               paste0(mergedir,"/","tmp_pct_closed_binary_reclass_loss.tif")
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(mergedir,"/","tmp_pct_closed_binary_reclass_loss.tif"),
               chg_closed
))


system(sprintf("rm %s",paste0(mergedir,"/","tmp_*")))


(closing_time <- Sys.time() - closing_start_time)


