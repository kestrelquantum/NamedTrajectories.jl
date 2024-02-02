module RandomTrajectories

using ..StructNamedTrajectory

"""
    rand(
        ::Type{NamedTrajectory},
        T::Int;
        timestep_value::Float64=1.0,
        timestep_name::Symbol=:Δt,
        free_time::Bool=false,
        timestep::Union{Float64,Symbol}=free_time ? timestep_name : timestep_value,
        state_dim::Int=3,
        control_dim::Int=2
    )

Create a random `NamedTrajectory` with `T` time steps, a state variable `x` of dimension `state_dim`, and a control variable `u` of dimension `control_dim`. If `free_time` is `true`, the time step is a symbol `timestep_name` and the time step value is `timestep_value`. Otherwise, the time step is a number `timestep_value`.
"""
function Base.rand(
    ::Type{NamedTrajectory},
    T::Int;
    timestep_value::Float64=1.0,
    timestep_name::Symbol=:Δt,
    free_time::Bool=false,
    timestep::Union{Float64,Symbol}=free_time ? timestep_name : timestep_value,
    state_dim::Int=3,
    control_dim::Int=2
)
    data = (
        x = randn(state_dim, T),
        u = randn(control_dim, T)
    )

    if timestep isa Symbol
        data = merge(data, NamedTuple((timestep => fill(timestep_value, T),)))
    end

    return NamedTrajectory(data; timestep=timestep, controls=:u)
end


end
