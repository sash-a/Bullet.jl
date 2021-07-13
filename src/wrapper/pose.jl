function get_base_pose(sm, body_id)
    pointer_ref = Ref{Ptr{Cdouble}}()

    command_handle = Raw.b3RequestActualStateCommandInit(sm, body_id)
    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_ACTUAL_STATE_UPDATE_COMPLETED)

    null = Ptr{Any}(0)
    Raw.b3GetStatusActualState(
    status_handle, null #= body_unique_id =#,
    null #= num_degree_of_freedom_q =#, null #= num_degree_of_freedom_u =#,
    null #= root_local_inertial_frame =#, pointer_ref,
    null #= actual_state_q_dot =#, null #= joint_reaction_forces =#)

    pos_quat = unsafe_wrap(Array, pointer_ref[], (7,), own=false)
    pos = SVector(pos_quat[1:3]...)
    
    quat = let (x, y, z, w) = pos_quat[4:7]
        CoordinateTransformations.Rotations.Quat(w, x, y, z, false)
    end

    pose = compose(Translation(pos), LinearMap(quat))
    return pose
end


function set_base_pose(sm, body_id, transformation)
    command_handle = Raw.b3CreatePoseCommandInit(sm, body_id)

    translation = transformation.translation
    rotation = transformation.linear

    Safe.CreatePoseCommandSetBasePosition(command_handle, translation)
    Safe.CreatePoseCommandSetBaseOrientation(command_handle, rotation)

    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_CLIENT_COMMAND_COMPLETED)
end


function get_links_poses(sm, body_id)
    command_handle = Raw.b3RequestActualStateCommandInit(sm, body_id)
    Raw.b3RequestActualStateCommandComputeForwardKinematics(command_handle, true)
    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_ACTUAL_STATE_UPDATE_COMPLETED)

    link_index = 1
    link_state_ref = Ref{Raw.b3LinkState}()
    Raw.b3GetLinkState(sm, status_handle, link_index, link_state_ref)
    return link_state_ref[]
end
    

struct BodyManager
    sm::Ptr{Raw.b3PhysicsClientHandle__}
    body_id::Int
    joint_names::OffsetArray{Symbol,1,Vector{Symbol}}
    link_names::OffsetArray{Symbol,1,Vector{Symbol}}
    joint_types::OffsetArray{Raw.JointType,1,Vector{Raw.JointType}}
    joint::Dict{Symbol,Int}
    link::Dict{Symbol,Int}
end


function BodyManager(sm, body_id::Integer)
    all_joints = Bullet.get_all_joints(sm, body_id)
    BodyManager(
      sm, body_id,
      map(Symbol, all_joints.joint_names),
      map(Symbol, all_joints.link_names),
      all_joints.joint_types,
      Dict(Symbol(all_joints.joint_names[i]) => i for i = eachindex(all_joints.joint_names)),
      Dict(Symbol(all_joints.link_names[i]) => i for i = eachindex(all_joints.link_names))
    )
end