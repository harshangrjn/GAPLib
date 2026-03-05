"""
Known optimal (or best-known) objective values for GAP benchmark instances,
collected from GAPLIB (http://astarte.csr.unibo.it/gapdata/gapinstances.html)
and the OR-Library (https://people.brunel.ac.uk/~mastjjb/jeb/orlib/gapinfo.html).

All values are for the minimization formulation.

Keys are `(family, filename)` tuples, e.g. `(:A, "a05100")`.
A value of `nothing` means only an upper bound is known (stored separately).
"""
const KNOWN_OPTIMA = Dict{Tuple{Symbol,String}, Union{Int,Nothing}}(
    # ── Type A (Yagiura / Chu-Beasley) ──
    (:A, "a05100") => 1698,
    (:A, "a05200") => 3235,
    (:A, "a10100") => 1360,
    (:A, "a10200") => 2623,
    (:A, "a20100") => 1158,
    (:A, "a20200") => 2339,

    # ── Type B ──
    (:B, "b05100") => 1843,
    (:B, "b05200") => 3552,
    (:B, "b10100") => 1407,
    (:B, "b10200") => 2827,
    (:B, "b20100") => 1166,
    (:B, "b20200") => 2339,

    # ── Type C (includes published larger-instance optima) ──
    (:C, "c05100") => 1931,
    (:C, "c05200") => 3456,
    (:C, "c10100") => 1402,
    (:C, "c10200") => 2806,
    (:C, "c10400") => 5597,
    (:C, "c15900") => 11341,
    (:C, "c20100") => 1243,
    (:C, "c201600") => 18803,
    (:C, "c20200") => 2391,
    (:C, "c20400") => 4782,
    (:C, "c30900") => 9982,
    (:C, "c40400") => 4244,
    (:C, "c401600") => 17146,
    (:C, "c60900") => 9326,

    # ── Type D (n ≤ 200 only; d20200 has no published optimum) ──
    (:D, "d05100") => 6353,
    (:D, "d05200") => 12742,
    (:D, "d10100") => 6347,
    (:D, "d10200") => 12430,
    (:D, "d10400") => 24961,
    (:D, "d20100") => 6185,
    (:D, "d20200") => nothing,   # best-known UB = 12244

    # ── Type E ──
    (:E, "e05100")  => 12681,
    (:E, "e05200")  => 24931,
    (:E, "e10100")  => 11577,
    (:E, "e10200")  => 23307,
    (:E, "e10400")  => 45748,
    (:E, "e15900")  => 102426,
    (:E, "e20100")  => 8436,
    (:E, "e20200")  => 22379,
    (:E, "e20400")  => 44879,
    (:E, "e201600") => 180659,
    (:E, "e30900")  => 100433,
    (:E, "e40400")  => 44561,
    (:E, "e60900")  => 100149,
    (:E, "e401600") => 178307,
    (:E, "e801600") => 176820,
)

"""
Best-known upper bounds for instances where the optimum is not proven.
"""
const KNOWN_UPPER_BOUNDS = Dict{Tuple{Symbol,String}, Int}(
    (:D, "d20200") => 12244,
)

"""
    get_known_optimum(family::Symbol, filename::String)

Return `(opt, source)` where `opt` is the known optimal value (or `nothing`)
and `source` is `:optimum`, `:upper_bound`, or `:unknown`.
"""
function get_known_optimum(family::Symbol, filename::String)
    key = (family, filename)
    if haskey(KNOWN_OPTIMA, key)
        val = KNOWN_OPTIMA[key]
        if val !== nothing
            return (val, :optimum)
        end
    end
    if haskey(KNOWN_UPPER_BOUNDS, key)
        return (KNOWN_UPPER_BOUNDS[key], :upper_bound)
    end
    return (nothing, :unknown)
end
