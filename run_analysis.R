#Part1
#First we download the zipped folder in a folder called "Project" in the working directory. 
if(!file.exists("./Project")){dir.create("./Project")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./Project/Dataset.zip")

#We unzip the zipped folder.
unzip(zipfile="./Project/Dataset.zip",exdir="./Project/Data")

#Unzipped files are in the folder "UCI HAR Dataset" in the directory "./Project/Data/"
path_data <- file.path("./Project/Data", "UCI HAR Dataset")
list.files(path_data, recursive=TRUE)

#Now we combine the test and train datasets into one file for x, y and Subject each respectively.

yTest  <- read.table(file.path(path_data, "test" , "Y_test.txt" ),header = FALSE)
yTrain <- read.table(file.path(path_data, "train", "Y_train.txt"),header = FALSE)

Subject <- rbind(SubjectTest, SubjectTrain)
x <- rbind(xTest, xTrain)
y <- rbind(yTest, yTrain)

#sET names to variables(head(FeaturesName) to choose the correct column)
names(Subject)<-c("subject")
names(y)<- c("activity")
FeaturesNames <- read.table(file.path(path_data, "features.txt"),head=FALSE)
names(x) <- FeaturesNames$V2

#Creating the single Data Frame "Data"
DataCombine <- cbind(Subject, y)
Data <- cbind(x, DataCombine)



#Part2
#Extracting only the measurements on the mean and standard deviation for each measurement. 
MeanDevFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
selectedNames<-c(as.character(MeanDevFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)


#Part3
#Use the descriptive activity names to name the activity names in Data.
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"),header = FALSE)
Data$activity<-factor(Data$activity);
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))


#Part4
#Label Data with descriptive variable names.
#- prefix t  is replaced by  time
#- Acc is replaced by Accelerometer
#- Gyro is replaced by Gyroscope
#- prefix f is replaced by frequency
#- Mag is replaced by Magnitude
#- BodyBody is replaced by Body
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


#Part5
#In this part,a second, independent tidy data set will be created with the average 
#of each variable for each activity and each subject  based on the data set in step 4. 
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "./Project/tidydata.txt",row.names=FALSE, sep = "\t")

