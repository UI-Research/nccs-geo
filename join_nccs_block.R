library(tigris)
library(tidyverse)
library(sf)

# set filepath of where to 
# save raw block shapefiles

path <- "xwalk/"


#set boolean for whether you want to download block shapefiles
download_block <- FALSE

# get unique state fips codes (including dc)

unique_states <- fips_codes %>% 
  filter(state_code != 74) %>%
  pull(state_code) %>% 
  unique()


# only run if download_block is TRUE
if(download_block){

# if shapefiles directory doesn't exist, create it
if(!dir.exists(path)){
  dir.create(path)
}

# download block shapefiles by state
# abridge to only the geoid variable
# and save 
	
walk(unique_states, function(x) {
  
  blocks(state = x, 
         year = 2010) %>% 
    select(GEOID10) %>% 
    st_write(str_c(path, "block_", x, ".geojson")) 
   })
  
  }


# list paths of all 
# saved block shapefiles

block_paths <- 
  list.files( path, full.names = TRUE )


# get state fips crosswalk

state_xwalk <- 
  fips_codes %>% 
  select( state_code, state ) %>% 
  distinct()


# read in nccs data

nccs_data <- read_csv( str_c(path, "tinybmf.csv" ))

nccs_data_sf <- st_as_sf(nccs_data, 
												 coords = c("Longitude",
												 					 "Latitude"),
												 crs = 4326) %>% 
  select(id, 
  			 STATE, 
  			 Longitude, 
  			 Latitude) %>%
  st_transform("EPSG:4269")

# if intermediate directory doesn't exist, create it
if(!dir.exists("intermediate")){
  dir.create("intermediate")
}

# if final directory doesn't exist, create it
if(!dir.exists("final")){
  dir.create("final")
}



# joins nccs data to block data by state
join_nccs <- function(my_state){
  print(my_state)

  # get state abbreviation  
  state_abbv <- state_xwalk %>% 
    filter(state_code == my_state) %>%
    pull(state)
  
  # keep only nccs data for the state we're joining to minimize memory and time
  nccs_state <- filter(nccs_data_sf,
  										 STATE == state_abbv)
  
  # read in block geojson
  state_block <- st_read(str_c(path, 
  														 "block_",
  														 my_state,
  														 ".geojson"))
  
  # join data and remove the geometry
  data_out<- st_join(nccs_state, 
  									 state_block) %>% 
    st_drop_geometry()
  
  # save the joined data
  write_csv(data_out, str_c("intermediate/joined_block_", 
                            my_state, 
                            ".csv" ))
  
}

# iterate through all states and join data
walk( unique_states, join_nccs)

# read in all joined data and append together
full_joined_dat <- list.files("intermediate", 
															pattern = "joined_block_", 
															full.names = TRUE) %>% 
  map_dfr(~read_csv(., 
  									col_types = list(GEOID10 = col_character())))

# joni abridged data with block info back to full dataset and write out
nccs_dat_full <- left_join(nccs_data,
													 full_joined_dat, 
													 by = c("id", "STATE")) %>% 
  write_csv("final/nccs_test.csv")

