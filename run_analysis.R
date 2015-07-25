setwd("~/Dropbox/Code/R/Getting and cleaning data")

library(dplyr)

### 1) Merge the training and test dataset
#Loading test data
test_X <- read.table("./test/X_test.txt")
test_y <- read.table("./test/y_test.txt")
test_subject <- read.table("./test/subject_test.txt")
features <- read.table("features.txt")
colnames(test_X) <- features$V2
colnames(test_y) <- c("activity_label")
colnames(test_subject) <- c("subject")

#merging the test datasets
test <- cbind(test_y,test_subject,test_X)
#removing unnecessary objects from memory
rm(test_y,test_X,test_subject) # features will be used for train

#Loading train data
train_X <- read.table("./train/X_train.txt")
train_y <- read.table("./train/y_train.txt")
train_subject <- read.table("./train/subject_train.txt")
features <- read.table("features.txt")
colnames(train_X) <- features$V2
colnames(train_y) <- c("activity_label")
colnames(train_subject) <- c("subject")


#merging the train datasets
train <- cbind(train_y,train_subject,train_X)
rm(train_y,train_X,train_subject) 

# combining the two dataset
combined <-rbind(train,test)
rm(train,test, features)

### 2) Extracts only the measurements on the mean and standard deviation for each measurement.
base_col <- c(1,2) # we keep the two first columns (activity and subject)
mean_col <- grep("-mean",names(combined)) # we grab the nlist of mean columns
std_col <- grep("-std",names(combined)) # and std-err
#could use the SELECT command from dply too


selector <-  append(base_col,append(mean_col,std_col)) # we put them together
selector <- sort(selector) # not to mess with the order of the columns ... not really
  #needed but makes it cleaner

combined <- combined[,selector]
#remove unneeded variables 
rm(base_col,mean_col,std_col,selector)

### 3) Uses descriptive activity names to name the activities in the data set
# loading activities info
activity_labels <- read.table("activity_labels.txt")
combined <- merge(combined,activity_labels,by.x="activity_label",by.y="V1") 
  #merging on the index column of the file
combined$activity_label <- NULL #removing the old label
combined$activity_label <- combined$V2 # "renaming" the new one
combined$V2 <- NULL # removing duplicate info
rm(activity_labels)

### 4) Appropriately labels the data set with descriptive variable names. 
# done already at lines 8-11 and 54-56

### 5) From the data set in step 4, creates a second, independent tidy data 
# set with the average of each variable for each activity and each subject.

small_and_tidy <- combined %>% group_by(activity_label,subject) %>% summarise_each(funs(mean))
write.table(small_and_tidy,"small_tidy.txt",row.names = FALSE)

