
## import JSON-LD into our standard S3 list layout
## FIXME NOTE: this should be called as the first part of json_to_xml
#
# f <- system.file()
embed.list <- function(x, context = TREEBASE){
  frame.list(x,
              list("@embed" = "@always",
                   "@type" = "nexml")
              )
}

# Do not embed otus or otu inside trees elements:


## apply a frame without changing the context
frame.list <- function(x,
                       frame = system.file("frames/nexml.json", package="nexld")
                       ){

  ## Grab the context (in list & json formats)
  context <- x[["@context"]]
  context.json <- jsonlite::toJSON(context, auto_unbox = TRUE)

  ## Build the frame
  if(is.list(frame))
    frame <- jsonlite::toJSON(c(list("@context" = context), frame), auto_unbox=TRUE)

  ## Serialize to json, frame, compact, parse back to list
  json <- jsonlite::toJSON(x, auto_unbox=TRUE)
  framed <- jsonld::jsonld_frame(json, frame)
  compact <- jsonld::jsonld_compact(framed, context.json)
  out <- jsonlite::fromJSON(compact, simplifyVector = FALSE)

  out
}
