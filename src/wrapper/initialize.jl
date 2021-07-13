connection_state = nothing
timer_state = nothing

function handle_gui(sm)
    # Just a no-op command.
    submit_client_command_and_wait_status_checked(
        sm,
        Raw.b3InitRequestPhysicsParamCommand(sm);
        checked_status=Raw.CMD_REQUEST_PHYSICS_SIMULATION_PARAMETERS_COMPLETED)
end

function setup_gui_timer()
    global connection_state
    global timer_state
    if connection_state === nothing
        error("not connected")
    end

    if timer_state === nothing
        timer_state = Timer((_ -> handle_gui(connection_state.handle)), 0.0, interval=1 / 30)
    end
end

function connect(;kind=:direct, do_reset_sim=true,)
    global connection_state

    if connection_state === nothing
        if kind == :direct
            handle = Raw.b3ConnectPhysicsDirect()
            connection_state = (kind = kind, handle = handle)
        elseif kind == :gui
      handle = Raw.b3CreateInProcessPhysicsServerAndConnectMainThread(0, [])
      connection_state = (kind = kind, handle = handle)
        end

        if connection_state === nothing
            error("unknown kind: $(kind)")
        end
    end

    if connection_state.kind == kind
        if do_reset_sim
            reset_simulation(connection_state.handle)
        end
        return connection_state.handle
    else
        error("Can't switch kind after connection, unless you like segfaults")
    end
end

function disconnect()
    global connection_state
    if connection_state === nothing
        error("not connected")
    end

    if connection_state.kind == :direct
        Raw.b3DisconnectSharedMemory(connection_state.handle)
    else
        error("refuse to disconnect from GUI")
    end
    connection_state = nothing
end