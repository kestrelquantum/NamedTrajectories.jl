"""
test: struct_named_trajectory.jl
"""

@testset "testing constructor" begin
    # define number of timesteps and timestep
    T = 10
    dt = 0.1

    components = (
    x = rand(3, T),
    u = rand(2, T),
    Δt = fill(dt, 1, T),
    )

    timestep = 0.1
    control = :u

    # some global params as a NamedTuple
    params = (
        α = rand(1),
        β = rand(1)
    )

    traj = NamedTrajectory(components; timestep=timestep, controls=control, params=params)

    @test traj.params == params
end