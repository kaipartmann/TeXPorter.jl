using PackageCompiler

create_app(
    "/Users/kfrb/Code/TeXPorter",
    "texporter",
    precompile_statements_file="build/generate_precompile.jl",
)
