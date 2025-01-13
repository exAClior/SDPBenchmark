using BenchmarkTools
using JuMP
using CSV
using DataFrames
using Clarabel
using SDPLR
using MosekTools
using Hypatia
using Loraine
using Pajarito
using ProxSDP
using SCS
using SDPA
using COSMO
using CSDP

include("../scripts/problems.jl")

function main()
    level = 1
    for solver in [SDPLR, Clarabel, Mosek, Hypatia, Loraine, Pajarito, ProxSDP, SCS, SDPA, COSMO, CSDP]
        CSV.write("data/$(solver)_sdp_star_graph.csv", DataFrame(solver=[], size=Int64[],
            time=Float64[], error=Float64[], mem=Float64[]))
        for n in 2:4:10
            try
                time = @belapsed solve_star_graph_problem($n, $level, $(solver.Optimizer))

                mem = @ballocated solve_star_graph_problem($n, $level, $(solver.Optimizer))

                cur_err = abs(solve_star_graph_problem(n, level, solver.Optimizer) - (-1.0))

                @info "solver: $solver, n: $n, finished in $time seconds, with error $cur_err, mem: $(mem/10^6) MB"
                CSV.write("data/$(solver)_sdp_star_graph.csv", DataFrame(solver=solver, size=n, time=time, error=cur_err, mem=mem / 10^6), append=true)
            catch e
                @info "solve: $solver, n: $n, error: $e"
            end

        end
    end
end

# By Theorem 8 in paper "Application of the Level-2 Quantum Lasserre  Hierarchy
# in Quantum Approximation Algorithms", 

# maximum eigenvalue of H = sum_{i,j} (I - X_i X_j - Y_i Y_j - Z_i Z_j)/4 = (n
# +1)/2 where $n$ is the number leaves in the star graph

# The hamiltonian we compute here is H' = n * I - 2 * H
# therefore, we should always get the minimum eigenvalue of -1

main()