library(rgdal)
library(rmapshaper)

chl <- readOGR(dsn="data/comunas.json",encoding = "UTF-8")
chl <- ms_simplify(chl, keep = 0.1)
chl <- write_rds(chl,"data/chl.rds")

muni_data <- read_csv("data/piemunicipal.csv")
muni_data <- write_rds(muni_data,"data/piemunicipal.rds")

social_data <- read_csv("data/sociales.csv")
social_data <- write_rds(social_data,"data/sociales.rds")