# F# + Nix

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)<br>
[![[.Net] Build & Test](https://github.com/mtrsk/fsharp-nix/actions/workflows/build.yml/badge.svg)](https://github.com/mtrsk/fsharp-nix/actions/workflows/build.yml)
[![[Nix] Build Container](https://github.com/mtrsk/fsharp-nix/actions/workflows/build-container.yml/badge.svg)](https://github.com/mtrsk/fsharp-nix/actions/workflows/build-container.yml)

An opinionated F# template and development environment that's powered by Nix.

- [F# + Nix](#f--nix)
  - [Development](#development)
    - [Devenv](#devenv)
      - [Justfile](#justfile)
    - [Nix Build](#nix-build)
    - [Github Actions (+Nix)](#github-actions-nix)
    - [Docker](#docker)

## Development

### Devenv

```shell
nix develop --impure
```
or `direnv allow`, if you have [direnv](https://github.com/direnv/direnv) installed.

#### Justfile

If you type `just` for a list of commands.

```shell
$ just        
PROJECT: Sample - RELEASE: 
just --list
Available recipes:
    build     # Builds the project
    b         # alias for `build`
    build-nix # Builds the project (with Nix)
    bnix      # alias for `build-nix`
    default   # Lists all availiable targets
    delete    # Deletes a release
    gen-deps  # Generates nix dependencies for deps.nix
    gd        # alias for `gen-deps`
    pack      # Packages current tag as a .Net release
    push      # Pushes release to NUGET
    test      # Runs testing suite
    t         # alias for `test`
```
to build this project, you can run:

```shell
# or just b, if you're lazy
just build
```
and for running the testing suite:

```shell
# or just b, if you're lazy
just test
```

### Nix Build

To build this with Nix:

```shell
nix build
```

### Github Actions (+Nix)

I've also pre-configured some [Github Actions](https://github.com/mtrsk/fsharp-nix/actions).

### Docker

A container image can also be generated via:
```shell
nix build .#dockerImage
```

