# Set working directory
setwd("f:/diss copy/dissertation/Dissertation data/R_dist")

# Load necessary libraries
library(tidyverse)
library(forcats)

# Load the data
data <- read.csv("all_data_personality_master.csv")
dataWB <- read.csv("all_data_wellbeing_master.csv")

# Convert 'year.1' and 'year' columns to numeric
data$year.1 <- as.numeric(data$year.1)
dataWB$year <- as.numeric(dataWB$year)

# Identify the range of years in the wellbeing dataset
years_wellbeing <- unique(dataWB$year)

# Identify the existing years in the personality dataset
years_personality <- unique(data$year.1)

# Determine the missing years
missing_years <- setdiff(years_wellbeing, years_personality)

# Create placeholders for missing years, ensuring all columns are included
placeholders <- data.frame(
  year.1 = missing_years,
  LA_code = NA,
  LA_initial = NA,
  LA_name = NA,
  extra = NA,
  consc = NA,
  neuro = NA,
  open = NA,
  agree = NA,
  # Add other columns with default NA values if necessary
  stringsAsFactors = FALSE
)

# Append placeholders to the personality dataset
data_filled <- bind_rows(data, placeholders)

# Merge the datasets
mergedDF <- data_filled %>%
  left_join(dataWB, by = c("year.1" = "year"))

# View the merged data
View(mergedDF)

# Check the unique years
unique(data$year.1)
unique(mergedDF$year.1)

# Select relevant columns and bin the data
data2 <- data %>%
  select(c("extra", "consc", "neuro", "open", "agree", "LA_code", "LA_initial", "year.1"))

# Bin the data
data3 <- data2 %>%
  mutate(
    extrabin = case_when(
      extra >= 1 & extra < 2 ~ "1-2",
      extra >= 2 & extra < 3 ~ "2-3",
      extra >= 3 & extra < 4 ~ "3-4",
      extra >= 4 & extra <= 5 ~ "4-5",
      TRUE ~ NA_character_
    ),
    agreebin = case_when(
      agree >= 1 & agree < 2 ~ "1-2",
      agree >= 2 & agree < 3 ~ "2-3",
      agree >= 3 & agree < 4 ~ "3-4",
      agree >= 4 & agree <= 5 ~ "4-5",
      TRUE ~ NA_character_
    ),
    conscbin = case_when(
      consc >= 1 & consc < 2 ~ "1-2",
      consc >= 2 & consc < 3 ~ "2-3",
      consc >= 3 & consc < 4 ~ "3-4",
      consc >= 4 & consc <= 5 ~ "4-5",
      TRUE ~ NA_character_
    ),
    neurobin = case_when(
      neuro >= 1 & neuro < 2 ~ "1-2",
      neuro >= 2 & neuro < 3 ~ "2-3",
      neuro >= 3 & neuro < 4 ~ "3-4",
      neuro >= 4 & neuro <= 5 ~ "4-5",
      TRUE ~ NA_character_
    ),
    openbin = case_when(
      open >= 1 & open < 2 ~ "1-2",
      open >= 2 & open < 3 ~ "2-3",
      open >= 3 & open < 4 ~ "3-4",
      open >= 4 & open <= 5 ~ "4-5",
      TRUE ~ NA_character_
    )
  )

# Pivot longer
data3long <- data3 %>%
  select(-c("extra", "consc", "neuro", "open", "agree")) %>%
  pivot_longer(cols = -c("LA_code", "LA_initial", "year.1"), names_to = "Measurement", values_to = "Value")

# Define bin_to_midpoint function
bin_to_midpoint <- function(bin) {
  case_when(
    bin == "1-2" ~ 1.5,
    bin == "2-3" ~ 2.5,
    bin == "3-4" ~ 3.5,
    bin == "4-5" ~ 4.5,
    TRUE ~ NA_real_
  )
}

# Step 1: Remove NAs
data3long <- data3long %>%
  filter(!is.na(Value))

# Step 2 & 3: Convert bin ranges to their numeric midpoints
data3long <- data3long %>%
  mutate(Value = bin_to_midpoint(Value))

# Step 4: Filter to a new dataframe for the years 2011 and 2022
merged_DF_1122 <- data3long %>%
  filter(year.1 %in% c(2011, 2022)) #####mising 2022!!!!!##### how????####

# Calculate the total value for each LA_initial
total_values <- merged_DF_1122 %>%
  group_by(LA_initial) %>%
  summarize(TotalValue = sum(Value, na.rm = TRUE)) %>%
  arrange(desc(TotalValue))

# Reorder LA_initial based on total values
merged_DF_1122 <- merged_DF_1122 %>%
  mutate(LA_initial = factor(LA_initial, levels = total_values$LA_initial))

# Rename the bins
merged_DF_1122 <- merged_DF_1122 %>%
  mutate(Measurement = fct_recode(Measurement,
                                  "Openness" = "openbin",
                                  "Conscientiousness" = "conscbin",
                                  "Extraversion" = "extrabin",
                                  "Agreeableness" = "agreebin",
                                  "Neuroticism" = "neurobin"))

# Set the desired order of the levels
desired_order <- c("Openness", "Conscientiousness", "Extraversion", "Agreeableness", "Neuroticism")
merged_DF_1122$Measurement <- factor(merged_DF_1122$Measurement, levels = desired_order)

# Calculate the maximum value for each Measurement to position the labels
max_values <- merged_DF_1122 %>%
  group_by(Measurement) %>%
  summarize(MaxValue = max(Value, na.rm = TRUE))

# Add text labels for each facet
label_data <- max_values %>%
  mutate(LA_initial = max(total_values$LA_initial),  # Position to the far right
         Value = MaxValue + 0.5)  # Position slightly above the maximum value

# Plot with reordered LA_initial based on total values and desired facet order
ggplot(data = merged_DF_1122, aes(x = LA_initial, y = Value, fill = as.factor(Value))) +
  geom_bar(stat = "identity") +
  facet_wrap(~Measurement, scales = "free_x") +  # Allow each facet to have its own x-axis scale
  geom_text(data = label_data, aes(label = Measurement, x = LA_initial, y = Value), hjust = -0.1, vjust = -7, size = 3, fontface = "bold", check_overlap = TRUE) +
  scale_x_discrete(guide = guide_axis(angle = 90)) +
  labs(
    title = "2011 Local Authority Scores by O.C.E.A.N",
    x = "Local Authority",
    y = "Value",
    fill = "Value"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 6, face = "bold"),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    strip.text = element_blank()  # Hide the facet strip labels
  )

#IGNORE ALL BELOW...####
############################################################################
# Verify the data
#print("Structure of merged_DF_1122:")
#str(merged_DF_1122)

#print("First few rows of merged_DF_1122:")
#head(merged_DF_1122)



# Check the summary statistics
#summary(merged_DF_1122)
#print(colnames(mergedDF))
#print("Column names of mergedDF:")
#print(colnames(mergedDF))

# Define the columns you want to keep
#selected_columns <- c("extra", "agree", "consc", "neuro", "open", 
    #   #               "LA_code.y", "LA_initial.y", "LA_name", "measure_of_wb", 
   #                   "wb_rating", "WB_av", "year.1")

# Create the smaller dataframe
#mergedDFsmall <- mergedDF %>% select(all_of(selected_columns))

# View the structure of the smaller dataframe
#print("Structure of mergedDFsmall:")
#str(mergedDFsmall)

#unique(mergedDFsmall$WB_av) # shows N's and all the numerics
#class(mergedDFsmall$WB_av) # numeric

# Save the smaller dataframe to a CSV file

#write.csv(mergedDFsmall, "mergedDFsmall.csv", row.names = FALSE)

# Print the first few rows of the smaller dataframe
#print("First few rows of mergedDFsmall:")
#head(mergedDFsmall)
#unique(merged_DF_1122$year.1)
#unique(mergedDF$year.1)

## Run the regression model using mergedDF
#model <- lm(wb_rating ~ extra + agree + consc + neuro + open, data = mergedDFsmall)

# Summarize the model to view the results
#summary(model)

#DATAFRAME NOTES#
#mergedDF = the one we use in python..#


