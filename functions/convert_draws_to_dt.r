convert_draws_to_dt <- function(draws, geographies, parties, dates_campaign){
  dt_prof <- setDT(
      as.data.frame(draws), 
      keep.rownames = "draw")
  dt_prof <- melt(
      dt_prof, 
      id.vars = c("draw"),
      variable.name = "tmp", value.name = "values")
  dt_prof[, c("t", "party", "geography") := tstrsplit(tmp, ".", fixed=TRUE)]
  # drop tmp column from data.table
  dt_prof[, tmp := NULL]
  dt_prof[, `:=`(values = ifelse(is.nan(values), NA, values), 
              t = dates_campaign[as.numeric(t)],
              draw = as.numeric(draw),
              party = parties[as.numeric(party)],
              geography = geographies[as.numeric(geography)]
              )
          ]
  return(as.data.frame(dt_prof))
}