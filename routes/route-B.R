# routes/route.R

#* Return a message
#* @param msg The message to echo
#* @serializer unboxedJSON
#* @get /
function(msg="") {
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Return a hello message
#* @serializer unboxedJSON
#* @get /hello
function(msg="") {
  list(msg = 'Hallo from /hello endpoint')
}