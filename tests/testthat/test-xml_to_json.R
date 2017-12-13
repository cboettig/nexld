testthat::context("xml to json")

library(nexld)

ex <- system.file("extdata/example.xml", package = "nexld")

testthat::test_that("we can parse xml into a json-list", {
  json <- xml_to_json(ex)
  expect_is(json, "json")
})

