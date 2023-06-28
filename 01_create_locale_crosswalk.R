# load libraries
library(tigris)
library(tidyverse)
library(sf)

# set filepath of where to save raw block shapefiles
path <- "raw/shapefiles/block/"

# get 51 unique state fips codes (including dc)
unique_states <- fips_codes %>% 
	filter(state_code < 60) %>%
	pull(state_code) %>% 
	unique()

# download block shapefiles by state, abridge to only the geoid varaible, and save 
walk(unique_states, function(x) blocks(state = x, 
														year = 2010) %>% 
		 	                     select(GEOID10) %>% 
		 	st_write(str_c(path, "block_", x, ".geojson")))

# list paths of all saved block shapefiles
block_paths <- list.files(path)

# read in locale data
locales <- st_read("raw/shapefiles/EDGE_Locale18_US/edge_locale18_nces_all_us.shp")

# make locale data valid
locales_1 <- st_make_valid(locales)

# joins locale data to block data by state
join_locale <- function(my_state){
	print(my_state)
	locale_filter <- filter(locales_1, STATEFP == my_state)
	state_block <- st_read(str_c(path, "block_", my_state, ".geojson"))
	
	data_out<- st_join(state_block, locale_filter, join = st_covered_by) %>% 
		st_drop_geometry()
	
	write_csv(data_out, str_c("intermediate/joined_", 
														my_state, 
														".csv" ))
	
}

walk( unique_states, join_locale)
