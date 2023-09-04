d <- read.csv("tinybmf.csv")


keep <- 
c( 
"EIN", 
"NAME",
"SEC_NAME", 
"RULEDATE",
"SUBSECCD",
"FNDNCD",
"FRCD", 
"NTEEFINAL", 
"NTEECC",
"NAICS",
"LEVEL1",
"LEVEL2",
"LEVEL3",
"LEVEL4", 
"FILER", 
"ZFILER",
"OUTREAS", 
"OUTNCCS", 
"TAXPER",
"ACCPER",
"INCOME",
"ASSETS",
"CTAXPER",
"CFINSRC",
"CTOTREV",
"CASSETS",
"ADDRESS", 
"CITY", 
"STATE",
"ZIP5",
"Match_addr", 
"Longitude", 
"Latitude", 
"Addr_type", 
"Score",
"GEOID10")

dd <- d[keep]

x <- dd$GEOID10
dd$GEOID10 <- stringr::str_pad( x, 15, side="left", pad="0" )

dd$GEOTRACTID <- substr( dd$GEOID10, 1, 11 )
dd$GEOTRACTID <- paste0( "GEO-", dd$GEOTRACTID )

dd$GEOID10 <- paste0( "GEO-", dd$GEOID10 )

ntee <- read.csv( "ntee-crosswalk.csv" )

ntee2 <- ntee[c("NTEE", "NTEE2")]

dd <- merge( dd, ntee2, by.x="NTEEFINAL", by.y="NTEE", all.x=T )


keep2 <- 
c("EIN", "NAME", "SEC_NAME", 
"RULEDATE", "SUBSECCD", "FNDNCD", "FRCD", 
"NTEECC", "NTEEFINAL", "NTEE2", 
"NAICS", "LEVEL1", "LEVEL2", "LEVEL3", "LEVEL4", 
"FILER", "ZFILER", "OUTREAS", "OUTNCCS", 
"TAXPER", "ACCPER", "INCOME", "ASSETS", 
"CTAXPER", "CFINSRC", "CTOTREV", "CASSETS", 
"ADDRESS", "CITY", "STATE", "ZIP5", 
"Match_addr", "Longitude", "Latitude", 
"Addr_type", "Score", "GEOID10", "GEOTRACTID")

dd <- dd[keep2]


write.csv( dd, "TEST-BMF-BLOCKS-JOINED.csv" )






    

