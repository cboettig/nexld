testthat::context("xml to json")

library(nexld)


testthat::test_that("we can parse xml into a json-list", {

  ex <- system.file("extdata/example.xml", package = "nexld")
  json <- xml_to_json(ex)
  testthat::expect_is(json, "json")
  nexld <- parse_nexml(ex)
  testthat::expect_equal(nexld$trees$tree[["@id"]], "tree1")
})

