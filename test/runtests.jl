using Test
using Bullet

const assets_dir = joinpath(@__DIR__, "..", "deps", "usr", "data")

# include("demo.jl")
# include("demo_robot.jl")
# include("robot_collision.jl")
# include("raycast.jl")
@testset "wrap" begin include("wrap.jl") end