module Utils

export save, load

using JLD2
using ..Types

function JLD2.save(filename::String, traj::NamedTrajectory)
    @assert split(filename, ".")[end] == "jld2"
    save(filename, "traj", traj)
end

function JLD2.load(filename::String)
    @assert split(filename, ".")[end] == "jld2"
    return load(filename, "traj")
end

end
