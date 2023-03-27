# NamedTrajectories.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://aarontrowbridge.github.io/NamedTrajectories.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aarontrowbridge.github.io/NamedTrajectories.jl/dev/)
[![Build Status](https://github.com/aarontrowbridge/NamedTrajectories.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/aarontrowbridge/NamedTrajectories.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/aarontrowbridge/NamedTrajectories.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/aarontrowbridge/NamedTrajectories.jl)

**NamedTrajectories.jl** is a package for working with trajectories of named variables. It is designed to be used with [Pico.jl]() and [IterativeLearningControl.jl]().

## Notice!

This package is under active development and issues may arise -- please be patient and report any issues you find!

## Installation

NamedTrajectories.jl is not yet registered, so you will need to install it manually:

```julia
using Pkg
Pkg.add(url="https://github.com/aarontrowbridge/NamedTrajectories.jl", rev="main")
```