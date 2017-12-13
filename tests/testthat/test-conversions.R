testthat::context("test-conversions: convert NeXML files to JSON-LD and RDF files")

"This script tests whether we can convert NeXML files into JSON-LD and RDF
using the nexld and jsonld libraries. By continuously converting the example
NeXML files provided, it ensures that the example JSON-LD and RDF files remain
up-to-date with the code and input files.

New NeXML files can be added by adding them to the `tests/example_nexml` directory.
"

library(nexld)
library(jsonld)

# Part 1. Convert all NeXML files into JSON-LD

# Look for XML files to convert
files_to_convert <- list.files("../example_nexml", pattern=".+\\.xml")
for(filename in files_to_convert) {
    # Construct input and output files.
    input_file <- sprintf("../example_nexml/%s", filename)
    output_file <- sprintf("../example_jsonld/%s.json", substr(filename, 1, nchar(filename) - 4))
    
    content_jsonld <<- NA

    # We don't want a failing file to stop processing other files, so
    # we catch an exception and keep going.
    tryCatch({
        testthat::test_that("we can convert a NeXML file to a JSON-LD file", {
            # Convert NeXML to JSON-LD using nexld
            content_jsonld <<- xml_to_json(input_file)
            testthat::expect_is(content_jsonld, "json")
        })
        
        # Save a copy of the JSON-LD file so we can see if it's changed.
        if(is.na(content_jsonld)) {
            # Blank contents are suspicious.
            stop("Blank output JSON-LD file produced")
        } else {
            # Write the produced JSON-LD output into the
            # examples/example_jsonld directory.
            fd_json_output <- file(output_file, open="w")
            writeLines(content_jsonld, fd_json_output)
            close(fd_json_output)
        }

    }, expectation_failure = function(err) {
        print(sprintf("Unable to convert '%s' to JSON-LD: %s", input_file, err))
    })
}

# Part 2. Convert all JSON-LD files into RDF

# List all JSON-LD files to convert
files_to_convert <- list.files("../example_jsonld", pattern=".+\\.json")
for(filename in files_to_convert) {
    # Prepare filenames for input and output files.
    input_file <- sprintf("../example_jsonld/%s", filename)
    output_file <- sprintf("../example_rdf/%s.txt", substr(filename, 1, nchar(filename) - 5))

    content_nquads <<- NA

    # We don't want a failing file to stop processing other files, so
    # we catch an exception and keep going.
    tryCatch({
        # fd_json_input <- file(input_file, open="r")
        # content_jsonld <- readLines(fd_json_input)
        # close(fd_json_input)

        testthat::test_that("we can convert a JSON-LD file to an n-quads file", {
            # Convert the JSON-LD file to RDF (as N-quads)
            content_nquads <<- jsonld_to_rdf(input_file)

            # content_nquads <<- jsonld_normalize(input_file)
        })
        
        # Save a copy of the n-quads file so we can see if it's changed.
        if(is.na(content_nquads)) {
            stop("Blank output n-quads file produced")
        } else {
            fd_nquads_output <- file(output_file, open="w")
            writeLines(content_nquads, fd_nquads_output)
            close(fd_nquads_output)
        }

    }, expectation_failure = function(err) {
        print(sprintf("Unable to convert '%s' to n-quads: %s", input_file, err))
    })
}
