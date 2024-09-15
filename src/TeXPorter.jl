module TeXPorter

using ArgParse
using Dates
using REPL.TerminalMenus
using Printf

include("types.jl")
include("iomanager.jl")
include("parser.jl")
include("userinput.jl")

function julia_main()::Cint
    s = ArgParseSettings("TeXManager - manage the export process for LaTeX-projects.")
    @add_arg_table! s begin
        "--dir", "-d"
            arg_type = String
            default = pwd()
            help = "Directory to search for preamble"
        "--out", "-o"
            arg_type = String
            default = joinpath(pwd(), Dates.format(now(), "yyyy-mm-dd_HH-MM"))
            help = "Destination of exported files"
    end
    parsed_args = parse_args(ARGS, s)

    ## start main program
    println("="^80)
    println("TeXManager.jl")
    println("Copyright © 2024 Kai Partmann. All rights reserved.")
    println("="^80)
    preamble_file = find_preamble(parsed_args["dir"])
    preamble = Preamble(preamble_file)
    texfiles = [preamble; [LinkedTeXFile(file) for file ∈ preamble.linkedtexfiles]]
    alllinkedfiles = show_found_files(texfiles)
    ask_for_other_files_to_include(parsed_args["dir"], alllinkedfiles)
    copy_all_files(parsed_args["out"], alllinkedfiles)
    update_links(parsed_args["out"], texfiles)
    return 0
end

end
