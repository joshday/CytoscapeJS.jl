using Pkg; Pkg.activate(@__DIR__)

using Tar, Downloads, Dates, ArtifactUtils

url = "https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.21.0/cytoscape.min.js"

dir = mkpath(joinpath(@__DIR__, "artifacts"))

#-----------------------------------------------------------------------------# start from scratch
rm(dir, recursive=true, force=true)
rm(joinpath(@__DIR__, "cytoscape_jl.tar"), force=true)
rm(joinpath(@__DIR__, "cytoscape_jl.tar.gz"), force=true)


#-----------------------------------------------------------------------------# download
Downloads.download(url, joinpath(mkdir(dir), "cytoscape.min.js"))

tarfile = joinpath(@__DIR__, "cytoscape_jl.tar")

Tar.create(dir, tarfile)

run(`gzip $tarfile`)

#-----------------------------------------------------------------------------# upload
try
    artifacts_today = "artifacts_$(today())"

    run(`gh release create $artifacts_today $(tarfile * ".gz") --title $artifacts_today --notes ""`)

    @info "Sleeping so artifact is ready on GitHub..."
    sleep(10)
    add_artifact!(
        "Artifacts.toml",
        "cytoscape.min.js",
        "https://github.com/joshday/CytoscapeJS.jl/releases/download/$artifacts_today/plotly.tar.gz",
        force=true,
    )
catch ex
    @error "Error (probably the release already exists): $ex"
end
