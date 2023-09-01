library(tigris)
library(tidyverse)
library(sf)

# set filepath of where to 
# save raw block shapefiles

path <- "xwalk/"


# get 51 unique state fips 
# codes (including dc)

unique_states <- fips_codes %>% 
  filter(state_code < 60) %>%
  pull(state_code) %>% 
  unique()


# download block shapefiles by state, 
# abridge to only the geoid varaible, 
# and save 

walk( unique_states, 
        function(x){ 
           blocks( state = x, 
           year = 2010) %>% 
           select(GEOID10) %>% 
           st_write(str_c( path, "block_", x, ".geojson" ))
)


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

nccs_data <- read_csv( "xwalk/tinybmf.csv" )


nccs_data_sf <- 
  st_as_sf( nccs_data, 
            coords = c( "Longitude", "Latitude" ), 
            crs = 4326 ) %>% 
  st_transform( "EPSG:4269" )


# joins nccs data to 
# block data by state

join_nccs <- function( my_state ){
  
  print( my_state )
  
  state_abbv <- 
    state_xwalk %>% 
    filter( state_code == my_state ) %>%
    pull( state )
  
  nccs_state <- 
    filter( 
      nccs_data_sf, 
      STATE == state_abbv 
  )
  
  state_block <- 
    st_read( 
        str_c( path, "block_", my_state, ".geojson" ) 
  )

  data_out <- 
    st_join( nccs_state, state_block ) %>% 
    st_drop_geometry()
  
  write_csv( 
    data_out, 
    str_c("joined/joined_", 
    my_state, 
    ".csv" )
  )
  
}



dir.create( "joined" )
walk( unique_states, join_nccs )




