testthat::context("test-conversions: convert NeXML files to JSON-LD files")

library(nexld)

files_to_convert <- list.files("../example_nexml", pattern=".+\\.xml")
for(filename in files_to_convert) {
    input_file <- paste("../example_nexml/", filename, sep="")
    output_file <- paste("../example_jsonld/", substr(filename, 1, nchar(filename) - 4), ".json", sep="")
    
    # print(paste("Converting", input_file, "to", output_file))

    content_jsonld <<- NA

    # We don't want a failing file to stop processing other files, so
    # we catch an exception and keep going.
    tryCatch({
        testthat::test_that("we can convert the nexld file to a JSON-LD file", {
            content_jsonld <<- xml_to_json(input_file)
            testthat::expect_is(content_jsonld, "json")
        })
        
        # TODO for now, just write it down
        if(is.na(content_jsonld)) {
            expect_error("Blank output file produced")
        } else {
            fd_json_output <- file(output_file, open="w")
            writeLines(content_jsonld, fd_json_output)
            close(fd_json_output)
        }

    }, expectation_failure = function(err) {
        print(sprintf("Unable to convert '%s': %s", input_file, err))
    })
}

