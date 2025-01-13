alias b := benchmark

init: 
	julia --project -e 'using Pkg; Pkg.activate(); Pkg.instantiate(); Pkg.update()'

benchmark:
	julia --project benchmarks/sdpsolvers.jl 2>&1 | tee log/benchmark.log

plot:
	julia --project scripts/plots.jl
