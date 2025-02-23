module PlottingExt

using NamedTrajectories
import NamedTrajectories: namedplot, namedplot!, trajectoryplot

# Ideally, we'd only need MakieCore for recipes
# But, we need Series, Axis, Figure etc. 
# And it's recommended to use Makie for ext
using Makie
import Makie: convert_arguments

# -------------------------------------------------------------- #
# Plot trajectories by name using Series or Plot
# -------------------------------------------------------------- #

function convert_arguments(
    P::Type{<:Series}, 
    traj::NamedTrajectory,
    name::Symbol;
    transform::Union{Function, Nothing}=nothing
)
    if !isnothing(transform)
        transform_data = try
            stack(transform.(eachcol(traj[name])))
        catch
            throw(ArgumentError("Transformation of $(name) failed."))
        end
    else
        transform_data = traj[name]
    end

    return convert_arguments(P, get_times(traj), transform_data)
end

# Allow transform to be passed to the plotting function
Makie.used_attributes(::Type{<:Series}, ::NamedTrajectory, ::Symbol) = (:transform,)

# Allow plot to be called on NamedTrajectory
Makie.plottype(::NamedTrajectory, ::Symbol) = Series

# -------------------------------------------------------------- #
# Plot trajectories by name with recipe
# -------------------------------------------------------------- #

@recipe(NamedPlot, traj, input_name, output_name, transform) do scene
    # Add any desired series attributes here
    Attributes(
        color=:seaborn_colorblind,
        linestyle=theme(scene, :linestyle),
        linewidth=theme(scene, :linewidth),
        marker=:circle,
        markersize=theme(scene, :markersize),
        # Merge: If true, all components are plotted with the same label
        merge=false,
    )
end

# Add the ability to recall plot labels for a legend (extract series subplots)
Makie.get_plots(P::NamedPlot) = Makie.get_plots(P.plots[1])

# Plot existing component
function Makie.plot!(
    P::NamedPlot{<:Tuple{<:NamedTrajectory, Symbol}};
    kwargs...
)
    lift(P[:traj], P[:input_name]) do traj, name

        if P[:merge][]
            labels = fill("$name", length(traj.components[name]))
        else
            labels = ["$(name) $(i)" for i in eachindex(traj.components[name])]
        end

        plot!(
            P, traj, name;
            labels=labels,
            color = P[:color],
            linestyle = P[:linestyle],
            linewidth = P[:linewidth],
            marker = P[:marker],
            markersize = P[:markersize],
        )
        
    end
    return P
end

# Plot transformed component
function Makie.plot!(
    P::NamedPlot{<:Tuple{
        <:NamedTrajectory, 
        Symbol, 
        Union{Nothing, Symbol, String}, 
        Function
    }};
    kwargs...
)
    lift(P[:traj], P[:input_name], P[:output_name], P[:transform]) do traj, input, output, transform

        if isnothing(output)
            output = "T($input)"
        end

        if P[:merge][]
            labels = fill("$output", length(traj.components[input]))
        else
            labels = ["$(output) $(i)" for i in eachindex(traj.components[input])]
        end

        plot!(
            P, traj, input;
            transform=transform,
            labels=labels,
            color = P[:color],
            linestyle = P[:linestyle],
            linewidth = P[:linewidth],
            marker = P[:marker],
            markersize = P[:markersize],
        )
        
    end
    return P
end

# -------------------------------------------------------------- #
# Plot trajectories as figure
# -------------------------------------------------------------- #

function trajectoryplot(
    traj::NamedTrajectory,
    names::Union{AbstractVector{Symbol}, Tuple{Vararg{Symbol}}}=traj.names;

    # ---------------------------------------------------------------------------
    # component specification keyword arguments
    # ---------------------------------------------------------------------------

    # whether or not to plot the timestep componenent
    ignore_timestep::Bool=true,
    
    # whether or not to include unique labels for components
    merge_labels::Union{Bool, AbstractVector{Bool}} = false,

    # ---------------------------------------------------------------------------
    # transformation keyword arguments
    # ---------------------------------------------------------------------------

    # transformations
    transformations::NamedTuple{<:Any, <:Tuple{Vararg{<:Function}}} = (;),

    # labels for transformed components
    transformation_labels::AbstractVector{<:Union{Nothing, String}} = fill(nothing, length(transformations)),
    
    # whether or not to include unique labels for transformed components
    merge_transformation_labels::Union{Bool, AbstractVector{Bool}} = false,
    
    # ---------------------------------------------------------------------------
    # figure and axis keyword arguments
    # ---------------------------------------------------------------------------
    
    fig_size::Tuple{Int, Int} = (1200, 800),
    titlesize::Int=16,
    xlabelsize::Int=16,

    # ---------------------------------------------------------------------------
    # plot keyword arguments (for all names)
    # ---------------------------------------------------------------------------
    kwargs...
)

    # parse arguments
    if names isa Symbol
        names = [names]
    end

    if merge_labels isa Bool
        merge_labels = fill(merge_labels, length(names))
    end

    if merge_transformation_labels isa Bool
        merge_transformation_labels = fill(merge_transformation_labels, length(transformations))
    end

    @assert length(merge_transformation_labels) == length(transformation_labels) == length(transformations)

    # create figure
    fig = Figure(size=fig_size)

    # Default components
    # ------------------
    for (i, name) in enumerate(names)
        if traj.timestep isa Symbol && name == traj.timestep && ignore_timestep
            continue
        end

        ax = Axis(
            fig[i, 1],
            title = i == 1 ? "Named Trajectory" : "",
            titlealign = :left,
            titlesize = titlesize,
            xticklabelsvisible = i == length(names),
            xtickalign=1,
            xlabel = i == length(names) ? "time" : "",
            xlabelsize = xlabelsize,
        )
        merge = merge_labels[i]
        namedplot!(ax, traj, name, merge=merge; kwargs...)
        Legend(fig[i, 2], ax, merge=merge)
    end

    for i in 1:length(names) - 1
        rowgap!(fig.layout, i, 0.0)
    end


    # Transformations
    # ---------------
    offset = length(names)

    for (i, (input, transform)) in enumerate(pairs(transformations))
        ax = Axis(
            fig[offset + i, 1],
            title = i == 1 ? "Transformations" : "",
            titlealign = :left,
            titlesize = titlesize,
            xticklabelsvisible = i == length(transformations),
            xtickalign = 1,
            xlabel = i == length(transformations) ? "time" : "",
            xlabelsize = xlabelsize,
        )
        output = transformation_labels[i]
        merge = merge_transformation_labels[i]
        namedplot!(ax, traj, input, output, transform, merge=merge; kwargs...)
        Legend(fig[offset + i, 2], ax, merge=merge)
    end

    for i in 1:length(transformations)-1
        rowgap!(fig.layout, offset + i, 0.0)
    end

    fig
end

# TODO: We should have a default theme
function trajectoryplot(
    theme::Makie.Theme,
    args...;
    kwargs...
)
    with_theme(theme) do
        trajectoryplot(args...; kwargs...)
    end
end


end