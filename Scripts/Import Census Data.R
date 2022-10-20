library(tidycensus)
library(httr)
library(jsonlite)
library(tidyverse)

# LOAD API VALUES
source("API_Information.R")

# DOWNLOAD ZIP CODE TO TRACK CONVERSION FROM HUD.GOV
tract_type = '1'
tract_query = 'All'
tract_url <- paste0("https://www.huduser.gov/hudapi/public/usps?type=", tract_type, "&query=", tract_query)

zip_tract <- GET(tract_url,
                 content_type_json(),
                 add_headers('Authorization' = paste0("Bearer ", API_KEY_HUD)))

zip_tract_char <- fromJSON(rawToChar(zip_tract$content))
zip_tract.df <- do.call(rbind, lapply(zip_tract_char, as.data.frame)) %>%
  mutate(ZIP = results.zip,
         GEOID = results.geoid,
         City = str_to_title(results.city),
         State = results.state,
         Year = year,
         Quarter = quarter) %>%
  select(Year,
         Quarter,
         GEOID,
         ZIP,
         City, 
         State)

# LOAD VARIABLES FOR ACS5 DATA (2020)
v20 <- load_variables(2020, "acs5", cache = T)

# LOAD STATE ABBREVIATIONS
states <- state.abb

# VARIABLES TO GET FROM CENSUS
variables_to_get <- c(
  median_home_value = "B25077_001",
  median_income = "DP03_0062",
  total_population = "B01003_001",
  median_age = "B01002_001",
  pct_college = "DP02_0068P",
  pct_foreign_born = "DP02_0094P",
  pct_white = "DP05_0077P",
  median_year_built = "B25037_001",
  percent_ooh = "DP04_0046P"
)

## TESTING TO SEE IF DATA DOWNLOADS

medianIncome <- get_acs(geography = "tract", 
              variables = c(medincome = "B19013_001"), 
              year = 2020)

giniIndex <- get_acs(geography = "tract",
                     variables = c(giniIndex = "B19083_001"),
                     year = 2020,
                     output = "wide")

## TODO:: CREATE FUNCTION TO ITERATE OVER STATES WITH THE DECLARED VARIABLES (variables_to_get)



