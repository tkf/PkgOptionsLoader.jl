module PkgOptionsLoader

using Base: PkgId, package_slug, slug, _crc32c
using Pkg: TOML

macro return_if_nothing(ex)
    quote
        ans = $(esc(ex))
        ans === nothing && return nothing
        ans
    end
end

project_slug() = slug(_crc32c(@return_if_nothing Base.active_project()), 5)

optionsdir() =
    joinpath(Base.DEPOT_PATH[1], "options", @return_if_nothing project_slug())

optionspath(pkg::PkgId) =
    joinpath(@return_if_nothing(optionsdir()),
             package_slug(pkg.uuid),
             pkg.name * ".toml")

function load(mod)
    pkg = PkgId(mod)
    if pkg.uuid === nothing
        error("Cannot load package options in a non-package module ", mod)
    end

    tomlpath = optionspath(pkg)
    if tomlpath === nothing || !isfile(tomlpath)
        return Dict{String,Any}()
    end

    # Editing this TOML file should invalidate the cache:
    Base.include_dependency(tomlpath)

    return TOML.parsefile(tomlpath)
end

"""
    PkgOptionsLoader.@load

Load package options for current module at _expansion time_.  It
evaluates to a Dict.  It is recommended to load it at the top level of
your package module:

```julia
const pkgoptions = PkgOptionsLoader.@load
```

It also is a good idea to verify options and then assign it to a `const`:

```julia
get!(pkgoptions, "FEATURE_FLAG", false)  # default

if !(pkgoptions["FEATURE_FLAG"] isa Bool)
    error("some helpful error message")
end

const FEATURE_FLAG::Bool = pkgoptions["FEATURE_FLAG"]
```
"""
macro load()
    load(__module__)
end

end # module
