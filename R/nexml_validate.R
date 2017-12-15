ONLINE_VALIDATOR <- "http://162.13.187.155/nexml/phylows/validator"
CANONICAL_SCHEMA <- "http://162.13.187.155/nexml/xsd/nexml.xsd"
#ONLINE_VALIDATOR <- "http://www.nexml.org/nexml/phylows/validator"
#CANONICAL_SCHEMA <- "http://www.nexml.org/2009/nexml.xsd"

#' validate nexml using the online validator tool
#' @param file path to the nexml file to validate
#' @param schema URL of schema (for fallback method only, set by default).  
#' @details Requires an internet connection.  see http://www.nexml.org/nexml/phylows/validator for more information in debugging invalid files
#' @return TRUE if the file is valid, FALSE or error message otherwise
#' @export
#' @importFrom httr POST upload_file content
#' @importFrom xml2 xml_find_all read_html
#' @examples \dontrun{
#' f <- system.file("extdata/example.xml", package="nexld")
#' nexml_validate("birds_orders.xml")
#' }
nexml_validate <- function(file, schema=CANONICAL_SCHEMA){
  a = httr::POST(ONLINE_VALIDATOR, body=list(file = httr::upload_file(file)))
  if(a$status_code %in% c(200,201)){
    TRUE
  } else if(a$status_code == 504){
    warning("Online validator timed out, trying schema-only validation.")
    nexml_schema_validate(file, schema=schema)

  } else if(a$status_code == 400){
    warning(paste("Validation failed, error messages:",
         xml2::xml_find_all(xml2::read_html(httr::content(a, "text")), 
                     "//li[contains(@class, 'error') or contains(@class, 'fatal')]")
         ))
    FALSE
  } else {
    warning(paste("Unable to reach validator. status code:", a$status_code, ".  Message:\n\n", content(a, "text")))
    NULL
  }
}


nexml_schema_validate <- function(file, schema=CANONICAL_SCHEMA){
  a = httr::GET(schema)
  if(a$status_code == 200){
    xml2::xml_validate(file, schema) 
  } else {
    warning("Unable to obtain schema, couldn't validate")
    NULL
  }
}



