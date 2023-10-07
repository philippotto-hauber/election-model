# function to load the states and corresponding regions of Dataland 
# source is the provided .csv file
# output is a dataframe with two columns: state and region
load_dataland_states_regions <- function(path = here::here("data", "dataland_demographics.csv")){
    dat <- read.csv(path, stringsAsFactors = FALSE)
    df <- dat[, c("province", "region")]
    names(df)[grepl("province", names(df))] <- "state"
    df <- df[order(df$region, df$state), ]
    rownames(df) <- seq(1, nrow(df))
    df
}