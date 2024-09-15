abstract type Token end
abstract type TeXFile end

struct Include <: Token
    pos::UnitRange{Int}
    text::String
    argpos::UnitRange{Int}
    arg::String
end

struct Input <: Token
    pos::UnitRange{Int}
    text::String
    argpos::UnitRange{Int}
    arg::String
end

struct IncludeGraphics <: Token
    pos::UnitRange{Int}
    text::String
    argpos::UnitRange{Int}
    arg::String
end

struct BibResource <: Token
    pos::UnitRange{Int}
    text::String
    argpos::UnitRange{Int}
    arg::String
end

struct FileLink
    linkedfilename::String
    path::String
    startpos::Int
    endpos::Int
end

struct LinkedTeXFile <: TeXFile
    filepath::String
    links::Vector{FileLink}
end

struct Preamble <: TeXFile
    filepath::String
    links::Vector{FileLink}
    linkedtexfiles::Vector{String}
end

