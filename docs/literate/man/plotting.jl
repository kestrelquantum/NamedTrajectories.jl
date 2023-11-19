# # Plotting

# Visualizing trajectories is crucial for understanding the solutions of trajectory optmization problems and `NamedTrajectories` exports a `plot` function that contains a lot of functionality that is continually being added to. [Makie.jl](https://docs.makie.org/stable/) is used as the plotting framework, and at the moment the default backend is `CairoMakie`, as it creates high quality vector graphics. The function is called as follows:

#=
```@docs
NamedTrajectories.plot(
    ::NamedTrajectory,
    ::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}} = traj.names;
    kwargs...
)
```
=#

# ## Basic example

# Let's first create a simple trajectory to plot

using NamedTrajectories

## define the number timestamps
T = 100
Δt = 0.1
ts = [0:T-1...] * Δt

## define sinusoidal state trajectories
X = zeros(3, T)
X[1, :] = sin.(3 * 2π * ts / (2 * (T - 1) * Δt))
X[2, :] = -sin.(5 * 2π * ts / (2 * (T - 1) * Δt))
X[3, :] = sin.(9 * 2π * ts / (2 * (T - 1) * Δt))

## define gaussian shaped controls
U = stack(
    [
        exp.(-((ts .- ts[length(ts)÷3]) / 2.0).^2) .* sin.(5.0 * ts),
        exp.(-((ts .- ts[2(length(ts)÷3)]) / 1.5).^2) .* sin.(4.0 * ts)
    ];
    dims=1
)
V = exp.(-((ts .- ts[length(ts)÷2]) ./ 1.5).^2) .* sin.(6.0 * ts)

## create the trajectory
traj = NamedTrajectory(
    (
        x=X,
        u=U,
        v=V
    );
    timestep=Δt,
    controls=(:u, :v)
)

## plot the trajectory
plot(traj)

# ## Selectively plotting components

# We can selectively plot components of the trajectory by passing a `Vector` of `Symbol`s to the `components` keyword argument. For example, if we only wanted to plot the state and the first control we could do the following:

plot(traj, [:x, :u])

# ## Playing with transformations

# We can also apply transformations to the components of the trajectory. Transformations are performed on columns of the data.

# For example, if we wanted to plot absolute values of the states we could do the following:

transformations = OrderedDict(
    :x => x -> abs.(x),
)

plot(traj, [:x]; transformations=transformations)

# We can also pass multiple transformations to the same component, with selective labels and titles:

## define the transformations
transformations = OrderedDict(
    :x => [
        x -> [x[1] + x[2], x[3] - x[2]],
        x -> [x[1] - x[2], x[3] + x[2]]
    ],
)

## define the labels
transformation_labels = OrderedDict(
    :x => [
        "\\tilde{x}",
        "\\hat{x}"
    ],
)

## define the titles
transformation_titles = OrderedDict(
    :x => [
        L"x_1 + x_2, x_3 - x_2",
        L"x_1 - x_2, x_3 + x_2"
    ],
)

## plot the trajectory, with only the transformation and the `u` control
plot(traj, [:u];
    transformations=transformations,
    transformation_labels=transformation_labels,
    include_transformation_labels=[[true, true]],
    transformation_titles=transformation_titles,
)
