

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
      tmp <- lapply(orig[i], function(x){
        if(is.null(x[["@type"]]))
          c("@type" = p, x)
        else
          x
      })

      out <- c(out, setNames(list(unname(tmp)), p))
    }
  }


  out <- remap_meta(out)

  out
}



remap_meta <- function(nodelist){

  ## FIXME Handles case of meta: [], must also handle and meta: {} (nonlist)

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



