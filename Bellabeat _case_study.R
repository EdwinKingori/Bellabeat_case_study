# Bellbeat_Case_study
# Loading packages
library(tidyverse)
library(lubridate)
library(skimr)
library(dplyr)
library(janitor)
library(ggplot2)
library(selectr)

#(A) Preparing Data
#importing files

activity <- read.csv("dailyActivity_merged.csv")
calories <- read.csv("dailyCalories_merged.csv")
intensities <- read.csv("dailyIntensities_merged.csv")
steps <- read.csv("dailySteps_merged.csv")
sleepday <- read.csv("sleepDay_merged.csv")
Weight <- read.csv("weightLogInfo_merged.csv")

head(activity)
head(calories)
head(intensities)
head(steps)
head(sleepday)
head(Weight)

#data cleaning
#cleaning the  column names
activity1 <- janitor::clean_names(activity)
calories1 <- janitor::clean_names(calories)
intensities1 <- janitor::clean_names(intensities)
steps1 <- janitor::clean_names(steps)
sleepday1 <- janitor::clean_names(sleepday)
Weight1 <- janitor::clean_names(Weight)

colnames(activity1)
colnames(calories1)
colnames(intensities1)
colnames(sleepday1)
colnames(steps1)

# (B) Analyzing Data
#Summarizing data

#Checking sample size to decide whether to use for analysis
n_distinct(activity$Id)
n_distinct(calories$Id)
n_distinct(intensities$Id)
n_distinct(steps$Id)
n_distinct(sleepday$Id)
n_distinct(Weight$Id)

# Conclusion 
# 8 participants in the weight data sets are not a significant number to make a comprehensive analytic decision.

#Checking the summary statistics of the data sets.
activity1 %>%
  select(total_steps,
         total_distance,
         sedentary_minutes, calories) %>%
  summary()
#summarizing the number of active minutes per category
activity1 %>%
  select(very_active_minutes,
         fairly_active_minutes,
         lightly_active_minutes) %>%
  summary()
#calories summary
calories1 %>%
  select(calories) %>%
  summary()
#Intensities 
#summarizing the number of active minutes per category
intensities1 %>%
  select(very_active_minutes,
         fairly_active_minutes,
         lightly_active_minutes) %>%
  summary()
#Sleep
sleepday1 %>%
  select(total_sleep_records,
         total_minutes_asleep,
         total_time_in_bed) %>%
  summary()

# Discoveries made from the summary
#1: Most participants are lightly active
#2: Most participants spend an approximated 7 hours of sleep
#3: Most participants average around 7400 steps, resulting them to burn around 2300 calories a day
#4: the average sedentary time is 991, an equivalent of 16 hours which is lower than the medically required 4-8hours a day (https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-023-15029-8). 

# formatting: changing the date format, making the tables compatible for a successful merge
# Formatting 'activity1' table
activity1$activity_date <- as.POSIXct(activity1$activity_date, format = "%m/%d/%Y", tz = Sys.timezone())
activity1$date <- format(activity1$activity_date, format = "%m/%d/%y")

# Formatting 'sleepday1' table
sleepday1$sleep_day <- as.POSIXct(sleepday1$sleep_day, format = "%m/%d/%Y %I:%M:%S %p", tz = Sys.timezone())
sleepday1$date <- format(sleepday1$sleep_day, format = "%m/%d/%y")

head(activity1)
head(sleepday1)

#Merging Datasets
merged_data <- merge ( sleepday1, activity1, by = c('id', 'date'))
#merged_data <- distinct(merged_data, .keep_all = TRUE)
head(merged_data)
merged_data2 <- merge(x = steps1, y =  activity1, by = 'id')
head(merged_data2)

#Visualization 
# Relationship between the Steps vs Calories
ggplot(data = merged_data, aes(x = total_steps, y = calories, color = calories))+
  geom_point()+
  geom_smooth()+
  labs(title = 'Relationship between the Steps vs Calories')+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"))

#Calories burnt by steps and distance.

# Relationship Between Calories and Total Steps by Activity Date
ggplot(data = merged_data, aes(x=calories, y= total_steps))+
  geom_point()+
  geom_smooth()+
  facet_wrap(~activity_date)+
  labs(title = "Relationship Between Calories and Total Steps by Activity Date")+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA))

ggplot(data = merged_data, aes(x=calories, y= total_distance))+
  geom_point()+
  geom_smooth()+
  facet_wrap(~activity_date)+
  labs(title = "Relationship Between Calories and Total Distance by Activity Date")+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA))

#Exploring the relationship between steps taken in a day and sedentary minutes

ggplot(data = merged_data, aes(x = total_steps, y = sedentary_minutes))+
  geom_point(color = "blue")+
  geom_smooth()+
  labs(title = "Sedentary Minutes vs Total steps Taken")+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA))
# the plot shows the need for the company to sensitize its users to start  walking more

#Exploring the Relationship Between Minutes Asleep and Time in Bed
ggplot(data = sleepday1, aes(x= total_minutes_asleep, y = total_time_in_bed, color = total_minutes_asleep))+
  geom_point()+
  geom_smooth()+
  labs(title = "Relationship Between Minutes Asleep and Time in Bed")+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"))+
  scale_color_gradient(low="red", high ="#008000") 

#Exploring the Relationship Between Minutes Asleep and Time in Bed (as per each sleep-day)
ggplot(data = sleepday1, aes(x= total_minutes_asleep, y = total_time_in_bed, color = sleep_day))+
  geom_point()+
  geom_smooth()+
  labs(title = " Minutes Asleep Vs Time in Bed(per each sleep_day)")+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"))

ggplot(data = merged_data, aes(x= total_minutes_asleep, y = sedentary_minutes))+
  geom_point(color ="darkblue")+
  geom_smooth()+
  labs(title = "Relationship Between Minutes Asleep and sedentary_minutes")+
  theme(plot.title = element_text(hjust = 0.5))
# The plot shows that for users to improve their sleep, the company can recommend reducing sedentary time

# Creating two variables: User_type and sleep_quality that will exhibit the distribution of the steps and sleep day data for all users
merged_df <- merged_data%>%
  mutate(user_type = case_when(
    .$total_steps < 5000 ~ "Sedentary",
    .$total_steps >= 5000 & .$total_steps < 7499 ~ "Low_active",
    .$total_steps >= 7500 & .$total_steps < 9999 ~ "Moderately_active",
    .$total_steps >= 10000 & .$total_steps < 12499 ~ "Active",
    .$total_steps >= 12500  ~ "very_active"
  ),sleep_quality = case_when(
    .$total_minutes_asleep/60 >= 6 & .$total_minutes_asleep/60 <= 8 ~"Sufficient Sleep",
    .$total_minutes_asleep/60 < 6  ~ "InSufficient Sleep",
    .$total_minutes_asleep/60 > 9  ~ "OverSleeping"
    
  )
  )
# User_type Distribution Plot
ggplot(data = merged_df, aes( x = user_type, fill = user_type))+
  geom_bar()+
  labs(title = "User_type Distribution")+
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black',  fill = NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"))

merged_intensity <- merged_data%>%
  mutate(Intensityminutes = case_when(
    sedentary_minutes > 0~1,
    very_active_minutes > 0 ~2,
    fairly_active_minutes > 0 ~3,
    lightly_active_minutes > 0 ~4,
    
    TRUE ~ NA_integer_
  ))
head(merged_intensity)

ggplot(data = merged_intensity, aes(x = sedentary_minutes, y = calories)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Intensity and Calories") +
  facet_wrap(~ Intensityminutes, scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(color = 'black', fill = NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"))

merged_data <- merged_data %>%
  mutate(Intensityminutes = lightly_active_minutes + very_active_minutes + fairly_active_minutes)

dailyIntensitiesCalories_vizPointFacet <- merged_data %>%
  ggplot(mapping = aes(x = Intensityminutes, y = calories)) +
  geom_point(mapping = aes(color = Intensityminutes), show.legend = FALSE) +
  geom_smooth(mapping = aes(linetype = Intensityminutes), show.legend = FALSE) +
  facet_wrap(~ Intensityminutes, scales = "free")

dailyIntensitiesCalories_vizPointFacet


  


  