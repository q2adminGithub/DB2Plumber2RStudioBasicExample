# library(pool)
# library(plumber)
library(magrittr)

# Create pool connection
con <- pool::dbPool(
  drv = RPostgres::Postgres(),
  dbname = "anomaly",
  host = "db", # this needs to be the name of the postgres service
  # (line 3 in docker-compose.yml)
  user = "rahul",
  password = "pass",
  port = 5432)

# load required helpers
source("./helpers/error.R")
source("./helpers/logging.R")
source("./helpers/validator.R")

# load env variables
## USE THIS HOST TO START THE API CONTAINER VIA DOCKER COMPOSE
host <- Sys.getenv("HOST", "127.0.0.1")
## USE THIS HOST WHEN RUNNING API IN THIS RSTUDIO TO DEVELOP/TEST CODE
# host <- "127.0.0.1" # Sys.getenv("HOST", "127.0.0.1")
port <- strtoi(Sys.getenv("PORT", 8000))

# App initialization and settings for warning, trailing slash
app <- plumber::pr()
options(warn = -1)
plumber::options_plumber(trailingSlash = TRUE)

# Plumbber settings
app %>% 
  plumber::pr_set_error(error_handler) %>%
  plumber::pr_hooks(list(preroute = pre_route_logging, postroute = post_route_logging))

# Simple Routes
app %>%
  # plumber::pr_get("/", function(req, res){
  #   logger::log_warn("CUSTOM WARNING...")
  #   return(list(message = "Welcome R Services"))
  # }, serializer = plumber::serializer_unboxed_json()) %>%
    plumber::pr_get("/error", function(req, res){
      logger::log_error("CUSTOM ERROR LOG...")
      api_error("ERROR MESSAGE FROM HELPERS", 400)
    }, serializer = plumber::serializer_unboxed_json()) %>%
    plumber::pr_get("/default-error", function(req, res){
      stop("DEFAULT ERROR")
      }, serializer = plumber::serializer_unboxed_json())

# mount routes
##get all router files
r_routes_file_names <- base::list.files(path = './routes',
                                       full.names=TRUE, 
                                       recursive=TRUE)
##loop over all routers and mount them
for (file_name in r_routes_file_names) {
  route_name <- base::substring(file_name, 10, nchar(file_name) - 2)
  app %>%
    plumber::pr_mount(route_name, 
                      plumber::pr(file_name))
}

# app

#save current default openapi file
# t<-yaml::as.yaml(app$getApiSpec())
# fileConn<-file("output.txt")
# writeLines(t, fileConn)
# close(fileConn)

#load custom openapi file
app %>%
  plumber::pr_set_api_spec(yaml::read_yaml("openapi.yaml"))

# #* @plumber 
# function(pr) {
#   pr %>%
#     plumber::pr_set_api_spec(yaml::read_yaml("openapi.yaml"))
# }

 
# run plumber
app %>%
  plumber::pr_run(host = host, port = port)

# Close your pool connection on exit
app$registerHooks(
  list(
    "exit" = function() {
      pool::poolClose(pool)
    }
  )
)