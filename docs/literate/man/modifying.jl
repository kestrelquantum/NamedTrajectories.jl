# ```@meta
# CollapsedDocStrings = true
# ```

#=

# Modifying trajectories

Modifying existing trajectories can be useful for a variety of reasons. Sometimes, you may 
want to change the values of the states, controls, or other components of the trajectory. 
Other times, you may want to add or remove components from the trajectory.

=#

using NamedTrajectories

# Create a random trajectory with 5 time steps, a state variable `x` of dimension 3, and a control variable `u` of dimension 2
traj = rand(NamedTrajectory, 5)
traj.names

# Add a new state variable `y` to the trajectory. Notice this is in-place.
y_data = rand(4, 5)
add_component!(traj, :y, y_data)
traj.names

# Remove the state variable `y` from the trajectory. This is not in place.
restored_traj = remove_component(traj, :y)
restored_traj.names


#=
## Adding suffixes

Another common operation is to add or remove a suffix from the components of a trajectory.
This can be useful when you want to create a modified version of a trajectory that is
related to the original trajectory in some way, or when you want to create a new trajectory
that is a combination of two or more existing trajectories.

For now, these tools are used to create a new trajectory.

=#

# Add a suffix "_new" to the state variable `x`
modified_traj = add_suffix(traj, "_modified")
modified_traj.names

# The modified trajectory contains the same data
modified_traj.x_modified == traj.x

#=
## Merging trajectories

You can also merge two or more trajectories into a single trajectory. This can be useful
when you want to combine data. Mergining trajectories is like taking a direct sum of the
underlying data.

=#

# Merge the original trajectory with the modified trajectory
merged_traj = merge(traj, modified_traj)
merged_traj.names |> println

# You can also extract a specific suffix from the components of a trajectory
extracted_traj = get_suffix(merged_traj, "_modified")
extracted_traj.names

# If you want the original names, you can remove the suffix
original_traj = get_suffix(merged_traj, "_modified", remove=true)
original_traj.names

# ### Merging with conflicts

# If there are any conflicting symbols, you can specify how to resolve the conflict.
conflicting_traj = rand(NamedTrajectory, 5)
traj.names, conflicting_traj.names

# In this case, keep the `u` data from the first trajectory and the `x` data from the second trajectory
merged_traj = merge(traj, conflicting_traj; merge_names=(u=1, x=2,))
println(merged_traj.u == traj.u, ", ", merged_traj.u == conflicting_traj.u)
println(merged_traj.x == traj.x, ", ", merged_traj.x == conflicting_traj.x)

# Merged names
merged_traj.names
