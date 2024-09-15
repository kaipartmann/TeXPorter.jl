function show_found_files(texfiles::Vector{TeXFile})
    println("\nThe following files are linked to the project:")
    alllinkedfiles = Vector{String}(undef, 0)
    for file ∈ texfiles
        println("•  ", basename(file.filepath))
        push!(alllinkedfiles, file.filepath)
        for linkedfile ∈ file.links
            println("   ->  ", basename(linkedfile.path))
            push!(alllinkedfiles, linkedfile.path)
        end
    end
    unique!(alllinkedfiles)
    println()
    return alllinkedfiles
end

function ask_for_other_files_to_include(dir::AbstractString, allinkedfiles::Vector{String})
    foundfiles = readdir(dir, join=true)
    files = Vector{String}(undef, 0)
    for file ∈ foundfiles
        if file ∉ allinkedfiles
            push!(files, file)
        end
    end
    files = basename.(filter(x->!endswith(x,".DS_Store") .& isfile(x), files))
    menu = MultiSelectMenu(files, pagesize=30, charset=:unicode)
    idxSet = request("Select files that should be included in the export, too:", menu)
    for idx ∈ idxSet
        push!(allinkedfiles, files[idx])
    end
    return nothing
end