load_election_vote_shares <- function(path = here::here("data", "dataland_election_results_1984_2023.csv")) {
    rawdata <- read.csv(path, stringsAsFactors = FALSE)

    rawdata %>%
        dplyr::select(year,
                      state = province,
                      region,
                      cc = cc_share, 
                      dgm = dgm_share, 
                      pdal = pdal_share, 
                      ssp = ssp_share) %>%
        dplyr::arrange(region, state) -> election_results
}