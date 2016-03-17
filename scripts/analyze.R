# Hannah Recht, 01-31-16
# Analyze NY Philharmonic concert metadata
# Data source: NY Philharmonic digital archives https://github.com/nyphilarchive/PerformanceHistory
# https://raw.githubusercontent.com/nyphilarchive/PerformanceHistory/master/Programs/complete.xml

library(dplyr)

main <- read.csv("data/programs_main.csv", stringsAsFactors = F)
concerts <- read.csv("data/programs_concerts.csv", stringsAsFactors = F)
works <- read.csv("data/programs_works.csv", stringsAsFactors = F)

########################################################################################################
# When selected movements are performed, each movement is counted as its own work
# ie if they perform 15 out of 16 movements, that's counted as 15 separate works - treat this as one work, not 15
# This is particularly noticeable for the Messiah - see programid 9542, 9678, 10608 etc
# Collapse these into a single work and create an nmovements column
########################################################################################################
works <- works %>% mutate(p = 1) %>%
  group_by(programid, composer, work, conductor) %>% 
  summarize(nmovements = sum(p))
 
# Now replace nworks with new calculation that counts each piece as 1 work
nworks <- works %>% mutate(p = 1)%>%
  group_by(programid) %>%
  summarize(nworks = sum(p))

main <- main %>% select(-nworks)
main <- left_join(main, nworks, by="programid")
main$nworks[is.na(main$nworks)] <- 0
summary(main$nworks)

works <- left_join(works, main, by="programid")

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

# super redundant one row per work x concert
full <- merge(concerts, works, by="programid", all.x=T, all.y=T)

locations <- as.data.frame(table(concerts$location))
colnames(locations) <- c("location", "concerts")

########################################################################################################
# Analysis
########################################################################################################

worksfreq <- full %>% mutate(p=1) %>%
  group_by(composer, work, orchestra) %>% 
  summarize(nconcerts = sum(p))