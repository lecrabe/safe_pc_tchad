####################################################################################
####### Object:  Merge results from classification and assign change value
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2016/11/08                                          
####################################################################################

merge_start_time <- Sys.time()


################################################################################
## Compute time 2 classification value on each segment
system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
               t2_file_m,
               t2_cl_st,
               segs_id,
               nbclass
))

################################################################################
## Compute time 1 classification distribution on each segment
system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
               t1_file_m,
               t1_cl_st,
               segs_id,
               nbclass
               ))

################################################################################
## Compute IMAD change values on each segment
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               imad,
               im_cl_st,
               segs_id))

################################################################################
## Create one data file with all info
df_t2 <- read.table(t2_cl_st)
df_t1 <- read.table(t1_cl_st)
df_im <- read.table(im_cl_st)

names(df_t2) <- c("sg_id",paste0("t2_",c("total","no_data",legend$class)))
names(df_im) <- c("sg_id","sg_sz",paste0("imad",1:nbbands))
names(df_t1) <- c("sg_id",paste0("t1_",c("total","no_data",legend$class)))

head(df_t2)
head(df_t1)
head(df_im)

summary(df_t1$t1_total - rowSums(df_t1[,paste0("t1_",c("no_data",legend$class))]))

df <- df_t2

df$sortid <- row(df)[,1]

df <- merge(df,df_im,by.x="sg_id",by.y="sg_id")
df <- merge(df,df_t1,by.x="sg_id",by.y="sg_id")

#df <- merge(df,legend,by.x="t2_class",by.y="value")
head(df)
#table(df$class,df$t2_class)

################################################################################
## Determine criterias for change 

## Take out the columns that don't have any pixels coded
df1 <- df[,colSums(df[,!(names(df) %in% names(legend))]) != 0]

## Check sizes of segments
summary(df1$t1_total)

## Create list of classes that have some fuelwood biomass in them
fuelwood_classes <- legend[c(grep(pattern="forest",legend$class),
                             grep(pattern="shadow",legend$class)
                             ),]$class

(my_fuelwood_classes_t2 <- names(df1)[names(df1) %in% paste0("t2_",fuelwood_classes)])

(my_fuelwood_classes_t1 <- names(df1)[names(df1) %in% paste0("t1_",fuelwood_classes)])

head(df1)
## Create a new reclass column: 1==Fuelwood loss, 2==Fuelwood stable, 3==the rest, 4==Fuelwood Gains

### By default it is all "other land"
df1$recl <- 3

### No data
tryCatch({
  df1[
    df1$t1_no_data > 0.5 * df1$t1_total |
    df1$t2_no_data > 0.5 * df1$t2_total ,
    ]$recl <- 0
}, error=function(e){cat("No such configuration\n")}
)

## Fuelwood stable is if it was majority of Fuelwood in both time periods
tryCatch({
  df1[
      df1$t2_total > 5 &                                 # size is bigger than 10 pixels (1 pixel = 0.6m*0.6m = 0.36 m2)
      rowSums(as.data.frame(df1[,my_fuelwood_classes_t2])) > 0.9*df1$t2_total &  # time 2 classification says more than 90% fuelwood
      rowSums(as.data.frame(df1[,my_fuelwood_classes_t1])) > 0.9*df1$t1_total ,  # time 1 classification says more than 90% fuelwood
    ]$recl <- 2
}, error=function(e){cat("No such configuration\n")}
)

## Fuelwood loss is if it was majority of Fuelwood in t1 and other than water in t2
tryCatch({
  df1[
    df1$t2_total > 5 &                                # size is bigger than 10 pixels (1 pixel = 1.5m*1.5m = 2.25 m2)
      rowSums(as.data.frame(df1[,my_fuelwood_classes_t2])) < 0.2*df1$t2_total &  # time 2 classification says less than 10% fuelwood
      rowSums(as.data.frame(df1[,my_fuelwood_classes_t1])) > 0.9*df1$t1_total &  # time 1 classification says more than 90% fuelwood
      abs(df1$imad4) > 0.2                              # IMAD indicates some change is occuring
    ,]$recl <- 1
}, error=function(e){cat("No such configuration\n")}
)

## Fuelwood gains is if it was majority of Fuelwood in period 2 only
tryCatch({
  df1[
    df1$t2_total > 10 &                                  # size is bigger than 10 pixels (1 pixel = 1.5m*1.5m = 2.25 m2)
      rowSums(as.data.frame(df1[,my_fuelwood_classes_t2])) > 0.9*df1$t2_total &  # time 2 classification says more than 90% fuelwood
      rowSums(as.data.frame(df1[,my_fuelwood_classes_t1])) < 0.2*df1$t1_total &  # time 1 classification says less than 10% fuelwood
      abs(df1$imad4) > 0.5 ,
    ]$recl <- 4
}, error=function(e){cat("Configuration impossible \n")}
)


## Resort in the same order as it was when read. 
df2 <- arrange(df1,sortid)
table(df2$recl)

## Export as data table
write.table(file=reclass,df2[,c("sg_id","recl")],sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)

## Reclass the raster with the change values
system(sprintf("(echo %s; echo 1; echo 1; echo 2; echo 0) | oft-reclass -oi  %s %s",
               reclass,
               paste0(mergedir,"/","tmp_reclass.tif"),
               segs_id
               ))

####################  CREATE A PSEUDO COLOR TABLE
cols <- col2rgb(c("red","darkgreen","grey","lightgreen"))

pct <- data.frame(cbind(c(1:4),
                        cols[1,],
                        cols[2,],
                        cols[3,]
))

write.table(pct,paste0(mergedir,"/color_table.txt"),row.names = F,col.names = F,quote = F)


################################################################################
## Add pseudo color table to result
system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(mergedir,"/","tmp_reclass.tif"),
               paste0(mergedir,"/","tmp_reclass_byte.tif")
))

system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(mergedir,"/color_table.txt"),
               paste0(mergedir,"/","tmp_reclass_byte.tif"),
               paste0(mergedir,"/","tmp_pct_reclass.tif")
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(mergedir,"/","tmp_pct_reclass.tif"),
               chg_class
               ))

system(sprintf(paste0("rm ",mergedir,"/","tmp*.tif")))

#df2[df2$sg_id == 6343080,]

(merge_time <- Sys.time() - merge_start_time )
