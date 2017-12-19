testthat::context("Test round trip validation")

suite <- list.files(system.file("nexml_examples", package="nexld"), full.names = TRUE)


test_roundtrip <- function(f){

  testthat::test_that(paste(
    "testing that", basename(f), "can roundtrip & validate"),
  {
  #testthat::expect_true(nexml_validate(f))
  out <- basename(f)
  #xml_to_json(f, file.path("inst/jsonld_examples", gsub("\\.xml", ".json", out)))
  json <- xml_to_json(f)
  json_to_xml(json, out)
  testthat::expect_true(nexml_validate(out))
  unlink(out)
  })
}

lapply(suite, test_roundtrip)
