module NamedTrajectories

using Reexport

include("types.jl")
@reexport using .Types

include("methods.jl")
@reexport using .Methods

include("utils.jl")
@reexport using .Utils

include("plotting.jl")
@reexport using .Plotting

end
