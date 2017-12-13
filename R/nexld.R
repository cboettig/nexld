#' xml_to_json
#'
#' Convert an NeXML file into a json file/string
#'
#' @param x path to a nexml file
#' @param file output filename; optional, if ommitted will return JSON string
#' @return json string or json output file
#' @export
#' @importFrom xml2 read_xml xml_find_all xml_remove as_list
#' @importFrom jsonlite toJSON write_json
#' @examples
#'
#' ex <- system.file("extdata/example.xml", package = "nexld")
#' xml_to_json(ex)
#' 
#' ex1 <- system.file("extdata/ontotrace.xml", package = "nexld")
#' xml_to_json(ex1)
xml_to_json <- function(x, file = NULL){
  json <- parse_nexml(x)
  if(is.null(file)){
    jsonlite::toJSON(json, pretty = TRUE, auto_unbox = TRUE)
  } else {
    jsonlite::write_json(json, file, pretty = TRUE, auto_unbox = TRUE)
  }
}

#' parse_nexml
#'
#' Parse an NeXML file into an R list object
#' @inheritParams xml_to_json
#'
#' @export
parse_nexml <- function(x){
  xml <- xml2::read_xml(x)

  ## Drop comment nodes.
  xml2::xml_remove(xml2::xml_find_all(xml, "//comment()"))

  ## strip about attributes
  res <- xml2::xml_find_all(xml, '//*[@about]')
  invisible(xml2::xml_remove(res))

  ## Main transform, map XML to list using a modification of the xml2::as_list convention
  ## See as_list.R
  json <- as_nexld(xml)

  ## Set up the JSON-LD context
  # json <- c(list("@context" = list("@vocab" = "http://www.nexml.org/2009/")), json)
  # xmlns <- grepl("^xmlns", names(json))
  # json <- json[!xmlns]   # just drop namespaces for now, should be appended to context
  con <- list()
  if ("base" %in% names(json$nexml)) {
    con$base <- json$nexml$base
    json$nexml$base <- NULL
  }
  con$`@vocab` <- json$nexml$xmlns
  json$nexml$xmlns <- NULL
  nss <- json$nexml[grepl("xmlns\\:", names(json$nexml))]
  con <- c(con, 
    stats::setNames(nss, 
      vapply(names(nss), function(x) strsplit(x, split = ":")[[1]][[2]], character(1))
    )
  )
  xmlns <- grepl("^xmlns", names(json$nexml))
  json$nexml <- json$nexml[!xmlns]
  json$`@context` <- con
  # order names so @context shows up first
  json <- json[order(names(json))]

  return(json)
}
