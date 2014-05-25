
library(reshape)
library(sqldf)


setwd("C:/Morrow/datasciencecoursera/DataCourseProject/CleansingProject")

# Load metadata
activitylabels <- read.table("./activity_labels.txt", header = FALSE)
features <- read.table("./features.txt", header = FALSE)

# Load Test data
testsubjects <- read.table("./test/subject_test.txt", header = FALSE)
xtest <- read.table("./test/X_test.txt", header = FALSE,stringsAsFactors = FALSE)
ytest <- read.table("./test/y_test.txt", header = FALSE)

#Load Training data
trainsubjects <- read.table("./train/subject_train.txt", header = FALSE)
xtrain <- read.table("./train/X_train.txt", header = FALSE, stringsAsFactors = FALSE)
ytrain <- read.table("./train/y_train.txt", header = FALSE)

# Combine test subjects and train subjects and activities
subjects <- rbind(testsubjects, trainsubjects) 
activity <- rbind(ytrain, ytest)

# Combine test and train data
cdat <- rbind(xtrain, xtest)

# Cleanup column names
x <- tolower(features[,2])
x <- gsub("-","", x, ignore.case = TRUE)
x <- gsub("\\(","",x, ignore.case = TRUE)
x <- gsub("\\)","",x, ignore.case = TRUE)
x <- gsub("\\'","",x, ignore.case = TRUE)
x <- gsub("\\.","",x, ignore.case = TRUE)

# Replace column names with cleaned versions
colnames(cdat) <- x

# Subset by mean and std
pattern <- "mean|std"
# y <- grep(pattern, names(cdat))
cdat <- cdat[, grep(pattern, names(cdat))]

# Subset further for Jerk
pattern <- "jerk"
# y <- grep(pattern, names(cdat))
cdat <- cdat[, grep(pattern, names(cdat))]

# Subset further for acc
pattern <- "acc"
# y <- grep(pattern, names(cdat))
cdat <- cdat[, grep(pattern, names(cdat))]

# Subset further for body only
pattern <- "body"
# y <- grep(pattern, names(cdat))
cdat <- cdat[, grep(pattern, names(cdat))]

# Add the Subject and activities columns - SQL for kicks
act <- sqldf("
             SELECT  b.V2 AS activity
             FROM activity a
             JOIN activitylabels b ON A.V1 = B.V1
             ")

cdat <- cbind(act, cdat)
cdat <- cbind(subjects, cdat)

# Change first 2 column names subject and activity
names(cdat)[1] <- "subject"
names(cdat)[2] <- "activity"

# Aggregate by subject and activity
agg <- aggregate(. ~ subject + activity, data=cdat, mean, na.rm=TRUE)

# Order y subject and activity
agg <- agg[order(agg[,1]),]

# Write dataset
write.table(agg, "./jerkyAcceleration.txt", sep="\t", row.names = FALSE, col.names = TRUE)













