
as_nexld <- function(x, ns = character(), ...) {
  UseMethod("as_nexld")
}
as_nexld.xml_missing <- function(x, ns = character(), ...) {
  list()
}
as_nexld.xml_document <- function(x, ns = character(), ...) {
  if (!inherits(x, "xml_node")) {
    return(list())
  }
  out <- list(NextMethod())
  names(out) <- xml_name(x)
  out
}

## based on xml2::as_list method
#' @importFrom xml2 xml_contents xml_name xml_attrs xml_type xml_text
as_nexld.xml_node <- function(x, ns = character(), embed_attr=TRUE, ...) {
  contents <- xml2::xml_contents(x)
  if (length(contents) == 0) {
    # Base case - contents
    type <- xml2::xml_type(x)

    ## ignore these types
    if (type %in% c("text", "cdata"))
      return(xml2::xml_text(x))
    if (type != "element" && type != "document")
      return(paste("[", type, "]"))
    out <- list()
  } else {
    out <- lapply(seq_along(contents), function(i) as_nexld(contents[[i]], ns = ns))
    nms <- ifelse(xml2::xml_type(contents) == "element", xml2::xml_name(contents, ns = ns), "")
    if (any(nms != "")) {
      names(out) <- nms
    }
  }
  node_attr <- special_jsonld_attrs(xml_attrs(x, ns = ns))
  # Add xml attributes as R attributes or embed in list
  if(embed_attr)
    out <- c(node_attr, out)
  else
    attributes(out) <- node_attr

  ## Group repeated elements
  out <- regroup(out)
  out
}

## based on xml2::as_list method
as_nexld.xml_nodeset <- function(x, ns = character(), ...) {
  out <- lapply(seq_along(x), function(i) as_nexld(x[[i]], ns = ns, ...))

  ## re-attach names
  nms <- ifelse(xml_type(x) == "element", xml2::xml_name(x, ns = ns), "")
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

      out <- c(out, setNames(list(unname(orig[i])), p))
    }
  }


  out <- remap_meta(out)

  out
}



remap_meta <- function(nodelist){

  is_meta <- names(nodelist) %in% "meta"

  if(sum(is_meta) == 0)
    return(nodelist)

  meta_nodes <- nodelist[is_meta]
  # "meta": {}
  if("@type" %in% names(meta_nodes[[1]])){
    out <-
      lapply(meta_nodes, function(n)
        setNames(meta_value(n), meta_property(n)))

  # "meta": [{}, {}]
  } else {
    out <-
      lapply(meta_nodes, function(n){
        setNames(lapply(n, meta_value),
                 lapply(n, meta_property))
    })

  }


  c(nodelist[!is_meta],
    unlist(unname(out),recursive = FALSE))

}



meta_property <- function(node){
  if(!is.null(node$href))
    node$rel
  else
    node$property
}

meta_value <- function(node){
  if(!is.null(node$href))
    node$href
  else {
    out <- node$content
    if(!is.null(node$datatype)){
      datatype <- strsplit(node$datatype, ":")[[1]][2]
      out <- switch(datatype,
             boolean = as.logical(out),
             int = as.integer(out),
             integer = as.integer(out),
             decimal = as.numeric(out),
             string = as.character(out),
             date = as.character(out))
    }
    out
  }
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



