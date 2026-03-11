"""
Solve a single GAP instance with JuMP and an ILP solver.

Run from the repository root:
    1) Edit the hard-coded configuration values below.
    2) Run: julia --project=. run_gap.jl

Instance source library and references:
    - OR-Library (GAP format/info):
      https://people.brunel.ac.uk/~mastjjb/jeb/orlib/gapinfo.html
    - Yagiura GAP page (A/B/C/D/E sets):
      http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/
    - GAPLIB benchmark summary:
      http://astarte.csr.unibo.it/gapdata/gapinstances.html

"""

using Printf
using JuMP
using Gurobi

include(joinpath(@__DIR__, "src", "api.jl"))
include(joinpath(@__DIR__, "src", "log.jl"))

# --------------------------------------------------------------------------
# Hard-coded run configuration (edit these values as needed)
# --------------------------------------------------------------------------
const FAMILY = :C               # Available: :A, :B, :C, :D, :E
const FILE = "c20400"           # Example: "a05100", "d10200", "e20200"
const TIME_LIMIT_SEC = 1500.0    # Solver time limit in seconds
const QUIET = true             # true => suppress solver output

function solve_one(family::Symbol, file::String; time_limit::Float64=300.0, quiet::Bool=false)
    data = load_gap_instance(family, file)
    model = build_gap_model(data; optimizer_factory=Gurobi.Optimizer)

    if quiet
        JuMP.set_silent(model)
    end
    JuMP.set_time_limit_sec(model, time_limit)
    JuMP.optimize!(model)

    status = string(termination_status(model))
    obj = has_values(model) ? objective_value(model) : NaN

    known, source = get_known_optimum(family, file)
    match = if isnan(obj)
        :no_solution
    elseif source == :unknown
        :no_reference
    elseif source == :optimum && known !== nothing
        abs(obj - known) < 1e-6 ? :exact : :mismatch
    elseif source == :upper_bound && known !== nothing
        obj <= known + 1e-6 ? :within_ub : :mismatch
    else
        :no_reference
    end

    return SolveResult(family, file, data.m, data.n, obj, status, known, source, match)
end

result = solve_one(FAMILY, FILE; time_limit=TIME_LIMIT_SEC, quiet=QUIET)
print_result_box(result)


