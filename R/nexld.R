#' xml_to_json
#'
#' @param x path to a nexml file
#' @return json string
#' @export
#' @importFrom xml2 read_xml xml_find_all xml_remove as_list
#' @importFrom jsonlite toJSON
#' @examples
#'
#' ex <- system.file("extdata/example.xml", package = "nexld")
#' xml_to_json(ex)
#'
xml_to_json <- function(x){
  json <- parse_nexml(x)
  toJSON(json, pretty=TRUE, auto_unbox=TRUE)

}

#' @export
parse_nexml <- function(x){
  xml <- xml2::read_xml(x)
  comments <- xml2::xml_find_all(xml, "//comment()")
  xml2::xml_remove(comments)
  json <- as_list(xml)
  json <- c(list("@context" = list("@vocab" = "http://www.nexml.org/2009/")), json)
  xmlns <- grepl("^xmlns", names(json))
  json <- json[!xmlns]   # just drop namespaces for now, should be appended to context

  json
}
