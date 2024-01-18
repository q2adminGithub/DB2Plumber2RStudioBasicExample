# routes/db.R


#* Connect to db
#* @param dbname A string. Name of DB
#* @param host A string. This needs to be the name of the DB service
#* @param user A string. User name
#* @param password A string. DB password
#* @param port A number. Port number
#* @get /dbconnect
function(req, res) {
  #get input parameters
  dbname <- req$args$dbname
  host <- req$args$host
  user <- req$args$user
  password <- req$args$password
  port <- req$args$port
  #connect to db
  con <- pool::dbPool(
    drv = RPostgres::Postgres(),
    dbname = dbname,
    host = host, # this needs to be the name of the postgres service
    # (line 3 in docker-compose.yml)
    user = user,
    password = password,
    port = port)
  #check if db is connected
  isDBconnected <- pool::dbIsValid(con)
  if(!isDBconnected) {
    logger::log_error("DB IS NOT CONNECTED!")
    logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
    api_error("DB IS NOT CONNECTED! FROM GET db/dbconnect", 400)
  } else {
    #assign connection object as global variable
    assign("con", con, envir = .GlobalEnv)
    return(list(message = "DB is connected..."))
  }
}

#* Check if db connection is valid
#* @get /dbisconnected
function(req, res) {
  res <- pool::dbIsValid(con)
  return(res)
}

#* Close db connection
#* @get /dbcloseconnection
function(req, res) {
  res <- pool::poolClose(con)
  return(res)
}

#* Get data table
#* @param name A string. Table name
#* @get /dbgetTable
function(req, res) {
  #check if db is connected
  isDBconnected <- pool::dbIsValid(con)
  if(!isDBconnected) {
    logger::log_error("DB IS NOT CONNECTED!")
    logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
    api_error("DB IS NOT CONNECTED! FROM GET db/dbgetTable", 400)
  } else {
    name <- req$args$name
    res <- con %>% dplyr::tbl(name) %>% dplyr::collect()
    return(res)
  }
}

#* Create data table
#* @param name A string. Table name
#* @param overwrite A boolean. Flag to overwrite existing data table
#* @serializer json
#* @post /dbCreateTable
function(req, res) {
  #check if db is connected
  isDBconnected <- pool::dbIsValid(con)
  if(!isDBconnected) {
    logger::log_error("DB IS NOT CONNECTED!")
    logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
    api_error("DB IS NOT CONNECTED! FROM GET db/dbgetTable", 400)
  } else {
    name <- req$args$name
    value <- req$args$value
    overwrite <- req$args$overwrite
    data <- as.data.frame(req$body$data)
    res <- con %>% DBI::dbWriteTable(name, data, overwrite = TRUE)
    return(res)
  }
}

#* Remove data table
#* @param name A string. Table name
#* @get /dbRemoveTable
function(req, res) {
  #get name
  name <- req$args$name
  #check if db is connected
  isDBconnected <- pool::dbIsValid(con)
  if(!isDBconnected) {
    logger::log_error("DB IS NOT CONNECTED!")
    logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
    api_error("DB IS NOT CONNECTED! FROM GET db/dbgetTable", 400)
  } else {#check if table is in db
    l <- con %>% DBI::dbListTables()
    if(name %in% l) {#remove table
      con %>% DBI::dbRemoveTable(name)
    } else {#this table is not in db
      logger::log_error(glue::glue("TABLE {name} IS NOT IN DB!"))
      logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
      api_error(glue::glue("TABLE {name} IS NOT IN DB! FROM GET db/dbgetRemoveTable"), 400)
    }
  }
}
