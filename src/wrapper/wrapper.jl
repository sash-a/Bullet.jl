# Adapting to julia:
# https://github.com/bulletphysics/bullet3/blob/cdd56e46411527772711da5357c856a90ad9ea67/examples/SharedMemory/b3RobotSimulatorClientAPI_NoDirect.cpp

Sim = Ptr{Bullet.Raw.b3PhysicsClientHandle__}

include("util.jl")
include("initialize.jl")
include("sim.jl")
include("load.jl")
include("collision.jl")
include("debug.jl")
include("joints.jl")
include("joint_motor_control.jl")
include("pose.jl")
include("raycast.jl")