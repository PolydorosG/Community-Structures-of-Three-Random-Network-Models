include("julia-community.jl")

using DataFrames, Graphs

import .JuliaCommunity as juliac


#n are the number of vertices 
n = 100 
#k is each vertex exepected degree 
k = 2
#b is the probability two vertex to be conected 
b = 0.5

g = watts_strogatz(n, k, b)

adj_g = adjacency_matrix(g)

println(adj_g)

from = adj_g.rowval
to = zeros(Int64,length(from)) 
id = zeros(Int64,n)
importance = zeros(Int64,length(id))
weight = zeros(Int64,length(from))

for i in 1:n
    id[i] = i
    importance[i] = 1
    for j in (adj_g.colptr[i]):(adj_g.colptr[i+1]-1)
        to[j] = i;
        weight[j] = 1
    end
end

println(id)
println(from)
println(to)
println(importance)
println(weight)

nodes = DataFrame(id = id, 
               label = id, 
            importance = importance)
network = DataFrame(from = from,
                      to = to,
                  weight = weight)


#================================================================
create a JuliaCommunity instance.
task_series is used to name the processing data files (e.g., data/communities-$task_series.csv) and 
the svgs (e.g., fig/network-graph-$task_series.svg or fig/community-$(community_id)-$task_series.svg).
================================================================#
jc = juliac.JuliaCommunityInstance(network, nodes = nodes, node_label_field = "label", 
                                   node_weighted = true, to_summarise_graph = false, task_series = "leiden")

#plot the entire network/graph
juliac.plot_network(jc , line_type="straight", node_size_smoother = 0.8, edge_width_smoother = 1.2)

jc.γ = 0.1

juliac.discover_communities(jc)

println(jc.communities)
println(jc.memberships)

for i in 1:jc.n_community
    juliac.plot_community(jc, i, line_type="straight")
end
