
context("xml to json")
library(nexld)
ex <- system.file("extdata/example.xml", package = "nexld")
json <- xml_to_json(ex)
