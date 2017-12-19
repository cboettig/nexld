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
json_to_xml <- function(x, file = NULL, ...){ UseMethod("json_to_xml")}

#' @export
json_to_xml.character <- function(x, file = NULL, ...){
  if(file.exists(x)){  ## Read from file
    x <- jsonlite::read_json(x)
  } else { ## Read from string
    x <- jsonlite::fromJSON(x, simplifyVector = FALSE)
  }
  json_to_xml(x, file, ...)
}

#' @export
json_to_xml.json <- function(x, file = NULL, ...){
  x <- jsonlite::fromJSON(x, simplifyVector = FALSE)
  json_to_xml(x, file, ...)
}

#' @export
json_to_xml.list <- function(x, file = NULL, ...){

  ## Frame/compact into original context for a standardized structure
  nexml_list <- frame.list(x)

  ## Sort S3/list elements according to NeXML ordering requirements
  nexml <- sort_nexml(nexml_list)

  ## Step 3: Serialize S3/list into XML
  xml <- as_nexml_document(list(nexml = nexml))

  ## Step 4: Add namespaces from the original context as xmlns:prefix=""
  context <- context_namespaces(nexml_list[["@context"]])
  root <- xml2::xml_root(xml)
  for(ns in names(context)){
    switch(ns,
           "@vocab" = xml2::xml_set_attr(root, "xmlns", context[[ns]]),
           "@base" = xml2::xml_set_attr(root, "xml:base", context[[ns]]),
           xml2::xml_set_attr(root, paste("xmlns", ns, sep=":"), context[[ns]]))
  }

  ## Serialize to file if desired
  if(!is.null(file))
    xml2::write_xml(xml, file, ...)
  else
    xml
}

context_namespaces <- function(context){
  ## unpack list-contexts
  context <- unlist(lapply(context, function(y){
    if(is.null(names(y)))
      return(NULL)
    else
      y
  }))
  ## Drop terms that aren't namespaces (don't end in / or #); e.g. drop
  ##     name: http://schema.org/name
  ## but not:
  ##     schema: http://schema.org/
  as.list(context[grepl(".*(#$|/$)",context)])
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

  sort_characters <-
  lapply(nexml_list[characters], function(characters){
    lapply(characters, function(characters){

      if("format" %in% names(characters)){
        ## Sort format block
        format <- characters$format
        states <- grep("states", names(format))
        char <- grep("char", names(format))
        characters$format <- c(format[-c(states, char)], format[states], format[char])

        if(length(states)>0){
          states <- characters$format$states
          state <- grep("^state$", names(states))
          mult_state <- grep("\\w+_state_set", names(states))
          characters$format$states <- c(states[-c(state, mult_state)], states[state], states[mult_state])
        }
      }
      characters
    })
  })

  ## states before polymorphic states

 out <- c(nexml_list[attr], nexml_list[meta], nexml_list[otus], sort_trees, sort_characters)
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

textTypeNodes <- c("seq")

add_node <- function(x, parent, tag = NULL) {
  if (is.atomic(x)) {
    ## No use of xml_set_text please, we want atomic elements to be XML attribute values
    ##return(xml_set_text(parent, as.character(x)))
    return()
  }

  x <- into_meta(x)

  if (!is.null(tag)) {
    if(!is.null(names(x)) & length(x) > 0)
      parent <- xml2::xml_add_child(parent, tag)

    ## While xml2 as_xml_doc uses R attributes -> xml attributes,
    ## we want to treat atomic elements in a list as the xml attributes:
    attr <- x[vapply(x, is.atomic, logical(1))]
    for (i in seq_along(attr)) {
      ## Handle special attributes
      key <- gsub("^@(\\w+)", "\\1", names(attr)[[i]]) # drop json-ld `@`
      if(length(key) > 0){

      ## assumes xsi: is the prefix, should be confirmed / set explicitly as such!
      if(key == "type")
        key <- paste0("xsi:", key)

      if(key %in% textTypeNodes){
        textType <- xml2::xml_add_child(parent, key)
        xml2::xml_set_text(textType, attr[[i]])
      } else {
        xml2::xml_set_attr(parent, key, attr[[i]])
      }
      }
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



