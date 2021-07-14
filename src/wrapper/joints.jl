function c_string(data::NTuple{N,UInt8}) where {N}
    data = (data[1:(findfirst(isequal(0), data)) - 1])
    return String(SArray{Tuple{length(data)}}(data))
end

function get_joint_info(sm::Sim, body_id, joint_id)
    ji = Ref{Raw.b3JointInfo}()
    @assert 1 == Raw.b3GetJointInfo(sm, body_id, joint_id, ji)
    return ji[]
end

get_num_joints(sm::Sim, body_id) = Raw.b3GetNumJoints(sm, body_id)

function get_all_joints(sm::Sim, body_id)
    num_joints = get_num_joints(sm, body_id)
    joint_names = OffsetArray{String}(undef, 0:num_joints - 1)
    link_names = OffsetArray{String}(undef, 0:num_joints - 1)
    joint_types = OffsetArray{Raw.JointType}(undef, 0:num_joints - 1)

    joint_info_ref = Ref{Raw.b3JointInfo}()
    for joint_id = 0:num_joints - 1
        @assert 1 == Raw.b3GetJointInfo(sm, body_id, joint_id, joint_info_ref)
        joint_names[joint_id] = c_string(joint_info_ref[].m_jointName)
        link_names[joint_id] = c_string(joint_info_ref[].m_linkName)
        joint_types[joint_id] = Raw.JointType(joint_info_ref[].m_jointType)
    end
    return @eponymtuple(joint_names, link_names, joint_types)
end

function get_sensor_state(sm::Sim, body_id, joint_id)
    command_handle = Raw.b3RequestActualStateCommandInit(sm, body_id)
    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_ACTUAL_STATE_UPDATE_COMPLETED)
    sensor_state_ref = Ref{Raw.b3JointSensorState}()
    @assert 1 == Raw.b3GetJointState(sm, status_handle, joint_id, sensor_state_ref)
    return sensor_state_ref[]
end

get_joint_position(sm::Sim, body_id, joint_id) = get_sensor_state(sm, body_id, joint_id).m_jointPosition


function set_joint_position(sm::Sim, body_id, joint_id; position=nothing, velocity=nothing)
    command_handle = Raw.b3CreatePoseCommandInit(sm, body_id)

    position !== nothing && Raw.b3CreatePoseCommandSetJointPosition(sm, command_handle, joint_id, position);
    velocity !== nothing && Raw.b3CreatePoseCommandSetJointVelocity(sm, command_handle, joint_id, velocity);

    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_CLIENT_COMMAND_COMPLETED)
end

# TODO resetJoinState