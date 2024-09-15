function checked_filepath(filepath::String, dir::String)
    # if isfile(filepath)
    #     return filepath
    # elseif isfile(joinpath(dir, filepath))
    #     return normpath(joinpath(dir, filepath))
    # elseif isfile(joinpath(dir, basename(filepath)))
    #     return normpath(joinpath(dir, basename(filepath)))
    # else
    #     error("File ", filepath, " not found!")
    # end
    if isabspath(filepath) && isfile(filepath)
        return filepath
    elseif !isabspath(filepath) && isfile(filepath)
        newpath = joinpath(dir, filepath)
        if isfile(newpath)
            return newpath
        else
            error("file ", newpath, " not found!")
        end
    else
        error("file ", filepath, " not found!")
    end
end

function copy_all_files(dest::String, allfiles::Vector{String})
    println("\nCopy files to ", dest, "...")
    mkpath(dest)
    # for file ∈ texfiles
    #     cp(file.filepath, joinpath(dest, basename(file.filepath)), force=true)
    #     println("   ✔ ", basename(file.filepath))
    #     for link ∈ file.links
    #         cp(link.path, joinpath(dest, link.linkedfilename), force=true)
    #         println("   ✔ ", link.linkedfilename)
    #     end
    # end
    # for file ∈ copy2
    #     cp(file, joinpath(dest, basename(file)), force=true)
    #     println("   ✔ ", basename(file))
    # end
    for file ∈ allfiles
        cp(file, joinpath(dest, basename(file)), force=true)
        println("   ✔ ", basename(file))
    end
end

function update_links(dest::String, texfiles::Vector{TeXFile})
    println("Update links...")
    for file ∈ texfiles
        if length(file.links) > 0
            str = read(joinpath(dest, basename(file.filepath)), String)
            newstr = ""
            a = 1
            b = file.links[1].startpos-1
            newstr *= str[a:b]
            n = length(file.links)
            for i ∈ 1:n-1
                newstr *= file.links[i].linkedfilename
                a, b = file.links[i].endpos+1, file.links[i+1].startpos-1
                newstr *= str[a:b]
            end
            i = n
            newstr *= file.links[i].linkedfilename
            a = file.links[i].endpos+1
            newstr *= str[a:end]
            open(joinpath(dest, basename(file.filepath)), "w+") do io
                write(io, newstr)
            end
            println("   ✔ ", basename(file.filepath))
        end
    end
    println()
end
