# Analyze NY Philharmonic concert metadata
# Data source: NY Philharmonic digital archives https://github.com/nyphilarchive/PerformanceHistory
# https://raw.githubusercontent.com/nyphilarchive/PerformanceHistory/master/Programs/complete.xml

library(dplyr)
library(stringr)
library(tidyr)

main <- read.csv("data/programs_main.csv", stringsAsFactors = F)
concerts <- read.csv("data/programs_concerts.csv", stringsAsFactors = F)
works <- read.csv("data/programs_works.csv", stringsAsFactors = F)

########################################################################################################
# convert "None" to NA
########################################################################################################
formatNone <- function(dt) {
  dt[dt == "None"] <- NA
  return(dt)
}
main <- formatNone(main)
concerts <- formatNone(concerts)

########################################################################################################
# Count unique works performed in each programid
########################################################################################################
nworks_byprogram <- works %>%
  group_by(programid) %>%
  summarize(nworks = n_distinct(workid))

# Join to works dataset, add main data
works <- left_join(works, nworks_byprogram, by = "programid")
works <- left_join(works, main, by = "programid")
works <- works %>% select(programid, season, orchestra, nworks, nconcerts, everything()) %>%
  select(-id)

########################################################################################################
# Concerts
########################################################################################################
concerts <- left_join(concerts, main, by = "programid")
concerts <- left_join(concerts, nworks_byprogram, by = "programid")
concerts <- concerts %>% select(programid, season, orchestra, nworks, nconcerts, concertnumber, everything())

# Split location into city and state/country
concerts <- concerts %>% separate(location, into=c("city", "state_country"), sep=",", extra = "merge")

cities <- concerts %>% group_by(city, state_country) %>%
  summarize(concerts = n()) %>%
  arrange(desc(concerts))
state_countries <- concerts %>% group_by(state_country) %>%
  summarize(concerts = n()) %>%
  arrange(desc(concerts))

########################################################################################################
# Analysis
########################################################################################################

# Most popular composers
# Group by program & work (because if they performed 5/6 movements, it gets 5 rows)
composers <- works %>% group_by(programid, workid, composer, nconcerts, orchestra) %>%
  summarize(temp = n()) %>%
  group_by(composer, orchestra) %>%
  summarize(performances = sum(nconcerts)) %>%
  arrange(desc(performances))

# Most popular works
pieces <- works %>% group_by(programid, workid, work, composer, nconcerts, orchestra) %>%
  summarize(temp = n()) %>%
  group_by(workid, work, composer, orchestra) %>%
  summarize(performances = sum(nconcerts)) %>%
  arrange(desc(performances))

# Pieces by season
works_byseason <- works %>% group_by(programid, season, workid, work, composer, nconcerts, orchestra) %>%
  summarize(temp = n()) %>%
  group_by(season, workid, work, composer, orchestra) %>%
  summarize(performances = sum(nconcerts)) %>%
  arrange(season, desc(performances))  
mahler1 <- works_byseason %>% filter(workid == 52826) %>% group_by(season) %>%
  summarize(performances = sum(performances))
plot(mahler1$season, mahler1$performances, type = "l")
