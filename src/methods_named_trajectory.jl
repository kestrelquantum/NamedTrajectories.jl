module MethodsNamedTrajectory

export components
export add_component!
export remove_component
export remove_components
export update!
export times
export timesteps

using DataStructures

using ..StructNamedTrajectory
using ..StructKnotPoint


"""
    copy(::NamedTrajectory)

Returns a copy of the trajectory.
"""
function Base.copy(traj::NamedTrajectory)
    return NamedTrajectory(copy(traj.data), traj)
end

"""
    isequal(traj1::NamedTrajectory, traj2::NamedTrajectory)

Check if trajectories are equal w.r.t. data using `Base.isequal`
"""
function Base.isequal(traj1::NamedTrajectory, traj2::NamedTrajectory)
    if isequal(traj1.data, traj2.data) &&
        isequal(traj1.names, traj2.names)
        return true
    else
        return false
    end
end


"""
    :(==)(traj1::NamedTrajectory, traj2::NamedTrajectory)

Check if trajectories are equal w.r.t. using `Base.:(==)`
"""
function Base.:(==)(traj1::NamedTrajectory, traj2::NamedTrajectory)
    if traj1.data == traj2.data &&
        traj1.names == traj2.names
        return true
    else
        return false
    end
end




"""
    components(::NamedTrajectory)

Returns a NamedTuple containing the names and corresponding data matrices of the trajectory.
"""
function components(traj::NamedTrajectory)
    data = [traj[comp] for comp ∈ traj.names]
    return NamedTuple(zip(traj.names, data))
end


"""
    timesteps(::NamedTrajectory)

Returns the timesteps of a trajectory as a vector.
"""
function timesteps(traj::NamedTrajectory)
    if traj.timestep isa Symbol
        return vec(traj[traj.timestep])
    else
        return fill(traj.timestep, traj.T)
    end
end

"""
    add_component!(traj, name::Symbol, data::AbstractVecOrMat; type={:state, :control})

Add a component to the trajectory.
"""
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

    comp_dict = OrderedDict(pairs(traj.components))

    comp_dict[name] = (traj.dim + 1):(traj.dim + dim)

    if type == :state
        comp_dict[:states] = vcat(comp_dict[:states], comp_dict[name])
    else
        comp_dict[:controls] = vcat(comp_dict[:controls], comp_dict[name])
    end

    traj.components = NamedTuple(comp_dict)


    # update dims

    traj.dim += dim

    dim_dict = OrderedDict(pairs(traj.dims))

    dim_dict[name] = dim

    if type == :state
        dim_dict[:states] += dim
    else
        traj.control_names = (traj.control_names..., name)
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

"""
    remove_component(traj, name::Symbol)

Remove a component from the trajectory.
"""
function remove_component(traj::NamedTrajectory, name::Symbol)
    @assert name ∈ traj.names
    comps = NamedTuple([(key => data) for (key, data) ∈ pairs(components(traj)) if key != name])
    return NamedTrajectory(comps, traj)
end

"""
    remove_components(traj, names::Vector{Symbol})

Remove a set of components from the trajectory.
"""
function remove_components(traj::NamedTrajectory, names::Vector{Symbol})
    @assert all([name ∈ traj.names for name ∈ names])
    comps = NamedTuple([(key => data) for (key, data) ∈ pairs(components(traj)) if !(key ∈ names)])
    return NamedTrajectory(comps, traj)
end

"""
    update!(traj, name::Symbol, data::AbstractMatrix{Float64})

Update a component of the trajectory.
"""
function update!(traj::NamedTrajectory, name::Symbol, data::AbstractMatrix{Float64})
    @assert name ∈ traj.names
    @assert size(data, 1) == traj.dims[name]
    @assert size(data, 2) == traj.T
    # TODO: test to see if updating both matrix and vec is necessary
    traj.data[traj.components[name], :] = data
    traj.datavec = vec(view(traj.data, :, :))
end

# TODO: implement and test this
# function update_bounds!(traj::NamedTrajectory, comp::Symbol, bounds::AbstractMatrix{Float64})
#     @assert comp ∈ keys(traj.components)
#     @assert size(bounds, 1) == 2
#     @assert size(bounds, 2) == length(traj.components[comp])
#     traj.bounds[traj.components[comp], :] = bounds
# end


"""
    times(traj)::Vector{Float64}

Returns the times of a trajectory as a vector.
"""
function times(traj::NamedTrajectory)
    if traj.timestep isa Symbol
        return cumsum([0.0, vec(traj[traj.timestep])[1:end-1]...])
    else
        return [0:traj.T-1...] * traj.timestep
    end
end


"""
    size(traj::NamedTrajectory) = (dim = traj.dim, T = traj.T)
"""
Base.size(traj::NamedTrajectory) = (dim = traj.dim, T = traj.T)

"""
    getindex(traj, t::Int)::KnotPoint

Returns the knot point at time `t`.
"""
Base.getindex(traj::NamedTrajectory, t::Int) = KnotPoint(traj, t)

"""
    getindex(traj, ts::AbstractVector{Int})::Vector{KnotPoint}

Returns the knot points at times `ts`.
"""
function Base.getindex(traj::NamedTrajectory, ts::AbstractVector{Int})::Vector{KnotPoint}
    return [traj[t] for t ∈ ts]
end

"""
    lastindex(traj::NamedTrajectory)

Returns the final time index of the trajectory.
"""
Base.lastindex(traj::NamedTrajectory) = traj.T

"""
    getindex(traj, symb::Symbol)

Dispatches indexing of trajectories as either accessing a component or a property via `getproperty`.
"""
Base.getindex(traj::NamedTrajectory, symb::Symbol) = getproperty(traj, symb)

"""
    getproperty(traj, symb::Symbol)

Returns the component of the trajectory with name `symb` or the property of the trajectory with name `symb`.
"""
function Base.getproperty(traj::NamedTrajectory, symb::Symbol)
    if symb ∈ fieldnames(NamedTrajectory)
        return getfield(traj, symb)
    else
        indices = traj.components[symb]
        return traj.data[indices, :]
    end
end

"""
    setproperty!(traj, name::Symbol, val::Any)

Dispatches setting properties of trajectories as either setting a component or a property via `setfield!` or `update!`.
"""
function Base.setproperty!(traj::NamedTrajectory, symb::Symbol, val::Any)
    if symb ∈ fieldnames(NamedTrajectory)
        setfield!(traj, symb, val)
    else
        update!(traj, symb, val)
    end
end



function Base.:*(α::Float64, traj::NamedTrajectory)
    return NamedTrajectory(α * traj.datavec, traj)
end

function Base.:*(traj::NamedTrajectory, α::Float64)
    return NamedTrajectory(α * traj.datavec, traj)
end

function Base.:+(traj1::NamedTrajectory, traj2::NamedTrajectory)
    @assert sort([traj1.names...]) == sort([traj2.names...])
    @assert traj1.dim == traj2.dim
    @assert traj1.T == traj2.T
    return NamedTrajectory(traj1.datavec + traj2.datavec, traj1)
end

function Base.:-(traj1::NamedTrajectory, traj2::NamedTrajectory)
    @assert sort([traj1.names...]) == sort([traj2.names...])
    @assert traj1.dim == traj2.dim
    @assert traj1.T == traj2.T
    return NamedTrajectory(traj1.datavec - traj2.datavec, traj1)
end


end