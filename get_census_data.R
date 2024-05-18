get_census_data <- function( geo, years=c(1990,2000,2007:2019), format="long" ) {

  get_yearcsv <- function( year.i )
  { 
    if( year.i %in% c(1990,2000) )
    { year.csv <- paste0( year.i, ".csv" ) }
    if( year.i > 2000 )
    { year.csv <- paste0( year.i-2, "-", year.i+2, ".csv" ) }
    return( year.csv )
  }

  get_data <- function( geo, year )
  {
    BASE <- "https://nccsdata.s3.us-east-1.amazonaws.com/geo/data/"
    GEO <- paste0( geo, "/", geo, "_" )
    YEAR.CSV <- get_yearcsv( year )
    URL <- paste0( BASE, GEO, YEAR.CSV )
    d <- NULL 
    try( d <- read.csv( URL, colClasses="character" ) )
    return( d )
  }

  d.list <- list()

  for( i in years )
  {
    v_year <- paste0( "v", i )
    d <- get_data( geo=geo, year=i )
    d$version <- v_year
    d.list[[ v_year ]] <- d
  }

  df <- dplyr::bind_rows( d.list )

  if( format == "wide" )
  {
    geoids <- c("geoid","geoid_2010","cbsa_code","cbsa_title","metro")
    idvars <- geoids[ geoids %in% names(df) ]
    df <- reshape( df, idvar=idvars, timevar="version", direction="wide" )
  }

  return( df )
}
