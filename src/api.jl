"""
    Shared API for loading and solving GAP instances across families A–E.
"""

include("structs.jl")
include("parse_gap.jl")
include("model_gap.jl")
include("known_optima.jl")

# Mapping from family symbol to the data folder name.
# This corresponds to the Yagiura archive families:
# A->gap_a, B->gap_b, C->gap_c, D->gap_d, E->gap_e.
#   Type A: http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/gap_a.zip
#   Type B: http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/gap_b.zip
#   Type C: http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/gap_c.zip
#   Type D: http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/gap_d.zip
#   Type E: http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/gap_e.zip

const FAMILY_DIRS = Dict{Symbol,String}(
    :A => "gap_a",
    :B => "gap_b",
    :C => "gap_c",
    :D => "gap_d",
    :E => "gap_e",
)

"""
    benchmarks_root()

Return the benchmarks directory (`<project_root>/benchmarks`).
"""
function benchmarks_root()
    return joinpath(data_root(), "benchmarks")
end

"""
    data_root()

Return the project root directory (parent of `src/`).
"""
function data_root()
    return dirname(@__DIR__)
end

"""
    load_gap_instance(family::Symbol, file::String, instance_id::Int=1) -> GAPInstance

Load a single GAP instance from disk.

Arguments:
  - `family`      : one of `:A`, `:B`, `:C`, `:D`, `:E`
  - `file`        : filename within the family folder, e.g. `"a05100"`
  - `instance_id` : 1-based index if the file contains multiple instances
                    (Yagiura files always contain 1)
"""
function load_gap_instance(family::Symbol, file::String, instance_id::Int=1)
    haskey(FAMILY_DIRS, family) || error("Unknown family :$family. Expected one of :A, :B, :C, :D, :E.")

    filepath = joinpath(benchmarks_root(), FAMILY_DIRS[family], file)
    isfile(filepath) || error("Instance file not found: $filepath")

    instances = parse_gap_file(filepath)

    if instance_id < 1 || instance_id > length(instances)
        error("instance_id=$instance_id out of range; file '$file' contains $(length(instances)) instance(s).")
    end

    return instances[instance_id]
end

"""
    build_gap_model(family::Symbol, file::String, instance_id::Int=1;
                    optimizer_factory=nothing)
        -> (model, data)

Convenience wrapper: loads the instance and builds the JuMP model in one call.
"""
function build_gap_model(family::Symbol, file::String, instance_id::Int=1;
                         optimizer_factory=nothing)
    data = load_gap_instance(family, file, instance_id)
    model = build_gap_model(data; optimizer_factory=optimizer_factory)
    return model, data
end

"""
    list_instance_files(family::Symbol) -> Vector{String}

Return sorted list of instance filenames for the given family.
"""
function list_instance_files(family::Symbol)
    haskey(FAMILY_DIRS, family) || error("Unknown family :$family")
    dir = joinpath(benchmarks_root(), FAMILY_DIRS[family])
    files = filter(f -> !startswith(f, "."), readdir(dir))
    return sort(files)
end
