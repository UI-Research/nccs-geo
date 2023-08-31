# load libraries

library(tidyverse)
library(tidycensus)
library(readxl)
library(tigris)
library(janitor)


#######
#######   TRACTS
#######


# reads in data from MABLE geocorr crosswalks
read_geocorr <- function(xwalk_path){
	xwalk_names <-  xwalk_path %>% 
		read_csv(n_max = 0) %>%
		names()
	
    xwalk_path %>% 
		read_csv(col_names = xwalk_names, 
						 skip = 2)
	
}
	


# get distinct states
state_abbv <- fips_codes %>% 
	select(state_name, state_code) %>% 
	distinct()

# get all county names to join woodard data on
my_counties <- counties(year = 2010) %>% 
	sf::st_drop_geometry() %>% 
	select(GEOID10, 
				 NAME10, 
				 NAMELSAD10) %>% 
	mutate(NAMELSAD10 = case_when(
	GEOID10 == "35013" ~ "Dona Ana County", 
	GEOID10 == "22059" ~ "LaSalle Parish",
	TRUE ~ NAMELSAD10
	), 
	state_code = str_sub(GEOID10, 1, 2)) %>% 
	left_join(state_abbv, by = "state_code")

# read in state to census region crosswalk
state_to_census_region <- read_csv("https://raw.githubusercontent.com/cphalpert/census-regions/master/us%20census%20bureau%20regions%20and%20divisions.csv") %>% 
	clean_names() %>% 
	select(-state_code)

# read in tract to puma crosswalk
tract_to_puma <- read_csv("https://www2.census.gov/geo/docs/maps-data/data/rel/2010_Census_Tract_to_2010_PUMA.txt") %>% 
	clean_names() %>% 
	mutate(county = str_c(statefp, countyfp), 
				 tract = str_c(county, tractce)) %>% 
	select(county, tract, puma = puma5ce)

# read in county to cbsa crosswalk
county_to_cbsa <- read_geocorr("raw/county_to_cbsa.csv") %>% 
	select(county, cbsa10, cbsaname10)

# read in county to csa crosswalk
county_to_csa <- read_geocorr("raw/county_to_csa.csv") %>% 
	select(county, csa10, csaname10)

# read in woodard crosswalk. The crosswalk does not have fips codes on it, so we hvae to merge by county name and state name.
# there is a note from the folks who made this crosswalk that they were in contact with woodard and some of these typologies are splitting up some counties,
# which this crosswalk does not reflect. I couldn't find one that did, however. 
woodards <- read_csv("raw/woodards american nations by county - woodards american nations by county.csv") %>% 
	janitor::clean_names() %>% 
	mutate(county_name_full = case_when(
		str_detect(county_name_full, "Ana County") ~ "Dona Ana County", 
		str_detect(county_name_full, "Oglala") ~ "Shannon County",
		TRUE ~ county_name_full
	)) %>% 
	left_join(my_counties, by = c("county_name_full" = "NAMELSAD10", 
																"state_name")) %>% 
	select(county = GEOID10, 
				 woodard_nation_name)


# read in cultural crosswalk
cultural <- read_excel("raw/2023-Typology.xlsx") %>% 
	clean_names() %>% 
	mutate(county = str_pad(fips, 5, "left", "0")) %>% 
	select(county, cultural_regions = x2023_typology)


# join all tract info crosswalks together and save
tract_crosswalk <- tract_to_puma %>% 
	mutate(state_code = str_sub(county, 1, 2)) %>% 
	left_join(state_abbv, by = "state_code") %>%
	left_join(county_to_cbsa, by = "county") %>% 
	left_join(county_to_csa, by = "county") %>% 
	left_join(woodards, by = "county") %>%
	left_join(cultural, by = "county") %>% 
	left_join(state_to_census_region, by = c("state_name" = "state")) 

new.order <- 
c("tract", 
"county", 
"puma", 
"state_code", 
"state_name", 
"cbsa10", 
"cbsaname10", 
"csa10", 
"csaname10", 
"woodard_nation_name", 
"cultural_regions", 
"region", 
"division")

tract_crosswalk <- tract_crosswalk[new.order]

new.names <- 
c("tract.census.geoid", "county.census.geoid", "puma.census.geoid", 
"state.census.geoid", "state.census.name", "metro.census.cbsa10.geoid", 
"metro.census.cbsa10.name", "metro.census.csa10.geoid", "metro.census.csa10.name", 
"region.woodard.nation", "region.woodard.culture", "region.census.main", 
"region.census.division")

names(tract_crosswalk) <- new.names

saveRDS( tract_crosswalk, "final/TRACTX.RDS" )




#######
#######   BLOCKS
#######


# get file paths for block to x filepaths (4 in each) 
place_files <- list.files("raw/", pattern = "place", full.names = TRUE)
ua_files <- list.files("raw/", pattern = "ua", full.names = TRUE)
vtd_files <- list.files("raw/", pattern = "vtd", full.names = TRUE)
zcta_files <- list.files("raw/", pattern = "zcta", full.names = TRUE)

# read in block to place crosswalk data
block_place<- map_dfr(place_files, ~read_geocorr(.) %>% 
										mutate(county = str_pad(county, 5, "left", "0"), 
													 state = str_pad(state, 2, "left", "0"), 
													 tract = str_pad(as.numeric(tract) * 100, 
													 											 6, 
													 											 "left", 
													 											 "0"),
													 block = str_pad(block, 4, "left", "0")))

# read in block to urban area crosswalk data
block_ua <- map_dfr(ua_files, ~read_geocorr(.) %>% 
											mutate(county = str_pad(county, 5, "left", "0"), 
														 tract = str_pad(as.numeric(tract) * 100, 
														 											 6, 
														 											 "left", 
														 											 "0"),
														 block = str_pad(block, 4, "left", "0")))

# read in block to voting district crosswalk data
block_vtd <- map_dfr(vtd_files, ~read_geocorr(.) %>% 
										 	mutate(county = str_pad(county, 5, "left", "0"),
										 				 tract = str_pad(as.numeric(tract) * 100, 
										 				 											 6, 
										 				 											 "left", 
										 				 											 "0"),
										 				 block = str_pad(block, 4, "left", "0")))

# read in block to ZCTA crosswalk data
block_zcta <- map_dfr(zcta_files, ~read_geocorr(.) %>% 
												mutate(county = str_pad(county, 5, "left", "0"),
															 tract = str_pad(as.numeric(tract) * 100, 
															 											 6, 
															 											 "left", 
															 											 "0"),
															 block = str_pad(block, 4, "left", "0")))

# clean place to block data
block_place_1 <- block_place %>% 
	transmute(block_geoid = str_c(county, tract, block), 
						tract_geoid = str_c(county, tract), 
						county_geoid = county,
						place_geoid = str_c(state, placefp)
						)

# clean place to ua data
block_ua_1 <- block_ua %>% 
	transmute(block_geoid = str_c(county, tract, block), 
						ua_geoid = ua)

# clean block to voting district data
block_vtd_1 <- block_vtd %>% 
	transmute(block_geoid = str_c(county, tract, block), 
						vtd_geoid = vtd) 

# clean block to zcta data
block_zcta_1 <- block_zcta %>% 
	transmute(block_geoid = str_c(county, tract, block), 
						zcta_geoid = zcta5)

# get block to locale crosswalk filepaths
locale_paths <- list.files("intermediate", pattern = "joined", full.names = TRUE)


# read in block to locale crosswalk data
block_locales <- map_dfr(locale_paths, ~read_csv(.) %>% 
												 	transmute(block_geoid = str_pad(GEOID10, 15, "left", "0"), 
												 						locale = LOCALE))


# merge block crosswalks together and fix geoids of those that aren't matching with the 2010 block shapefile (from the locale crosswalk)
full_block <- block_place_1 %>% 
left_join(block_ua_1, by = "block_geoid") %>% 
	left_join(block_vtd_1, by = "block_geoid") %>% 
	left_join(block_zcta_1, by = "block_geoid") %>%
	mutate(block_geoid = str_replace(block_geoid, "01e\\+05", "100000") %>%
				 	str_replace("02e\\+05", "200000") %>%
				 	str_replace("03e\\+05", "300000") %>%
				 	str_replace("04e\\+05", "400000"), 
				 block_geoid = 
				 	case_when(
				 		str_sub(block_geoid, 1, 5) == "02158" ~ str_c("02270", str_sub(block_geoid, 6, 15)), 
				 		str_sub(block_geoid, 1, 5) == "46102" ~ str_c("46113", str_sub(block_geoid, 6, 15)), 
				 		TRUE ~ block_geoid)) %>%
	left_join(block_locales, by = "block_geoid") %>% 
	mutate(tract_geoid = str_sub(block_geoid, 1, 11))



new.order <- 
c("block_geoid", 
"tract_geoid", 
"zcta_geoid",
"place_geoid",
"county_geoid",  
"vtd_geoid",
"ua_geoid",   
"locale")

full_block <- full_block[new.order]

new.names <- 
c("block.census.geoid",
"tract.census.geoid",
"zcta.census.geoid",
"place.census.geoid",
"county.census.geoid",
"vtd.census.geoid",
"urbanrural.census.geoid",
"urbanrural.nces.geoid")

names(full_block) <- new.names

# write out block crosswalk
saveRDS(full_block, "final/BLOCKX.RDS")
