# To manipulate the data, use library "reshape2", "dplyr"
library(reshape2)
library(dplyr)
library(plyr)

# Unzip the dataset
unzip("getdata_dataset.zip") 

# Read activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("activity_id","activity_nm"))
str(activity_labels)
activity_labels[,2] <- as.character(activity_labels[,2])
str(activity_labels)

# Read features
features <- read.table("UCI HAR Dataset/features.txt")
str(features)
features[,2] <- as.character(features[,2])
str(features)

# Extract only mean and std
features_use <- grep(".*mean.*|.*std.*", features[,2])
features_use_nm <- features[features_use,2]
?grep

# Load train dataset and bind
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_use]
colnames(train) <- features_use_nm
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_all <- cbind(train_subjects, train_activities, train)

# Load test dataset and bind
test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_use]
colnames(test) <- features_use_nm
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_all <- cbind(test_subjects, test_activities, test)

# merge train and test dataset, and rename column_name
master_all <- rbind(train_all, test_all)
colnames(master_all) <- c("subject_id", "activity_nm", features_use_nm)

# turn activity_nm & subject_id into factors
str(master_all)
master_all$subject_id <- as.factor(master_all$subject_id)
master_all$activity_nm <- factor(master_all$activity_nm, levels = activity_labels[,1], labels = activity_labels[,2])
str(master_all)

# Use melt fuction and dcast
melted_all <- melt(master_all, id = c("subject_id", "activity_nm"))
mean_all <- dcast(melted_all, subject_id + activity_nm ~ variable, mean)
str(mean_all)

# Write the data
write.table(mean_all, "tidy_data.txt", row.names = FALSE)
