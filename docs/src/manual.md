# Manual

## Installation

```julia
pkg> add NamedTrajectories
```

## Usage

```julia
using NamedTrajectories
```

### Creating a trajectory

A trajectory is a collection of named vectors, each of which has the same length. The vectors can be of any type, but must be named. The names are used to identify the vectors, and must be unique.

```julia
data =  