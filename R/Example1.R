library(magrittr)

# An example data frame to play with
iris = as.data.frame(iris)
summary(iris)

## make names db safe: no '.' or other illegal characters,
## all lower case and unique
dbSafeNames = function(names) {
  names = gsub('[^a-z0-9]+','_',tolower(names))
  names = make.names(names, unique=TRUE, allow_=TRUE)
  names = gsub('.','_',names, fixed=TRUE)
  names
}
##correct illegal characters and check
colnames(iris) = dbSafeNames(colnames(iris))
summary(iris)


# Create a connection to the database
##open connection to db
con <- DBI::dbConnect(
  drv = RPostgres::Postgres(),
  dbname = "anomaly",
  host = "db", # this needs to be the name of the postgres service
  # (line 3 in docker-compose.yml)
  user = "rahul",
  password = "pass",
  port = 5432
)

## write the table into the database. Use row.names=FALSE to prevent the query 
## from adding the column 'row.names' to the table in the db
con %>% DBI::dbWriteTable('iris',iris, row.names=FALSE, overwrite = TRUE)
##list tables in DB
con %>% DBI::dbListTables()
##get table from DB and save as dataframe
df <-con %>% dplyr::tbl("iris")
##select cols with dplyr & show query
df %>% dplyr::select(sepal_length,species) %>% dplyr::show_query()
##select cols with sql & show query
con %>% dplyr::tbl(dplyr::sql("SELECT sepal_length, species FROM iris")) %>% 
  dplyr::show_query()
#change data in R but not yet in db, but data is change only for a few rows (lazy)
df %>% dplyr::mutate(sepal_width=0)
#load all data in R and change data in R but not yet in db
df.new <- df %>% dplyr::collect() %>% dplyr::mutate(sepal_width=0)
#data is not change in DB yet
con %>% dplyr::tbl("iris")
#now commit changes to db
con %>% DBI::dbWriteTable('iris', df.new, overwrite = TRUE)

# write df to db via copy_to
con %>% dplyr::copy_to(cars)
# list table
con %>% dplyr::tbl("cars") %>% dplyr::collect()
#insert rows into existing table in db
con %>% DBI::dbAppendTable('cars', cars)
con %>% dplyr::tbl("cars") %>% dplyr::collect()

