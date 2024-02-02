@testset "random trajectories" begin
    @test rand(NamedTrajectory, 5) isa NamedTrajectory
    @test rand(NamedTrajectory, 5; timestep=0.1).timestep == 0.1
    @test rand(NamedTrajectory, 5; timestep=:dt).timestep == :dt
    @test rand(NamedTrajectory, 5; free_time=true).timestep isa Symbol
end
