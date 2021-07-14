function reset_simulation(sm::Sim)
    submit_client_command_and_wait_status_checked(
        sm,
        Raw.b3InitResetSimulationCommand(sm);
        checked_status=Raw.CMD_RESET_SIMULATION_COMPLETED)
end

function step_simulation(sm::Sim)
    status_handle = Raw.b3SubmitClientCommandAndWaitStatus(sm, Raw.b3InitStepSimulationCommand(sm))
    status = Raw.b3GetStatusType(status_handle)
end

function set_gravity(sm::Sim, gravity)  # this should probably move to physics.jl with raycasts and maybe collisions
    command = Raw.b3InitPhysicsParamCommand(sm)

    Safe.PhysicsParamSetGravity(command, gravity)

    submit_client_command_and_wait_status_checked(sm, command; checked_status=Raw.CMD_CLIENT_COMMAND_COMPLETED)
end