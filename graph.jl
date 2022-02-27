using Graphs, GraphPlot, Plots, Colors, DataFrames 
include("julia-community.jl")
import .JuliaCommunity as juliac



function run_erdos(n, ne)
    g = erdos_renyi(n, ne);
    nodesize = [Graphs.outdegree(g, v) for v in Graphs.vertices(g)];
    
    return g, gplot(g, nodesize = nodesize);
end

function run_barabasi(n, k)
    g = barabasi_albert(n, k);
    nodesize = [Graphs.outdegree(g, v) for v in Graphs.vertices(g)];
    return g, gplot(g, nodesize = nodesize);
end

function barabasi_graph(n,k)
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

function erdos_graph(n,ne)
    g = erdos_renyi(n, ne);
    
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


# n = 50

# for i in 2:10:100
#     g_erdos, plot_erdos = run_erdos(n,i)
#     display(plot_erdos)
# end

# for i in 2:5:10
#     g_barabasi, plot_barabasi = run_barabasi(n,i)
#     display(plot_barabasi)
# end


n = 1000 # number of vertices
k = 5   # vertex exepected degree 
b = 0.1  #probability two vertex be conected 


# g = watts_strogatz(n, k, b)
# # g = erdos_renyi(n, 10000);
# adj_g = adjacency_matrix(g)

# from = adj_g.rowval
# to = zeros(Int64,length(from)) 
# id = [i for i=1:n]

# for i in 1:n
#     for j in (adj_g.colptr[i]):(adj_g.colptr[i+1]-1)
#         to[j] = i
#     end
# end

# adj_g , from , to , id = barabasi_graph(n , 10)
# adj_g , from , to , id = watts_strogatz_graph(n , k , b)
adj_g , from , to , id = erdos_graph(n , 100)


nodes = DataFrame(id = id, label = id, importance = ones(Int64,n))
network = DataFrame(from = from, to = to, weight = ones(Int64,size(from)))


jc = juliac.JuliaCommunityInstance(network, nodes = nodes, node_label_field = "label", 
                                   node_weighted = true, is_directed = false,
                                   to_summarise_graph = false, task_series = "leiden")

#plot the entire network/graph
juliac.plot_network(jc , line_type="straight", node_size_smoother = 0.8, edge_width_smoother = 1.2)

jc.γ = 0.1

juliac.discover_communities(jc)
# display(spy(adj_g))

println(jc.memberships)
# sort!(jc.memberships,[:c])

coms = [hcat(jc.memberships.id)  hcat(jc.memberships.c)]
coms = coms[sortperm(coms[:, 2]), :]; # sorted by communities

A = Matrix(adj_g)

A = A[coms[:,1], coms[:,1]]
spy(A)

# for i in 1:jc.n_community
#     juliac.plot_community(jc, i, line_type="straight")
# end
