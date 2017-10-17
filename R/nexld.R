

## override xml2 method
#' @importFrom xml2 xml_contents xml_name xml_attrs xml_type xml_text
as_list.xml_node <- function(x, ns = character(), embed_attr=TRUE, ...) {
  contents <- xml2::xml_contents(x)
  if (length(contents) == 0) {
    # Base case - contents
    type <- xml2::xml_type(x)

    ## ignore these types
    if (type %in% c("text", "cdata"))
      return(xml_text(x))
    if (type != "element" && type != "document")
      return(paste("[", type, "]"))

    out <- list()
  } else {
    out <- lapply(seq_along(contents), function(i) as_list(contents[[i]], ns = ns))

    nms <- ifelse(xml_type(contents) == "element", xml_name(contents, ns = ns), "")
    if (any(nms != "")) {
      names(out) <- nms
    }

  ## Group repeated elements
  out <- regroup(out)
  }

  node_attr <- special_jsonld_attrs(xml_attrs(x, ns = ns))
  # Add xml attributes as R attributes or embed in list
  if(embed_attr)
    out <- c(node_attr, out)
  else
    attributes(out) <- node_attr

  out
}

## override xml2 method
as_list.xml_nodeset <- function(x, ns = character(), ...) {
  out <- lapply(seq_along(x), function(i) as_list(x[[i]], ns = ns, ...))

  ## re-attach names
  nms <- ifelse(xml_type(x) == "element", xml_name(x, ns = ns), "")
  if (any(nms != "")) {
    names(out) <- nms
  }
  regroup(out)

}

## regroup repeated element names into a node list
#' @importFrom stats setNames
regroup <- function(out){

  property <- names(out)
  duplicate <- duplicated(property)

  if(sum(duplicate) > 0){
    for(p in unique(property[duplicate])){
      orig <- out
      i <- names(out) == p
      out <- out[!i]

      ## Assumes type matches property name.  FIXME other choices possible
      tmp <- lapply(orig[i], function(x) c("@type" = p, x))
      out <- c(out, setNames(list(unname(tmp)), p))
    }
  }
  out
}

ld_attributes <- c("id", "type")
special_jsonld_attrs <- function(x) {
  if (length(x) == 0) {
    return(NULL)
  }
  # escape special names
  special <- names(x) %in% ld_attributes
  names(x)[special] <- paste0("@", names(x)[special])
  r_attrs_to_xml(as.list(x))
}

## Adapted from xml2
special_attributes <- c("class", "comment", "dim", "dimnames", "names", "row.names", "tsp")
r_attrs_to_xml <- function(x) {
  if (length(x) == 0) {
    return(NULL)
  }
  # Drop R special attributes
  x <- x[!names(x) %in% special_attributes]
  # Rename any xml attributes needed
  special <- names(x) %in% paste0(".", special_attributes)
  names(x)[special] <- sub("^\\.", "", names(x)[special])
  x
}





#' xml_to_json
#'
#' @param x path to a nexml file
#' @export
#' @importFrom xml2 read_xml xml_find_all xml_remove as_list
#' @importFrom jsonlite toJSON
#' @examples
#'
#' ex <- system.file("extdata/example.xml", package = "nexld")
#' xml_to_json(ex)
#'
#'
#'
xml_to_json <- function(x){
  xml <- xml2::read_xml(x)
  comments <- xml2::xml_find_all(xml, "//comment()")
  xml2::xml_remove(comments)

  json <- as_list(xml)

  json <- c(list("@context" = list("@vocab" = "http://www.nexml.org/2009/")), json)
  xmlns <- grepl("^xmlns", names(json))
  json <- json[!xmlns]   # just drop namespaces for now, should be appended to context

  toJSON(json, pretty=TRUE, auto_unbox=TRUE)

}



#download.file("https://raw.githubusercontent.com/ropensci/RNeXML/master/inst/examples/multitrees.xml", "example.xml")
#
# xml <- read_xml("example.xml")
# comments <- xml2::xml_find_all(xml, "//comment()")
# xml2::xml_remove(comments)
#
# ## single node
# x <- xml_children(xml_children(xml)[[1]])
# as_list(x) %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)
#
# ## node set
# xml_children(xml)[[2]] %>% as_list() %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)
#
#
# ## whole document
# xml %>% as_list() %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)
