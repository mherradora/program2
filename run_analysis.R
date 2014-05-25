library(data.table)
library(reshape)
library(Hmisc)

#####
# Verify the existance of the folder
if(!file.exists("./data")){dir.create("./data")}

# The file to download
theF1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download the file and asign the name data.zip
download.file(theF1,"./data/data.zip",method="wget")

# Unzip the file
unzip("./data/data.zip",exdir="./data")

#####
#  Generate the list of files
# filelist <- dir("./data", recursive = TRUE, all.files = TRUE, full.names = TRUE)

#####
# Read the features file
features <- read.table("./data/UCI HAR Dataset/features.txt", quote="\"",as.is=T)

names(features) <- c("col","feature")
#####
# Eliminate the punctuation elements in the possible names of the variables

features$var.name <- features$feature

toDel <- c("\\(","\\)","\\-")
toInc <- c("","","_")

for(i in 1:length(toDel)){
  features$var.name <- gsub(toDel[i],toInc[i],features$var.name)
}

features$var.valid <- grepl("mean\\(",features$feature) | grepl("std\\(",features$feature)

features$var.class <- ifelse(features$var.valid,"numeric","NULL")

validVars <- features[features$var.valid,"var.name"]

#####
# Read the test set
data.test <- read.table("./data/UCI HAR Dataset/test/X_test.txt",
                      quote="\"",
                      as.is=T,
                      colClasses=features$var.class)

names(data.test) <- validVars

#####
# Read the training set
data.train <- read.table("./data/UCI HAR Dataset/train/X_train.txt",
                        quote="\"",
                        as.is=T,
                        colClasses=features$var.class)

#####
# Put names to data.train variables with the validVars
names(data.train) <- validVars

#####
# Read the information of the lables for train and test sets
test.labels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", quote="\"",as.is=T)
train.labels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", quote="\"",as.is=T)

#####
# Put names to the variables
names(test.labels) <- "labels"
names(train.labels) <- "labels"

#####
# Read the information of the subjects for train and test sets
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", quote="\"",as.is=T)
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", quote="\"",as.is=T)

#####
# Put names to the variables
names(subject_test) <- "subject"
names(subject_train) <- "subject"

#####
# Join the test features with the labels and the subjects
data.test <- cbind(test.labels,subject_test,data.test)

#####
# Join the train features with the labels and the subjects
data.train <- cbind(train.labels,subject_train,data.train)

#####
# Join the test and the train sets
data <- rbind(data.test,data.train)

#####
# Read the file with the activity labels
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", quote="\"",as.is=T)

#####
# Put names to the variables of the activity labels data.frame
names(activity_labels) <- c("levels","labels")

#####
# Transform the labels variable to factor with the information of the activity labels
data$labels <- factor(data$labels,
                      levels=activity_labels$levels,
                      labels=activity_labels$labels)

#####
# Transform the data.frame into a data.table
data <- data.table(data)

#####
# Melt the data 
tmp.data <- melt(data,id.vars=c("labels","subject"))

#####
# Cast the data to obtain the tiny.data
tiny.data <- dcast.data.table(tmp.data,labels+subject~variable,fun=mean)

#####
# Save the tiny.data in a file
write.csv(tiny.data,"tiny.data.csv")
