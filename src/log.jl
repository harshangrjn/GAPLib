"""
Logging helpers for GAP scripts.
"""

function print_result_box(r)
    known_text = r.known_opt === nothing ? "- ($(r.opt_source))" : "$(r.known_opt) ($(r.opt_source))"
    lines = [
        "Instance  : $(r.family)/$(r.file)",
        "Size      : m=$(r.m), n=$(r.n)",
        "Status    : $(r.termination_status)",
        "Objective : $(r.objective)",
        "Known     : $(known_text)",
        "Match     : $(r.match)",
    ]

    width = maximum(length.(lines))
    border = "+" * repeat("-", width + 2) * "+"

    println(border)
    for line in lines
        println("| " * rpad(line, width) * " |")
    end
    println(border)
end

