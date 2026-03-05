"""
    parse_gap_file(filepath::String) -> Vector{GAPInstance}

Parse a GAP instance file in the Yagiura / OR-Library format.

The format expected per file is one instance (no leading P count):

    m  n
    c[1,1] c[1,2] … c[1,n]     (m rows, whitespace-delimited, may span lines)
    …
    c[m,1] c[m,2] … c[m,n]
    r[1,1] r[1,2] … r[1,n]
    …
    r[m,1] r[m,2] … r[m,n]
    b[1] b[2] … b[m]

Returns a vector of `GAPInstance` (length 1 for Yagiura files).
"""
function parse_gap_file(filepath::String)::Vector{GAPInstance}
    raw = read(filepath, String)
    tokens = split(raw)
    nums = parse.(Int, tokens)

    pos = 1
    instances = GAPInstance[]

    while pos <= length(nums)
        remaining = length(nums) - pos + 1
        if remaining < 2
            break
        end

        m = nums[pos]
        n = nums[pos + 1]
        pos += 2

        expected = 2 * m * n + m   # costs + resources + capacities
        if pos + expected - 1 > length(nums)
            error("parse_gap_file: not enough data in '$filepath' for instance " *
                  "with m=$m, n=$n. Need $expected more integers but only " *
                  "$(length(nums) - pos + 1) remain.")
        end

        c = Matrix{Int}(undef, m, n)
        for i in 1:m, j in 1:n
            c[i, j] = nums[pos]
            pos += 1
        end

        r = Matrix{Int}(undef, m, n)
        for i in 1:m, j in 1:n
            r[i, j] = nums[pos]
            pos += 1
        end

        b = Vector{Int}(undef, m)
        for i in 1:m
            b[i] = nums[pos]
            pos += 1
        end

        _validate_instance(filepath, length(instances) + 1, m, n, c, r, b)

        push!(instances, GAPInstance(m, n, c, r, b))
    end

    if isempty(instances)
        error("parse_gap_file: no valid instance found in '$filepath'.")
    end

    return instances
end

"""
    _validate_instance(filepath, idx, m, n, c, r, b)

Sanity-check a parsed instance. Warns on errors in dimension mismatches.
"""
function _validate_instance(filepath::String, idx::Int,
                            m::Int, n::Int,
                            c::Matrix{Int}, r::Matrix{Int}, b::Vector{Int})
    if size(c) != (m, n)
        error("Instance $idx in '$filepath': cost matrix size $(size(c)) != ($m,$n)")
    end
    if size(r) != (m, n)
        error("Instance $idx in '$filepath': resource matrix size $(size(r)) != ($m,$n)")
    end
    if length(b) != m
        error("Instance $idx in '$filepath': capacity vector length $(length(b)) != $m")
    end

    if any(c .< 0)
        @warn "Instance $idx in '$filepath': negative cost entries detected"
    end
    if any(r .< 0)
        @warn "Instance $idx in '$filepath': negative resource entries detected"
    end
    if any(b .< 0)
        @warn "Instance $idx in '$filepath': negative capacity entries detected"
    end
end
