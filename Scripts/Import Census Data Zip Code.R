# LOAD LIBRARIES ####
library(tidycensus)
library(httr)
library(jsonlite)
library(tidyverse)
library(DBI)

# LOAD API VALUES ####
source("API_Information.R")
source("Scripts/baseFunctions.R")

# CREATE LOCAL DB CONNECTION
con <- dbConnect(odbc::odbc(), 
                 Driver = {"SQL Server"}, 
                 Server = "WS5666", 
                 Database = "BIFN2", 
                 timeout = 10)

# LOAD VARIABLES FOR ACS5 DATA (2020) ####
v20 <- load_variables(2020, "acs5", cache = T)
v20S <- load_variables(2020, "acs5/subject")

# IMPORT DATA BY CATEGORY ####
# TODO [Demographic]
# [Education]
# [Income]
# [Industry]

# DEMOCRATIC VARIABLES SCRIPT ####
DemographicVariables <- c()

demographic_raw <- get_acs()

demographic <- demographic_raw

# EDUCATION VARIABLES SCRIPT ####
EducationVariables <- c(Edu_No_HS = "B06009_002", 
                        Edu_HS = "B06009_003", 
                        Edu_Associates = "B06009_004", 
                        Edu_Bachelor = "B06009_005",
                        Edu_Grad = "B06009_006")


education_raw <- get_acs(geography = "zcta",
                     variables = EducationVariables, 
                     year = 2020, 
                     survey = "acs5",
                     output = "tidy",
                     summary_var = "B06009_001",
                     cache_table = T)

education <- education_raw %>%
  mutate(estimate = as.integer(estimate),
         summary_est = as.integer(summary_est),
         Survey = "Education") %>%
  select(GeoID = GEOID,
         Name = NAME,
         Survey,
         Variable = variable,
         Estimate = estimate,
         Summary_Est = summary_est)

# Export Education Census Data (CENSUS.Fact_Eductaion)
# dbWriteTable(con,
#             "CENSUS_Fact_Education",
#             education,
#             overwrite = TRUE,
#             batch_rows = 1000)

# INCOME VARIABLES SCRIPT
IncomeVariables <- c(LT10k = "B19001_002",
                     BT_10k_15k = "B19001_003",
                     BT_15k_20k = "B19001_004",
                     BT_20k_25k = "B19001_005",
                     BT_25k_30k = "B19001_006",
                     BT_30k_35k = "B19001_007",
                     BT_35k_40k = "B19001_008",
                     BT_40k_45k = "B19001_009",
                     BT_45k_50k = "B19001_010",
                     BT_50k_60k = "B19001_011",
                     BT_60k_75k = "B19001_012",
                     BT_75k_100k = "B19001_013",
                     BT_100k_125k = "B19001_014",
                     BT_125k_150k = "B19001_015",
                     BT_150k_200k = "B19001_016",
                     GT_200k = "B19001_017")

income_raw <- get_acs(geography = "zcta",
                     variables = IncomeVariables, 
                     year = 2020, 
                     survey = "acs5",
                     output = "tidy",
                     summary_var = "B19001_001",
                     cache_table = T)

income <- income_raw %>%
  mutate(estimate = as.integer(estimate),
         summary_est = as.integer(summary_est),
         Survey = "Income") %>%
  select(GeoID = GEOID,
         Name = NAME,
         Survey,
         Variable = variable,
         Estimate = estimate,
         Summary_Est = summary_est)

# Export Income Census Data (CENSUS.Fact_Income)
# dbWriteTable(con,
#              "CENSUS_Fact_Income",
#              income,
#              overwrite = TRUE,
#              batch_rows = 1000)

# INDUSTRY/EMPLOYMENT VARIABLES SCRIPT
IndustryVariables <- c(Aggricuture = "S2405_C01_002",
                       Construction = "S2405_C01_003",
                       Manufacturing = "S2405_C01_004",
                       WholeSale_Trade = "S2405_C01_005",
                       Retail_Trade = "S2405_C01_006",
                       Transportatioin = "S2405_C01_007",
                       Information = "S2405_C01_008",
                       Finance_Insurance = "S2405_C01_009",
                       Professional_Waste_Mgmt = "S2405_C01_010",
                       Educational = "S2405_C01_011",
                       Arts = "S2405_C01_012",
                       Other_Non_PublicAdmin = "S2405_C01_013",
                       PublicAdmin = "S2405_C01_014"
                       )

industry_raw <- get_acs(geography = "zcta",
                        variables = IndustryVariables,
                        year = 2020,
                        survey = "acs5",
                        summary_var = "S2405_C01_001")

industry <- industry_raw %>%
  mutate(estimate = as.integer(estimate),
         summary_est = as.integer(summary_est),
         Survey = "Industry") %>%
  select(GeoID = GEOID,
         Name = NAME,
         Survey,
         Variable = variable,
         Estimate = estimate,
         Summary_Est = summary_est)

# Export Industry Census Data (CENSUS.Fact_Industry)
# dbWriteTable(con,
#              "CENSUS_Fact_Industry",
#              industry,
#              overwrite = TRUE)

# APPEND ALL CENSUS DATA ####
censusData <- rbind(education, income, industry)

# Export Census Data
dbWriteTable(con,
             "Fact_CENSUS",
             censusData,
             overwrite = TRUE,
             batch_rows = 10000)

# MISC VARIABLES SCRIPT ####
MiscVariables <- c(
  median_home_value = "B25077_001",
  median_income = "DP03_0062",
  total_population = "B01003_001",
  median_age = "B01002_001",
  pct_white = "DP05_0077P"
)

misc_raw <- get_acs(geography = "zcta",
                      variables = MiscVariables, 
                      year = 2020, 
                      survey = "acs5",
                      output = "tidy",
                      cache_table = T)

# GINI INDEX SCRIPT ####
giniIndex <- get_acs(geography = "zcta",
                     variables = c(giniIndex = "B19083_001"),
                     year = 2020) %>%
  rename(GeoID = GEOID,
         Name = NAME,
         Variable = variable,
         Estimate = estimate)
