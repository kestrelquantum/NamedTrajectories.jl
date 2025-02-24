module Plotting

export namedplot
export namedplot!

"""
    namedplot(traj::NamedTrajectory, name::Symbol; kwargs...)

Plot a single component of a `NamedTrajectory` using Makie.

The default plot type is `Series`. Series attributes can be passed as keyword arguments.

"""
function namedplot end

function namedplot! end

end