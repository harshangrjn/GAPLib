using JuMP

"""
    build_gap_model(inst::GAPInstance; optimizer_factory=nothing) -> Model

Build the standard GAP integer linear program for a single
instance.

Decision variables:
    x[i,j] ∈ {0,1}  —  1 iff job j is assigned to agent i

Objective (minimize):
    ∑_{i,j} c[i,j] * x[i,j]

Constraints:
    (assignment)  ∀ j:  ∑_i x[i,j] = 1
    (capacity)    ∀ i:  ∑_j r[i,j] * x[i,j] ≤ b[i]
"""
function build_gap_model(inst::GAPInstance; optimizer_factory=nothing)
    m, n = inst.m, inst.n

    if optimizer_factory !== nothing
        model = JuMP.Model(optimizer_factory)
    else
        model = JuMP.Model()
    end

    JuMP.@variable(model, x[1:m, 1:n], Bin)

    JuMP.@objective(model, Min, sum(inst.c[i, j] * x[i, j] for i in 1:m, j in 1:n))

    JuMP.@constraint(model, assignment[j in 1:n],
        sum(x[i, j] for i in 1:m) == 1)

    JuMP.@constraint(model, capacity[i in 1:m],
        sum(inst.r[i, j] * x[i, j] for j in 1:n) <= inst.b[i])

    return model
end
