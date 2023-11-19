module Plotting

export plot

import CairoMakie: plot

using CairoMakie
using LaTeXStrings
using OrderedCollections

using ..StructNamedTrajectory
using ..StructKnotPoint
using ..MethodsNamedTrajectory
using ..MethodsKnotPoint

import ..StructNamedTrajectory: NamedTrajectory

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
- `res::Tuple{Int, Int}`: the resolution of the figure, `(width, height)`. The default is `(1200, 800)`.
- `titlesize::Int`: the size of the titles. The default is `25`.
- `series_color::Symbol`: the color of the series. The default is `:glasbey_bw_minc_20_n256`. See options [here](https://docs.makie.org/stable/explanations/colors/index.html#colormaps)
- `markersize`: the size of the markers. The default is `5`.

## other
- `kwargs...`: keyword arguments passed to [`CairoMakie.series!`](https://docs.makie.org/stable/reference/plots/series/).
"""
function plot(
    traj::NamedTrajectory,
    comps::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}} = traj.names;

    # ---------------------------------------------------------------------------
    # component specification keyword arguments
    # ---------------------------------------------------------------------------

    ignored_labels::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}}=(),
    ignore_timestep::Bool=true,

    # ---------------------------------------------------------------------------
    # transformation keyword arguments
    # ---------------------------------------------------------------------------

    # transformations
    transformations::OrderedDict{Symbol, <:Union{Function, Vector}} =
        OrderedDict{Symbol, Union{Function, Vector{Function}}}(),

    # labels for transformed components
    transformation_labels::Union{
        Nothing,
        OrderedDict{
            Symbol,
            <:Union{
                Nothing,
                String,
                Vector{<:Union{Nothing, <:AbstractString}}
            }
        }
    } = nothing,

    # whether or not to include labels for transformed components
    include_transformation_labels::Union{
        Bool,
        Vector{<:Union{Bool, Vector{Bool}}}
    } = false,

    # titles for transformations
    transformation_titles::Union{
        Nothing,
        OrderedDict{Symbol, <:Union{<:AbstractString, Vector{<:AbstractString}}}
    } = nothing,

    # ---------------------------------------------------------------------------
    # style keyword arguments
    # ---------------------------------------------------------------------------

    res::Tuple{Int, Int}=(1200, 800),
    titlesize::Int=25,
    markersize=5,
    series_color::Symbol=:glasbey_bw_minc_20_n256,

    # ---------------------------------------------------------------------------
    # CairoMakie.series! keyword arguments
    # ---------------------------------------------------------------------------
    kwargs...
)
    # convert single symbol to vector: comps
    if comps isa Symbol
        comps = [comps]
    end

    # if transformations is only a bool, convert to vector of bools
    if include_transformation_labels isa Bool
        include_transformation_labels = fill(
            include_transformation_labels,
            length(transformations)
        )
    end

    @assert length(include_transformation_labels) == length(transformations)

    include_transformation_labels = Any[include_transformation_labels...]

    for (i, (b, f)) ∈ enumerate(zip(
        include_transformation_labels,
        values(transformations)
    ))
        if f isa Function
            @assert b isa Bool
        else
            if b isa Bool
                include_transformation_labels[i] = fill(b, length(f))
            else
                @assert length(b) == length(f)
            end
        end
    end

    # convert single symbol to iterable: ignored labels
    if ignored_labels isa Symbol
        ignored_labels = Symbol[ignored_labels]
    elseif ignored_labels isa Tuple
        ignored_labels = Symbol[ignored_labels...]
    end

    @assert all([key ∈ keys(traj.components) for key ∈ comps])
    @assert all([key ∈ keys(traj.components) for key ∈ keys(transformations)])

    ts = times(traj)

    # create figure
    fig = Figure(resolution=res)

    # initialize axis count
    ax_count = 0

    # plot transformed components
    for ((key, f), include_transformation_labels_k) ∈ zip(
        transformations,
        include_transformation_labels
    )
        if f isa Vector

            @assert all([fⱼ isa Function for fⱼ in f])

            for (j, fⱼ) in enumerate(f)

                # data matrix for key component of trajectory
                data = traj[key]

                # apply transformation fⱼ to each column of data
                transformed_data = mapslices(fⱼ, data; dims=1)

                # create axis for transformed data
                ax = Axis(
                    fig[ax_count + 1, 1];

                    title= isnothing(transformation_titles) ? latexstring(key, "(t)", "\\text{ transformation } $j") : transformation_titles[key][j],
                    titlesize=titlesize,
                    xlabel=L"t"
                )

                # plot transformed data
                if include_transformation_labels_k[j]

                    if isnothing(transformation_labels[key][j])
                        labels = [
                            latexstring(key, "_{$i}")
                                for i = 1:size(transformed_data, 2)
                        ]
                    else
                        labels = [
                            latexstring(transformation_labels[key][j], "_{$i}")
                                for i = 1:size(transformed_data, 2)
                        ]
                    end

                    series!(
                        ax,
                        ts,
                        transformed_data;
                        color=series_color,
                        markersize=markersize,
                        labels=labels
                    )
                    # create legend
                    Legend(fig[ax_count + 1, 2], ax)
                else
                    series!(
                        ax,
                        ts,
                        transformed_data;
                        color=series_color,
                        markersize=markersize
                    )
                end

                # increment axis count
                ax_count += 1
            end
        else

            # data matrix for key componenent of trajectory
            data = traj[key]

            # apply transformation f to each column of data
            transformed_data = mapslices(f, data; dims=1)

            if isnothing(transformation_titles)
                title = latexstring(key, "(t)", "\\text{ transformation}")
            else
                if isnothing(transformation_titles[key])
                    title = latexstring(key, "(t)", "\\text{ transformation}")
                else
                    title = transformation_titles[key]
                end
            end

            # create axis for transformed data
            ax = Axis(
                fig[ax_count + 1, :];
                title = isnothing(transformation_titles)
                ? latexstring(key, "(t)", "\\text{ transformation}") : transformation_titles[key],
                titlesize=titlesize,
                xlabel=L"t"
            )

            # plot transformed data
            if include_transformation_labels_k

                if isnothing(transformation_labels[key])
                    labels = [
                        latexstring(key, "_{$i}")
                            for i = 1:size(transformed_data, 2)
                    ]
                else
                    labels = [
                        latexstring(transformation_labels[key], "_{$i}")
                            for i = 1:size(transformed_data, 2)
                    ]
                end

                series!(
                    ax,
                    ts,
                    transformed_data;
                    color=series_color,
                    markersize=markersize,
                    labels=labels
                )
                # create legend
                Legend(fig[ax_count + 1, 2], ax)
            else
                series!(
                    ax,
                    ts,
                    transformed_data;
                    color=series_color,
                    markersize=markersize,
                    kwargs...
                )
            end

            # increment axis count
            ax_count += 1
        end
    end

    # plot normal components
    for key in comps

        if traj.timestep isa Symbol && key == traj.timestep && ignore_timestep
            continue
        end

        # data matrix for key componenent of trajectory
        data = traj[key]

        # create axis for data
        ax = Axis(
            fig[ax_count + 1, 1];
            title=latexstring(key, "(t)"),
            titlesize=titlesize,
            xlabel=L"t"
        )

        # create labels if key is not in ignored_labels
        if key ∈ ignored_labels
            labels = nothing
        else
            labels = [latexstring(key, "_{$i}") for i = 1:size(data, 1)]
        end

        # plot data
        series!(
            ax,
            ts,
            data;
            color=series_color,
            markersize=markersize,
            labels=labels,
            kwargs...
        )

        # create legend
        if key ∉ ignored_labels
            Legend(fig[ax_count + 1, 2], ax)
        end

        # increment axis count
        ax_count += 1
    end

    return fig
end

function plot(path::String, traj::NamedTrajectory, comps=traj.names; kwargs...)
    if !isdir(dirname(path))
        mkdir(dirname(path))
    end
    save(path, plot(traj, comps; kwargs...))
end

end
