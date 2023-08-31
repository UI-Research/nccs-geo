# NCCS Geographic Crosswalks

This repository houses the code to create geographic crosswalks between various geographic levels. 

To replicate the code, run R scripts in numerical order.

The data for this work currently lives on Box. Email cdavis@urban.org for access.

There are two crosswalk types included; one at the census block level and one at the census tract level. 

### TRACTX: Census Tract Crosswalk [ 74,091 tracts/rows, 15 MB ]

  - Public Use Microdata Areas (PUMAs)
  - Core Based Statistical Areas (CBSAs)
  - Combined Statistical Areas (CSAs)
  - County
  - State
  - Woodard's Cutural Regions
  - American Communities Cultural Regions
  - Census Regions
  - Census Divisions

```r
x <- "https://nccsdata.s3.us-east-1.amazonaws.com/geo/xwalk/TRACTX.csv"
d <- readr::read_csv(x)
d[,1:5] %>% as.data.frame() %>% head() %>% knitr::kable( align="c" )
d[,6:7] %>% as.data.frame() %>% head() %>% knitr::kable( align="c" )
d[,8:9] %>% as.data.frame() %>% head() %>% knitr::kable( align="c" )
d[,10:13] %>% as.data.frame() %>% head() %>% knitr::kable( align="c" )
```

| tract.census.geoid | county.census.geoid | puma.census.geoid | state.census.geoid | state.census.name |
|:------------------:|:-------------------:|:-----------------:|:------------------:|:-----------------:|
|    01001020100     |        01001        |       02100       |         01         |      Alabama      |
|    01001020200     |        01001        |       02100       |         01         |      Alabama      |
|    01001020300     |        01001        |       02100       |         01         |      Alabama      |
|    01001020400     |        01001        |       02100       |         01         |      Alabama      |
|    01001020500     |        01001        |       02100       |         01         |      Alabama      |
|    01001020600     |        01001        |       02100       |         01         |      Alabama      |


| metro.census.cbsa10.geoid |           metro.census.cbsa10.name           |
|:-------------------------:|:--------------------------------------------:|
|           33860           | Montgomery, AL Metropolitan Statistical Area |
|           33860           | Montgomery, AL Metropolitan Statistical Area |
|           33860           | Montgomery, AL Metropolitan Statistical Area |
|           33860           | Montgomery, AL Metropolitan Statistical Area |
|           33860           | Montgomery, AL Metropolitan Statistical Area |
|           33860           | Montgomery, AL Metropolitan Statistical Area |



| metro.census.csa10.geoid |                 metro.census.csa10.name                 |
|:------------------------:|:-------------------------------------------------------:|
|           388            | Montgomery-Alexander City, AL Combined Statistical Area |
|           388            | Montgomery-Alexander City, AL Combined Statistical Area |
|           388            | Montgomery-Alexander City, AL Combined Statistical Area |
|           388            | Montgomery-Alexander City, AL Combined Statistical Area |
|           388            | Montgomery-Alexander City, AL Combined Statistical Area |
|           388            | Montgomery-Alexander City, AL Combined Statistical Area |


| region.woodard.nation | region.woodard.culture | region.census.main | region.census.division |
|:---------------------:|:----------------------:|:------------------:|:----------------------:|
|      DEEP SOUTH       | Working Class Country  |       South        |   East South Central   |
|      DEEP SOUTH       | Working Class Country  |       South        |   East South Central   |
|      DEEP SOUTH       | Working Class Country  |       South        |   East South Central   |
|      DEEP SOUTH       | Working Class Country  |       South        |   East South Central   |
|      DEEP SOUTH       | Working Class Country  |       South        |   East South Central   |
|      DEEP SOUTH       | Working Class Country  |       South        |   East South Central   |


BLOCKX: Census Block Crosswalk [ 11,078,297 blocks/rows, 636 MB ]

  - Census Places
  - Urban/Rural Areas (Census)
  - Urvan/Rural Areas (NCES Locales)
  - Voting Districts
  - ZCTAs (zip code equivalents)

```r
url <- "https://nccsdata.s3.us-east-1.amazonaws.com/geo/xwalk/BLOCKX.csv"
d <- readr::read_csv( url )
d[,1:4] %>% as.data.frame() %>% head() %>% knitr::kable( align="c" )
d[,5:8] %>% as.data.frame() %>% head() %>% knitr::kable( align="c" )
```

| block.census.geoid | tract.census.geoid | zcta.census.geoid | place.census.geoid |
|:------------------:|:------------------:|:-----------------:|:------------------:|
|  010010201001000   |    01001020100     |       36067       |      0162328       |
|  010010201001001   |    01001020100     |       36067       |      0162328       |
|  010010201001002   |    01001020100     |       36067       |      0162328       |
|  010010201001003   |    01001020100     |       36067       |      0162328       |
|  010010201001004   |    01001020100     |       36067       |      0162328       |
|  010010201001005   |    01001020100     |       36067       |      0162328       |


| county.census.geoid | vtd.census.geoid | urbanrural.census.geoid | urbanrural.nces.geoid |
|:-------------------:|:----------------:|:-----------------------:|:---------------------:|
|        01001        |       0220       |           NA            |          NA           |
|        01001        |       0220       |           NA            |          41           |
|        01001        |       0220       |          58600          |          NA           |
|        01001        |       0160       |           NA            |          NA           |
|        01001        |       0160       |           NA            |          41           |
|        01001        |       0160       |           NA            |          41           |

