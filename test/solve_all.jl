"""
Iterates through all GAP families (A–E), parses every instance, solves with
JuMP + Gurobi, and compares to known optimal values where available.

Usage (from project root):
    julia --project=. test/solve_all.jl
"""

using Printf

include(joinpath(@__DIR__, "..", "src", "api.jl"))
using Gurobi

const FAMILIES = [:A, :B, :C, :D, :E]

struct SolveResult
    family::Symbol
    file::String
    m::Int
    n::Int
    objective::Float64
    termination_status::String
    known_opt::Union{Int,Nothing}
    opt_source::Symbol          # :optimum, :upper_bound, or :unknown
    match::Symbol               # :exact, :within_ub, :mismatch, :no_reference
end

function solve_all(; families=FAMILIES, time_limit::Float64=300.0, silent::Bool=true)
    results = SolveResult[]
    mismatches = SolveResult[]

    println("=" ^ 100)
    @printf("%-6s  %-12s  %5s  %5s  %12s  %-18s  %12s  %-12s  %s\n",
            "Family", "File", "m", "n", "Objective", "Status", "Known Opt", "Source", "Match")
    println("-" ^ 100)

    for family in families
        files = list_instance_files(family)
        for file in files
            data = load_gap_instance(family, file)

            model = build_gap_model(data; optimizer_factory=Gurobi.Optimizer)
            if silent
                JuMP.set_silent(model)
            end
            JuMP.set_time_limit_sec(model, time_limit)

            JuMP.optimize!(model)

            status = string(termination_status(model))
            obj = if has_values(model)
                objective_value(model)
            else
                NaN
            end

            known, source = get_known_optimum(family, file)

            match_result = if isnan(obj)
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

            r = SolveResult(family, file, data.m, data.n, obj, status,
                            known, source, match_result)
            push!(results, r)
            if match_result == :mismatch
                push!(mismatches, r)
            end

            known_str = known === nothing ? "-" : string(known)
            @printf("%-6s  %-12s  %5d  %5d  %12.1f  %-18s  %12s  %-12s  %s\n",
                    family, file, data.m, data.n, obj, status,
                    known_str, source, match_result)
        end
    end

    println("=" ^ 100)
    println()

    n_total = length(results)
    n_exact = count(r -> r.match == :exact, results)
    n_ub    = count(r -> r.match == :within_ub, results)
    n_mis   = count(r -> r.match == :mismatch, results)
    n_noref = count(r -> r.match == :no_reference, results)
    n_nosol = count(r -> r.match == :no_solution, results)

    println("Summary: $n_total instances solved")
    println("  Exact match to known optimum:  $n_exact")
    println("  Within known upper bound:      $n_ub")
    println("  No published reference:        $n_noref")
    println("  No solution found:             $n_nosol")
    println("  MISMATCH:                      $n_mis")

    if !isempty(mismatches)
        println()
        println("⚠ MISMATCHES (objective ≠ known optimum):")
        for r in mismatches
            @printf("  %s/%s: got %.1f, expected %s (%s)\n",
                    r.family, r.file, r.objective,
                    r.known_opt === nothing ? "?" : string(r.known_opt),
                    r.opt_source)
        end
    end

    return results
end

if abspath(PROGRAM_FILE) == @__FILE__
    results = solve_all()
end
