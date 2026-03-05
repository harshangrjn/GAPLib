"""
    GAPInstance

Holds a single Generalized Assignment Problem instance parsed from the
Yagiura / OR-Library format.

Fields:
  m  - number of agents
  n  - number of jobs
  c  - cost matrix (m x n), c[i,j] = cost of assigning job j to agent i
  r  - resource matrix (m x n), r[i,j] = resource consumed
  b  - capacity vector (length m), b[i] = capacity of agent i
"""
struct GAPInstance
    m::Int
    n::Int
    c::Matrix{Int}
    r::Matrix{Int}
    b::Vector{Int}
end

"""
    SolveResult

Shared result container used by single-instance and batch solve scripts.
"""
struct SolveResult
    family::Symbol
    file::String
    m::Int
    n::Int
    objective::Float64
    termination_status::String
    known_opt::Union{Int,Nothing}
    opt_source::Symbol
    match::Symbol
end
