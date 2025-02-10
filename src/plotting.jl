module Plotting

export plot

using OrderedCollections
using NamedTrajectories

"""
    plot(traj::NamedTrajectory, comps=traj.names; kwargs...)

Plot a `NamedTrajectory` using `CairoMakie`.

# Arguments
- `traj::NamedTrajectory`: the trajectory to plot
- `comps::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}}`: the components of the trajectory to plot, e.g., `:x`, `[:x, :u]`, or `(:x, :u)`.

# Keyword Arguments

## component specification
- `ignored_labels::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}}`: the components of the trajectory to ignore. The default is `()`.
- `ignore_timestep::Bool`: whether or not to ignore the timestep component of the trajectory. The default is `true`.

## transformations
- `transformations::OrderedDict{Symbol, <:Union{Function, Vector}}`: a dictionary of transformations to apply to the components of the trajectory. The keys of the dictionary are the components of the trajectory to transform, and the values are either a single function or a vector of functions to apply to each column of the component. If a single function is provided, it is applied to each column of the component. If a vector of functions is provided, a separate plot is created for each function. The default is an empty `OrderedDict`.
- `transformation_labels::Union{Nothing, OrderedDict{Symbol, <:Union{Nothing, <:AbstractString, Vector{<:Union{Nothing, <:AbstractString}}}}}`: a dictionary of labels for the transformed components of the trajectory. The keys of the dictionary are the components of the trajectory to transform, and the values are either a single string or a vector of strings that correspond to a vector of transformations. If a single string is provided, it is applied to each transformation of the component. If a vector of strings is provided, a separate label is created for each function. The default is `nothing`.
- `include_transformation_labels::Union{Bool, Vector{<:Union{Bool, Vector{Bool}}}}`: a boolean, vector of booleans, or vector of vectors of booleans, that determines whether or not to include the labels for the transformed components of the trajectory. The default is `false`.
- `transformation_titles::Union{Nothing, OrderedDict{Symbol, <:Union{<:AbstractString, Vector{String}}}}`: a dictionary of titles for the transformed components of the trajectory. The keys of the dictionary are the components of the trajectory to transform, and the values are either a single string or a vector of strings that correspond to a vector of transformations. If a single string is provided, it is applied to each transformation of the component. If a vector of strings is provided, a separate title is created for each function. The default is `nothing`.

## style
- `fig_size::Tuple{Int, Int}`: the size of the figure, `(width, height)`. The default is `(1200, 800)`.
- `titlesize::Int`: the size of the titles. The default is `25`.
- `series_color::Symbol`: the color of the series. The default is `:glasbey_bw_minc_20_n256`. See options [here](https://docs.makie.org/stable/explanations/colors/index.html#colormaps)
- `markersize`: the size of the markers. The default is `5`.

## other
- `kwargs...`: keyword arguments passed to [`CairoMakie.series!`](https://docs.makie.org/stable/reference/plots/series/).
"""
function plot end

# =========================================================================== #

# @testitem "save plotting" begin
#     plot_path = joinpath(@__DIR__, "test.pdf")

#     traj = rand(NamedTrajectory, 5)

#     plot(plot_path, traj)

#     @test isfile(plot_path)

#     rm(plot_path)
# end

# @testitem "xlim and ylim" begin
#     using CairoMakie 
#     include("../test/test_utils.jl")
    
#     # has x and y
#     traj = get_fixed_time_traj2()
#     @test plot(traj, xlims=(0, 5)) isa Figure
#     @test plot(traj, ylims=(x=(0, 5))) isa Figure
#     @test plot(traj, ylims=(x=(0, 5), y=(0, 5))) isa Figure
#     @test plot(traj, ylims=(0, 5)) isa Figure
# end

# @testitem "LaTeX strings" begin
#     using CairoMakie 
    
#     # weird names
#     traj = NamedTrajectory((α_β_2=rand(2, 5), y_1_2=rand(1,5)), controls=:y_1_2, timestep=1.0)
#     @test plot(traj, use_latex=false) isa Figure
# end

end
