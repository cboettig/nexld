
#' json_to_xml
#'
#' json_to_xml
#' @param x JSON-LD representation of NeXML, as json, character, or list object.
#' @param file output filename. If NULL (default), will return xml_document
#' @param ... additional arguments to xml2::write_xml
#' @export
json_to_xml <- function(x, file = NULL, ...){

  ## Step 0: Render nexld S3/list to json object
  if(is.list(x))
    x <- jsonlite::toJSON(x, auto_unbox = TRUE)

  ## Step 1: Compact the `nexml` element into `nexml` vocab alone
  ## This will leave non-nexml properties (i.e. meta properties) with
  ## their original prefixes in place.
  nexml_only <- '{"@vocab": "http://www.nexml.org/2009"}'
  compacted <- jsonld::jsonld_compact(x, context = nexml_only)

  ## Step 2a: Parse compacted JSON back into  S3/list,
  compacted <- jsonlite::fromJSON(compacted, simplifyVector = FALSE)

  ## Step 2b: Sort S3/list elements according to NeXML ordering requirements

  ## Step 3: Serialize S3/list into XML
  xml <- as_nexml_document(x)

  ## Step 4: Add namespaces from the original context as xmlns:prefix=""



  if(!is.null(file))
    xml2::write_xml(xml, file, ...)
  else
    xml
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
      # FIXME: set `xsi:type="LiteralMeta` and datatype
      x[[n]] <- list(property = names(x[n]), content = x[[n]])
    names(x)[n] <- "meta"
  }

  x
}


as_nexml_document <- function(x, ...) {UseMethod("as_nexml_document")}

#' @importFrom jsonlite fromJSON
as_nexml_document.character <- function(x, ...){
  as_nexml_document(jsonlite::fromJSON(x, simplifyVector = FALSE))
}
as_nexml_document.json <- function(x, ...){
  as_nexml_document(jsonlite::fromJSON(x, simplifyVector = FALSE))
}


add_node <- function(x, parent, tag = NULL) {
  if (is.atomic(x)) {
    ## No use of xml_set_text please, we want atomic elements to be XML attribute values
    ##return(xml_set_text(parent, as.character(x)))
    return()
  }

  ## Add coercion into meta nodes first.  Should also alter the `about` tag of the parent

  ## FIXME need to handle head <nexml> elements separately -- the xmlns: attributes
  ## are somehow being turned into metas too
  x <- into_meta(x)

  ## FIXME: Still have to turn structures like: otu: [ {}, {}, {}] back into
  ## named lists, i.e. otu = {}, otu = {}, otu = {}.
  ## (JSON doesn't like repeated keys but they are fine in R lists)
  ## Basically, need to turn `@type` into tag

  if (!is.null(tag)) {
    parent <- xml2::xml_add_child(parent, tag)

    ## While xml2 as_xml_doc uses R attributes -> xml attributes,
    ## we want to treat atomic elements in a list as the xml attributes:
    attr <- x[vapply(x, is.atomic, logical(1))]
    for (i in seq_along(attr)) {
      key <- gsub("^@(\\w+)", "\\1", names(attr)[[i]]) # drop json-ld `@`
      xml2::xml_set_attr(parent, key, attr[[i]])
    }
  }
  for (i in seq_along(x)) {
    if(!is.null(names(x))){
      tag <- names(x)[[i]]
    } else {
      tag <- xml_name(parent)
    }
    add_node(x[[i]], parent, tag)
  }
}

#' @importFrom xml2 xml_add_child xml_set_attr xml_new_document
as_nexml_document.list <- function(x, ...) {
  if (length(x) > 1) {
    if(!is.null(x$nexml))
      x <- x["nexml"]
    else
      stop("Root nexml node not found", call. = FALSE)
  }

  doc <- xml2::xml_new_document()
  add_node(x, doc)
  xml2::xml_root(doc)
}


## Identical to as_xml_document methods

#' @importFrom xml2 xml_new_root
as_nexml_document.xml_node <- function(x, ...) {
  xml2::xml_new_root(.value = x, ..., .copy = TRUE)
}
as_nexml_document.xml_nodeset <- function(x, root, ...) {
  doc <- xml2::xml_new_root(.value = root, ..., .copy = TRUE)
  for (i in seq_along(x)) {
    xml2::xml_add_child(doc, x[[i]], .copy = TRUE)
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
