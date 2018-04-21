library(ape)
data("bird.orders")
plot(bird.orders)

library(tidygraph)
library(ggraph)
bird <- as_tbl_graph(bird.orders)

ggraph(bird, layout="dendrogram") + geom_edge_elbow()

bird %>% activate(edges) %>%
  mutate(length = bird.orders$edge.length) %>%
  ggraph(layout="dendrogram") + geom_edge_elbow(aes(y=length))
