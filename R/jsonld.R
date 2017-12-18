
NEXML <- "https://raw.githubusercontent.com/cboettig/nexld/master/inst/context/nexml.json"
TREEBASE <- "https://raw.githubusercontent.com/cboettig/nexld/master/inst/context/treebase.json"

## Add our prebuilt context onto an existing nexld object
add_context.nexld <- function(nexld, context = NEXML){

nexld[["@context"]] <- list(context, nexld[["@context"]])

}

## import JSON-LD into our standard S3 list layout
## FIXME NOTE: this should be called as the first part of json_to_xml
#
# f <- system.file()
embed.nexld <- function(nexld, context = TREEBASE){
  frame.nexld(nexld,
              list("@embed" = "@always",
                   "@type" = "nexml")
              )
}

## apply a frame without changing the context
frame.nexld <- function(nexld, frame = list("@type" = "nexml")){

  ## Grab the context (in list & json formats)
  context <- nexld[["@context"]]
  context.json <- jsonlite::toJSON(context, auto_unbox = TRUE)

  ## Build the frame
  frame.json <- jsonlite::toJSON(
    c(list("@context" = context), frame), auto_unbox=TRUE)

  ## Serialize to json, frame, compact, parse back to list
  json <- jsonlite::toJSON(nexld, auto_unbox=TRUE)
  framed <- jsonld::jsonld_frame(json, frame.json)
  compact <- jsonld::jsonld_compact(framed, context.json)
  out <- jsonlite::fromJSON(compact, simplifyVector = FALSE)

  out
}
