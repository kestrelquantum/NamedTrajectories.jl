@testset "testing plotting" begin

    plot_path = joinpath(@__DIR__, "test.pdf")

    traj = rand(NamedTrajectory, 5)

    plot(plot_path, traj)

    @test isfile(plot_path)

    rm(plot_path)

end
