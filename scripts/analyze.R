# Hannah Recht, 01-31-16
# Analyze NY Philharmonic concert metadata
# Data source: NY Philharmonic digital archives https://github.com/nyphilarchive/PerformanceHistory
# https://raw.githubusercontent.com/nyphilarchive/PerformanceHistory/master/Programs/complete.xml

library(dplyr)

main <- read.csv("data/programs_main.csv", stringsAsFactors = F)
concerts <- read.csv("data/programs_concerts.csv", stringsAsFactors = F)
works <- read.csv("data/programs_works.csv", stringsAsFactors = F)

########################################################################################################
# Take advantage of new workid field, count unique works performed in each programid
########################################################################################################
works <- works %>%
  group_by(programid) %>%
  mutate(nworks = n_distinct(workid))

# Join to main
temp <- works[!duplicated(works$programid),] 
main <- left_join(main, temp[ , c("programid", "nworks")], by = "programid")

########################################################################################################
# Concerts
########################################################################################################

concerts <- left_join(concerts, main, by="programid")
# See if event types are constant across programid
eventtypes <- concerts %>% mutate(p=1) %>%
  group_by(programid, eventtype) %>%
  summarize(freq = sum(p))
eventtypes$dup <- duplicated(eventtypes$programid)
# Nope, there are ~120 with multiple event types (usually subscription + student concerts)

locations <- as.data.frame(table(concerts$location))
colnames(locations) <- c("location", "concerts")

########################################################################################################
# Analysis
########################################################################################################

# Count times a piece has appeared - but multiple movements in one concert = 1 appearance