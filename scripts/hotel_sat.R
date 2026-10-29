#Upload the data set in to R
df <- read.csv("/enter_your_hotel_data_file_path")

#check data frame
View(df) 
colnames(df)

summary(df)


#To check the skewness of predictors or correlations between predictors
install.packages("gpairs")
library(gpairs)
gpairs(df[1:8]) #All normal
gpairs(df[9:16]) #All normal
gpairs(df[17:19]) #NO col 20 (categorical data) and (18)distanceTravelled, (19)nightsStayed skewed
gpairs(df[21:23]) #NO col 24 (categorical data) and (22)avgFoodSpendPerNight, (23)avgWifiSpendPerNight skewed

#To double check the skewness of skewed columns which are not normally distributed
hist(df$distanceTraveled)
hist(df$nightsStayed)
hist(df$avgFoodSpendPerNight)
hist(df$avgWifiSpendPerNight)

#Change to normal distribution
df$logdis <- log(df$distanceTraveled)
hist(df$logdis)

df$lognightS <- log(df$nightsStayed)
hist(df$lognightS) #####check whether this is normal or not

df$logavgFoodNight <- log(df$avgFoodSpendPerNight)
hist(df$logavgFoodNight) #####check whether this is normal or not

df$logavgWifiNight <- log(df$avgWifiSpendPerNight)
hist(df$logavgWifiNight) #####check whether this is normal or not

#Check the new data frame
View(df)

#log transformed new columns,
#18 -> logdis(25), 19 -> lognightS(26), 22 -> logavgFoodNight(27), 23 -> logavgWifiNight(28)

#Col 18,19,22,23 are skewed, 20,24 are categorical data.
#Therefore check the skewness after log transformations of columns (25:28)

gpairs(df[25:28]) #Only logdis shows a normal behavior

#Corrplot : To check correlations between each variables
install.packages("corrplot")
library(corrplot)
corrplot.mixed(cor(df[,c(1:17,21,25:28)]),upper = "ellipse")

corrplot.mixed(cor(df[,c(1:8, 17)]),upper = "ellipse") #Only frontStaff shows a strong relationship with overall sat (0.51)
corrplot.mixed(cor(df[,c(9:16, 17)]),upper = "ellipse") #No strong relationship
corrplot.mixed(cor(df[,c(25:26, 17)]),upper = "ellipse") #No strong relationship
corrplot.mixed(cor(df[,c(27:28, 17)]),upper = "ellipse") #-Inf values so can't get any relationship


lm(satOverall ~ satFrontStaff, data=df)
#Intercept (a) : 1.9597  ,   b : 0.5114  ,  y = 1.9597 + 0.5114x


#Building different models - Model 1
model1 <- lm(satOverall ~ satFrontStaff, data=df)

#plot linear model for satisfaction rate for front staff vs overall satisfaction
plot(satOverall ~ satFrontStaff, data=df,
     xlab = "satisfaction rate for front staff", ylab = "overall satisfaction")
abline(model1, col='blue')

summary(model1)
#p value is significant so coefficient accepeted and has a positive relationship with satOverall
#Intercept (a) : 1.95969  ,   b : 0.51137  ,  y = 1.95969 + 0.51137x
#Multiple R-squared : 0.2558  ,	 Adjusted R-squared : 0.2553 

plot(model1)


#Tested model 1 with satisfaction for Perks because it had 0.40 ccoefficient value
test1 <- lm(satOverall ~ satPerks, data=df)
plot(satOverall ~ satPerks, data=df,
     xlab = "satisfaction rate for Perks", ylab = "overall satisfaction")
abline(test1, col='blue')

summary(test1)
#p value is significant so coefficient accepeted and has a positive relationship with satOverall
#Intercept (a) : 2.19760  ,   b : 0.41166  ,  y = 2.19760 + 0.41166x
#Multiple R-squared : 0.1623  ,	 Adjusted R-squared : 0.1618 


#Buidling different models - Model 2 (without categorical skewed and log values)
colnames(df)
model2 <- lm(satOverall ~ satFrontStaff + satCleanRoom + satCleanBath + satCleanCommon + satDiningStaff + 
satHouseStaff + satValetStaff + satPerks + satRoomPrice + satDiningPrice + satWifiPrice + satParkingPrice + 
satCloseTransp + satCloseEvents + satPoints + satRecognition + avgRoomSpendPerNight, data=df)
summary(model2)
#p value siginficant only in ***(satFrontStaff > satCleanRoom > satDinningPrice) > **(satPerks) > *(satPoints
# > satWifiPrice > satcleanBath > satCloseTransp > satHouseStaff)

plot(model2)

#Compare two models
#Step 1 - From comparing R-squared values
summary(model1)$r.squared
summary(model2)$r.squared
summary(model1)$adj.r.squared
summary(model2)$adj.r.squared
#Model 2  -  Multiple R-squared : 0.3255795  ,	 Adjusted R-squared : 0.3178432
#Model 1  -  Multiple R-squared : 0.2557557  ,	 Adjusted R-squared : 0.2552589
#R-squared value has been improved then model2 is better

#Compare two models
#Step 2 - ANOVA
anova(model1,model2)

#Plot the coefficients
install.packages("coefplot")
library(coefplot)
coefplot(model2, intercept=FALSE, outerCI=1.96, IwdOuter=1.5,
         ylab="Satisfacction Rate Factor",
         xlab="Association with Overall Satisfaction")

#Create a new data frame containing categorical values
summary(df)
newdf <- df[ , c(-18, -19, -22, -23, -27, -28)] #18,19,22,23 skewed and 27,28 -Inf values(tried to build model but can't)
View(newdf)


#Buidling different models - Model 3 (considering only siginificant columns from model 2 and)
colnames(newdf)
model3 <- lm(satOverall ~ satCleanRoom + satCleanBath + satCleanCommon + satFrontStaff + satDiningStaff + 
satHouseStaff + satValetStaff + satPerks + satRoomPrice + satDiningPrice + satWifiPrice + satParkingPrice + 
satCloseTransp + satCloseEvents + satPoints + satRecognition + visitPurpose + avgRoomSpendPerNight +
eliteStatus + logdis + lognightS , data=newdf)
summary(model3)
#p value siginficant only in ***(satFrontStaff > satCleanRoom > satDinningPrice) > *(satPerks > satCloseTransp
# > satcleanBath > satHouseStaff > eliteStatusNoStatus > eliteStatusPlatinum)
#(satPoints and satWifiPrice) - model2 significants has been removed
#new significant p col compared to model2 ()


#Buidling different models - Model 4 

#(considering only significant columns from model2 and + visitPurpose + eliteStatus + logdis + lognightS)

#means removed below columns from model2 (satCleanCommon + satDiningStaff + satValetStaff + satRoomPrice + 
# satParkingPrice + satCloseEvents + satRecognition + avgRoomSpendPerNight)

model4 <- lm(satOverall ~ satCleanRoom + satCleanBath + satFrontStaff + satHouseStaff + satPerks + 
satDiningPrice + satWifiPrice + satCloseTransp + satPoints + visitPurpose + eliteStatus + logdis + lognightS 
, data=newdf)
summary(model4)

summary(model3)$r.squared
summary(model4)$r.squared
summary(model3)$adj.r.squared
summary(model4)$adj.r.squared
#Model 1  -  Multiple R-squared : 0.2557557  ,	 Adjusted R-squared : 0.2552589
#Model 2  -  Multiple R-squared : 0.3255795  ,	 Adjusted R-squared : 0.3178432
#Model 3  -  Multiple R-squared : 0.3346347  ,	 Adjusted R-squared : 0.3224303
#Model 4  -  Multiple R-squared : 0.3308741  ,	 Adjusted R-squared : 0.322284
#Model 3 is better

#visitPurpose and eliteStatus are characters therefore, change them into factors
df$eliteStatus <- as.factor(df$eliteStatus)
levels(df$eliteStatus)

newdf$nightsStayed <- df$nightsStayed
View(newdf)
newdf$nightsStayedFactor <- factor(newdf$nightsStayed)
View(newdf)
newdf <- newdf[-23]

model5 <- lm(satOverall ~ satCleanRoom + satCleanBath + satCleanCommon + satFrontStaff + satDiningStaff + 
satHouseStaff + satValetStaff + satPerks + satRoomPrice + satDiningPrice + satWifiPrice + satParkingPrice + 
satCloseTransp + satCloseEvents + satPoints + satRecognition + visitPurpose + avgRoomSpendPerNight +
eliteStatus + logdis + lognightS + nightsStayedFactor, data=newdf)
summary(model5)
#Not much of a improvement



