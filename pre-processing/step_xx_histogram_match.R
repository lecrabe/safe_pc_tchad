####################################################################################
####### Object:  Shift imagery               
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/06/05                                      
####################################################################################

#################### EXTRACT BANDS
nbands <- nbands(brick(paste0(procimgdir,"aoi1_2004_west_utm_shift.tif")))

# for(band in 1:nbands){
#   ############# Extract bands from WEST SHIFTED product
#   system(sprintf("gdal_translate -b %s -co COMPRESS=LZW %s %s",
#                  band,
#                  paste0(procimgdir,"aoi1_2004_west_utm_shift.tif"),
#                  paste0(procimgdir,"aoi1_2004_west_utm_shift_b",band,".tif") 
#   ))
#   
#   ############# Extract bands from EAST SHIFTED product
#   system(sprintf("gdal_translate -b %s -co COMPRESS=LZW %s %s",
#                  band,
#                  paste0(procimgdir,"aoi1_2004_east_utm_shift.tif"),
#                  paste0(procimgdir,"aoi1_2004_east_utm_shift_b",band,".tif")       
#   ))
# }


input1 <- paste0(procimgdir,"aoi1_2004_east_utm_shift.tif")
input2 <- paste0(procimgdir,"aoi1_2004_west_utm_shift.tif")
nPoints=10000
band = 1

#################### DEFINE A HISTOGRAM NORMALIZATION FUNCTION

####### Get pathname and basename for input2 which will be histogram-normalized
outdir <- dirname(input2)

base1   <- basename(input1)
base2   <- basename(input2)

####### Read rasters and determine common intersection extent
r1 <- brick(paste0(input1))
r2 <- brick(paste0(input2))

e1 <- extent(r1)
e2 <- extent(r2)

####### Polygonize
poly_1 <- Polygons(list(Polygon(cbind(
  c(e1@xmin,e1@xmin,e1@xmax,e1@xmax,e1@xmin),
  c(e1@ymin,e1@ymax,e1@ymax,e1@ymin,e1@ymin))
)),1)

####### Polygonize
poly_2 <- Polygons(list(Polygon(cbind(
  c(e2@xmin,e2@xmin,e2@xmax,e2@xmax,e2@xmin),
  c(e2@ymin,e2@ymax,e2@ymax,e2@ymin,e2@ymin))
)),1)

####### Convert to SpatialPolygon
sp_poly_1 <- SpatialPolygons(list(poly_1))

####### Convert to SpatialPolygon
sp_poly_2 <- SpatialPolygons(list(poly_2))

####### Intersect both zones
sp_poly   <- intersect(sp_poly_1,sp_poly_2)

####### Rasterize intersect
# temp   <- raster(sp_poly,
#                  resolution=res(r1)[1],
#                  ext=extent(sp_poly),
#                  crs=proj4string(r1)
#                  )
# temp[is.na(temp)] <- 0
# proj4string(temp) <- proj4string(r1)
# 
# writeRaster(temp,paste0(procimgdir,"inter.tif"))

# system(sprintf("oft-clip.pl %s %s %s",
#                paste0(procimgdir,"inter.tif"),
#                paste0(procimgdir,"aoi1_2004_east_utm_shift.tif"),
#                paste0(procimgdir,"aoi1_2004_east_utm_shift_clip.tif")
# ))
# 
# system(sprintf("oft-clip.pl %s %s %s",
#                paste0(procimgdir,"inter.tif"),
#                paste0(procimgdir,"aoi1_2004_west_utm_shift.tif"),
#                paste0(procimgdir,"aoi1_2004_west_utm_shift_clip.tif")
# ))
# 
# system(sprintf("otbcli_MultivariateAlterationDetector -in1 %s -in2 %s -out %s",
#                paste0(procimgdir,"aoi1_2004_east_utm_shift_clip.tif"),
#                paste0(procimgdir,"aoi1_2004_west_utm_shift_clip.tif"),
#                paste0(procimgdir,"tmp_chdet.tif")
# ))
# 
# r3 <- brick(paste0(procimgdir,"tmp_chdet.tif"))

####### Shoot randomly points on the intersection, extract values from both rasters
pts <- spsample(sp_poly,n=nPoints,"random")

h1 <- data.frame(extract(x = r1,y = pts))
h2 <- data.frame(extract(x = r2,y = pts))
#h3 <- data.frame(extract(x = r3,y = pts))

#######  Put datasets together and exclude zeros
hh <- data.frame(cbind(h1,h2))
names(hh) <- c(paste0("X1",1:nbands),paste0("X2",1:nbands))

hh <- hh[rowSums(hh[,paste0("X1",1:nbands)]) != 0 ,]
hh <- hh[rowSums(hh[,paste0("X2",1:nbands)]) != 0 ,]

# hh <- hh[hh$X1 > quantile(hh$X1,probs= seq(0,1,0.1))[2] & hh$X1 < quantile(hh$X1,probs= seq(0,1,0.1))[10],]
# hh <- hh[hh$X2 > quantile(hh$X2,probs= seq(0,1,0.1))[2] & hh$X2 < quantile(hh$X2,probs= seq(0,1,0.1))[10],]
dev.off()
par(mfrow = c(2,4))
par(mar=c(0,0,0,0))

for(band in 1:nbands){

  plot(hh[,paste0("X1",band)],hh[,paste0("X2",band)])
  
  #######  GLM of dataset 1 vs dataset 2 and normalized raster 2 as output
  glm12 <- lm(hh[,paste0("X1",band)] ~ hh[,paste0("X2",band)] + 0)
  
  hh$residuals <- residuals(glm12)
  hh$score<-scores(hh$residuals,type="z")
  
  outlier <- hh[abs(hh$score)>1.5,]
  plot(hh[,paste0("X2",band)],hh[,paste0("X1",band)],col="darkgrey")
  points(outlier[,paste0("X2",band)],outlier[,paste0("X1",band)],col="red")
  
  summary(hh)
  hh <- hh[abs(hh$score)<=1.5,]
  glm12 <- lm(hh[,paste0("X1",band)] ~ hh[,paste0("X2",band)] + 0)
  
  i12 <- 0 #glm12$coefficients[1]
  c12 <- glm12$coefficients[1]
  
  
  #######  Apply model to have a normalized input2
  system(sprintf("gdal_calc.py -A %s --A_band=%s --outfile=%s --NoDataValue=0 --co COMPRESS=LZW --calc=\"%s\"",
                 input2,
                 band,
                 paste0(outdir,"/","norm_b",band,"_",base2),
                 paste0("(A*",c12,"+",i12,")")
  ))

  #######  Apply model to have a normalized input1
  system(sprintf("gdal_calc.py -A %s --A_band=%s --outfile=%s --NoDataValue=0 --co COMPRESS=LZW --calc=\"%s\"",
                 input1,
                 band,
                 paste0(outdir,"/","norm_b",band,"_",base1),
                 paste0("A")
  ))

}


#######  Merge all normalized bands from input 2 together
system(sprintf("gdal_merge.py -o %s -separate -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
               paste0(procimgdir,"tmp_aoi1_2004_west_merge.tif"),
               paste0(outdir,"/","norm_b*west*.tif")
))

#######  Merge all normalized bands from input 1 together
system(sprintf("gdal_merge.py -o %s -separate -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
               paste0(procimgdir,"tmp_aoi1_2004_east_merge.tif"),
               paste0(outdir,"/","norm_b*east*.tif")
))

#######  Merge all normalized WEST and EAST together
system(sprintf("gdal_merge.py -o %s -n 0 -co COMPRESS=LZW -co BIGTIFF=YES -v %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_merge.tif"),
               paste0(procimgdir,"tmp_aoi1_2004_east_merge.tif"),
               paste0(procimgdir,"tmp_aoi1_2004_west_merge.tif")
))

#######  COMPRESS
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_merge.tif"),
               paste0(procimgdir,"merge_aoi1_2004.tif")
))

###################################################################################
###################################################################################
#######  CLIP 2016 data to 2004
system(sprintf("oft-clip.pl %s %s %s",
               paste0(procimgdir,"merge_aoi1_2004.tif"),
               paste0(procimgdir,"aoi1_2016_spot.TIF"),
               paste0(procimgdir,"tmp_merge_aoi1_2016.tif")
))

###################################################################################
#######          Compress
system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
               paste0(procimgdir,"tmp_merge_aoi1_2016.tif"),
               paste0(procimgdir,"merge_aoi1_2016.tif")
))

#################### CLEAN TMP FILES
system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_*.tif")
))

system(sprintf("rm -r %s",
               paste0(procimgdir,"norm_*.tif")
))
