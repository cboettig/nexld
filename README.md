
[![Travis-CI Build Status](https://travis-ci.org/cboettig/nexld.svg?branch=master)](https://travis-ci.org/cboettig/nexld)

<!-- README.md is generated from README.Rmd. Please edit that file -->
nexld
=====

The goal of nexld is to serialize NeXML xml data into JSON-LD.

Installation
------------

You can install nexld from github with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/nexld")
```

Example
-------

This is a basic example which shows you how to solve a common problem:

``` r
library(nexld)
ex <- system.file("extdata/example.xml", package = "nexld")

xml_to_json(ex)
{
  "@context": {
    "@vocab": "http://www.nexml.org/2009/"
  },
  "version": "0.9",
  "base": "http://example.org/",
  "schemaLocation": "http://www.nexml.org/2009 ../xsd/nexml.xsd",
  "otus": {
    "@id": "tax1",
    "label": "RootTaxaBlock",
    "otu": [
      {
        "@type": "otu",
        "@id": "t1",
        "label": "species 1"
      },
      {
        "@type": "otu",
        "@id": "t2",
        "label": "species 2"
      },
      {
        "@type": "otu",
        "@id": "t3",
        "label": "species 3"
      },
      {
        "@type": "otu",
        "@id": "t4",
        "label": "species 4"
      },
      {
        "@type": "otu",
        "@id": "t5",
        "label": "species 5"
      }
    ]
  },
  "trees": [
    {
      "@type": "trees",
      "otus": "tax1",
      "@id": "Trees1",
      "label": "TreesBlockFromXML",
      "tree": [
        {
          "@type": "tree",
          "@id": "tree1",
          "@type.1": "nex:FloatTree",
          "label": "tree1",
          "node": [
            {
              "@type": "node",
              "@id": "n1",
              "label": "n1",
              "root": "true"
            },
            {
              "@type": "node",
              "@id": "n2",
              "label": "n2",
              "otu": "t1"
            },
            {
              "@type": "node",
              "@id": "n3",
              "label": "n3"
            },
            {
              "@type": "node",
              "@id": "n4",
              "label": "n4",
              "about": "#n4",
              "meta": {
                "@id": "dict1",
                "property": "cdao:has_tag",
                "content": "true",
                "@type": "nex:LiteralMeta",
                "datatype": "xsd:boolean"
              }
            },
            {
              "@type": "node",
              "@id": "n5",
              "label": "n5",
              "otu": "t3"
            },
            {
              "@type": "node",
              "@id": "n6",
              "label": "n6",
              "otu": "t2"
            },
            {
              "@type": "node",
              "@id": "n7",
              "label": "n7"
            },
            {
              "@type": "node",
              "@id": "n8",
              "label": "n8",
              "otu": "t5"
            },
            {
              "@type": "node",
              "@id": "n9",
              "label": "n9",
              "otu": "t4"
            }
          ],
          "edge": [
            {
              "@type": "edge",
              "source": "n1",
              "target": "n3",
              "@id": "e1",
              "length": "0.34534"
            },
            {
              "@type": "edge",
              "source": "n1",
              "target": "n2",
              "@id": "e2",
              "length": "0.4353"
            },
            {
              "@type": "edge",
              "source": "n3",
              "target": "n4",
              "@id": "e3",
              "length": "0.324"
            },
            {
              "@type": "edge",
              "source": "n3",
              "target": "n7",
              "@id": "e4",
              "length": "0.3247"
            },
            {
              "@type": "edge",
              "source": "n4",
              "target": "n5",
              "@id": "e5",
              "length": "0.234"
            },
            {
              "@type": "edge",
              "source": "n4",
              "target": "n6",
              "@id": "e6",
              "length": "0.3243"
            },
            {
              "@type": "edge",
              "source": "n7",
              "target": "n8",
              "@id": "e7",
              "length": "0.32443"
            },
            {
              "@type": "edge",
              "source": "n7",
              "target": "n9",
              "@id": "e8",
              "length": "0.2342"
            }
          ]
        },
        {
          "@type": "tree",
          "@id": "tree2",
          "@type.1": "nex:IntTree",
          "label": "tree2",
          "node": [
            {
              "@type": "node",
              "@id": "tree2n1",
              "label": "n1"
            },
            {
              "@type": "node",
              "@id": "tree2n2",
              "label": "n2",
              "otu": "t1"
            },
            {
              "@type": "node",
              "@id": "tree2n3",
              "label": "n3"
            },
            {
              "@type": "node",
              "@id": "tree2n4",
              "about": "#tree2n4",
              "label": "n4",
              "meta": {
                "@id": "tree2dict1",
                "property": "cdao:has_tag",
                "content": "true",
                "@type": "nex:LiteralMeta",
                "datatype": "xsd:boolean"
              }
            },
            {
              "@type": "node",
              "@id": "tree2n5",
              "label": "n5",
              "otu": "t3"
            },
            {
              "@type": "node",
              "@id": "tree2n6",
              "label": "n6",
              "otu": "t2"
            },
            {
              "@type": "node",
              "@id": "tree2n7",
              "label": "n7"
            },
            {
              "@type": "node",
              "@id": "tree2n8",
              "label": "n8",
              "otu": "t5"
            },
            {
              "@type": "node",
              "@id": "tree2n9",
              "label": "n9",
              "otu": "t4"
            }
          ],
          "edge": [
            {
              "@type": "edge",
              "source": "tree2n1",
              "target": "tree2n3",
              "@id": "tree2e1",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n1",
              "target": "tree2n2",
              "@id": "tree2e2",
              "length": "2"
            },
            {
              "@type": "edge",
              "source": "tree2n3",
              "target": "tree2n4",
              "@id": "tree2e3",
              "length": "3"
            },
            {
              "@type": "edge",
              "source": "tree2n3",
              "target": "tree2n7",
              "@id": "tree2e4",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n4",
              "target": "tree2n5",
              "@id": "tree2e5",
              "length": "2"
            },
            {
              "@type": "edge",
              "source": "tree2n4",
              "target": "tree2n6",
              "@id": "tree2e6",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n7",
              "target": "tree2n8",
              "@id": "tree2e7",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n7",
              "target": "tree2n9",
              "@id": "tree2e8",
              "length": "1"
            }
          ]
        }
      ]
    },
    {
      "@type": "trees",
      "otus": "tax1",
      "@id": "Trees",
      "label": "TreesBlockFromXML",
      "tree": [
        {
          "@type": "tree",
          "@id": "tree1",
          "@type.1": "nex:FloatTree",
          "label": "tree1",
          "node": [
            {
              "@type": "node",
              "@id": "n1",
              "label": "n1",
              "root": "true"
            },
            {
              "@type": "node",
              "@id": "n2",
              "label": "n2",
              "otu": "t1"
            },
            {
              "@type": "node",
              "@id": "n3",
              "label": "n3"
            },
            {
              "@type": "node",
              "@id": "n4",
              "label": "n4",
              "about": "#n4",
              "meta": {
                "@id": "dict1",
                "property": "cdao:has_tag",
                "content": "true",
                "@type": "nex:LiteralMeta",
                "datatype": "xsd:boolean"
              }
            },
            {
              "@type": "node",
              "@id": "n5",
              "label": "n5",
              "otu": "t3"
            },
            {
              "@type": "node",
              "@id": "n6",
              "label": "n6",
              "otu": "t2"
            },
            {
              "@type": "node",
              "@id": "n7",
              "label": "n7"
            },
            {
              "@type": "node",
              "@id": "n8",
              "label": "n8",
              "otu": "t5"
            },
            {
              "@type": "node",
              "@id": "n9",
              "label": "n9",
              "otu": "t4"
            }
          ],
          "edge": [
            {
              "@type": "edge",
              "source": "n1",
              "target": "n3",
              "@id": "e1",
              "length": "0.34534"
            },
            {
              "@type": "edge",
              "source": "n1",
              "target": "n2",
              "@id": "e2",
              "length": "0.4353"
            },
            {
              "@type": "edge",
              "source": "n3",
              "target": "n4",
              "@id": "e3",
              "length": "0.324"
            },
            {
              "@type": "edge",
              "source": "n3",
              "target": "n7",
              "@id": "e4",
              "length": "0.3247"
            },
            {
              "@type": "edge",
              "source": "n4",
              "target": "n5",
              "@id": "e5",
              "length": "0.234"
            },
            {
              "@type": "edge",
              "source": "n4",
              "target": "n6",
              "@id": "e6",
              "length": "0.3243"
            },
            {
              "@type": "edge",
              "source": "n7",
              "target": "n8",
              "@id": "e7",
              "length": "0.32443"
            },
            {
              "@type": "edge",
              "source": "n7",
              "target": "n9",
              "@id": "e8",
              "length": "0.2342"
            }
          ]
        },
        {
          "@type": "tree",
          "@id": "tree2",
          "@type.1": "nex:IntTree",
          "label": "tree2",
          "node": [
            {
              "@type": "node",
              "@id": "tree2n1",
              "label": "n1"
            },
            {
              "@type": "node",
              "@id": "tree2n2",
              "label": "n2",
              "otu": "t1"
            },
            {
              "@type": "node",
              "@id": "tree2n3",
              "label": "n3"
            },
            {
              "@type": "node",
              "@id": "tree2n4",
              "about": "#tree2n4",
              "label": "n4",
              "meta": {
                "@id": "tree2dict1",
                "property": "cdao:has_tag",
                "content": "true",
                "@type": "nex:LiteralMeta",
                "datatype": "xsd:boolean"
              }
            },
            {
              "@type": "node",
              "@id": "tree2n5",
              "label": "n5",
              "otu": "t3"
            },
            {
              "@type": "node",
              "@id": "tree2n6",
              "label": "n6",
              "otu": "t2"
            },
            {
              "@type": "node",
              "@id": "tree2n7",
              "label": "n7"
            },
            {
              "@type": "node",
              "@id": "tree2n8",
              "label": "n8",
              "otu": "t5"
            },
            {
              "@type": "node",
              "@id": "tree2n9",
              "label": "n9",
              "otu": "t4"
            }
          ],
          "edge": [
            {
              "@type": "edge",
              "source": "tree2n1",
              "target": "tree2n3",
              "@id": "tree2e1",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n1",
              "target": "tree2n2",
              "@id": "tree2e2",
              "length": "2"
            },
            {
              "@type": "edge",
              "source": "tree2n3",
              "target": "tree2n4",
              "@id": "tree2e3",
              "length": "3"
            },
            {
              "@type": "edge",
              "source": "tree2n3",
              "target": "tree2n7",
              "@id": "tree2e4",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n4",
              "target": "tree2n5",
              "@id": "tree2e5",
              "length": "2"
            },
            {
              "@type": "edge",
              "source": "tree2n4",
              "target": "tree2n6",
              "@id": "tree2e6",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n7",
              "target": "tree2n8",
              "@id": "tree2e7",
              "length": "1"
            },
            {
              "@type": "edge",
              "source": "tree2n7",
              "target": "tree2n9",
              "@id": "tree2e8",
              "length": "1"
            }
          ]
        }
      ]
    }
  ]
} 
```
