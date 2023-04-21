module NamedTrajectories

using Reexport

include("struct_named_trajectory.jl")
@reexport using .StructNamedTrajectory

include("struct_knot_point.jl")
@reexport using .StructKnotPoint

include("methods_named_trajectory.jl")
@reexport using .MethodsNamedTrajectory

include("methods_knot_point.jl")
@reexport using .MethodsKnotPoint

include("utils.jl")
@reexport using .Utils

include("plotting.jl")
@reexport using .Plotting

end
