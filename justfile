alias b := benchmark

init: 
	julia --project -e 'using Pkg; Pkg.activate(); Pkg.instantiate(); Pkg.update()'

performance:
	julia --project benchmarks/performance.jl 2>&1 | tee log/performance.log

benchmark:
	julia --project benchmarks/sdpsolvers.jl 2>&1 | tee log/benchmark.log

plot:
	julia --project scripts/plots.jl

plot_perf: 
	julia --project scripts/plots_perf.jl