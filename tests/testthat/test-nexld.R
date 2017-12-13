testthat::context("test-nexld: basic tests")

library(nexld)

ex <- system.file("extdata/example.xml", package = "nexld")

testthat::test_that("we can parse xml into a json-list", {
  json <- xml_to_json(ex)
  testthat::expect_is(json, "json")
})

library(jsonld)

testthat::test_that("we can expand and compact successfully", {
  # uses the base R "bizzaro pipe" ->.;
  xml_to_json(ex) ->.;
    jsonld_expand(.) ->.;
    jsonld_compact(., '{"@vocab": "http://www.nexml.org/2009/"}') ->
    out

  testthat::expect_is(out, "json")
})

testthat::test_that("we can go from json back to xml", {


  json <- parse_nexml(ex)
  ## fails on json <- xml_to_json(ex)
  xml <- json_to_xml(json)
  testthat::expect_is(xml, "xml_document")

})



testthat::test_that("we can validate after roundtrip", {

  ex <- system.file("extdata/example.xml", package = "nexld")
  json <- parse_nexml(ex)
  xml <- json_to_xml(json)
  testthat::expect_is(xml, "xml_document")
  xml2::write_xml(xml, "ex.xml")

  #testthat::expect_true(RNeXML::nexml_validate("ex.xml"))
  unlink("ex.xml")
})


