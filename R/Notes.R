# curl -X GET "http://api:8000/route-A/?msg=t"


# Send API request
res <- httr::GET(paste0("http://", HOST), port = PORT, path = "/db/dbisconnected")
jsonlite::fromJSON(httr::content(res, as = 'text', encoding = "UTF-8"))

url <- "http://api:8000/db/dbgetTable?name=iris"
res <- httr::GET(paste0("http://", HOST), port = PORT, path = "/db/dbgetTable?name=iris")
res <- httr::GET(url = url)
tb <- jsonlite::fromJSON(httr::content(res, as = 'text', encoding = "UTF-8"))
df <- dplyr::tibble(tb)

jsonlite::fromJSON(geterrmessage())


con %>% DBI::dbRemoveTable('cars')

# curl -X GET "http://api/db/dbgetTable?name=iris" -H "accept: application/json"