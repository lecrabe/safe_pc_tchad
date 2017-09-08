####################################################################################
####### Object:  Shift imagery  by vectorial lines              
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/09/04                                     
####################################################################################

##########################################################################################
#### Shift is VISUALLY ASSESSED (GCP in QGIS)

aoi <- "aoi2"

#################### READ SHIFT FILE AS SHAPEFILE
shp_shift    <- readOGR(paste0(shift_dir,"gcp_lines_aoi2.shp"),"gcp_lines_aoi2")
im_reference <- paste0(procimgdir,aoi,"_2016_spot_utm.tif")

#################### Loop through blocks of image
for(tile in 1:4){
  
  im_to_shift <- paste0(procimgdir,aoi,"_2004_tile",tile,"_utm.tif")
  im_shifted  <- paste0(procimgdir,aoi,"_2004_tile",tile,"_utm_shift.tif")
  
  ### Select only shifts for that block
  shift  <- shp_shift[shp_shift@data$tile == tile,]
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
  size_box <- max(shift_x,shift_y)+5
  

  #################### Find a display for 2 times the number of available vectors
  p <- primeFactors(nb_vec*2)
  p <- sample(p)
  lines <- prod(p[1:floor(length(p)/2)])
  cols  <- prod(p[(floor(length(p)/2)+1):length(p)])
  c(lines,cols)

  dev.off()
  par(mfrow = c(lines,cols))
  par(mar=c(0,0,0,0))
  
  #################### Plot each GCP pair point in a 100m square box
  for(i in 1:nb_vec){
    lp <- list()

    e<-extent((v[i,1]+v[i,3])/2-size_box/2 ,
              (v[i,1]+v[i,3])/2+size_box/2,
              (v[i,2]+v[i,4])/2-size_box/2,
              (v[i,2]+v[i,4])/2+size_box/2)

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

    rasname <- im_to_shift
    nir <- crop(raster(rasname,4),box)
    grn <- crop(raster(rasname,2),box)
    red <- crop(raster(rasname,1),box)

    stack <- stack(nir,red,grn)

    plot(box)
    plotRGB(stack,stretch="hist",add=T)
    points(v[i,1],v[i,2],col="yellow")
    points(v[i,3],v[i,4],col="green")

    rasname <- im_reference
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
                 im_to_shift,
                 paste0(procimgdir,"coord_",aoi,"_tile_",tile,"_to_shift.txt")
  ))

  local <- read.table(paste0(procimgdir,"coord_",aoi,"_tile_",tile,"_to_shift.txt"))

  #################### Generate gdal_translate equation from all local initial points to final points
  equ_2 <- paste("-gcp",
                 lapply(1:nb_vec,function(i){paste(local[i,1],local[i,2],v[i,3],v[i,4],sep=" ")}),
                 collapse = " "
  )

  #################### TRANSLATE ORIGIN IMG
  system(sprintf("gdal_translate %s %s %s",
                 equ_2,
                 im_to_shift,
                 paste0(procimgdir,"tmp_",aoi,"_tile_",tile,"_shift.tif")
  ))
  
  #################### FINAL REWARP
  system(sprintf("gdalwarp -r bilinear -t_srs EPSG:32633 %s %s",
                 paste0(procimgdir,"tmp_",aoi,"_tile_",tile,"_shift.tif"),
                 im_shifted 
                 ))
  
}

#################### Clean
system(sprintf("rm -r %s",
               paste0(procimgdir,"tmp_aoi1_2004_*.tif")
))
