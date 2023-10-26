load_election_vote_shares <- function(path = here::here("data", "dataland_election_results_1984_2023.csv")) {
    rawdata <- read.csv(path, stringsAsFactors = FALSE)

    rawdata %>%
        dplyr::select(year,
                      state = province,
                      region,
                      CC = cc_share, 
                      DGM = dgm_share, 
                      PDAL = pdal_share, 
                      SSP = ssp_share) %>%
        dplyr::arrange(region, state) -> election_results
}