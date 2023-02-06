module Methods

export add_component!
export update!
export times

using ..Types

function add_component!(
    traj::NamedTrajectory,
    symb::Symbol,
    vals::AbstractVecOrMat{Float64};
    type=:state
)
    if vals isa AbstractVector
        vals = reshape(vals, 1, traj.T)
    end

    @assert size(vals, 2) == traj.T
    @assert symb ∉ keys(traj.components)
    @assert type ∈ (:state, :control)

    dim = size(vals, 1)

    traj.components = (;
        traj.components...,
        symb => (traj.dim + 1):(traj.dim + dim)
    )
    traj.data = vcat(traj.data, vals)
    traj.datavec = vec(view(traj.data, :, :))
    traj.dim += dim
    dim_dict = Dict(pairs(dims))
    dim_dict[symb] = dim
    if type == :state
        push!(traj.states, symb)
        dim_dict[:x] += dim
    else
        push!(traj.controls, symb)
        dim_dict[:u] += dim
    end
    traj.dims = NamedTuple(dim_dict)
end

function update!(traj::NamedTrajectory, comp::Symbol, data::AbstractMatrix{Float64})
    @assert comp ∈ keys(traj.components)
    @assert size(data, 1) == length(traj.components[comp])
    @assert size(data, 2) == traj.T
    # TODO: test to see if updating both matrix and vec is necessary
    traj.data[traj.components[comp], :] = data
    traj.datavec = vec(view(traj.data, :, :))
end

function times(traj::NamedTrajectory)
    return [0:traj.T-1...] .* traj.dt
end


"""
    size(traj::NamedTrajectory) = (dim = traj.dim, T = traj.T)
"""
Base.size(traj::NamedTrajectory) = (dim = traj.dim, T = traj.T)

Base.getindex(traj::NamedTrajectory, t::Int)::TimeSlice =
    TimeSlice(t, view(traj.data, :, t), traj.components, traj.names, traj.controls_names)

Base.lastindex(traj::NamedTrajectory) = traj.T

function Base.getindex(traj::NamedTrajectory, ts::AbstractVector{Int})::Vector{TimeSlice}
    return [traj[t] for t ∈ ts]
end

Base.getindex(traj::NamedTrajectory, symb::Symbol) = getproperty(traj, symb)

Base.setproperty!(traj::NamedTrajectory, symb::Symbol, val::AbstractMatrix{Float64}) =
    update!(traj, symb, val)

function Base.getproperty(traj::NamedTrajectory, symb::Symbol)
    if symb ∈ fieldnames(NamedTrajectory)
        return getfield(traj, symb)
    else
        indices = traj.components[symb]
        return traj.data[indices, :]
    end
end

function Base.getproperty(slice::TimeSlice, symb::Symbol)
    if symb in fieldnames(TimeSlice)
        return getfield(slice, symb)
    else
        indices = slice.components[symb]
        return slice.data[indices]
    end
end

function Base.:*(α::Float64, traj::NamedTrajectory)
    return NamedTrajectory(α * traj.datavec, traj)
end

function Base.:*(traj::NamedTrajectory, α::Float64)
    return NamedTrajectory(α * traj.datavec, traj)
end

function Base.:+(traj1::NamedTrajectory, traj2::NamedTrajectory)
    @assert traj1.dim == traj2.dim
    @assert traj1.T == traj2.T
    return NamedTrajectory(traj1.datavec + traj2.datavec, traj1)
end

function Base.:-(traj1::NamedTrajectory, traj2::NamedTrajectory)
    @assert traj1.dim == traj2.dim
    @assert traj1.T == traj2.T
    return NamedTrajectory(traj1.datavec - traj2.datavec, traj1)
end

end
