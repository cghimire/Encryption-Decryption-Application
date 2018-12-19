library(ggplot2)
library(caretEnsemble)
library(ROSE)
library(mlbench)
library(DMwR)
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library('dplyr')
library("gridExtra")
library(readr)
library(ggplot2)
library(lattice)
library(plyr)
library(dplyr)
library(caret)
library(mlbench)
library(foreign)
library(ggplot2)
library(reshape)
library(scales)
library(e1071)
library(MASS)
library(klaR)
library(C50)
library(kernlab)
library(nnet)

#Load the dataset

mydata <- read.csv('/Users/chiranjibighimire/Desktop/CS\ 522-Bank_Project-DM\ analysis/bank-additional.csv', sep = ';')


dim(mydata)
str(mydata)
#Find out if there are any NAs, that we might have to either destroy or impute

naColumns <- function(df) 
naColumns(mydata)


## OR we can check NAs in another way

newdata <- na.omit(mydata)
nrow(newdata)==nrow(mydata)

#There are no NAs so far in the data set


#Summary on dataset
summary(mydata)


# Number of yes and no in targeted output (y)
table(mydata$y)



########################################################################################################
####################################  Data Understanding  ##############################################
########################################################################################################


######################################### Box Plot and Bar Plot ######################################################

hist(mydata$age)
hist(mydata$duration)
hist(mydata$campaign)
hist(mydata$pdays)

##ggplot(mydata, aes(x=age, y=job, color=y)) + geom_point()+ geom_smooth(method=lm)+ geom_smooth(method=lm, aes(group-1)+facet_wrap(- job, scales-"free_y")+ labs(x="Age", y="salary", title="salary by age group")+ theme(axis.text.x-element_text(ang=90))




ggplot(mydata, aes(factor(y), age)) + geom_boxplot(aes(fill = factor(y)))



p_job <- ggplot(mydata, aes(factor(y), job)) + geom_boxplot(aes(fill = factor(y)))
p_job

p_day <- ggplot(mydata, aes(factor(y), day)) + geom_boxplot(aes(fill = factor(y)))
p_day


fp_duration <- ggplot(mydata, aes(factor(y), duration)) + geom_boxplot(aes(fill = factor(y)))
p_duration

p_campaign <- ggplot(mydata, aes(factor(y), campaign)) + geom_boxplot(aes(fill = factor(y)))
p_campaign

p_pdays <- ggplot(mydata, aes(factor(y), pdays)) + geom_boxplot(aes(fill = factor(y)))
p_pdays

p_previous <- ggplot(mydata, aes(factor(y), previous)) + geom_boxplot(aes(fill = factor(y)))
p_previous

barplot(table(mydata$job),col="red",ylab="Counts",las=2,main="Job",cex.names = 0.8,cex.axis = 0.8)

boxplot(mydata$age~mydata$y, main=" Age",ylab="Age of Clients",xlab="Deposit A/C Open or Not")

barplot(table(mydata$nr.employed),col="red",ylab="Counts",las=2,main="Number of Employed",cex.names = 0.8,cex.axis = 0.8)
boxplot(mydata$nr.employed~mydata$y, main=" Number of Employed",ylab="Counts",xlab="Deposit A/C Open or Not")

boxplot(mydata$education~mydata$y, main=" Education",ylab="No. of Clients",xlab="Deposit A/C Open or Not")
barplot(table(mydata$education),col="red",ylab="No. of Clients",las=2,main="Education",cex.names = 0.8,cex.axis = 0.8)


barplot(table(mydata$age),col="red",ylab="No. of Clients",las=2,main="age",cex.names = 0.8,cex.axis = 0.8)


####################### HISTOGRAM FOR VARIOUS COMBINATION ################################################

#Histogram visualization for relationship between duration Vs predicted output 

bankSampleYYes <- filter(mydata, y == 'yes')
bankSampleYNo <-  filter(mydata, y == 'no')

yesTermDepositsByDuration <- ggplot(bankSampleYYes, aes(duration)) + geom_histogram(binwidth = 10) + labs(title = "Term Deposits Yes by Duration", x="Duration", y="Count of Yes") + xlim(0,3000)
noTermDepositsByDuration <- ggplot(bankSampleYNo, aes(duration)) + geom_histogram(binwidth = 10) + labs(title = "Term Deposits No by Duration", x="duration", y="Count of No")+ xlim(0,3000)
grid.arrange(yesTermDepositsByDuration, noTermDepositsByDuration)

#Histogram for relationship between campaign Vs predicted output

yesTermDepositsByCampaign <- ggplot(bankSampleYYes, aes(campaign)) + geom_histogram(binwidth = 5) + labs(title = "Term Deposits Yes by number of campaigns", x="campaigns", y="Count of Yes") + xlim(0,20)
noTermDepositsByCampaign <- ggplot(bankSampleYNo, aes(campaign)) + geom_histogram(binwidth = 5) + labs(title = "Term Deposits No by number of campaigns", x="campaigns", y="Count of No") + xlim(0,20)
grid.arrange(yesTermDepositsByCampaign, noTermDepositsByCampaign)


##Histogram for relationship between previous Vs predicted output

yesTermDepositsByPrevious <- ggplot(bankSampleYYes, aes(previous)) + geom_histogram(binwidth = 2) + labs(title = "Term Deposits Yes by number of previous", x="previous", y="Count of Yes") + xlim(0,15)
noTermDepositsByPrevious <- ggplot(bankSampleYNo, aes(previous)) + geom_histogram(binwidth = 2) + labs(title = "Term Deposits No by number of previous", x="previous", y="Count of No") + xlim(0,15)
grid.arrange(yesTermDepositsByPrevious, noTermDepositsByPrevious)

#### ggplot of education 
ggplot(mydata, aes(education, y)) + geom_jitter()


# The duration has a high correlation with the target variable. This attribute highly affects the output target (e.g., if duration=0 then y='no'). Yet, the duration is not known before a call is performed. Also, after the end of the call y is obviously known. Thus, this input should only be included for benchmark purposes and should be discarded if the intention is to have a realistic predictive model.
boxplot(mydata$duration~mydata$y, main=" Duration",ylab="Call Duration",xlab="Deposit A/C Open or Not")


############################################################################################################
######################################## DATA PREPARATION ##################################################
############################################################################################################


##### Check the outlier and Missing Values  ######

#### Outlier removal by the Tukey rules on quartiles +/- 1.5 IQR
### It will remove the outliers and replace by NAs


outlierKD <- function(dt, var) {
  var_name <- eval(substitute(var),eval(dt))
  tot <- sum(!is.na(var_name))
  na1 <- sum(is.na(var_name))
  m1 <- mean(var_name, na.rm = T)
  par(mfrow=c(2, 2), oma=c(0,0,3,0))
  boxplot(var_name, main="With outliers")
  hist(var_name, main="With outliers", xlab=NA, ylab=NA)
  outlier <- boxplot.stats(var_name)$out
  mo <- mean(outlier)
  var_name <- ifelse(var_name %in% outlier, NA, var_name)
  boxplot(var_name, main="Without outliers")
  hist(var_name, main="Without outliers", xlab=NA, ylab=NA)
  title("Outlier Check", outer=TRUE)
  na2 <- sum(is.na(var_name))
  message("Outliers identified: ", na2 - na1, " from ", tot, " observations")
  message("Proportion (%) of outliers: ", (na2 - na1) / tot*100)
  message("Mean of the outliers: ", mo)
  m2 <- mean(var_name, na.rm = T)
  message("Mean without removing outliers: ", m1)
  message("Mean if we remove outliers: ", m2)
  response <- readline(prompt="Do you want to remove outliers and to replace with NA? [yes/no]: ")
  if(response == "y" | response == "yes"){
    dt[as.character(substitute(var))] <- invisible(var_name)
    assign(as.character(as.list(match.call())$dt), dt, envir = .GlobalEnv)
    message("Outliers successfully removed", "\n")
    return(invisible(dt))
  } else{
    message("Nothing changed", "\n")
    return(invisible(var_name))
  }
}


# Remove outlier from specific Columns
outlierKD(mydata, age)
outlierKD(mydata, previous)
outlierKD(mydata, duration)
outlierKD(mydata, campaign)
outlierKD(mydata, nr.employed)
outlierKD(mydata, pdays)

########## Check the NAs 



naColumns <- function(df)
naColumns(mydata)


# #### Replace NAs by 0
 
mydata <- as.data.frame(mydata)
mydata[is.na(mydata)] <- 0

str(mydata)


# Chcek If there any remaining NAs (missing values) 

if(length(which(is.na(mydata)==TRUE)>0)){
  print("Missing Value found in the specified column")
} else{
  print("All okay: No Missing Value found in the specified column")
}


# # # Graphic Visualization (Boxplot, Barplot, and Histogram) of predictors and output after removing outlier and missing values
# # 
# p_campaign <- ggplot(mydata, aes(factor(y), campaign)) + geom_boxplot(aes(fill = factor(y)))
# p_campaign
# 
# p_duration <- ggplot(mydata, aes(factor(y), duration)) + geom_boxplot(aes(fill = factor(y)))
# p_duration
# # 
# # p_pdays <- ggplot(mydata, aes(factor(y), pdays)) + geom_boxplot(aes(fill = factor(y)))
# # p_pdays
# # 
# 
# #campaign Vs predicted Output
# 
# 

hist(mydata$age)
barplot(table(mydata$age),col="red",ylab="No. of Clients",las=2,main="age",cex.names = 0.8,cex.axis = 0.8)
# hist(mydata$duration)
# hist(mydata$campaign)
# hist(mydata$pdays)



################# Correlation Analysis #################

#It emphsize on what we say using box plot, It can tell if predictor is a good predictor or not a good predictor
#This analysis can help us decide if we can drop some columns/predictors depending upon its correlation with the outcome variable
library(psych)
pairs.panels(mydata[, c(1:8,17)])
pairs.panels(mydata[, c(9:21)])

################# Subset Selection #################
mydata_sub <-mydata[, c(1:17,20:21)]
str(mydata_sub)
pairs.panels(mydata_sub)

################### DATA PRE-PROCESSING ##############################################################
################# Binning and data Trasformation ######################################################
# We do data transformation and binning for better modeling. We convert categorical variable into numerical using binning.

mydata_sub$age <- cut(mydata_sub$age, c(1,20,40,60,100))
mydata_sub$is_divorced <- ifelse( mydata_sub$marital == "divorced", 1, 0)
mydata_sub$is_single <- ifelse( mydata_sub$marital == "single", 1, 0)
mydata_sub$is_married <- ifelse( mydata_sub$marital == "married", 1, 0)
mydata_sub$marital <- NULL
str(mydata_sub)



# ###Plotting to see the overlap between predictors (after pre-processing the data)
# boxplot(duration~y,data=mydata_sub, main="Finding Overlap between predictor and outcome",
#         yaxt="n", xlab="Duration", horizontal=TRUE,
#         col=terrain.colors(3))
# 
# 
# boxplot(campaign~y,data=mydata_sub, main="Finding Overlap between predictor and outcome",
#         yaxt="n", xlab="Campaign", horizontal=TRUE,
#         col=terrain.colors(3))



#################################### DATA MODELING ###############################################
##################################################################################################


############# Spiliting the Data for Training and Testing ###########################

install.packages("caret", dependencies = c("Depends", "Suggests"))
install.packages("stringi")
install.packages("lubridate", dependencies = TRUE)
library(lattice)
library(ggplot2)
library(mlbench)
library(caret)

set.seed(1234)
TrainingDataIndex <- createDataPartition(mydata_sub$y, p=0.75, list = FALSE)
train <- mydata_sub[TrainingDataIndex,]
test <-mydata_sub[-TrainingDataIndex,]
prop.table(table(train$y))
nrow(train)
nrow(test)

# createDataPartition does the magic 
dim(train);dim(test)
# We can see imbalancing has been taken care of or not
table(train$y); table(test$y)

############################ Decision Tree ###################################################################
#####################################################################################################################################################################################


library("rpart")
treeAnalysis=rpart(y~ . - duration, data=train)
treeAnalysis
install.packages("rpart.plot")
library("rpart.plot")
rpart.plot(treeAnalysis, extra = 4)

# # Prediction
# PwithClass= predict(treeAnalysis, test, type = "class")
# t= table(predictions =PwithClass, actual=test$y)
# t
# 
# 
# #Accuracy
# 
# sum(diag(t))/sum(t)



#################### Classification Method:Decision Tree Model #####################

########### Training the Model #####################

#After partitioning the data to train and test, use a 10 fold cross validation repeated 5 times to evaluate the model.
TrainingParameters <- trainControl(method = "cv", number = 10)

########################### Create Decision Tree using C5.0 Algorithm ######################

library(C50)
install.packages('e1071', dependencies=TRUE)

DecTreeModel <- train(y ~ ., data = train, 
                      method = "C5.0",
                      trControl= TrainingParameters,
                      na.action = na.omit)


DecTreeModel

summary(DecTreeModel)


## Testing the Model

DTPredictions <-predict(DecTreeModel, test, na.action = na.pass)
confusionMatrix(DTPredictions, test$y)



######## Suppor Vector Machines (SVM) ######################################

#Training the Model


set.seed(120)
TrainingDataIndex <- createDataPartition(mydata$y, p=0.75, list = FALSE)
train <- mydata[TrainingDataIndex,]
test <-mydata[-TrainingDataIndex,]
svm_model <- train(y~., data = train,
                   method = "svmPoly",
                   trControl= trainControl(method = "cv", number = 10, repeats = 5),
                   tuneGrid = data.frame(degree = 1,scale = 1,C = 1))
svm_model

#Testing the Model


SVMPredictions <-predict(svm_model, test, na.action = na.pass)
confusionMatrix(SVMPredictions, test$y)



####################### NEURAL NETWORK  ####################

####Training the Model

set.seed(80)
TrainingDataIndex <- createDataPartition(mydata_sub$y, p=0.75, list = FALSE)
train <- mydata_sub[TrainingDataIndex,]
test <-mydata_sub[-TrainingDataIndex,]
nnmodel <- train(train[,-20], train$y, method = "nnet",
                 trControl= trainControl(method = "cv", number = 10, repeats = 5))
nnmodel


##### TESTING THE MODEL ###########
nnetpredictions <-predict(nnmodel, test, na.action = na.pass)
confusionMatrix(nnetpredictions, test$y)



################################ Random Forest  ####################################################

#Training the model
install.packages("randomForest")
library(randomForest)
set.seed(1)
training <- mydata_sub[, colSums(is.na(mydata_sub)) == 0]
model_RF <- randomForest(y ~ ., data=training)
model_RF



#importance of each predictor
importance(model_RF)

############ Testing Random forest Model ############
library(caret)
predicted <- predict(model_RF, test)
table(predicted)
confusionMatrix(predicted, test$y)


#Effect of increasing tree count 
accuracy=c()
for (i in seq(1,50, by=1)) {
  modFit <- randomForest(y ~ ., data=training, ntree=i)
  accuracy <- c(accuracy, confusionMatrix(predict(modFit, test, type="class"), test$y)$overall[1])
}
par(mfrow=c(1,1))
plot(x=seq(1,50, by=1), y=accuracy, type="l", col="green",
     main="Accuracy VS Tree-Size", xlab="Tree Size", ylab="Accuracy")





#####################################The End ########################################################################

# Data Preparation

#For oversampling the data, we have to convert the categorical data into numerical variable
#

#Generate dummy variables
# for(level in unique(mydata$job)){
#   mydata[paste("job", level, sep = "_")] <- ifelse(mydata$job == level, 1, 0)
# }
# 
# for(level in unique(mydata$marital)){
#   mydata[paste("marital", level, sep = "_")] <- ifelse(mydata$marital == level, 1, 0)
# }
# 
# for(level in unique(mydata$education)){
#   mydata[paste("education", level, sep = "_")] <- ifelse(mydata$education == level, 1, 0)
# }
# 
# mydata$default_yes <- ifelse(mydata$default == "yes", 1, 0)
# 
# mydata$housing_yes <- ifelse(mydata$housing == "yes", 1, 0)
# 
# mydata$loan_yes <- ifelse(mydata$loan == "yes", 1, 0)
# 
# for(level in unique(mydata$contact)){
#   mydata[paste("contact", level, sep = "_")] <- ifelse(mydata$contact == level, 1, 0)
# }
# 
# for(level in unique(mydata$month)){
#   mydata[paste("month", level, sep = "_")] <- ifelse(mydata$month == level, 1, 0)
# }
# 
# for(level in unique(mydata$poutcome)){
#   mydata[paste("poutcome", level, sep = "_")] <- ifelse(mydata$poutcome == level, 1, 0)
# }
# 
# mydata$Class <- ifelse(mydata$y == "yes", "Yes", "No")
# 
# bank_num= mydata[,c(1,2,11,12:14,20,22:64)]
# summary(bank_num)
# str(bank_num)
# #Remove unwanted columns
# ##mydata$X <- NULL
# #mydata$job <- NULL
# #mydata$marital <- NULL
# # mydata$education <- NULL
# # mydata$default <- NULL
# # mydata$housing <- NULL
# # mydata$loan <- NULL
# # mydata$contact <- NULL
# # mydata$month <- NULL
# # mydata$poutcome <- NULL
# # mydata$y <- NULL
# 
# mydata$Class <- as.factor((mydata$Class))
# 
# # 
# # colnames(mydata)[11] <- "job_blue_collar"
# # colnames(mydata)[14] <- "job_admin"
# # colnames(mydata)[16] <- "job_self_employeed"
# 
# 
# ###################################################################
# #Splitting
# set.seed(113)
# training_size <- floor(0.80 * nrow(bank_num))
# train_ind <- sample(seq_len(nrow(bank_num)), size = training_size)
# training <- bank_num[train_ind, ]
# testing <- bank_num[-train_ind, ]
# dim(testing)
# dim(training)
# 
# 
# library("rpart")
# treeAnalysis_1=rpart(y~ ., data=training)
# treeAnalysis_1
# install.packages("rpart.plot")
# library("rpart.plot")
# rpart.plot(treeAnalysis_1, extra = 4)
# 
# 
# 
# #Normalizing
# preProcValues <- preProcess(training, method = c("center", "scale"))
# scaled.training <- predict(preProcValues, training)
# scaled.testing <- predict(preProcValues, testing)
# 
# Summary(scaled.testing)
# #Sampling
# ctrl <- trainControl(method = "repeatedcv", repeats = 5,
#                      classProbs = TRUE,
#                      summaryFunction = twoClassSummary)
# 
# set.seed(2)
# down_training <- downSample(x = scaled.training[, -ncol(scaled.training)],
#                             y = scaled.training$Class)
# 
# up_training <- upSample(x = scaled.training[, -ncol(scaled.training)],
#                         y = scaled.training$Class
#                         
# installed.packages("grid")                        
# library(DMwR)
# 
# smote_training <- SMOTE(Class~., data = scaled.training)
# 
# summary(smote_training$y)
# 
# DecTreeModel_1 <- train(smote_training$y ~ ., data = smote_training, 
#                       method = "C5.0",
#                       trControl= TrainingParameters,
#                       na.action = na.omit)
# 
# 
# DecTreeModel_1
# 
# summary(DecTreeModel_1)
# 
# 
# 
# 
# 
# rose_training <- ROSE(Class~., data = scaled.training, seed=2)$data
# 
# #Model training - CART
# set.seed(3)
# orig_fit <- train(Class~., data = training, 
#                   method = "rpart",
#                   metric = "ROC",
#                   trControl = ctrl)
# 
# set.seed(4)
# down_outside <- train(Class~., data = down_training, 
#                       method = "rpart",
#                       metric = "ROC",
#                       trControl = ctrl)
# 
# set.seed(5)
# up_outside <- train(Class~., data = up_training, 
#                     method = "rpart",
#                     metric = "ROC",
#                     trControl = ctrl)
# 
# set.seed(6)
# smote_outside <- train(Class~., data = smote_training, 
#                        method = "rpart",
#                        metric = "ROC",
#                        trControl = ctrl)
# 
# set.seed(7)
# rose_outside <- train(Class~., data = rose_training, 
#                       method = "rpart",
#                       metric = "ROC",
#                       trControl = ctrl)
# 
# #Model testing - Original
# original_model <- list(original = orig_fit)
# 
# test_roc <- function(model, data) {
#   library(pROC)
#   roc_obj <- roc(data$Class, 
#                  predict(model, data, type = "prob")[, "Yes"],
#                  levels = c("No", "Yes"))
#   ci(roc_obj)
# }
# 
# original_test <- lapply(original_model, test_roc, data = testing)
# original_test <- lapply(original_test, as.vector)
# original_test <- do.call("rbind", original_test)
# colnames(original_test) <- c("lower", "ROC", "upper")
# original_test <- as.data.frame(original_test)
# 
# #Model testing - Resampled
# scaled_models <- list(down = down_outside,
#                        up = up_outside,
#                        SMOTE = smote_outside,
#                        ROSE = rose_outside)
# 
# scaled_test <- lapply(scaled_models, test_roc, data = scaled.testing)
# scaled_test <- lapply(scaled_test, as.vector)
# scaled_test <- do.call("rbind", scaled_test)
# colnames(scaled_test) <- c("lower", "ROC", "upper")
# scaled_test <- as.data.frame(scaled_test)
# 
# cart_test <- rbind(original_test,scaled_test)
# 
# fancyRpartPlot(up_outside$finalModel)
