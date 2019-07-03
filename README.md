
[![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/joethorley/stability-badges#experimental)
[![Travis-CI Build
Status](https://travis-ci.org/cboettig/nexld.svg?branch=master)](https://travis-ci.org/cboettig/nexld)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# nexld

The goal of nexld is to serialize NeXML xml data into JSON-LD.

## Installation

You can install nexld from github with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/nexld")
```

## Heads up\!

Package is in purely exploratory stage at this time, function api likely
to change.

## Example

Let’s convert a simple NeXML file into JSON-LD:

``` r
library(nexld)
ex <- system.file("extdata/example.xml", package = "nexld")
json <- xml_to_json(ex)
```

``` r
tmp <- tempfile()
json_to_xml(json, tmp)
nexml_validate(tmp)
[1] TRUE
```

Obviously this is just a preliminary mapping to start discussion. The
convention is relatively self-explanatory.

1.  Repeated nodes (`edge`, `otu` etc) are replaced by a list of such
    nodes.  
2.  `meta` elements are collapsed into namespaced properties
3.  A `@context` is constructed from the `xmlns` namespaces
4.  Tweaks for tidy JSON-LD:

<!-- end list -->

  - XML comment nodes are dropped. Round trip will not restore these.
  - `about` attributes are dropped (as they are redundant to the nesting
    in JSON-LD). Round trip should restore these.

## Why would we want to do this?

### Linked-Data NeXML

The NeXML standard is only half-semantic, in that metadata (in
RDFa-style `meta` elements) can be serialized to RDF (e.g. via an XSLT
stylesheet), but the actual NeXML data cannot.
