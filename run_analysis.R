library(magrittr)

#download and save the file
if(!file.exists("./data")){dir.create("/data")}
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile = "./data/data.zip")

#unzip the file
unzip(zipfile = "./data/data.zip",exdir = "./data")

#quick look at the unzipped files
data_path<-file.path("./data","UCI HAR Dataset")
list.files(data_path,recursive = TRUE)

setwd("~/R")

#read activity files
actTestData<-read.table(file.path(data_path,"test","Y_test.txt"),
                        header=FALSE)
actTrainData<-read.table(file.path(data_path,"train","Y_train.txt"),
                         header=FALSE)

#read training files
subjectTrainData<-read.table(file.path(data_path,"train",
"subject_train.txt"),header=FALSE)
subjectTestData<-read.table(file.path(data_path,"test",
"subject_test.txt"),header=FALSE)

#read feature files
featureTestData<-read.table(file.path(data_path,"test","X_test.txt"),
                        header=FALSE)
featureTrainData<-read.table(file.path(data_path,"train","X_train.txt"),
                         header=FALSE)


####################################################################
#1:Merges the training and the test sets to create one data set
####################################################################

#Concatenate the data tables by rows
activityData<-rbind(actTestData,actTrainData)
subjectData<-rbind(subjectTrainData,subjectTestData)
featureData<-rbind(featureTestData,featureTrainData)

#create names to variables
names(activityData)<-c("activity")
names(subjectData)<-c("subject")
featureNames<-read.table(file.path(data_path, "features.txt"),
                         head=FALSE)
names(featureData)<-featureNames$V2

#Merge all data frames
data<- activityData %>% cbind(subjectData) %>% cbind(featureData)

####################################################################
#2:Extracts only the measurements on the mean and standard deviation 
#for each measurement.
####################################################################

#Subset Name of Features by measurements on the mean and 
#standard deviation
subdataFeatureNames<-featureNames$V2[grep("mean\\(\\)|std\\(\\)",
                      featureNames$V2)]
#Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeatureNames), 
                 "subject", "activity" )
data<-subset(data,select=selectedNames)

#########################################################################
#3:Uses descriptive activity names to name the activities in the data set
#########################################################################

activityLabels <- read.table(file.path(data_path,
                  "activity_labels.txt"),header = FALSE)
data$activity<- factor(data$activity,
                       labels=as.character(activityLabels$V2))

#########################################################################
#4:Appropriately labels the data set with descriptive variable names
#########################################################################

names(data)<-gsub("^t","Time",names(data))
names(data)<-gsub("^f","feature",names(data))
names(data)<-gsub("Acc","Accelerometer",names(data))
names(data)<-gsub("Gyro","Gyroscope",names(data))
names(data)<-gsub("Mag","Magnitude",names(data))
names(data)<-gsub("Bodybody","Body",names(data))

#########################################################################
#5:From the data set in step 4, creates a second, independent tidy data
#set with the average of each variable for each activity and each subject.
#########################################################################

library(plyr);
data2<-aggregate(. ~subject + activity, data, mean)
data2<-data2[order(data2$subject,data2$activity),]
write.table(data2, file = "tidydata.txt",row.name=FALSE)

