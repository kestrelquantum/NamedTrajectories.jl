# # Quickstart Guide

# To begin let's load the package

using NamedTrajectories

# A trajectory is a collection of named vectors, each of which has the same length. Mathematically we have a collection of vectors

#=
```math
\qty{z_t = \mqty(x_t \\ u_t)}_{t=1:T}
```
=#

# where $x_t$ is the state and $u_t$ is the control at a time indexed by $t$. Together $z_t$ is referred to as a *knot point* and a `NamedTrajectory` essentially just stores a collection of knot points and makes it easy to access the state and control variables.


# ## Creating a fixed-timestep `NamedTrajectory`

# Here we will createa a `NamedTrajectory` with a fixed timestep. This is done by passing a scalar as the `timestep` kwarg.

## define the number of timesteps
T = 10

## define the knot point data as a NamedTuple of matrices
data = (
    x = rand(3, T),
    u = rand(2, T),
)

## we must specify a timestep and control variable for the trajectory
timestep = 0.1
control = :u

## we can now create a `NamedTrajectory` object
traj = NamedTrajectory(data; timestep=timestep, controls=control)

## we can return the names of the stored variables
traj.names

# Let's plot this trajectory

plot(traj)


# ## Creating a variable-timestep `NamedTrajectory`

# Here we will create a `NamedTrajectory` with a variable timestep. This is done by passing a `Symbol`, corresponding to component of the data, as the `timestep` kwarg.

## define the number of timesteps
T = 10

## define the knot point data as a NamedTuple of matrices
data = (
    x = rand(3, T),
    u = rand(2, T),
    Δt = rand(T),
)

## we must specify a timestep and control variable for the NamedTrajectory
timestep = :Δt
control = :u

## we can now create a `NamedTrajectory` object
traj = NamedTrajectory(data; timestep=timestep, controls=control)

## we can return the names of the stored variables
traj.names


# ## Adding more problem data

# In many settings we will want to add problem data to our `NamedTrajectory` -- e.g. bounds, initial values, final values, and goal values. This is realized by passing NamedTuples containing this data.

## define the number of timesteps
T = 10

## define the knot point data as a NamedTuple of matrices
data = (
    x = rand(3, T),
    u = rand(2, T),
    Δt = rand(T),
)

## define initial values
initial = (
    x = [1.0, 0.0, 0.0],
    u = [0.0, 0.0],
)

## define final value, here just on the control
final = (
    u = [0.0, 0.0],
)

## define bounds
bounds = (
    x = 1.0,
    u = 1.0
)

## set a goal for the state
goal = (
    x = [0.0, 0.0, 1.0],
)

## we must specify a timestep and control variable for the NamedTrajectory
timestep = :Δt
control = :u

## we can now create a `NamedTrajectory` object
traj = NamedTrajectory(
    data;
    timestep=timestep,
    controls=control,
    initial=initial,
    final=final,
    bounds=bounds,
    goal=goal
)

## we can then show the bounds
traj.goal
