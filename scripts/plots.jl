using CSV, DataFrames
using SDPLR, Clarabel, MosekTools, Hypatia, Loraine, Pajarito, ProxSDP, SCS, SDPA, COSMO, CSDP
using CairoMakie

function plot_sdp_performance()

    solvers = [SDPLR, Clarabel, Mosek, Loraine, Pajarito, ProxSDP, SCS, SDPA, COSMO]

    mem_cost = Dict("$solver" => Tuple{Int64,Float64}[] for solver in solvers)
    time_cost = Dict("$solver" => Tuple{Int64,Float64}[] for solver in solvers)
    error = Dict("$solver" => Tuple{Int64,Float64}[] for solver in solvers)

	for solver in solvers
        df = CSV.read("data/$(solver)_sdp_star_graph.csv", DataFrame)
        mem_cost["$solver"] = [(data[1], data[2]) for data in zip(df.size, df.mem)]
        time_cost["$solver"] = [(data[1], data[2]) for data in zip(df.size, df.time)]
        error["$solver"] = [(data[1], data[2]) for data in zip(df.size, df.error)]
	end

    purposes = [("Memory Usage", "log(Memory Cost) (Mb)", mem_cost, log), ("Time Usage", "log(Time Cost) (sec)", time_cost, log), ("Error Plot", "log(1/Error)", error, x -> log(1 / x))]

	for (purpose, ylabel, dict, transform) in purposes
		fig = Figure()

		ax = Axis(fig[1,1],title=purpose, xlabel="Size", ylabel=ylabel)
		for solver in solvers
            lines!(ax, [term[1] for term in dict["$solver"]], [transform(term[2]) for term in dict["$solver"]], label="$solver")
		end
		axislegend(ax; position = :rb, labelsize = 15)
		save("figs/$purpose.png", fig)
	end


end


plot_sdp_performance()
