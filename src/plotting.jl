module Plotting

export plot

using CairoMakie
using LaTeXStrings

import CairoMakie: plot

using ..StructNamedTrajectory
using ..StructKnotPoint
using ..MethodsNamedTrajectory
using ..MethodsKnotPoint

function plot(
    traj::NamedTrajectory,
    comps::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}} = traj.names;

    # data keyword arguments
    transformations::Dict{Symbol, <:Union{Function, Vector{Function}}} =
        Dict{Symbol, Union{Function, Vector{Function}}}(),

    # style keyword arguments
    res::Tuple{Int, Int}=(1200, 800),
    titlesize::Int=25,
    series_color::Symbol=:glasbey_bw_minc_20_n256,
    ignored_labels::Union{Symbol, Vector{Symbol}, Tuple{Vararg{Symbol}}}=(),
    ignore_timestep::Bool=true
)
    # convert single symbol to vector: comps
    if comps isa Symbol
        comps = [comps]
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
    for (key, f) in transformations
        if f isa Vector
            for (j, fⱼ) in enumerate(f)

                # data matrix for key componenent of trajectory
                data = traj[key]

                # apply transformation fⱼ to each column of data
                transformed_data = mapslices(fⱼ, data; dims=1)

                # create axis for transformed data
                ax = Axis(
                    fig[ax_count + 1, 1];
                    title=latexstring(key, "(t)", "\\text{ transformation } $j"),
                    titlesize=titlesize,
                    xlabel=L"t"
                )

                # plot transformed data
                series!(
                    ax,
                    ts,
                    transformed_data;
                    color=series_color,
                    markersize=5,
                    labels=[latexstring(key, "_{$i}") for i = 1:size(transformed_data, 2)]
                )

                # create legend
                Legend(fig[ax_count + 1, 2], ax)

                # increment axis count
                ax_count += 1
            end
        else

            # data matrix for key componenent of trajectory
            data = traj[key]

            # apply transformation f to each column of data
            transformed_data = mapslices(f, data; dims=1)

            # create axis for transformed data
            ax = Axis(
                fig[ax_count + 1, :];
                title=latexstring(key, "(t)", "\\text{ transformation }"),
                titlesize=titlesize,
                xlabel=L"t"
            )

            # plot transformed data
            series!(
                ax,
                ts,
                transformed_data;
                color=series_color,
                markersize=5
            )

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
            markersize=5,
            labels=labels
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

function plot(path::String, traj::NamedTrajectory, args...; kwargs...)
    if !isdir(dirname(path))
        mkdir(dirname(path))
    end
    save(path, plot(traj, args...; kwargs...))
end

end
