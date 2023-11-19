# NamedTrajectories.jl

*An elegant way to handle messy trajectory data*

!!! info "Notice"
    This package is under active development and issues may arise -- please be patient and report any issues you find!  

## Motivation

[NamedTrajectories.jl](https://github.com/aarontrowbridge/NamedTrajectories.jl) is designed to aid in the messy indexing involved in solving trajectory optimization problems of the form

```math
\begin{align*}
\underset{u^1_{1:T}, \dots, u^{n_c}_{1:T}}{\underset{x^1_{1:T}, \cdots, x^{n_s}_{1:T}}{\operatorname{minimize}}} &\quad J\qty(x^{1:n_s}_{1:T},u^{1:n_c}_{1:T}) \\
\text{subject to} & \quad f\qty(x^{1:n_s}_{1:T},u^{1:n_c}_{1:T}) = 0 \\
& \quad x^i_1 = x^i_{\text{initial}} \\
& \quad x^i_T = x^i_{\text{final}} \\
& \quad u^i_1 = u^i_{\text{initial}} \\
& \quad u^i_T = u^i_{\text{final}} \\
& \quad x^i_{\min} < x^i_t < x^i_{\max} \\
& \quad u^i_{\min} < u^i_t < u^i_{\max} \\
\end{align*}
```

Where $x^i_t$ is the $i$th state variable and $u^i_t$ is the $i$th control variable at timestep $t$; state and control variables can be of arbitrary dimension. The function $f$ is a nonlinear constraint function and $J$ is the objective function. These problems can have an arbitrary number of state ($n_s$) and control ($n_c$) variables, and the number of timesteps $T$ can vary as well.  

In trajectory optimization problems it is common practice to bundle all of the state and control variables together into a single *knot point*

```math
z_t = \mqty(
    x^1_t \\
    \vdots \\
    x^{n_s}_t \\
    u^1_t \\
    \vdots \\
    u^{n_c}_t
).
```

The trajectory optimization problem can then be succinctly written as

```math
\begin{align*}
\underset{z_{1:T}}{\operatorname{minimize}} &\quad J\qty(z_{1:T}) \\
\text{subject to} & \quad f\qty(z_{1:T}) = 0 \\
& \quad z_1 = z_{\text{initial}} \\
& \quad z_T = z_{\text{final}} \\
& \quad z_{\min} < z_t < z_{\max} \\
\end{align*}
```

The `NamedTrajectories` package provides a `NamedTrajectory` type which abstracts away the messy indexing and vectorization details required for interfacing with numerical solvers.  It also provides a variety of helpful methods for common tasks.  For example, you can access the data by name or index.  In the case of an index, a `KnotPoint` is returned which contains the data for that timestep.


## Features

- Abstract away messy indexing and vectorization details required for interfacing with numerical solvers.
- Easily handle multiple trajectories with different names, e.g. various states and controls.
- Simple plotting of trajectories.
- Provide a variety of helpful methods for common tasks.


## Index

```@index
Modules = [
    NamedTrajectories.MethodsNamedTrajectory, 
    NamedTrajectories.MethodsKnotPoint,
    Base
]
```

