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

    # case: fixed time

    add_component!(fixed_time_traj, name, data; type=type)
    @test fixed_time_traj.z ≈ data
    @test name ∈ fixed_time_traj.names

    # case: free time

    add_component!(free_time_traj, name, data; type=type)
    @test free_time_traj.z ≈ data
    @test name ∈ free_time_traj.names

    # testing adding state vector component

    name = :y
    data = rand(T)
    type = :state

    # case: fixed time

    add_component!(fixed_time_traj, name, data; type=type)
    @test vec(fixed_time_traj.y) ≈ vec(data)
    @test name ∈ fixed_time_traj.names


    # case: free time

    add_component!(free_time_traj, name, data; type=type)
    @test vec(free_time_traj.y) ≈ vec(data)
    @test name ∈ free_time_traj.names

    # testing adding control matrix component

    name = :a
    data = rand(2, T)
    type = :control

    # case: fixed time

    add_component!(fixed_time_traj, name, data; type=type)
    @test fixed_time_traj.a ≈ data
    @test name ∈ fixed_time_traj.names
    @test name ∈ fixed_time_traj.control_names


    # case: free time

    add_component!(free_time_traj, name, data; type=type)
    @test free_time_traj.a ≈ data
    @test name ∈ free_time_traj.names
    @test name ∈ free_time_traj.control_names


    # testing adding control vector component

    name = :b
    data = rand(T)
    type = :control

    # case: fixed time

    add_component!(fixed_time_traj, name, data; type=type)
    @test vec(fixed_time_traj.b) ≈ vec(data)
    @test name ∈ fixed_time_traj.names
    @test name ∈ fixed_time_traj.control_names

    # case: free time

    add_component!(free_time_traj, name, data; type=type)
    @test vec(free_time_traj.b) ≈ vec(data)
    @test name ∈ free_time_traj.names
    @test name ∈ free_time_traj.control_names

    # testing removing control component

    name = :a

    # case: fixed time

    fixed_time_traj = remove_component(fixed_time_traj, name)
    @test name ∉ fixed_time_traj.names
    @test name ∉ fixed_time_traj.control_names

    # case: free time

    free_time_traj = remove_component(free_time_traj, name)
    @test name ∉ free_time_traj.names
    @test name ∉ free_time_traj.control_names

    # testing removing state components

    names = [:z, :y]

    # case: fixed time

    fixed_time_traj = remove_components(fixed_time_traj, names)
    @test all(name ∉ fixed_time_traj.names for name in names)

    # case: free time

    free_time_traj = remove_components(free_time_traj, names)
    @test all(name ∉ free_time_traj.names for name in names)

    # testing updating traj data

    name = :x
    data = rand(3, T)

    # case: fixed time

    update!(fixed_time_traj, name, data)
    @test fixed_time_traj.x == data

    # case: free time

    update!(free_time_traj, name, data)
    @test free_time_traj.x == data

    # testing returning times

    # case: free time

    @test times(free_time_traj) ≈ [0.0, cumsum(vec(free_time_traj.Δt))[1:end-1]...]

    # case: fixed time

    @test times(fixed_time_traj) ≈ 0.1 .* [0:T-1...]


    # test get size

    @test size(fixed_time_traj) == (dim = sum(fixed_time_traj.dims[fixed_time_traj.names]), T = T)
    @test size(free_time_traj) == (dim = sum(free_time_traj.dims[free_time_traj.names]), T = T)


    # ---------------------------------------------------------
    # knot point methods
    # ---------------------------------------------------------


    # test getindex
    # ---------------------------------------------------------
    # freetime
    @test free_time_traj[1] isa KnotPoint
    @test free_time_traj[1].x == free_time_traj.x[:, 1]
    @test free_time_traj[end] isa KnotPoint
    @test free_time_traj[end].x == free_time_traj.x[:, end]
    @test free_time_traj[:x] == free_time_traj.x
    @test free_time_traj.timestep isa Symbol

    # fixed time
    @test fixed_time_traj[1] isa KnotPoint
    @test fixed_time_traj[1].x == fixed_time_traj.x[:, 1]
    @test fixed_time_traj[end] isa KnotPoint
    @test fixed_time_traj[end].x == fixed_time_traj.x[:, end]
    @test fixed_time_traj[:x] == fixed_time_traj.x
    @test fixed_time_traj.timestep isa Float64



    # ---------------------------------------------------------
    # algebraic methods
    # ---------------------------------------------------------

    free_time_traj2 = copy(free_time_traj)
    fixed_time_traj2 = copy(fixed_time_traj)

    @test (free_time_traj + free_time_traj2).x == free_time_traj.x + free_time_traj2.x
    @test (fixed_time_traj + fixed_time_traj2).x == fixed_time_traj.x + fixed_time_traj2.x

    @test (free_time_traj - free_time_traj2).x == free_time_traj.x - free_time_traj2.x
    @test (fixed_time_traj - fixed_time_traj2).x == fixed_time_traj.x - fixed_time_traj2.x

    @test (2.0 * free_time_traj).x == (free_time_traj * 2.0).x == free_time_traj.x * 2.0
    @test (2.0 * fixed_time_traj).x == (fixed_time_traj * 2.0).x == fixed_time_traj.x * 2.0



end
