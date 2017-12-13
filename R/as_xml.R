

#' @export
json_to_xml <- function(x){
  as_nexml_document(x)
}


## Convert list to XML

# - Frame JSON into predictable format; applying context to achieve de-referencing
# - Import framed JSON as list
# - serialize list to XML: Adjust from xml2::as_xml_document

## inside adaptiation of as_xml_document_method?
# - Unfold list-of-elements, property = [{}, {}] into [property={}, property={}, property={}]
# - Data values as XML attributes

## Do these in JSON, list, or XML stage?
# - Replace any non-nexml-namespace node with corresponding meta node.
#   (identify URI properties as ResourceMeta rel/href)
# - Fix node ordering to conform to schema.
#   (Sort based on pre-specified order probably best/easiest;
#    alternately check refs come after defs)

is_URI <- function(x){
  grepl("\\w+://.+", x)
}
#is_URI("http://creativecommons.org/publicdomain/zero/1.0/")
#is_URI("creativecommons.org/publicdomain/zero/1.0/")


into_meta <- function(x){
  namespaced <- grep( "\\w+:\\w+", names(x))
  for(n in namespaced){
    if(is_URI(x[[n]]))  # ResourceMeta
      x[[n]] <- list(rel = names(x[n]), href = x[[n]])
    else # LiteralMeta
      x[[n]] <- list(property = names(x[n]), content = x[[n]])
    names(x)[n] <- "meta"
  }

  x
}


as_nexml_document <- function(x, ...) {UseMethod("as_nexml_document")}

#' @importFrom jsonlite fromJSON
as_nexml_document.character <- function(x, ...){
  as_nexml_document(jsonlite::fromJSON(x))
}
as_nexml_document.json <- function(x, ...){
  as_nexml_document.list(x)
}

## Here we go
as_nexml_document.list <- function(x, ...) {
  if (length(x) > 1) {
    x <- list(nexml = x)
    #stop("Root nodes must be of length 1", call. = FALSE)
  }


  add_node <- function(x, parent, tag = NULL) {
    if (is.atomic(x)) {
      ## No use of xml_set_text please, we want atomic elements to be XML attribute values
      ##return(xml_set_text(parent, as.character(x)))
      return()
    }

    ## Add coercion into meta nodes first.  Should also alter the `about` tag of the parent
    x <- into_meta(x)

    if (!is.null(tag)) {
      parent <- xml_add_child(parent, tag)


      ## No use of R attributes please
      #attr <- r_attrs_to_xml(attributes(x))
      attr <- x[vapply(x, is.atomic, logical(1))]
      for (i in seq_along(attr)) {
        xml_set_attr(parent, names(attr)[[i]], attr[[i]])
      }
    }
    for (i in seq_along(x)) {
      add_node(x[[i]], parent, names(x)[[i]])
    }
  }

  doc <- xml_new_document()
  add_node(x, doc)
  xml_root(doc)
}

as_nexml_document.xml_node <- function(x, ...) {
  xml_new_root(.value = x, ..., .copy = TRUE)
}

as_nexml_document.xml_nodeset <- function(x, root, ...) {
  doc <- xml_new_root(.value = root, ..., .copy = TRUE)
  for (i in seq_along(x)) {
    xml_add_child(doc, x[[i]], .copy = TRUE)
  }
  doc
}

as_nexml_document.xml_document <- function(x, ...) {
  x
}





## Frame: follow this framing order as well as nesting order
# nexml
#  - otus
#     - otu
#  - trees
#    - tree
#       - node
#       - edge
#  - characters
#    - format
#       - states
#       - char
#    - matrix
#       - row
#       - cell

## Use order given in json frame(?)
fix_node_order <- function(nexld){



}