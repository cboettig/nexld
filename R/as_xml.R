#' json_to_xml
#'
#' json_to_xml
#' @param x JSON-LD representation of NeXML, as json, character, or list object.
#' @param file output filename. If NULL (default), will return xml_document
#' @param ... additional arguments to xml2::write_xml
#' @export
#' @importFrom methods is
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom xml2 xml_root xml_set_attr write_xml
json_to_xml <- function(x, file = NULL, ...){

  ## Step 0: Render nexld S3/list to json object
  if(is.list(x)){
    context <- x[["@context"]]
    x <- jsonlite::toJSON(x, auto_unbox = TRUE)
  } else if(is(x,"json")){
    context <- jsonlite::fromJSON(x, simplifyVector = FALSE)[["@context"]]
  }

  ## Step 1: Frame, using the original context (where non-nexml properties are prefixed)
  frame <- jsonlite::toJSON(list("@context" = context, nexml = NULL), auto_unbox = TRUE, pretty = TRUE)
  framed <- jsonld::jsonld_frame(x, frame)

  ## Step 2a: Parse compacted JSON back into  S3/list,
  y <- jsonlite::fromJSON(framed, simplifyVector = FALSE)

  nexml_list <- y[["@graph"]][[1]][["nexml"]]
  nexml <- sort_nexml(nexml_list)
  ## Step 2b: Sort S3/list elements according to NeXML ordering requirements


  ## Step 3: Serialize S3/list into XML
  xml <- as_nexml_document(list(nexml = nexml))
  root <- xml2::xml_root(xml)

  ## Step 4: Add namespaces from the original context as xmlns:prefix=""
  for(ns in names(context)){
    if(ns == "@vocab")
      xml2::xml_set_attr(root, "xmlns", context[[ns]])
    else if(ns == "@base")
      xml2::xml_set_attr(root, "xml:base", context[[ns]])
    else
      xml2::xml_set_attr(root, paste("xmlns", ns, sep=":"), context[[ns]])
  }


  if(!is.null(file))
    xml2::write_xml(xml, file, ...)
  else
    xml
}


## use this instead
sort_nexml <- function(nexml_list){
  who <- names(nexml_list)

  attr <- grep("(schemaLocation|version)", who)
  meta <- grep("\\w+:\\w", who)
  otus <- grep("otus", who)
  trees <- grep("trees", who)
  characters <- grep("characters", who)

  ## Nodes before edges
  sort_trees <- lapply(nexml_list[trees], function(trees){
    lapply(trees, function(tree){
      node <- grep("node", names(tree))
      if(length(node)>0)
        c(tree[node], tree[-node])
      else
        tree
    })
  })
 out <- c(nexml_list[attr], nexml_list[meta], nexml_list[otus], sort_trees, nexml_list[characters])
 out
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


  x <- into_meta(x)



  if (!is.null(tag)) {

    if(!is.null(names(x)))
      parent <- xml2::xml_add_child(parent, tag)

    ## While xml2 as_xml_doc uses R attributes -> xml attributes,
    ## we want to treat atomic elements in a list as the xml attributes:
    attr <- x[vapply(x, is.atomic, logical(1))]
    for (i in seq_along(attr)) {
      ## Handle special attributes
      key <- gsub("^@(\\w+)", "\\1", names(attr)[[i]]) # drop json-ld `@`
      ## assumes xsi: is the prefix, should be confirmed / set explicitly as such!
      if(key == "type") key <- paste0("xsi:", key)
      xml2::xml_set_attr(parent, key, attr[[i]])
    }
  }
  for (i in seq_along(x)) {
    if(!is.null(names(x))){
      tag <- names(x)[[i]]
    } else {
      #tag <- xml_name(parent)
      ## FIXME if tag name comes from parent, parent should not be created as a node!
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



