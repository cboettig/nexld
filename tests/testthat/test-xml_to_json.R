
context("xml to json")
library(nexld)

ex <- system.file("extdata/example.xml", package = "nexld")
json <- xml_to_json(ex)

library(jsonld)

# base-R / bizzaro pipe ->.;
json ->.;
  jsonld_expand(.) ->.;
  jsonld_compact(., '{"@vocab": "http://www.nexml.org/2009/"}') ->
  out



