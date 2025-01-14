using BenchmarkTools
using JuMP
using CSV, DataFrames
using Clarabel, SDPLR, MosekTools, Hypatia, Loraine, Pajarito, ProxSDP, SCS,
SDPA, COSMO, CSDP, HiGHS, DSDP

include("../scripts/problems.jl")


@show Threads.nthreads()

function main()
    level = 1
    # Clarabel,Mosek,Hypatia
    for solver in [SDPLR, Loraine, Pajarito, ProxSDP, SCS, SDPA, COSMO, CSDP, DSDP]
        CSV.write("data/$(solver)_sdp_star_graph.csv", DataFrame(solver=[], size=Int64[],
            time=Float64[], error=Float64[], mem=Float64[]))
        optimizer = solver == Pajarito ? optimizer_with_attributes(
            Pajarito.Optimizer,
            "oa_solver" => optimizer_with_attributes(
                HiGHS.Optimizer,
                MOI.Silent() => true,
                "mip_feasibility_tolerance" => 1e-8,
                "mip_rel_gap" => 1e-6,
            ),
            "conic_solver" =>
                optimizer_with_attributes(Hypatia.Optimizer, MOI.Silent() => true),
        ) : solver.Optimizer
        for n in 4:2:16
            try
                time = @belapsed solve_star_graph_problem($n, $level, $(optimizer))

                mem = @ballocated solve_star_graph_problem($n, $level, $(optimizer))

                cur_err = abs(solve_star_graph_problem(n, level, optimizer) - (-1.0))

                @info "solver: $solver, n: $n, finished in $time seconds, with error $cur_err, mem: $(mem/10^6) MB"
                CSV.write("data/$(solver)_sdp_star_graph.csv", DataFrame(solver=solver, size=n, time=time, error=cur_err, mem=mem / 10^6), append=true)
                if time > 100
                    @info "solver: $solver solves $n in $time seconds, too long, aborting larger scales"
                    break
                end
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