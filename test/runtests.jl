using NamedTrajectories
using Test
using TestItems
using TestItemRunner

# Run all testitem tests in package
@run_package_tests

@testset "NamedTrajectories.jl" begin
    include("test_methods.jl")
    include("test_random.jl")
    include("test_plotting.jl")
end
