function reset_simulation(sm)
    submit_client_command_and_wait_status_checked(
        sm,
        Raw.b3InitResetSimulationCommand(sm);
        checked_status=Raw.CMD_RESET_SIMULATION_COMPLETED)
end

function step_simulation(sm)
    status_handle = Raw.b3SubmitClientCommandAndWaitStatus(sm, Raw.b3InitStepSimulationCommand(sm))
    status = Raw.b3GetStatusType(status_handle)
end