using Random

function get_fixed_time_traj(;
    T::Int=5, Δt::Float64=0.1, x_dim::Int=3, a_dim::Int=2
)
    fixed_time_data = (x = rand(x_dim, T), u = rand(a_dim, T))
    return NamedTrajectory(fixed_time_data; timestep=Δt, controls=:u)
end

function get_free_time_traj(;
    T::Int=5, Δt::Symbol=:Δt, x_dim::Int=3, a_dim::Int=2
)
    free_time_data = (x = rand(x_dim, T), u = rand(a_dim, T), Δt = rand(1, T))
    return NamedTrajectory(free_time_data; timestep=Δt, controls=:u)
end

function get_fixed_time_traj2(;
    T::Int=5, Δt::Float64=0.1, x_dim::Int=3, y_dim=3, a_dim::Int=2
)
    fixed_time_data = (x = rand(x_dim, T), y_dim = rand(y_dim, T), u = rand(a_dim, T))
    return NamedTrajectory(fixed_time_data; timestep=Δt, controls=:u)
end
