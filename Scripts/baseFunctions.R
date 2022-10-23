# FUNCTION: censusImport ####

## TESTING TO SEE IF DATA DOWNLOADS

# medianIncome <- get_acs(geography = "tract",
#                         state = "TN",
#                         variables = c(medincome = "B19013_001"), 
#                         year = 2020)
# 
# giniIndex <- get_acs(geography = "tract",
#                      variables = c(giniIndex = "B19083_001"),
#                      year = 2020,
#                      output = "wide")

censusImport <- function (states = NA){
  
  for (i in states){
    importStateData_ <- get_acs(geography = "tract",
                                variables = variables_to_get,
                                year = 2020,
                                state = i)
    
    if (which(states == i) == 1){
      censusData_ <- importStateData_[0,]
    }
    
    censusData_ <- rbind(censusData_, importStateData_)
    
  }
  
  censusData_
  
}

# FUNCTION: censusExport ####

# censusExport <- function(tractData_ = NA, censusData_ = NA){
#   
#   # CHECK FOR DB CONNECTION
#   if(!exists("con")){
#     library(DBI)
#     con <<- dbConnect(odbc::odbc(), 
#                       Driver = {"SQL Server"}, 
#                       Server = "WS5666", 
#                       Database = "BIFN2", 
#                       timeout = 10)
#   }
#   
#   # Export Tract to Zip Code Data
#   if(!is.null(tractData_)){
#     dbWriteTable(con, 
#                  "CENSUS.Dim_Tract_x_Zip",
#                  tractData_, 
#                  overwrite = TRUE, 
#                  batch_rows = 1000)
#     
#     print("Exported Tract to Zip table")
#   }else{
#     print("Nothing Exported: No Tract Data Found")
#   }
#   
#   # Export Census Data
#   if(!is.null(censusData_)){
#     dbWriteTable(con,
#                  "CENSUS.Fact_Census",
#                  censusData_,
#                  overwrite = TRUE,
#                  batch_rows = 1000)
#     
#     print("Exported Census Data")
#   }else{
#     print("Nothing Exported: No Census Data Found")
#   }
# 
# }