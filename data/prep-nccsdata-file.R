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

dd$GEOTRACTID <- substr( d$GEOID10, 1, 11 )

write.csv( dd, "TEST-BMF-BLOCKS-JOINED.csv" )








  
    
  "FIPS",  "PMSA", "MSA_NECH",  
    



"RANDNUM",  
"NTEE1",   "NTMAJ10", "MAJGRPB",  
 "NTMAJ12", "NTMAJ5",  


"ZIP7", "ZIP", "f_address", 
 "Status", "Region", "RegionAbbr", 
"Subregion", "MetroArea", "City", "Nbrhd", "geometry", "Match_type", 
"LongLabel", "ShortLabel", "Type", "PlaceName", "Place_addr", 
"Phone", "URL", "Rank", "AddBldg", "AddNum", "AddNumFrom", "AddNumTo", 
"AddRange", "Side", "StPreDir", "StPreType", "StName", "StType", 
"StDir", "BldgType", "BldgName", "LevelType", "LevelName", "UnitType", 
"UnitName", "SubAddr", "StAddr", "Block", "Sector", "District", 
"Territory", "Zone", "Postal", "PostalExt", "Country", "CntryName", 
"LangCode", "Distance", "DisplayX", "DisplayY", "Xmin", "Xmax", 
"Ymin", "Ymax", "ExInfo", "id", )
