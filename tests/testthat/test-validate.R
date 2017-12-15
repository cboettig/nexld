testthat::context("Test round trip validation")

suite <- list.files(system.file("test_nexml", package="nexld"), full.names = TRUE)


test_roundtrip <- function(f){

  testthat::test_that(paste(
    "testing that", basename(f), "can roundtrip xml -> json -> xml and validate"),
  {
  json <- xml_to_json(f)
  json_to_xml(json, "test.xml")
  testthat::expect_true(nexml_validate("test.xml"))


  ## FIXME Check that we aren't losing elements!!


  unlink("test.xml")
  })
}

lapply(suite, test_roundtrip)

