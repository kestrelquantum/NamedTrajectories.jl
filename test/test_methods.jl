"""
test: methods_named_trajectories.jl
"""


@testset "testing methods" begin

    T = 5

    fixed_time_data = (
        x = rand(3, T),
        u = rand(2, T)
    )

    free_time_data = (
        x = rand(3, T),
        u = rand(2, T),
        Δt = rand(1, T)
    )

    fixed_time_traj = NamedTrajectory(fixed_time_data; timestep=0.1, controls=:u)
    free_time_traj = NamedTrajectory(free_time_data; timestep=:Δt, controls=:u)


    # testing copying and equality checks

    fixed_time_traj_copy = copy(fixed_time_traj)
    free_time_traj_copy = copy(free_time_traj)

    @test isequal(fixed_time_traj, fixed_time_traj_copy)
    @test fixed_time_traj == fixed_time_traj_copy

    # testing adding state matrix component

    name = :z
    data = rand(2, T)
    type = :state

    add_component!(traj, name, data; type=type)
    @test traj.z ≈ data
    @test name ∈ traj.names

    # testing adding state vector component

    name = :y
    data = rand(T)
    type = :state

    add_component!(traj, name, data; type=type)

    @test vec(traj.y) ≈ vec(data)
    @test name ∈ traj.names


    # testing adding control matrix component

    name = :a
    data = rand(2, T)
    type = :control

    add_component!(traj, name, data; type=type)

    @test traj.a ≈ data
    @test name ∈ traj.names
    @test name ∈ traj.control_names


    # testing adding control vector component

    name = :b
    data = rand(T)
    type = :control

    add_component!(traj, name, data; type=type)

    @test vec(traj.b) ≈ vec(data)
    @test name ∈ traj.names
    @test name ∈ traj.control_names
end
