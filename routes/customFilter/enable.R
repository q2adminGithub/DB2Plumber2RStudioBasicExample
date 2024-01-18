# routes/custom-filter/enable.R

#* Endpoint with custom filter enabled
#* @serializer unboxedJSON
#* @get /
function(req, res) {
  return(list(message = "Custom Filter is enabled in this endpoint"))
}

#* Another Endpoint with custom filter enabled
#* @serializer unboxedJSON
#* @get /test
function(req, res) {
  return(list(message = "Custom Filter is enabled in this endpoint"))
}


# #* @plumber
# function(pr) {
#   pr %>%
#     plumber::pr_filter("custom-filter", function(req, res) {
#       logger::log_info("CUSTOM FILTER CALLED")
#       plumber::forward()
#     })
# }