using BenchmarkTools
using COSMO
using JuMP
using CSV, DataFrames

include("../scripts/problems.jl")

function main()
    level = 1
    # Clarabel,Mosek,Hypatia
    for solver in [COSMO]
        CSV.write("data/$(solver)_sdp_star_graph_perf.csv", DataFrame(solver=[], size=Int64[],
            time=Float64[], error=Float64[], mem=Float64[]))
        optimizer = solver.Optimizer
        for n in 4:4:30
            try
                # time = @belapsed solve_star_graph_problem($n, $level, $(optimizer))


                mem = @ballocated solve_star_graph_problem($n, $level, $(optimizer))

                cur_err = abs(solve_star_graph_problem(n, level, optimizer) - (-1.0))

                @info "solver: $solver, n: $n, mem: $(mem/10^6) MB"
                CSV.write("data/$(solver)_sdp_star_graph_perf.csv", DataFrame(solver=solver, size=n, mem=mem / 10^6), append=true)
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

main()