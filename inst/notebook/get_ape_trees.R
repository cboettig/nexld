library(tidyverse)
library(nexld)
# Utilities for converting NeXML to ape::phylo object formats
f <- system.file("examples", "comp_analysis.xml", package="RNeXML")



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

tips <- as.character(na.omit(nodes$label))
phy <- list(edge = unname(as.matrix(edge_list[c("source", "target")])),
            length = edge_list$length,
            Nnode = dim(nodes)[[1]] - length(tips),
            tip.label = tips
            )
class(phy) <- "phylo"
plot(phy)




get_trees <- function(nex){
  ## Frame fully nested?

}



get_characters <- function(nex){

}

get_taxa <- function(nex){

}

xml_to_json(f, "ex.json")
nex <- getElement(jsonlite::fromJSON(
  jsonld::jsonld_frame("ex.json", "inst/frames/embed.json")),
  "@graph")
nex$trees$tree$node
