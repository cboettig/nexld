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
#' as__list(read_xml("<foo> a <b /><c><![CDATA[<d></d>]]></c></foo>"))
#' as__list(read_xml("<foo> <bar><baz /></bar> </foo>"))
#' as__list(read_xml("<foo id = 'a'></foo>"))
#' as__list(read_xml("<foo><bar id='a'/><bar id='b'/></foo>"))
as__list <- function(x, ns = character(), ...) {
  UseMethod("as__list")
}

as__list.xml_missing <- function(x, ns = character(), ...) {
  list()
}

as__list.xml_document <- function(x, ns = character(), ...) {
  if (!inherits(x, "xml_node")) {
    return(list())
  }
  out <- list(NextMethod())
  names(out) <- xml_name(x)
  out
}

as__list.xml_node <- function(x, ns = character(), embed_attr=TRUE, ...) {
  contents <- xml_contents(x)
  if (length(contents) == 0) {
    # Base case - contents
    type <- xml_type(x)

    if (type %in% c("text", "cdata"))
      return(xml_text(x))
    if (type != "element" && type != "document")
      return(paste("[", type, "]"))

    out <- list()
  } else {
    out <- lapply(seq_along(contents), function(i) as__list(contents[[i]], ns = ns))

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

as__list.xml_nodeset <- function(x, ns = character(), ...) {
  out <- lapply(seq_along(x), function(i) as__list(x[[i]], ns = ns, ...))

  ## re-attach names
  nms <- ifelse(xml_type(contents) == "element", xml_name(x, ns = ns), "")
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
      i <- property == p
      out <- out[!i]
      out <- c(out, setNames(list(unname(orig[i])), p))
    }
  }

  out
}


special_attributes <- c("id", "type")
special_jsonld_attrs <- function(x) {
  if (length(x) == 0) {
    return(NULL)
  }
  # escape special names
  special <- names(x) %in% special_attributes
  names(x)[special] <- paste0("@", names(x)[special])
  as.list(x)
}


#download.file("https://raw.githubusercontent.com/ropensci/RNeXML/master/inst/examples/multitrees.xml", "example.xml")

xml <- read_xml("example.xml")


## single node
otus <- xml_children(xml_children(xml)[[1]])
as__list(otus) %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)

## node set
otus <- xml_children(xml)[[1]]
as__list(otus) %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)

## whole document
xml %>% as__list() %>% jsonlite::write_json("example.json", pretty=TRUE, auto_unbox=TRUE)
