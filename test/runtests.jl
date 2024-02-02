using NamedTrajectories
using Test

@testset "NamedTrajectories.jl" begin
    include("test_methods.jl")
    include("test_random.jl")
    include("test_plotting.jl")
end
