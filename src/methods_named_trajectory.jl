module MethodsNamedTrajectory

export add_component!
export update!
export times

using ..StructNamedTrajectory
using ..StructTimeSlice

function add_component!(
    traj::NamedTrajectory,
    name::Symbol,
    data::AbstractVecOrMat{Float64};
    type=:state
)

    # check if data is a vector and convert to matrix if so
    if data isa AbstractVector
        data = reshape(data, 1, traj.T)
    end

    # get the dimension of the new component
    dim = size(data, 1)

    # check data against existing data
    @assert size(data, 2) == traj.T
    @assert name ∉ keys(traj.components)
    @assert type ∈ (:state, :control)


    # update components

    comp_dict = Dict(pairs(traj.components))

    comp_dict[name] = (traj.dim + 1):(traj.dim + dim)

    if type == :state
        comp_dict[:states] = vcat(comp_dict[:states], comp_dict[name])
    else
        comp_dict[:controls] = vcat(comp_dict[:controls], comp_dict[name])
    end

    traj.components = NamedTuple(comp_dict)


    # update dims

    traj.dim += dim

    dim_dict = Dict(pairs(traj.dims))

    dim_dict[name] = dim

    if type == :state
        dim_dict[:states] += dim
    else
        traj.controls_names = (traj.controls_names..., name)
        dim_dict[:controls] += dim
    end

    traj.dims = NamedTuple(dim_dict)


    # update names

    traj.names = (traj.names..., name)


    # update data

    traj.data = vcat(traj.data, data)

    traj.datavec = vec(view(traj.data, :, :))

    return nothing
end

function update!(traj::NamedTrajectory, comp::Symbol, data::AbstractMatrix{Float64})
    @assert comp ∈ keys(traj.components)
    @assert size(data, 1) == length(traj.components[comp])
    @assert size(data, 2) == traj.T
    # TODO: test to see if updating both matrix and vec is necessary
    traj.data[traj.components[comp], :] = data
    traj.datavec = vec(view(traj.data, :, :))
end

function times(traj::NamedTrajectory, dt_name::Union{Symbol, Nothing}=nothing)
    if traj.dynamical_timesteps
        @assert !isnothing(dt_name)
        return cumsum(vec(traj[dt_name]))
    else
        return [0:traj.T-1...] .* traj.timestep
    end
end


"""
    size(traj::NamedTrajectory) = (dim = traj.dim, T = traj.T)
"""
Base.size(traj::NamedTrajectory) = (dim = traj.dim, T = traj.T)

Base.getindex(traj::NamedTrajectory, t::Int) = TimeSlice(traj, t)

Base.lastindex(traj::NamedTrajectory) = traj.T

function Base.getindex(traj::NamedTrajectory, ts::AbstractVector{Int})::Vector{TimeSlice}
    return [traj[t] for t ∈ ts]
end

Base.getindex(traj::NamedTrajectory, symb::Symbol) = getproperty(traj, symb)

function Base.setproperty!(traj::NamedTrajectory, symb::Symbol, val::AbstractMatrix)
    if symb ∈ fieldnames(NamedTrajectory)
        setfield!(traj, symb, val)
    else
        update!(traj, symb, val)
    end
end

function Base.getproperty(traj::NamedTrajectory, symb::Symbol)
    if symb ∈ fieldnames(NamedTrajectory)
        return getfield(traj, symb)
    else
        indices = traj.components[symb]
        return traj.data[indices, :]
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
