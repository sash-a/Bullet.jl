using Match

function _setup_joint_motor_control(sm, mode::Symbol, body_id, joint_idx)
    mode_map = Dict(:velocity => 0, :torque => 1, :position => 2)

    if !haskey(mode_map, mode)
        error("set_joint_motor_control received unknown mode: $(mode)")
    end

    command = Raw.b3JointControlCommandInit2(sm, body_id, mode_map[mode])
    info = get_joint_info(sm, body_id, joint_idx)

    (command, info)
end

function set_joint_motor_control(sm, mode::Symbol, body_id::Int, joint_idx::Int; target_position::Float64=0., target_velocity::Float64=0., kp::Float64=0.1, kd::Float64=0.9, max_torque::Float64=1000.)
    @match mode begin
        :position => set_joint_motor_control(sm, body_id, joint_idx, target_position, target_velocity, kp, kd, max_torque)
        :velocity => set_joint_motor_control(sm, body_id, joint_idx, target_velocity, kd, max_torque)
        :torque   => set_joint_motor_control(sm, body_id, joint_idx, max_torque)
        _         => error("received unknown mode $(mode)")
    end
end

function set_joint_motor_control(sm, body_id::Int, joint_idx::Int, target_position::Float64, target_velocity::Float64, kp::Float64, kd::Float64, max_torque::Float64)
    command, info = _setup_joint_motor_control(sm, :position, body_id, joint_idx)

    Raw.b3JointControlSetDesiredPosition(command, info.m_qIndex, target_position)
    Raw.b3JointControlSetKp(command, info.m_uIndex, kp)
    Raw.b3JointControlSetDesiredVelocity(command, info.m_uIndex, target_velocity)
    Raw.b3JointControlSetKd(command, info.m_uIndex, kd)
    Raw.b3JointControlSetMaximumForce(command, info.m_uIndex, max_torque)

    submit_client_command_and_wait(sm, command)
end
set_joint_motor_velocity(sm, body_id::Int, joint_idx::Int; target_position=0., target_velocity=0., kp=0.1, kd=0.9, max_torque=1000.) = set_joint_motor_control(sm, body_id::Int, joint_idx::Int, target_position::Float64, target_velocity::Float64, kp::Float64, kd::Float64, max_torque::Float64)

function set_joint_motor_control(sm, body_id::Int, joint_idx::Int, target_velocity::Float64, kd::Float64, max_torque::Float64)
    command, info = _setup_joint_motor_control(sm, :velocity, body_id, joint_idx)

    uIndex = info.m_uIndex
    if (uIndex >= 0)
        Raw.b3JointControlSetKd(command, uIndex, kd)
        Raw.b3JointControlSetDesiredVelocity(command, uIndex, target_velocity)
        Raw.b3JointControlSetMaximumForce(command, uIndex, max_torque)
    end
end
set_joint_motor_velocity(sm, body_id::Int, joint_idx::Int; target_velocity=0., kd=0.9, max_torque=1000.) = set_joint_motor_control(sm, body_id::Int, joint_idx::Int, target_velocity::Float64, kd::Float64, max_torque::Float64)

function set_joint_motor_control(sm, body_id::Int, joint_idx::Int, torque::Float64)
    command, info = _setup_joint_motor_control(sm, :torque, body_id, joint_idx)

    uIndex = info.m_uIndex;
    if (uIndex >= 0)
        Raw.b3JointControlSetDesiredForceTorque(command, uIndex, torque);
        submit_client_command_and_wait(sm, command)
    end
end
set_joint_motor_torque(sm, body_id::Int, joint_idx::Int, torque::Float64) = set_joint_motor_control(sm, body_id::Int, joint_idx::Int, torque::Float64)
