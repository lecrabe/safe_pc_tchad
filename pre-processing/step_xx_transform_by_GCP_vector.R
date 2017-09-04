####################################################################################
####### Object:  Shift imagery  by vectorial lines              
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/09/04                                     
####################################################################################

##########################################################################################
#### Shift is VISUALLY ASSESSED (GCP in QGIS)

# #################### DETERMINE DATASET DIR FOR EACH SAME DATE ACQUISITIONS
# qb04_east_dir  <- paste0(rawimgdir,"GSI_MDA/056880814010_01/056880814010_01_P001_PSH/")
# qb04_west_dir  <- paste0(rawimgdir,"GSI_MDA/056880814010_01/056880814010_01_P002_PSH/")
# 
# #################### MERGE SAME DATES ACQUISITIONS INTO MOSAICS
# system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
#                paste0(procimgdir,"tmp_aoi1_2004_east.tif"),
#                paste0(qb04_east_dir,"*.TIF")
# ))
# 
# #################### COMPRESS - EAST
# system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
#                paste0(procimgdir,"tmp_aoi1_2004_east.tif"),
#                paste0(procimgdir,"aoi1_2004_east.tif")
# ))
# 
# #################### REPROJECT IN UTM - EAST
# system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
#                paste0(procimgdir,"aoi1_2004_east.tif"),
#                paste0(procimgdir,"aoi1_2004_east_utm.tif")
# ))
# 
# #################### MERGE SAME DATES ACQUISITIONS INTO MOSAICS - WEST
# system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW -co BIGTIFF=YES -v %s",
#                paste0(procimgdir,"tmp_aoi1_2004_west.tif"),
#                paste0(qb04_west_dir,"*.TIF")
# ))
# 
# #################### COMPRESS - WEST
# system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte -co BIGTIFF=YES %s %s",
#                paste0(procimgdir,"tmp_aoi1_2004_west.tif"),
#                paste0(procimgdir,"aoi1_2004_west.tif")
# ))
# 
# #################### REPROJECT IN UTM - WEST
# system(sprintf("gdalwarp -t_srs EPSG:32633 -co COMPRESS=LZW %s %s",
#                paste0(procimgdir,"aoi1_2004_west.tif"),
#                paste0(procimgdir,"aoi1_2004_west_utm.tif")
# ))
# 
# #################### CLEAN TMP FILES
# system(sprintf("rm -r %s",
#                paste0(procimgdir,"tmp_aoi1_2004_*.tif")
# ))

#################### READ SHIFT FILE AS SHAPEFILE
shp_shift <- readOGR(paste0(shift_dir,"GCP_lines.shp"),"GCP_lines")

##### Run for one block first, to check all runs fine
block <- "west"

#################### Loop through blocks of image
for(block in c("west","east")){
  
  ### Select only shifts for that block
  shift <- shp_shift[shp_shift@data$image == block,]
  nb_vec <- length(shift)

  ### Initialize shifting data.frame and translate shapefile into "origin >> destination" coordinates set
  v <- as.data.frame(matrix(nrow = 0,ncol=4))

  for(i in 1:nb_vec){
    line <- shift[i,]@lines[[1]]@Lines[[1]]@coords
    start_x <- line[1,1]
    start_y <- line[1,2]
    stop_x  <- line[2,1]
    stop_y  <- line[2,2]
    v <- rbind(v,c(start_x,start_y,stop_x,stop_y))
  }

  names(v) <- c("start_x","start_y","stop_x","stop_y")

  #################### Check that the GCP points are correct
  shift_x <- v[,1]-v[,3]
  shift_y <- v[,2]-v[,4]
  plot(shift_x,shift_y)

  #################### Find a display for 2 times the number of available vectors
  p <- primeFactors(nb_vec*2)
  lines <- prod(p[1:(length(p)-1)])
  cols  <- p[length(p)]

  dev.off()
  par(mfrow = c(lines,cols))
  par(mar=c(0,0,0,0))

  #################### Plot each GCP pair point in a 100m square box
  for(i in 1:nb_vec){
    lp <- list()

    e<-extent((v[i,1]+v[i,3])/2-50,
              (v[i,1]+v[i,3])/2+50,
              (v[i,2]+v[i,4])/2-50,
              (v[i,2]+v[i,4])/2+50)

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

    rasname <- paste0(procimgdir,"aoi1_2004_",block,"_utm.tif")
    nir <- crop(raster(rasname,4),box)
    grn <- crop(raster(rasname,2),box)
    red <- crop(raster(rasname,1),box)

    stack <- stack(nir,red,grn)

    plot(box)
    plotRGB(stack,stretch="hist",add=T)
    points(v[i,1],v[i,2],col="yellow")
    points(v[i,3],v[i,4],col="green")

    rasname <- paste0(procimgdir,"aoi1_2016_spot.TIF")
    nir <- crop(raster(rasname,4),box)
    grn <- crop(raster(rasname,2),box)
    red <- crop(raster(rasname,1),box)

    stack <- stack(nir,red,grn)

    plot(box)
    plotRGB(stack,stretch="hist",add=T)
    points(v[i,1],v[i,2],col="yellow")
    points(v[i,3],v[i,4],col="green")
  }

  #################### Generate gdaltransform equation from all initial points
  equ_1 <- paste0("(",
                  paste0(
                    lapply(1:nb_vec,function(i){paste("echo",v[i,1],v[i,2])}),
                    collapse = ";"),
                  ")"
  )

  #################### COMPUTE LOCAL COORDINATES OF ORIGIN POINTS
  system(sprintf("%s | gdaltransform -i %s > %s",
                 equ_1,
                 paste0(procimgdir,"aoi1_2004_",block,"_utm.tif"),
                 paste0(procimgdir,"coord_",block,"_to_spot.txt")
  ))

  local <- read.table(paste0(procimgdir,"coord_",block,"_to_spot.txt"))

  #################### Generate gdal_translate equation from all local initial points to final points
  equ_2 <- paste("-gcp",
                 lapply(1:nb_vec,function(i){paste(local[i,1],local[i,2],v[i,3],v[i,4],sep=" ")}),
                 collapse = " "
  )

  #################### TRANSLATE ORIGIN IMG
  system(sprintf("gdal_translate %s %s %s",
                 equ_2,
                 paste0(procimgdir,"aoi1_2004_",block,"_utm.tif"),
                 paste0(procimgdir,"tmp_aoi1_2004_",block,"_utm_shift.tif")
  ))
  
  #################### FINAL REWARP
  system(sprintf("gdalwarp -r bilinear -t_srs EPSG:32633 %s %s",
                 paste0(procimgdir,"tmp_aoi1_2004_",block,"_utm_shift.tif"),
                 paste0(procimgdir,"aoi1_2004_",block,"_utm_shift.tif")))
  
}

#################### Clean
system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_aoi1_2004_*.tif")
))
