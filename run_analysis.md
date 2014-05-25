CodeBook.md : Explanation of the variables, the data and the processes
========================================================

Explanation of the variables and the data
-------------------------

This part is a copy of the information in the features_info.txt file with some transformation taking in consideration that in this case we only use the mean and the standart deviation of each variable.

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

* tBodyAcc-XYZ
* tGravityAcc-XYZ
* tBodyAccJerk-XYZ
* tBodyGyro-XYZ
* tBodyGyroJerk-XYZ
* tBodyAccMag
* tGravityAccMag
* tBodyAccJerkMag
* tBodyGyroMag
* tBodyGyroJerkMag
* fBodyAcc-XYZ
* fBodyAccJerk-XYZ
* fBodyGyro-XYZ
* fBodyAccMag
* fBodyAccJerkMag
* fBodyGyroMag
* fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 

* mean(): Mean value
* std(): Standard deviation

Explanation of the processes
-------------------------

For the cleaning of this data we use the following libraries:

```{r}
require(data.table)
require(reshape)
require(Hmisc)
```

### Download and unzip the raw data

Download the raw data if it not exists in the working folder. After that, the script unzip the data.

```{r}
# Verify the existance of the folder
if(!file.exists("./data")){dir.create("./data")}

# The file to download
theF1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download the file and asign the name data.zip
download.file(theF1,"./data/data.zip",method="wget")

# Unzip the file
unzip("./data/data.zip",exdir="./data")
```

### Process the features file
In this file we created the names of the final variables and filter the valid variables. At the same time we give some format to the name of the variables.

```{r}
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

#####
# Create a logic variable for the features of interest
features$var.valid <- grepl("mean\\(",features$feature) | grepl("std\\(",features$feature)

#####
# Create a variable with the class of the valid variables
features$var.class <- ifelse(features$var.valid,"numeric","NULL")

####
# List with the names of the valid variables 
validVars <- features[features$var.valid,"var.name"]
```

### Read the test and the train sets

Read the files of the test and train set selecting the variables of mean and standart deviation

```{r}
#####
# Read the test set
data.test <- read.table("./data/UCI HAR Dataset/test/X_test.txt",
                      quote="\"",
                      as.is=T,
                      colClasses=features$var.class)

#####
# Put names to data.test variables with the validVars
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
```

### Loading the labels

Loading the information of the activities to insert like a column in the row data set

```{r}
#####
# Read the information of the labels for train and test sets
test.labels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", quote="\"",as.is=T)
train.labels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", quote="\"",as.is=T)

#####
# Put names to the variables
names(test.labels) <- "labels"
names(train.labels) <- "labels"
```

### Loading the subject

Loading the information of the subjects to insert like a column in the row data set

```{r}
#####
# Read the information of the subjects for train and test sets
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", quote="\"",as.is=T)
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", quote="\"",as.is=T)

#####
# Put names to the variables
names(subject_test) <- "subject"
names(subject_train) <- "subject"
```

### Join the elements

With the objetive to obtain the tidy data, this part of the script join activity labels, the subjets and the raw data. Firts for each set apart and finally merge both sets.

```{r}
#####
# Join the test features with the labels and the subjects
data.test <- cbind(test.labels,subject_test,data.test)

#####
# Join the train features with the labels and the subjects
data.train <- cbind(train.labels,subject_train,data.train)

#####
# Join the test and the train sets
data <- rbind(data.test,data.train)
```

### Labelling the activities

This part of the script load the information of the activity labels and transform the labels variable in a factor with the appropriate labels and levels

```{r}
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

```

### Reshaping the data

To obtain the tidy data, the script implements a reshape of the raw data

```{r}
#####
# Transform the data.frame into a data.table
data <- data.table(data)

#####
# Melt the data 
tmp.data <- melt(data,id.vars=c("labels","subject"))

#####
# Cast the data to obtain the tiny.data
tiny.data <- dcast.data.table(tmp.data,labels+subject~variable,fun=mean)
```

### Save the tidy data

To share the information obtained the script save the tidy data like a csv file

```{r}
#####
# Save the tiny.data in a file
write.csv(tiny.data,"tiny.data.csv")
```
