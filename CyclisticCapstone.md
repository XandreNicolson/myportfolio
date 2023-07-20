---
title: "Cyclistic Capstone"
author: "Xandre"
date: "2023-07-06"
---

## Cyclistic Capstone

#### R code version

Here you will find the R coding version of my Cyclistic Capstone Project
for Google Analytics Professional Certificate. It follows the same goals
as completed in SQL and Tableau as best as possible in order to
demonstrate fluency.

### Packages & Importing Data

First we loaded the packages for data cleaning & analysis:

```{r message=FALSE, warning=FALSE}
library(tidyverse)
library(janitor)
library(skimr)
```

We imported all 12 files of the Cyclistic Data into Rstudio and RMarkdown:

```{r message=TRUE, warning=TRUE}
X202205_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202205-divvy-tripdata.csv", show_col_types = FALSE)
X202206_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202206-divvy-tripdata.csv", show_col_types = FALSE)
X202207_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202207-divvy-tripdata.csv", show_col_types = FALSE)
X202208_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202208-divvy-tripdata.csv", show_col_types = FALSE)
X202209_divvy_publictripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202209-divvy-publictripdata.csv", show_col_types = FALSE)
X202210_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202210-divvy-tripdata.csv", show_col_types = FALSE)
X202211_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202211-divvy-tripdata.csv", show_col_types = FALSE)
X202212_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202212-divvy-tripdata.csv", show_col_types = FALSE)
X202301_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202301-divvy-tripdata.csv", show_col_types = FALSE)
X202302_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202302-divvy-tripdata.csv", show_col_types = FALSE)
X202303_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202303-divvy-tripdata.csv", show_col_types = FALSE)
X202304_divvy_tripdata <- read_csv("C:/Users/xanni/OneDrive/Desktop/Data Analysis/Case Study - Cyclistic/CSV Files/Raw Data Unzipped/202304-divvy-tripdata.csv", show_col_types = FALSE)
```

### Data Preparation

While doing so, we were able to ensure consistent column names and data types.
Then we combined individual files into one data frame:

```{r}
combined_cyclistic_v1 <- rbind(X202205_divvy_tripdata, X202206_divvy_tripdata,
                            X202207_divvy_tripdata, X202208_divvy_tripdata,
                            X202209_divvy_publictripdata, X202210_divvy_tripdata,
                            X202211_divvy_tripdata, X202212_divvy_tripdata,
                            X202301_divvy_tripdata, X202302_divvy_tripdata,
                            X202303_divvy_tripdata, X202304_divvy_tripdata)
```

Then we took a peek:

```{r}
skim(combined_cyclistic_v1)
```

From this overview of the combined data set, we can see that: 
* the ride_id has no duplicates, 
* our member_casual has only two types,
*started_at/ended_at have no missing values. 

### Data Cleaning & Aggregation

Next we want to change all 'docked_bikes' to 'classic_bikes':

```{r}
combined_cyclistic_v2 <- mutate(combined_cyclistic_v1, rideable_type = recode(rideable_type, 'docked_bike' = 'classic_bike'))
```

From there, we want to remove station id columns:

```{r}
combined_cyclistic_v3 <- select(combined_cyclistic_v2, -start_station_id, -end_station_id)
```

Then we want to remove all rides that are less than one minute long
(140,515 rows) and longer than one day (5352 rows):

```{r}
combined_cyclistic_v4 <- combined_cyclistic_v3 %>% 
  mutate(trip_duration = (difftime(ended_at, started_at, unit = "mins"))) %>% 
  subset(trip_duration >= 1 & trip_duration <= 1439)
```

Eliminate classic_bike rows that have no end_station_name (817 rows):

Note: electric bikes do not need to be returned to stations so we keep that data
as it qualifies as an actual ride by a user. 

```{r}
combined_cyclistic_v5 <- combined_cyclistic_v4 %>% 
   filter(rideable_type == 'electric_bike' | !is.na(end_station_name))
```

Then we added the columns for Day and Month for when the rides we taken:

```{r}
combined_cyclistic_v6 <- combined_cyclistic_v5 %>% 
  mutate(day_of_week = wday(started_at, TRUE)) %>% 
  mutate(month = month(started_at, TRUE))
```

Finally we want to also make a column where we broadly note the time of
day when the bike ride took place. First we need to make a new column to
house the time component of the datetime variable:

```{r}
combined_cyclistic_v7 <- combined_cyclistic_v6 %>%
  mutate(time_of_day = format(as.POSIXct(started_at), format = "%H:%M:%S"))
```

Then we removed the ':' from the character datatype and then convert to
integer:

```{r}

combined_cyclistic_v7$time_of_day <- str_remove_all(
  combined_cyclistic_v7$time_of_day, "[:]")

combined_cyclistic_v7$time_of_day <- as.integer(combined_cyclistic_v7$time_of_day)
```

Lastly we made the catagories for time of day as such: \* Morning as 4am
to 11:56am \* Afternoon as 11:56am to 5:56pm \* Evening as 5:56pm to
9:56pm \* Night as 9:56pm to 4am

```{r}
combined_cyclistic_v7$time_of_day <-case_when(
  combined_cyclistic_v7$time_of_day <= 035959 ~ "Night",
  combined_cyclistic_v7$time_of_day > 035959 & 
    combined_cyclistic_v7$time_of_day <= 115559 ~ "Morning",
  combined_cyclistic_v7$time_of_day > 115559 & 
    combined_cyclistic_v7$time_of_day <= 175559 ~ "Afternoon",
  combined_cyclistic_v7$time_of_day >175559 &
    combined_cyclistic_v7$time_of_day <= 215559 ~ "Evening",
  combined_cyclistic_v7$time_of_day > 215559 ~ "Night")
```

The last data manipulation task we undertook was to make two smaller
data frames in order to see the top 50 stations for each member type. We
want to include the geographical coordinates as well for mapping in our
analysis.

```{r}
casual_top_stations <- combined_cyclistic_v7 %>% 
  filter(member_casual == 'casual', start_station_name != "") %>% 
  select(start_station_name,
         start_lat,
         start_lng) %>% 
  group_by(start_station_name,
         start_lat,
         start_lng) %>% 
  summarize(count=n(), .groups = 'drop') %>% 
  arrange(-count) %>% 
  head(50)

member_top_stations <- combined_cyclistic_v7 %>% 
  filter(member_casual == 'member', start_station_name != "") %>% 
  select(start_station_name,
         start_lat,
         start_lng) %>% 
  group_by(start_station_name,
         start_lat,
         start_lng) %>% 
  summarize(count=n(), .groups = 'drop') %>% 
  arrange(-count) %>% 
  head(50)  
```

### Analyzing & Visualizing Data

Below follows the coding to reproduce the graphs that were
first made in Tableau:

* Median Trip Duration By Time of Day

```{r}

# here we augmented data types and turned time_of_day & member_casual into factors
# so that facting was easier:

combined_cyclistic_v7$trip_duration <- as.numeric(combined_cyclistic_v7$trip_duration)

combined_cyclistic_v7$time_of_day <- factor(
  combined_cyclistic_v7$time_of_day,
    levels = c("Morning", "Afternoon", "Evening", "Night"))

combined_cyclistic_v7$member_casual <- factor(
  combined_cyclistic_v7$member_casual,
  c("member", "casual"))

```

```{r}

# here we created some smaller data frames in order to have an annotation layer
# to add later on the plot:

plot_median_data <-combined_cyclistic_v7 %>% 
  group_by(member_casual, time_of_day) %>% 
  summarise(median_duration = round(median(trip_duration),0), .groups = 'drop')

annual_annot <- plot_median_data %>% 
  filter(member_casual == "member")
  
annual_annot$median_duration <- paste(annual_annot$median_duration, "mins")

casual_annot <- plot_median_data %>% 
  filter(member_casual == "casual")

casual_annot$median_duration <- paste(casual_annot$median_duration, "mins")
  
# below is the code for the actual plot:

ggplot(data= plot_median_data) + 
  geom_col(mapping= aes(x = member_casual, median_duration, fill = member_casual)) +
  geom_text(data = annual_annot, x = 1, y = 5,
            aes(label = median_duration)) +
  geom_text(data = casual_annot, x = 2, y = 5,
            aes(label = median_duration)) +
  labs(x = "Rider Type", 
       y = "Trip Duration in Mins",
       title = "Median Trip Duration by Time of Day") +
  theme(plot.title = element_text(color = "lightsalmon"),
        panel.background = element_rect(fill = "antiquewhite1")) +
  scale_x_discrete(labels = c("member" = "Annual", "casual" = "Casual")) +
  scale_fill_manual(values = c("deepskyblue4", "darkorange"),
                    name = "Rider Type",
                    labels = c("Annual", "Casual")) +
  facet_wrap(~time_of_day) 
```
* Number of Rides By Time of Day:

Monday

```{r message=TRUE, warning=TRUE}

# first we made smaller tables with aggregated data:

mon_annual_rides <- combined_cyclistic_v7 %>% 
  filter(day_of_week == "Mon") %>% 
  group_by(member_casual, time_of_day) %>% 
  summarise(rides_by_member = n(), .groups = "drop")

mon_total_ride <- combined_cyclistic_v7 %>% 
  filter(day_of_week == "Mon") %>% 
  group_by(time_of_day) %>% 
  summarise(total_rides = n(), .groups = "drop")

mon_annual_rides <- left_join(
  mon_annual_rides, mon_total_ride, by = "time_of_day")

# added a column for percentage of rides between rider types:

mon_annual_rides$perc_of_rides <- scales::percent(
  mon_annual_rides$rides_by_member / mon_annual_rides$total_rides, accuracy = 1)

# made a data frame for annotation layer:

mon_label_vector_perc <-  mon_annual_rides$perc_of_rides

mon_label_vector_rides <- prettyNum(mon_annual_rides$rides_by_member, 
                                    big.mark = ",", scientific = FALSE)

mon_label_df_merged <- data.frame(
  x = c(1, 1, 2, 2, 3, 3, 4, 4, 1, 1, 2, 2, 3, 3, 4, 4), 
  y = c(140000, 125000, 235000, 220000, 140000, 125000, 75000, 60000,
        30000, 15000, 60000, 45000, 30000, 15000, 20000, 5000),
  label = c(rbind(mon_label_vector_perc, mon_label_vector_rides)))

# then the code for the plot:
  
combined_cyclistic_v7 %>% 
  filter(day_of_week == "Mon") %>% 
  ggplot(aes(x = time_of_day, fill = member_casual)) +
    geom_bar() +
  geom_text(data = mon_label_df_merged, 
            aes(x = x, y = y, label = label), inherit.aes = FALSE)+
    labs(x = "Time of Day", 
       y = "Number of Rides",
       title = "Number of Rides by Time of Day") +
  theme(plot.title = element_text(color = "lightsalmon"),
        panel.background = element_rect(fill = "antiquewhite1")) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("deepskyblue4", "darkorange"),
                    name = "Rider Type",
                    labels = c("Annual", "Casual")) +
  annotate("text", x = 3, y= 275000, 
             label = "Monday",
             size = 6,
             fontface = "bold")
```


Saturday:

```{r}
# first we made smaller tables with aggregated data:

sat_annual_rides <- combined_cyclistic_v7 %>% 
  filter(day_of_week == "Sat") %>% 
  group_by(member_casual, time_of_day) %>% 
  summarise(rides_by_member = n(), .groups = "drop")

sat_total_ride <- combined_cyclistic_v7 %>% 
  filter(day_of_week == "Sat") %>% 
  group_by(time_of_day) %>% 
  summarise(total_rides = n(), .groups = "drop")

sat_annual_rides <- left_join(
  sat_annual_rides, sat_total_ride, by = "time_of_day")

# added a column for percentage of rides between rider types:

sat_annual_rides$perc_of_rides <- scales::percent(
  sat_annual_rides$rides_by_member / sat_annual_rides$total_rides, accuracy = 1)

# made a data frame for annotation layer:

sat_label_vector_perc <- sat_annual_rides$perc_of_rides

sat_label_vector_rides <- prettyNum(sat_annual_rides$rides_by_member,
                                    big.mark = ",", scientific = FALSE)

sat_label_df_merged <- data.frame(
  x = c(1, 1, 2, 2, 3, 3, 4, 4, 1, 1, 2, 2, 3, 3, 4, 4), 
  y = c(140000, 125000, 315000, 300000, 140000, 125000, 100000, 85000,
        50000, 35000, 125000, 105000, 65000, 50000, 35000, 20000),
  label = c(rbind(sat_label_vector_perc, sat_label_vector_rides)))

# then the code for the plot:
  
combined_cyclistic_v7 %>% 
  filter(day_of_week == "Sat") %>% 
  ggplot(aes(x = time_of_day, fill = member_casual)) +
    geom_bar() +
  geom_text(data = sat_label_df_merged, 
            aes(x = x, y = y, label = label), inherit.aes = FALSE)+
    labs(x = "Time of Day", 
       y = "Number of Rides",
       title = "Number of Rides by Time of Day") +
  theme(plot.title = element_text(color = "lightsalmon"),
        panel.background = element_rect(fill = "antiquewhite1")) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("deepskyblue4", "darkorange"),
                    name = "Rider Type",
                    labels = c("Annual", "Casual")) +
  annotate("text", x = 3, y= 275000, 
             label = "Saturday",
             size = 6,
             fontface = "bold")
```
* Number of Rides by Month:

```{r}

# a new data frame of aggregated data for the plot:

line_graph_data_1 <- combined_cyclistic_v7 %>% 
  group_by(member_casual, month) %>% 
  summarise(member_monthly = n(), .groups = "drop")

line_graph_data_2 <- combined_cyclistic_v7 %>% 
  group_by(month) %>% 
  summarise(total_monthly = n(), .groups = "drop")

line_graph_data_3 <- left_join(
  line_graph_data_1, line_graph_data_2, by = "month")

line_graph_data_3 <- mutate(line_graph_data_3, 
                            perc_of_rides = scales::percent (
                              member_monthly/total_monthly, accuracy = 1))

#the code for the plot:

ggplot(data = line_graph_data_3, aes(
  x = month, y = member_monthly, group = member_casual, label = perc_of_rides)) +
  geom_line(aes(color = member_casual)) +
  geom_point(aes(color = member_casual))+
  geom_text(hjust = 0.8, vjust = 0.4, nudge_x = 0.3, nudge_y = 10000) +
  scale_color_manual(values = c("deepskyblue4", "darkorange"),
                    name = "Rider Type",
                    labels = c("Annual", "Casual")) +
  labs(y = "Number of Rides",
    title = "Number of Rides by Month") +
  theme(axis.title.x = element_blank(),
        plot.title = element_text(color = "lightsalmon"),
        panel.background = element_rect(fill = "antiquewhite")) +
  scale_y_continuous(labels = scales::comma) +
  annotate("text", x = 2.5, y = 375000,
           label = "Warm months see a\ndramatic increase in\nuse",
           size = 3,
           fontface = "bold") +
  annotate("text", x = 6.75, y = 215000, 
           label = "Casual Rider's use\nincreases\n5-to-7 times",
           size = 3.5,
           fontface = "bold",
           color = "darkorange") +
  annotate("text", x = 11, y = 400000, 
           label = "Annual Members\nnearly double during\nwarmer months",
           size = 2.5, color = "deepskyblue4",
           fontface = "bold")

```
