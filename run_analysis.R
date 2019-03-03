library(dplyr)

# load UCI HAR Dataset files

path <- './UCI HAR Dataset/'
features <- read.table(paste0(path, 'features.txt'), stringsAsFactors = FALSE)

subject_test <- read.table(paste0(path, 'test/subject_test.txt'))
X_test <- read.table(paste0(path, 'test/X_test.txt'))
y_test <- read.table(paste0(path, 'test/y_test.txt'))

subject_train <- read.table(paste0(path, 'train/subject_train.txt'))
X_train <- read.table(paste0(path, 'train/X_train.txt'))
y_train <- read.table(paste0(path, 'train/y_train.txt'))

# merge the training and test sets to create one data set
data <- rbind(X_test, X_train)

# appropriately label the data set with descriptive variable names
data = cbind(data, c(subject_test$V1, subject_train$V1), c(y_test$V1, y_train$V1)) # add column for subject ID and activity code
names(data) <- c(features$V2, 'subject_id', 'activity_id') # add feature names to data

# extract only the measurements on the mean and standard deviation for each measurement
wanted_cols <- grep("mean|std|id", names(data)) # take only columns for mean, std, and subject_id
data = data[,wanted_cols]

# use descriptive activity names to name the activities in the data set
# activity labels
# 1 = walking
# 2 = walking_upstairs
# 3 = walking_downstairs
# 4 = sitting
# 5 = standing
# 6 = laying
activity_ids <- c(y_test$V1, y_train$V1)
activity_desc <- gsub('1', 'walking', activity_ids)
activity_desc = gsub('2', 'walking_upstairs', activity_desc)
activity_desc = gsub('3', 'walking_downstairs', activity_desc)
activity_desc = gsub('4', 'sitting', activity_desc)
activity_desc = gsub('5', 'standing', activity_desc)
activity_desc = gsub('6', 'laying', activity_desc)
data = cbind(data, activity_desc)
names(data[,-1]) <- 'activity_desc'

# from the descriptive data set, create a second independent tidy data set with the 
# average of each variable for each activity and each subject
grouped_data <- group_by(data, activity_desc, subject_id)
summary <- dplyr::summarise_all(grouped_data, mean)

# export tidy data
write.table(summary, file = 'project_tidy.txt', row.name = FALSE)