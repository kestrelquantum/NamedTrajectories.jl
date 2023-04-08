"""
test: methods.jl
"""


@testset "testing methods" begin

    T = 5

    data = (
        x = rand(3, T),
        u = rand(2, T)
    )

    traj = NamedTrajectory(data; timestep=0.1, controls=:u)

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
    @test name ∈ traj.controls_names


    # testing adding control vector component

    name = :b
    data = rand(T)
    type = :control

    add_component!(traj, name, data; type=type)

    @test vec(traj.b) ≈ vec(data)
    @test name ∈ traj.names
    @test name ∈ traj.controls_names
end
