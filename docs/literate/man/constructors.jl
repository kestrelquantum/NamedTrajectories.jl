# # Constructors

# To construct a `NamedTrajectory` using NamedTrajectories.jl, we simply need to utilize the `NamedTrajectory` constructor.

using NamedTrajectories

## define number of timesteps and timestep
T = 10
dt = 0.1

# build named tuple of components and data matrices.

components = (
    x = rand(3, T),
    u = rand(2, T),
    Δt = fill(dt, 1, T),
)

# we must specify a timestep and control variable for the trajectory.

timestep = 0.1
control = :u

# we can now create a `NamedTrajectory` object.

traj = NamedTrajectory(components; timestep=timestep, controls=control)

# Construct `NamedTrajectory` from previous constructed one.

traj = NamedTrajectory(components, traj)