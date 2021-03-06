####################################################################################
####### Object:  Run supervised classification                 
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2016/10/31                                           
####################################################################################

classification_start <- Sys.time()

####################################################################################################################
########### Extract spectral signature from the imagery 
####################################################################################################################
## Extract spectral signature of the image on the segments of the whole image  --> the observations
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               im_input,
               img_sg_st,
               all_sg_id))

## Extract spectral signature of the image on the training polygons ids --> the training data spectral info
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               im_input,
               img_tr_st,
               sel_sg_id))

## Extract values of the training data on the training polygons ids --> the training data class info
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               sel_sg_train,
               tra_tr_st,
               sel_sg_id))

####################################################################################################################
########### Supervised classification using Random Forest algorithm
####################################################################################################################

### read data 
img_segs_spec <- read.table(img_sg_st)
img_trng_spec <- read.table(img_tr_st)
trainer_class <- read.table(tra_tr_st)

nband <- (ncol(img_segs_spec)-2)

names(img_segs_spec) <- c("sg_id","sg_sz",paste0("b",1:nband))
names(img_trng_spec) <- c("tr_id","tr_sz",paste0("b",1:nband))
names(trainer_class) <- c("tr_id","tr_sz","tr_code")

table(trainer_class$tr_code)

################### Get training data
training <- merge(img_trng_spec,trainer_class)

training <- training[training$tr_code != 0 ,c("tr_code",paste0("b",1:nband))]

training <- training[rowSums(training[,c(paste0("b",1:nband))])!=0,]

# Ratios : take them all for the training set
training$rat43<-(training$b4+0.5)/(training$b3+0.5);
training$rat42<-(training$b4+0.5)/(training$b2+0.5);
training$rat41<-(training$b4+0.5)/(training$b1+0.5);
training$rat32<-(training$b3+0.5)/(training$b2+0.5);
training$rat31<-(training$b3+0.5)/(training$b1+0.5);
training$rat21<-(training$b2+0.5)/(training$b1+0.5);

# Ratios : take them all for the observation set
img_segs_spec$rat43<-(img_segs_spec$b4+0.5)/(img_segs_spec$b3+0.5);
img_segs_spec$rat42<-(img_segs_spec$b4+0.5)/(img_segs_spec$b2+0.5);
img_segs_spec$rat41<-(img_segs_spec$b4+0.5)/(img_segs_spec$b1+0.5);
img_segs_spec$rat32<-(img_segs_spec$b3+0.5)/(img_segs_spec$b2+0.5);
img_segs_spec$rat31<-(img_segs_spec$b3+0.5)/(img_segs_spec$b1+0.5);
img_segs_spec$rat21<-(img_segs_spec$b2+0.5)/(img_segs_spec$b1+0.5);

nb_class <- length(levels(as.factor(training$tr_code)))
print("training is read and ratio are calculated, reading data....")


### Run the classification model
fit <- randomForest(as.factor(tr_code) ~ . ,ntree=400, mtry=6, data=training)
importance(fit)

results       <- predict(fit,img_segs_spec,keep.forest=TRUE)
resultsWithId <- data.frame(img_segs_spec[,1] , results , as.is=TRUE)
res_all       <- resultsWithId[,c(1,2)]

write.table(file=img_clas,res_all,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)



########################################
## Reclass the selected polygons cluster
system(sprintf("(echo %s; echo 1; echo 1; echo 2; echo 0) | oft-reclass -oi  %s %s",
               img_clas,
               paste0(outdir,"/","tmp_reclass.tif"),
               all_sg_id))

########################################
## Create a initial data mask
system(sprintf("(echo 1; echo \"#1 #2 * #3 * \") | oft-calc -ot Byte %s %s",
               im_input,
               paste0(outdir,"/","tmp_mask.tif")))

########################################
## Apply data mask
system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=%s",
               paste0(outdir,"/","tmp_mask.tif"),
               paste0(outdir,"/","tmp_reclass.tif"),
               paste0(outdir,"/","tmp_reclass_masked.tif"),
               "\"(A>0)*B\""))


####################  CREATE A PSEUDO COLOR TABLE
cols <- col2rgb(c("black","darkgreen","lightyellow","yellow","darkgrey"))
colors()
pct <- data.frame(cbind(c(0:4),
                        cols[1,],
                        cols[2,],
                        cols[3,]
                        ))

write.table(pct,paste0(outdir,"/color_table.txt"),row.names = F,col.names = F,quote = F)


################################################################################
## Add pseudo color table to result
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(outdir,"/color_table.txt"),
               paste0(outdir,"/","tmp_reclass_masked.tif"),
               paste0(outdir,"/","tmp_pct_reclass_masked.tif")
))


########################################
## Compress final result
system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(outdir,"/","tmp_pct_reclass_masked.tif"),
               output_rf
))



########################################
## Clean all
system(sprintf(paste0("rm ",outdir,"/","tmp*.tif")))

rm(img_segs_spec)
rm(res_all)
rm(resultsWithId)
gc()

(classification_time <- Sys.time() - classification_start)

