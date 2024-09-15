comment_positions(str::AbstractString) = findall(r"%.+?(?=\n)", str)

function is_no_comment(startpos::Int, cmtpositions::Vector{UnitRange{Int}})
    cmtflag = true
    for cmt in cmtpositions
        if startpos ∈ cmt
            cmtflag = false
        end
    end
    return cmtflag
end

function getarg(text::AbstractString)
    enclosed = findfirst(r"(?<=\{)(.|\s)+?(?=\})", text)
    if isnothing(enclosed)
        error("No argument found in given text!")
    else
        innerpos = findfirst(r"(?!\s).*", text[enclosed])
        pos = first(enclosed)+first(innerpos)-1:first(enclosed)+last(innerpos)-1
        return pos, text[pos]
    end
end

function is_preamble(str::AbstractString, cmtpos::Vector{UnitRange{Int}})
    positions = findall(r"\\documentclass((.|\n)*?)\{((.|\n)*?)\}", str)
    if !isnothing(positions)
        for pos ∈ positions
            if is_no_comment(first(pos), cmtpos)
                return true
            end
        end
    end
    return false
end

function get_include(str::AbstractString, cmtpos::Vector{UnitRange{Int}}) 
    positions = findall(r"\\include\{((.|\n)*?)\}", str)
    tokens = Vector{Include}(undef, 0)
    if !isnothing(positions)
        for pos ∈ positions
            if is_no_comment(first(pos), cmtpos)
                text = str[pos]
                argpos, arg = getarg(text)
                push!(tokens, Include(pos, text, argpos, arg))
            end
        end
    end
    return tokens
end

function get_input(str::AbstractString, cmtpos::Vector{UnitRange{Int}}) 
    positions = findall(r"\\input\{((.|\n)*?)\}", str)
    tokens = Vector{Input}(undef, 0)
    if !isnothing(positions)
        for pos ∈ positions
            if is_no_comment(first(pos), cmtpos)
                text = str[pos]
                argpos, arg = getarg(text)
                push!(tokens, Input(pos, text, argpos, arg))
            end
        end
    end
    return tokens
end

function get_includegraphics(str::AbstractString, cmtpos::Vector{UnitRange{Int}}) 
    positions = findall(r"\\includegraphics((.|\n)*?)\{((.|\n)*?)\}", str)
    tokens = Vector{IncludeGraphics}(undef, 0)
    if !isnothing(positions)
        for pos ∈ positions
            if is_no_comment(first(pos), cmtpos)
                text = str[pos]
                argpos, arg = getarg(text)
                push!(tokens, IncludeGraphics(pos, text, argpos, arg))
            end
        end
    end
    return tokens
end

function get_bibresource(str::AbstractString, cmtpos::Vector{UnitRange{Int}}) 
    positions = findall(r"\\addbibresource\{((.|\n)*?)\}", str)
    tokens = Vector{BibResource}(undef, 0)
    if !isnothing(positions)
        for pos ∈ positions
            if is_no_comment(first(pos), cmtpos)
                text = str[pos]
                argpos, arg = getarg(text)
                push!(tokens, BibResource(pos, text, argpos, arg))
            end
        end
    end
    return tokens
end

function find_preamble(dir::AbstractString)
    tex_files = filter(x -> endswith(x,".tex"), readdir(dir, join=true))
    tex_files_text = [read(file, String) for file ∈ tex_files]
    preamble_flag = zeros(Bool, length(tex_files))
    for (i, text) ∈ enumerate(tex_files_text)
        cmtpos = comment_positions(text)
        preamble_flag[i] = is_preamble(text, cmtpos)
    end
    preamble_finds = findall(preamble_flag)
    if length(preamble_finds) == 0
        error("No preamble found! check directory!")
    end
    if length(preamble_finds) > 1
        error("More than one preamble found! check directory!")
    end
    preamble = tex_files[preamble_finds[1]]
    return preamble
end

function lexer(str::AbstractString)
    cmtpos = comment_positions(str)
    IncludeTokens = get_include(str, cmtpos)
    InputTokens = get_input(str, cmtpos)
    IncludeGraphicsTokens = get_includegraphics(str, cmtpos)
    BibResourceTokens = get_bibresource(str, cmtpos)
    tokens = [IncludeTokens; InputTokens; IncludeGraphicsTokens; BibResourceTokens]
    return tokens
end

function parse_linkedfiles(str::AbstractString, dir::String)
    tokens = lexer(str)
    linkedfiles = Vector{FileLink}(undef, 0)
    for token ∈ tokens
        linkedfilename = basename(token.arg)
        path = checked_filepath(token.arg, dir)
        startpos = first(token.pos)+first(token.argpos)-1
        endpos = first(token.pos)+last(token.argpos)-1
        push!(linkedfiles, FileLink(linkedfilename, path, startpos, endpos))
    end
    sort!(linkedfiles, by=x->x.startpos)
    return linkedfiles
end

function LinkedTeXFile(filepath::String)
    str = read(filepath, String)
    links = parse_linkedfiles(str, dirname(filepath))
    LinkedTeXFile(filepath, links)
end

function Preamble(filepath::String)
    str = read(filepath, String)
    links = parse_linkedfiles(str, dirname(filepath))
    linkedtexfiles = Vector{String}(undef, 0)
    for link ∈ links
        if endswith(link.linkedfilename, ".tex")
            push!(linkedtexfiles, link.path)
        end
    end
    Preamble(filepath, links, linkedtexfiles)
end