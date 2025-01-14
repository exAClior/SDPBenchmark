using TinyPOP

using TinyPOP.Graphs, TinyPOP.DynamicPolynomials, TinyPOP.SemialgebraicSets 

function solve_star_graph_problem(n_sites::Int, lasserre_hierarchy::Int, optimizer)

    star = star_graph(n_sites)

    vec_idx2ij = [(i, j) for i in 1:n_sites for j in (i+1):n_sites]

    findvaridx(i, j) = findfirst(x -> x == (i, j), vec_idx2ij)

    @ncpolyvar pij[1:length(vec_idx2ij)]

    objective = sum(pij[[findvaridx(ee.src, ee.dst) for ee in edges(star)]])

    gs = [
        [(pij[findvaridx(i, j)]^2 - 1) for i in 1:n_sites for j in (i+1):n_sites];
        [-(pij[findvaridx(i, j)]^2 - 1) for i in 1:n_sites for j in (i+1):n_sites]; [(pij[findvaridx(sort([i, j])...)] * pij[findvaridx(sort([j, k])...)] - (pij[findvaridx(sort([i, j])...)] + pij[findvaridx(sort([j, k])...)] + pij[findvaridx(sort([i, k])...)] - 1) / 2) for i in 1:n_sites, j in 1:n_sites, k in 1:n_sites if (i != j && j != k && i != k)]
        [-(pij[findvaridx(sort([i, j])...)] * pij[findvaridx(sort([j, k])...)] - (pij[findvaridx(sort([i, j])...)] + pij[findvaridx(sort([j, k])...)] + pij[findvaridx(sort([i, k])...)] - 1) / 2) for i in 1:n_sites, j in 1:n_sites, k in 1:n_sites if (i != j && j != k && i != k)]]

    problem = PolyOptProblem(pij, objective, gs)

    method = MomentSOS(pij, lasserre_hierarchy, optimizer)

    model = relaxation(method, problem)
    set_silent(model)

    optimize!(model)
    return objective_value(model)
end