module StructNamedTrajectory

export NamedTrajectory
export BoundType

using OrderedCollections


const BoundType = Tuple{AbstractVector{<:Real}, AbstractVector{<:Real}}

mutable struct NamedTrajectory{R <: Real}
    data::AbstractMatrix{R}
    datavec::AbstractVector{R}
    T::Int
    timestep::Union{Symbol,R}
    dim::Int
    dims::NamedTuple{dnames, <:Tuple{Vararg{Int}}} where dnames
    bounds::NamedTuple{bnames, <:Tuple{Vararg{BoundType}}} where bnames
    initial::NamedTuple{inames, <:Tuple{Vararg{AbstractVector{R}}}} where inames
    final::NamedTuple{fnames, <:Tuple{Vararg{AbstractVector{R}}}} where fnames
    goal::NamedTuple{gnames, <:Tuple{Vararg{AbstractVector{R}}}} where gnames
    components::NamedTuple{cnames, <:Tuple{Vararg{AbstractVector{Int}}}} where cnames
    names::Tuple{Vararg{Symbol}}
    state_names::Tuple{Vararg{Symbol}}
    control_names::Tuple{Vararg{Symbol}}
end


function NamedTrajectory(
    comp_data::NamedTuple{names, <:Tuple{Vararg{vals}}} where
        {names, vals <: AbstractMatrix{R}};
    controls::Union{Symbol, Tuple{Vararg{Symbol}}}=(),
    timestep::Union{Nothing,Symbol,R}=nothing,
    bounds=(;),
    initial=(;),
    final=(;),
    goal=(;),
) where R <: Real
    controls = controls isa Symbol ? (controls,) : controls

    @assert !isempty(controls)
    @assert !isnothing(timestep)
    @assert timestep isa Symbol && timestep ∈ keys(comp_data) ||
        timestep isa Real "timestep $(timestep)::$(typeof(timestep)) must be a symbol or real"

    @assert all([k ∈ keys(comp_data) for k ∈ controls])
    @assert all([k ∈ keys(comp_data) for k ∈ keys(initial)])
    @assert all([k ∈ keys(comp_data) for k ∈ keys(final)])
    @assert all([k ∈ keys(comp_data) for k ∈ keys(goal)])

    @assert all([k ∈ keys(comp_data) for k ∈ keys(bounds)])

    @assert all([
        bound isa Real ||
        bound isa AbstractVector{<:Real} ||
        bound isa Tuple{<:Real,<:Real} ||
        bound isa BoundType
            for bound ∈ bounds
    ])

    if timestep isa Symbol && !in(timestep, controls)
        controls = (controls..., timestep)
    end

    bounds_dict = OrderedDict{Symbol,Any}(pairs(bounds))

    for (name, bound) ∈ bounds_dict
        if bound isa Real
            bounds_dict[name] = (
                -fill(bound, size(comp_data[name], 1)),
                fill(bound, size(comp_data[name], 1))
            )
        elseif bound isa AbstractVector
            bounds_dict[name] = (-bound, bound)
        elseif bound isa Tuple{<:Real, <:Real}
            bounds_dict[name] = ([bound[1]], [bound[2]])
        end
    end
    bounds = NamedTuple(bounds_dict)

    comp_data_pairs = []
    for (key, val) ∈ pairs(comp_data)
        if val isa AbstractVector{<:Real}
            data = reshape(val, 1, :)
            push!(comp_data_pairs, key => data)
        else
            push!(comp_data_pairs, key => val)
        end
    end

    data = vcat([val for (key, val) ∈ comp_data_pairs]...)

    T = size(data, 2)

    datavec = vec(data)

    # do this to store data matrix as view of datavec
    data = reshape(view(datavec, :), :, T)

    dim = size(data, 1)

    dims_pairs = [(k => size(v, 1)) for (k, v) ∈ comp_data_pairs]

    dims_tuple = NamedTuple(dims_pairs)

    @assert all([length(bounds[k][1]) == dims_tuple[k] for k ∈ keys(bounds)])
    @assert all([length(initial[k]) == dims_tuple[k] for k ∈ keys(initial)])
    @assert all([length(final[k]) == dims_tuple[k] for k ∈ keys(final)])
    @assert all([length(goal[k]) == dims_tuple[k] for k ∈ keys(goal)])

    comp_pairs::Vector{Pair{Symbol, AbstractVector{Int}}} =
        [(dims_pairs[1][1] => 1:dims_pairs[1][2])]

    for (k, dim) in dims_pairs[2:end]
        k_range = comp_pairs[end][2][end] .+ (1:dim)
        push!(comp_pairs, k => k_range)
    end

    # add states and controls to dims

    dim_states = sum([dim for (k, dim) in dims_pairs if k ∉ controls])
    dim_controls = sum([dim for (k, dim) in dims_pairs if k ∈ controls])

    push!(dims_pairs, :states => dim_states)
    push!(dims_pairs, :controls => dim_controls)

    # add states and controls to components

    comp_tuple = NamedTuple(comp_pairs)

    states_comps = vcat([comp_tuple[k] for k ∈ keys(comp_data) if k ∉ controls]...)
    controls_comps = vcat([comp_tuple[k] for k ∈ keys(comp_data) if k ∈ controls]...)

    push!(comp_pairs, :states => states_comps)
    push!(comp_pairs, :controls => controls_comps)

    dims = NamedTuple(dims_pairs)
    comps = NamedTuple(comp_pairs)

    names = Tuple(keys(comp_data))

    state_names = Tuple(k for k ∈ names if k ∉ controls)

    return NamedTrajectory{R}(
        data,
        datavec,
        T,
        timestep,
        dim,
        dims,
        bounds,
        initial,
        final,
        goal,
        comps,
        names,
        state_names,
        controls
    )
end

function NamedTrajectory(
    comps::NamedTuple;
    kwargs...
)
    @assert all([v isa AbstractMatrix || v isa AbstractVector for v ∈ values(comps)])
    vals = [v isa AbstractVector ? reshape(v, 1, :) : v for v ∈ values(comps)]
    comps = NamedTuple([(k => v) for (k, v) ∈ zip(keys(comps), vals)])
    return NamedTrajectory(comps; kwargs...)
end





function NamedTrajectory(
    datavec::AbstractVector{R},
    T::Int,
    components::NamedTuple{
        names,
        <:Tuple{Vararg{AbstractVector{Int}}}
    } where names;
    timestep::Union{Nothing,Symbol,R}=nothing,
    controls::Union{Symbol, Tuple{Vararg{Symbol}}}=(),
    bounds=(;),
    initial=(;),
    final=(;),
    goal=(;),
) where R <: Real
    controls = (controls isa Symbol) ? (controls,) : controls

    @assert !isempty(controls) "must specify at least one control"
    @assert !isnothing(timestep) "must specify a time step size"
    @assert timestep isa Symbol && timestep ∈ keys(components) ||
        timestep isa Real

    @assert all([k ∈ keys(components) for k ∈ controls])
    @assert all([k ∈ keys(components) for k ∈ keys(initial)])
    @assert all([k ∈ keys(components) for k ∈ keys(final)])
    @assert all([k ∈ keys(components) for k ∈ keys(goal)])

    @assert all([k ∈ keys(components) for k ∈ keys(bounds)])
    @assert all([
        (bound isa Real) ||
        (bound isa AbstractVector{<:Real}) ||
        (bound isa Tuple{<:Real,<:Real}) ||
        (bound isa BoundType)
        for bound ∈ bounds
    ])
    if timestep isa Symbol && !in(timestep, controls)
        controls = (controls..., timestep)
    end

    bounds_dict = OrderedDict(pairs(bounds))
    for (name, bound) ∈ bounds_dict
        if bound isa AbstractVector
            bounds_dict[name] = (-bound, bound)
        end
    end
    bounds = NamedTuple(bounds_dict)

    data = reshape(view(datavec, :), :, T)
    dim = size(data, 1)

    @assert all([isa(components[k], AbstractVector{Int}) for k in keys(components)])
    @assert vcat([components[k] for k in keys(components)]...) == 1:dim

    dim_pairs = [(k => length(components[k])) for k in keys(components)]

    dim_states = sum([dim for (k, dim) ∈ dim_pairs if k ∉ controls])
    dim_controls = sum([dim for (k, dim) ∈ dim_pairs if k ∈ controls])

    push!(dim_pairs, :states => dim_states)
    push!(dim_pairs, :controls => dim_controls)

    dims = NamedTuple(dim_pairs)

    @assert all([length(bounds[k][1]) == dims[k] for k in keys(bounds)])
    @assert all([length(initial[k]) == dims[k] for k in keys(initial)])
    @assert all([length(final[k]) == dims[k] for k in keys(final)])
    @assert all([length(goal[k]) == dims[k] for k in keys(goal)])

    names = Tuple(keys(components))

    state_names = Tuple(k for k ∈ names if k ∉ controls)

    return NamedTrajectory{R}(
        data,
        datavec,
        T,
        timestep,
        dim,
        dims,
        bounds,
        initial,
        final,
        goal,
        components,
        names,
        state_names,
        controls
    )
end

function NamedTrajectory(
    datavec::AbstractVector{R},
    Z::NamedTrajectory
) where R <: Real
    @assert length(datavec) == length(Z.datavec)

    # collecting here to prevent overlapping views
    # TODO: is this necessary?
    datavec = collect(datavec)

    data = reshape(view(datavec, :), :, Z.T)

    return NamedTrajectory{R}(
        data,
        datavec,
        Z.T,
        Z.timestep,
        Z.dim,
        Z.dims,
        Z.bounds,
        Z.initial,
        Z.final,
        Z.goal,
        Z.components,
        Z.names,
        Z.state_names,
        Z.control_names
    )
end

function NamedTrajectory(
    data::AbstractMatrix{R},
    traj::NamedTrajectory
) where R <: Real
    @assert size(data) == size(traj.data)

    # collecting here to prevent overlapping views
    # TODO: is this necessary?
    datavec = vec(collect(data))

    data = reshape(view(datavec, :), :, traj.T)

    return NamedTrajectory{R}(
        data,
        datavec,
        traj.T,
        traj.timestep,
        traj.dim,
        traj.dims,
        traj.bounds,
        traj.initial,
        traj.final,
        traj.goal,
        traj.components,
        traj.names,
        traj.state_names,
        traj.control_names
    )
end

function NamedTrajectory(
    data::AbstractMatrix{R},
    components::NamedTuple{
        names,
        <:Tuple{Vararg{AbstractVector{Int}}}
    } where names;
    kwargs...
) where R <: Real
    T = size(data, 2)
    datavec = vec(data)
    return NamedTrajectory(datavec, T, components; kwargs...)
end

function NamedTrajectory(
    comps::NamedTuple{
        names,
        <:Tuple{Vararg{AbstractMatrix{R}}}
    } where names,
    traj::NamedTrajectory;
) where R <: Real
    @assert all([k ∈ traj.names for k ∈ keys(comps)])

    controls = Tuple([name for name ∈ traj.control_names if name ∈ keys(comps)])
    @assert !isempty(controls) "must specify at least one control"

    bounds = NamedTuple([(k => traj.bounds[k]) for k ∈ keys(comps) if k ∈ keys(traj.bounds)])
    initial = NamedTuple([(k => traj.initial[k]) for k ∈ keys(comps) if k ∈ keys(traj.initial)])
    final = NamedTuple([(k => traj.final[k]) for k ∈ keys(comps) if k ∈ keys(traj.final)])
    goal = NamedTuple([(k => traj.goal[k]) for k ∈ keys(comps) if k ∈ keys(traj.goal)])

    return NamedTrajectory(
        comps;
        controls=controls,
        timestep=traj.timestep,
        bounds=bounds,
        initial=initial,
        final=final,
        goal=goal,
    )

end


end
