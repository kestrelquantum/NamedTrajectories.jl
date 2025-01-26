```@meta
EditURL = "../../../literate/man/params_in_struct.jl"
```

# Add params in NamedTrajectory

NamedTrajectory.jl support passing parameters as a Tuple when construct a `NamedTrajectory`.

````@example params_in_struct
using NamedTrajectories
````

First we need to define number of timesteps and timestep

````@example params_in_struct
T = 10
dt = 0.1
````

then build named tuple of components and data matrices.

````@example params_in_struct
components = (
    x = rand(3, T),
    u = rand(2, T),
    Δt = fill(dt, 1, T),
)
````

we must specify a timestep and control variable for the trajectory.

````@example params_in_struct
timestep = 0.1
control = :u
````

some global params as a NamedTuple

````@example params_in_struct
params = (
    α = rand(1),
    β = rand(1)
)
````

we can now create a `NamedTrajectory` object with parameters specification.

````@example params_in_struct
traj = NamedTrajectory(components; timestep=timestep, controls=control, global_data=params)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

