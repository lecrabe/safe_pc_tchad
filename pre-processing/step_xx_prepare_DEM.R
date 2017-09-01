####################################################################################
####### Object:  Processing chain : Prepare DEM data               
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/08/28                                   
####################################################################################

###################################################################################
#######          Process DEM obtained from http://dwtkns.com/srtm30m/
###################################################################################

for(zip in list.files(dem_dir)){
system(sprintf("echo A | unzip %s -d %s",
               paste0(dem_dir,zip),
               paste0(dem_dir)
))
}

dem_input <- paste0(dem_dir,"srtm_elev_30m_aoi.tif")
slp_input <- paste0(dem_dir,"srtm_slope_30m_aoi.tif")
asp_input <- paste0(dem_dir,"srtm_aspect_30m_aoi.tif")


system(sprintf("gdal_merge.py -v -o %s %s",
               paste0(dem_dir,"tmp_dem.tif"),
               paste0(dem_dir,"*.hgt")
))

system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
               paste0(dem_dir,"tmp_dem.tif"),
               paste0(dem_dir,"tmp_dem_utm.tif")
               ))


###################################################################################
#######          Compute slope
system(sprintf("gdaldem slope -co COMPRESS=LZW %s %s",
               paste0(dem_dir,"tmp_dem_utm.tif"),
               paste0(dem_dir,"tmp_slope.tif")
               ))

###################################################################################
#######          Compute aspect
system(sprintf("gdaldem aspect -co COMPRESS=LZW %s %s",
               paste0(dem_dir,"tmp_dem_utm.tif"),
               paste0(dem_dir,"tmp_aspect.tif")
))

###################################################################################
#######          Clip three DEM products to working resolution and extent
system(sprintf("oft-clip.pl %s %s %s",
               paste0(t1_dir,"aoi1_2004_merge.tif"),
               paste0(dem_dir,"tmp_dem_utm.tif"),
               paste0(dem_dir,"tmp_dem_aoi.tif")
))

system(sprintf("oft-clip.pl %s %s %s",
               paste0(t1_dir,"aoi1_2004_merge.tif"),
               paste0(dem_dir,"tmp_slope.tif"),
               paste0(dem_dir,"tmp_slope_aoi.tif")
))

system(sprintf("oft-clip.pl %s %s %s",
               paste0(t1_dir,"aoi1_2004_merge.tif"),
               paste0(dem_dir,"tmp_aspect.tif"),
               paste0(dem_dir,"tmp_aspect_aoi.tif")
))

###################################################################################
#######          Compress
system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
               paste0(dem_dir,"tmp_slope_aoi.tif"),
               slp_input
))

system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
               paste0(dem_dir,"tmp_aspect_aoi.tif"),
               asp_input
))

system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
               paste0(dem_dir,"tmp_dem_aoi.tif"),
               dem_input
))

###################################################################################
#######          Clean out TMP files
system(sprintf("rm %s",
               paste0(dem_dir,"tmp*.tif")
))



