library(tidyverse)
library(nexld)
# Utilities for converting NeXML to ape::phylo object formats
f <- system.file("examples", "comp_analysis.xml", package="RNeXML")

library(phylobase)

f1 <- system.file("examples", "simmap.nex", package="RNeXML")
f2 <- system.file("examples", "sparql.newick", package="RNeXML")

t1 <- readNexus(f1) #???
t2 <- readNewick(f2)

## FIXME: Parse into phylobase trees, sane format.  Let phylobase handle conversion

read_nexml <- function(x, ...){
  parse_nexml(x)
}
nex <- read_nexml(f)

edge_df <- purrr::map_dfr(nex$trees$tree$edge, dplyr::as_tibble)

edge_df %>%
  select(from = source, to = target, length=length) %>%
  as_tbl_graph() %>%
  ggraph( layout="dendrogram") +
  geom_edge_elbow(aes(y=length))

node_df <- purrr::map_dfr(nex$trees$tree$node, dplyr::as_tibble) %>% arrange(label)
otus_df <-purrr::map_dfr(nex$otus$otu, dplyr::as_tibble)

node_df$id <- as.integer(as.factor(node_df$`@id`))
nodes <- node_df %>% dplyr::select(`@id`, id, label)
edge_list <-
dplyr::inner_join(edge_df, nodes, by = c(source = "@id")) %>%
dplyr::select(length, target, source=id) %>%
dplyr::inner_join(nodes, by = c(target = "@id")) %>%
dplyr::select(length, source, target=id)

labels <- nodes$label
names(labels) <- nodes$id
labels <- labels[!is.na(labels)]

edge_len <- as.numeric(edge_list$length)
names(edge_len) <- paste(edge_list$source, edge_list$target, sep="-")

edges <- as.matrix(edge_list[c("source", "target")])
names(edges) <- c("ancestor", "descendant")

## No luck:
phy <- new("phylo4",
           edge = edges,
           edge.length = edge_len,
           label = labels,
           edge.label = setNames(character(0), character(0)))

## No luck with constructor method either:
phy <- phylo4(edges,
              edge.length = edge_len,
              tip.label = labels)





## direct to ape doesn't have any error checking, just creates a segfault...
phy <- list(edge = unname(as.matrix(edge_list[c("source", "target")])),
            length = as.numeric(edge_list$length),
            Nnode = dim(nodes)[[1]] - length(tips),
            tip.label = as.character(na.omit(nodes$label))
            )
class(phy) <- "phylo"
plot(phy)













## Not implemented

get_trees <- function(nex){
  ## Frame fully nested?

}



get_characters <- function(nex){

}

get_taxa <- function(nex){

}

## use jsonld to nest otu definitions in otu references
xml_to_json(f, "ex.json")
nex <- getElement(jsonlite::fromJSON(
  jsonld::jsonld_frame("ex.json", "inst/frames/embed.json")),
  "@graph")
nex$trees$tree$node
