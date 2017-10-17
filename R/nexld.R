library(xslt)
library(xml2)
library(jsonld)
library(rdflib)
library(magrittr)
library(jsonlite)

#' Coerce xml nodes to a list.
#'
#' This turns an XML document (or node or nodeset) into the equivalent R
#' list. Note that this is \code{as_list()}, not \code{as.list()}:
#' \code{lapply()} automatically calls \code{as.list()} on its inputs, so
#' we can't override the default.
#'
#' \code{as_list} currently only handles the four most common types of
#' children that an element might have:
#'
#' \itemize{
#'   \item Other elements, converted to lists.
#'   \item Attributes, stored as R attributes. Attributes that have special meanings in R
#'           (\code{\link{class}}, \code{\link{comment}}, \code{\link{dim}},
#'           \code{\link{dimnames}}, \code{\link{names}}, \code{\link{row.names}} and
#'           \code{\link{tsp}}) are escaped with '.'
#'   \item Text, stored as a character vector.
#' }
#'
#' @inheritParams xml_name
#' @param ... Needed for compatibility with generic. Unused.
#' @export
#' @examples
#' as_list(read_xml("<foo> a <b /><c><![CDATA[<d></d>]]></c></foo>"))
#' as_list(read_xml("<foo> <bar><baz /></bar> </foo>"))
#' as_list(read_xml("<foo id = 'a'></foo>"))
#' as_list(read_xml("<foo><bar id='a'/><bar id='b'/></foo>"))
as_list <- function(x, ns = character(), ...) {
  UseMethod("as_list")
}
as_list.xml_missing <- function(x, ns = character(), ...) {
  list()
}
as_list.xml_document <- function(x, ns = character(), ...) {
  if (!inherits(x, "xml_node")) {
    return(list())
  }
  out <- list(NextMethod())
  names(out) <- xml_name(x)
  out
}

as_list.xml_node <- function(x, ns = character(), embed_attr=TRUE, ...) {
  contents <- xml_contents(x)
  if (length(contents) == 0) {
    # Base case - contents
    type <- xml_type(x)

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


#download.file("https://raw.githubusercontent.com/ropensci/RNeXML/master/inst/examples/multitrees.xml", "example.xml")

xml <- read_xml("example.xml")

comments <- xml2::xml_find_all(xml, "//comment()")
xml2::xml_remove(comments)

## single node
x <- xml_children(xml_children(xml)[[1]])
as_list(x) %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)

## node set
xml_children(xml)[[2]] %>% as_list() %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)


## whole document
xml %>% as_list() %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)
