module StructTimeSlice

export TimeSlice

using ..StructNamedTrajectory

struct TimeSlice
    t::Int
    data::AbstractVector{Float64}
    components::NamedTuple{
        cnames, <:Tuple{Vararg{AbstractVector{Int}}}
    } where cnames
    names::Tuple{Vararg{Symbol}}
    controls_names::Tuple{Vararg{Symbol}}
end

function TimeSlice(
    Z::NamedTrajectory,
    t::Int
)
    @assert 1 ≤ t ≤ Z.T
    data = view(Z.data, :, t)
    return TimeSlice(t, data, Z.components, Z.names, Z.controls_names)
end

end
