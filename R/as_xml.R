
## Convert list to XML

# - Frame JSON into predictable format; applying context to achieve de-referencing
# - Import framed JSON as list
# - serialize list to XML: Adjust from xml2::as_xml_document

## inside adaptiation of as_xml_document_method?
# - Unfold list-of-elements, property = [{}, {}] into [property={}, property={}, property={}]
# - Data values as XML attributes

## Do these in JSON, list, or XML stage?
# - Replace any non-nexml-namespace node with corresponding meta node.  (identify URI properties as ResourceMeta rel/href)
# - Fix node ordering to conform to schema.  (Sort based on pre-specified order probably best/easiest; alternately check refs come after defs)




## Frame: follow this framing order as well as nesting order
# nexml
#  - otus
#     - otu
#  - trees
#    - tree
#       - node
#       - edge
#  - characters
#    - format
#       - states
#       - char
#    - matrix
#       - row
#       - cell

## Use order given in json frame(?)
fix_node_order <- function(nexld){



}
