using Graphs, GraphPlot, Colors, DataFrames, SparseArrays, Plots
include("julia-community.jl")
import .JuliaCommunity as juliac


# Create an Erdos-Renyi graph and return it in form suitable for Leiden algorithm
function erdos_graph(n, p)
    g = erdos_renyi(n, p);
    
    adj_g = adjacency_matrix(g)
    from = adj_g.rowval
    
    to = zeros(Int64,length(from)) 
    id = [i for i=1:n]

    for i in 1:n
        for j in (adj_g.colptr[i]):(adj_g.colptr[i+1]-1)
            to[j] = i
        end
    end

    return  adj_g , from , to , id; 
end


# Create a Watts-Strogatz graph and return it in form suitable for Leiden algorithm
function watts_strogatz_graph(n , k , b)
    g = watts_strogatz(n, k, b)
    
    adj_g = adjacency_matrix(g)
    from = adj_g.rowval
    
    to = zeros(Int64,length(from)) 
    id = [i for i=1:n]

    for i in 1:n
        for j in (adj_g.colptr[i]):(adj_g.colptr[i+1]-1)
            to[j] = i
        end
    end

    return  adj_g , from , to , id; 
end


# Create a Barabasi-Albert graph and return it in form suitable for Leiden algorithm
function barabasi_graph(n, k)
    g = barabasi_albert(n, k)
    
    adj_g = adjacency_matrix(g)
    from = adj_g.rowval
    
    to = zeros(Int64,length(from)) 
    id = [i for i=1:n]

    for i in 1:n
        for j in (adj_g.colptr[i]):(adj_g.colptr[i+1]-1)
            to[j] = i
        end
    end

    return  adj_g , from , to , id; 
end



n = 1000# number of vertices

# # Uncomment to produce Erdos Renyi matrices 
# for p in 0.001:0.003:0.09
#     local k = 5   # vertex exepected degree 
#     local adj_g , from , to , id = erdos_graph(n , p)


#     local nodes = DataFrame(id = id, label = id, importance = ones(Int64,n))
#     local network = DataFrame(from = from, to = to, weight = ones(Int64,size(from)))


#     local jc = juliac.JuliaCommunityInstance(network, nodes = nodes, node_label_field = "label", 
#                                     node_weighted = true, is_directed = false,
#                                     to_summarise_graph = false, task_series = "leiden")

#     #plot the entire network/graph
#     #juliac.plot_network(jc , line_type="straight", node_size_smoother = 0.8, edge_width_smoother = 1.2)

#     jc.γ = 0.1

#     juliac.discover_communities(jc)
#     println(p)

#     local coms = [hcat(jc.memberships.id)  hcat(jc.memberships.c)]
#     local coms = coms[sortperm(coms[:, 2]), :]; # sorted by communities

#     # use a sparse permutation matrix to move collumns and rows of adj matrix
#     local perm = sparse(1:n, coms[:,1],ones(Int64,n) )
#     local adj_a = perm*adj_g*perm'

#     println("Displaying")
#     display(spy(adj_a, plot_title = "p = " * string(p)))
#       
#     p = histogram(jc.communities.size,color ="grey",bins=100)
#      display(p)
#
# end



# Uncomment to produce Watts Strogatz matrices
# for k in [10, 40]
#     for b in [0.05, 0.8]
        
#         local adj_g , from , to , id = watts_strogatz_graph(n, k, b)

#         local nodes = DataFrame(id = id, label = id, importance = ones(Int64,n))
#         local network = DataFrame(from = from, to = to, weight = ones(Int64,size(from)))


#         local jc = juliac.JuliaCommunityInstance(network, nodes = nodes, node_label_field = "label", 
#                                         node_weighted = true, is_directed = false,
#                                         to_summarise_graph = false, task_series = "leiden")

#         #plot the entire network/graph
#         #juliac.plot_network(jc , line_type="straight", node_size_smoother = 0.8, edge_width_smoother = 1.2)

#         jc.γ = 0.1

#         juliac.discover_communities(jc)
#         println(b)

#         local coms = [hcat(jc.memberships.id)  hcat(jc.memberships.c)]
#         local coms = coms[sortperm(coms[:, 2]), :]; # sorted by communities

#         # use a sparse permutation matrix to move collumns and rows of adj matrix
#         local perm = sparse(1:n, coms[:,1],ones(Int64,n) )
#         local adj_a = perm*adj_g*perm'

#         println("Displaying")
#         display(spy(A, plot_title = "k = " * string(k) * ", b = " * string(b) ))
#         
#         p = histogram(jc.communities.size,color ="grey",bins=100)
#         display(p)
#
#     end
# end



# Uncomment to produce Barabasi Albert matrices
for k in [2 8 16 36]
    local adj_g , from , to , id = barabasi_graph(n , k)


    local nodes = DataFrame(id = id, label = id, importance = ones(Int64,n))
    local network = DataFrame(from = from, to = to, weight = ones(Int64,size(from)))


    local jc = juliac.JuliaCommunityInstance(network, nodes = nodes, node_label_field = "label", 
                                    node_weighted = true, is_directed = false,
                                    to_summarise_graph = false, task_series = "leiden")

    #plot the entire network/graph
    #juliac.plot_network(jc , line_type="straight", node_size_smoother = 0.8, edge_width_smoother = 1.2)

    jc.γ = 0.1

    juliac.discover_communities(jc)
    println(k)

    local coms = [hcat(jc.memberships.id)  hcat(jc.memberships.c)]
    local coms = coms[sortperm(coms[:, 2]), :]; # sorted by communities

    # use a sparse permutation matrix to move collumns and rows of adj matrix
    local perm = sparse(1:n, coms[:,1],ones(Int64,n) )
    local adj_a = perm*adj_g*perm'

    # Note : Our algorithm is quite fast in sorting the matrix by community
    # however running the code for n>10000 will cause the programm to hang 
    # right after printing 'Displaying' due to the implementation of spy 
    # in the Plots library.
    println("Displaying")
    display(spy(adj_a, plot_title = "k = " * string(k)))
    p = histogram(jc.communities.size,color ="grey",bins=100)
    display(p)
    
end
