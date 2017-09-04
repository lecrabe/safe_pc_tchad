####################################################################################
####### Object:  Shift imagery               
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/06/05                                      
####################################################################################

##########################################################################################
#### Shift is VISUALLY ASSESSED (GCP in QGIS)

#################### DETERMINE DATASET DIR FOR EACH SAME DATE ACQUISITIONS
qb04_east_dir  <- paste0(rawimgdir,"GSI_MDA/056880814010_01/056880814010_01_P001_PSH/")
qb04_west_dir  <- paste0(rawimgdir,"GSI_MDA/056880814010_01/056880814010_01_P002_PSH/")

#################### MERGE SAME DATES ACQUISITIONS INTO MOSAICS
system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
               paste0(procimgdir,"tmp_aoi1_2004_east.tif"),
               paste0(qb04_east_dir,"*.TIF")
))

#################### COMPRESS - EAST
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_east.tif"),
               paste0(procimgdir,"aoi1_2004_east.tif")
))

#################### REPROJECT IN UTM - EAST
system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
               paste0(procimgdir,"aoi1_2004_east.tif"),
               paste0(procimgdir,"aoi1_2004_east_utm.tif")
))

#################### MERGE SAME DATES ACQUISITIONS INTO MOSAICS - WEST
system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
               paste0(procimgdir,"tmp_aoi1_2004_west.tif"),
               paste0(qb04_west_dir,"*.TIF")
))

#################### COMPRESS - WEST
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_west.tif"),
               paste0(procimgdir,"aoi1_2004_west.tif")
))

#################### REPROJECT IN UTM - WEST
system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
               paste0(procimgdir,"aoi1_2004_west.tif"),
               paste0(procimgdir,"aoi1_2004_west_utm.tif")
))

#################### CLEAN TMP FILES
system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_aoi1_2004_*.tif")
))


#################### GRAB COORDINATES OF 6 GCP : initial and arrival
### WEST AGAINST EAST
v1 <- c(665310.8,900027.9,665336.1,900014.5)
v2 <- c(664862.7,908601.0,664878.9,908584.8)
v3 <- c(664580.4,909857.5,664592.7,909845.1)
v4 <- c(664666.4,897070.8,664673.4,897057.3)
v5 <- c(664593.7,892568.4,664581.0,892572.6)
v6 <- c(665292.9,909203.1,665308.1,909190.2)

### WEST 2004 AGAINST SPOT 2016
v1 <- c(658521.8,899480.1,658542.7,899474.7)
v2 <- c(654867.1,905720.3,654881.9,905723.6)
v3 <- c(661263.7,911848.8,661284.9,911836.9)
v4 <- c(663856.0,905913.1,663873.0,905909.3)
v5 <- c(665309.9,900033.7,665338.4,900027.4)
v6 <- c(664139.8,898281.1,664164.5,898272.5)

### From Naila West to Spot
v7 <- c(658826.6,904147.7,658841.1,904147.7)
v8 <- c(659942.9,905677.8,659962.8,905677.8)
v9<- c(660770.8,905418.4,660789.1,905421.8)
v10 <- c(660550.4,904111.8,660566.8,904113.7)
v11 <- c(660267.5,903875.4,660290.4,903878.9)
v12 <- c(660614.8,904031.2,660635.4,904029.3)

### From Yelena (west against spot)
v1 <- c(662166.4,901492.0,662190.5,901488.5)
v2 <- c(662154.0,900960.3,662176.1,900956.5) 
v3 <- c(663575.2,906863.3,663594.2,906855.3)




#################### Check that the GCP points are correct
all_v <- rbind(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10)
shift_x <- all_v[,1]-all_v[,3]
shift_y <- all_v[,2]-all_v[,4]
plot(shift_x,shift_y)

dev.off()
par(mfrow = c(5,4))
par(mar=c(0,0,0,0))

#################### Plot each GCP pair point in a 100m square box
for(i in 1:10){
  v <- all_v[i,]
  lp <- list()
  
  e<-extent((v[1]+v[3])/2-50,
            (v[1]+v[3])/2+50,
            (v[2]+v[4])/2-50,
            (v[2]+v[4])/2+50)
  
  poly <- Polygons(list(Polygon(cbind(
    c(e@xmin,e@xmin,e@xmax,e@xmax,e@xmin),
    c(e@ymin,e@ymax,e@ymax,e@ymin,e@ymin))
  )),"box")
  
  lp <- append(lp,list(poly))
  
  ## Transform the list into a SPDF PRIMER ERROR
  box <-SpatialPolygonsDataFrame(
    SpatialPolygons(lp,1:length(lp)), 
    data.frame("box"), 
    match.ID = F
  )
  
  rasname <- paste0(procimgdir,"aoi1_2004_west_utm.tif")
  nir <- crop(raster(rasname,4),box)
  grn <- crop(raster(rasname,2),box)
  red <- crop(raster(rasname,1),box)
  
  stack <- stack(nir,red,grn)
  
  plot(box)
  plotRGB(stack,stretch="hist",add=T)
  points(v[1],v[2],col="yellow")
  points(v[3],v[4],col="green")
  
  rasname <- paste0(procimgdir,"aoi1_2016_spot.TIF")
  nir <- crop(raster(rasname,4),box)
  grn <- crop(raster(rasname,2),box)
  red <- crop(raster(rasname,1),box)
  
  stack <- stack(nir,red,grn)
  
  plot(box)
  plotRGB(stack,stretch="hist",add=T)
  points(v[1],v[2],col="yellow")
  points(v[3],v[4],col="green")
}

#################### COMPUTE LOCAL COORDINATES OF ORIGIN POINTS
system(sprintf("(echo %s;echo %s;echo %s;echo %s;echo %s;echo %s;echo %s;echo %s;echo %s;echo %s) | gdaltransform -i %s > %s",
               paste(v1[1],v1[2],sep=" "),
               paste(v2[1],v2[2],sep=" "),
               paste(v3[1],v3[2],sep=" "),
               paste(v4[1],v4[2],sep=" "),
               paste(v5[1],v5[2],sep=" "),
               paste(v6[1],v6[2],sep=" "),
               paste(v7[1],v7[2],sep=" "),
               paste(v8[1],v8[2],sep=" "),
               paste(v9[1],v9[2],sep=" "),
               paste(v10[1],v10[2],sep=" "),
               paste0(procimgdir,"aoi1_2004_west_utm.tif"),
               paste0(procimgdir,"coord_west_to_spot.txt")
))

local <- read.table(paste0(procimgdir,"coord_west_to_spot.txt"))

#################### TRANSLATE ORIGIN IMG
system(sprintf("gdal_translate -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s   %s %s",
               local[1,1],local[1,2],v1[3],v1[4],
               local[2,1],local[2,2],v2[3],v2[4],
               local[3,1],local[3,2],v3[3],v3[4],
               local[4,1],local[4,2],v4[3],v4[4],
               local[5,1],local[5,2],v5[3],v5[4],
               local[6,1],local[6,2],v6[3],v6[4],
               local[7,1],local[7,2],v7[3],v7[4],
               local[8,1],local[8,2],v8[3],v8[4],
               local[9,1],local[9,2],v9[3],v9[4],
               local[10,1],local[10,2],v10[3],v10[4],
               paste0(procimgdir,"aoi1_2004_west_utm.tif"),
               paste0(procimgdir,"tmp_aoi1_2004_west_utm_shift.tif")
))

#################### FINAL REWARP
system(sprintf("gdalwarp -r bilinear -t_srs EPSG:32633 %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_west_utm_shift.tif"),
               paste0(procimgdir,"aoi1_2004_west_utm_shift.tif")))



### EAST 2004 AGAINST SPOT 2016
v1 <- c(667796.4,911538.7,667798.4,911545.1)
v2 <- c(666167.6,902519.4,666174.5,902526.8)
v3 <- c(665332.5,900019.8,665338.3,900027.1)
v4 <- c(674294.6,902036.4,674298.1,902050.4)
v5 <- c(673029.4,899582.2,673030.5,899598.0)
v6 <- c(668803.0,897141.2,668809.0,897152.2)

#################### Check that the GCP points are correct
all_v <- rbind(v1,v2,v3,v4,v5,v6)
shift_x <- all_v[,1]-all_v[,3]
shift_y <- all_v[,2]-all_v[,4]
plot(shift_x,shift_y)

dev.off()
par(mfrow = c(3,4))
par(mar=c(0,0,0,0))

#################### Plot each GCP pair point in a 100m square box
for(i in 1:6){
  v <- all_v[i,]
  lp <- list()
  
  e<-extent((v[1]+v[3])/2-50,
            (v[1]+v[3])/2+50,
            (v[2]+v[4])/2-50,
            (v[2]+v[4])/2+50)
  
  poly <- Polygons(list(Polygon(cbind(
    c(e@xmin,e@xmin,e@xmax,e@xmax,e@xmin),
    c(e@ymin,e@ymax,e@ymax,e@ymin,e@ymin))
  )),"box")
  
  lp <- append(lp,list(poly))
  
  ## Transform the list into a SPDF
  box <-SpatialPolygonsDataFrame(
    SpatialPolygons(lp,1:length(lp)), 
    data.frame("box"), 
    match.ID = F
  )
  
  rasname <- paste0(procimgdir,"aoi1_2004_east_utm.tif")
  nir <- crop(raster(rasname,4),box)
  grn <- crop(raster(rasname,2),box)
  red <- crop(raster(rasname,1),box)
  
  stack <- stack(nir,red,grn)
  
  plot(box)
  plotRGB(stack,stretch="hist",add=T)
  points(v[1],v[2],col="yellow")
  points(v[3],v[4],col="green")
  
  rasname <- paste0(procimgdir,"aoi1_2016_spot.TIF")
  nir <- crop(raster(rasname,4),box)
  grn <- crop(raster(rasname,2),box)
  red <- crop(raster(rasname,1),box)
  
  stack <- stack(nir,red,grn)
  
  plot(box)
  plotRGB(stack,stretch="hist",add=T)
  points(v[1],v[2],col="yellow")
  points(v[3],v[4],col="green")
}

#################### COMPUTE LOCAL COORDINATES OF ORIGIN POINTS
system(sprintf("(echo %s;echo %s;echo %s;echo %s;echo %s;echo %s) | gdaltransform -i %s > %s",
               paste(v1[1],v1[2],sep=" "),
               paste(v2[1],v2[2],sep=" "),
               paste(v3[1],v3[2],sep=" "),
               paste(v4[1],v4[2],sep=" "),
               paste(v5[1],v5[2],sep=" "),
               paste(v6[1],v6[2],sep=" "),
               paste0(procimgdir,"aoi1_2004_east_utm.tif"),
               paste0(procimgdir,"coord_east_to_spot.txt")
))

local <- read.table(paste0(procimgdir,"coord_east_to_spot.txt"))

#################### TRANSLATE ORIGIN IMG
system(sprintf("gdal_translate -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s -gcp %s %s %s %s   %s %s",
               local[1,1],local[1,2],v1[3],v1[4],
               local[2,1],local[2,2],v2[3],v2[4],
               local[3,1],local[3,2],v3[3],v3[4],
               local[4,1],local[4,2],v4[3],v4[4],
               local[5,1],local[5,2],v5[3],v5[4],
               local[6,1],local[6,2],v6[3],v6[4],
               paste0(procimgdir,"aoi1_2004_east_utm.tif"),
               paste0(procimgdir,"tmp_aoi1_2004_east_utm_shift.tif")
))

#################### FINAL REWARP
system(sprintf("gdalwarp -r bilinear -t_srs EPSG:32633 %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_east_utm_shift.tif"),
               paste0(procimgdir,"aoi1_2004_east_utm_shift.tif")))

system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_aoi1_2004_*.tif")
))

#################### MERGE SHIFTED WEST AND EAST
system(sprintf("gdal_merge.py -o %s -n 0 -co COMPRESS=LZW -co BIGTIFF=YES -v %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_merge.tif"),
               paste0(procimgdir,"aoi1_2004_west_utm_shift.tif"),
               paste0(procimgdir,"aoi1_2004_east_utm_shift.tif")
))

#################### COMPRESS - MERGE
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
               paste0(procimgdir,"tmp_aoi1_2004_merge.tif"),
               paste0(procimgdir,"aoi1_2004_merge.tif")
))