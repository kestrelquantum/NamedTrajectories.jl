module StructKnotPoint

export KnotPoint

using ..StructNamedTrajectory

struct KnotPoint
    t::Int
    data::AbstractVector{Float64}
    components::NamedTuple{
        cnames, <:Tuple{Vararg{AbstractVector{Int}}}
    } where cnames
    names::Tuple{Vararg{Symbol}}
    control_names::Tuple{Vararg{Symbol}}
end

function KnotPoint(
    Z::NamedTrajectory,
    t::Int
)
    @assert 1 ≤ t ≤ Z.T
    data = view(Z.data, :, t)
    return KnotPoint(t, data, Z.components, Z.names, Z.control_names)
end

end
