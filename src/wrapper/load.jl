function load_urdf(sm, urdfpath; position=[0, 0, 0], orientation=[0, 0, 0, 1], flags=0)
    command = Raw.b3LoadUrdfCommandInit(sm, urdfpath)
    Raw.b3LoadUrdfCommandSetFlags(command, flags)

    Raw.b3LoadUrdfCommandSetStartPosition(command, position...)
    Raw.b3LoadUrdfCommandSetStartOrientation(command, orientation...)

    status_handle = submit_client_command_and_wait_status_checked(sm, command; checked_status=Raw.CMD_URDF_LOADING_COMPLETED)
    bodyUniqueId = Raw.b3GetStatusBodyIndex(status_handle);
    return bodyUniqueId
end

function load_mjcf(sm, mjcfpath; flags=0)
    command = Raw.b3LoadMJCFCommandInit(sm, mjcfpath)
    Raw.b3LoadMJCFCommandSetFlags(command, flags)

    status_handle = submit_client_command_and_wait_status_checked(sm, command; checked_status=Raw.CMD_MJCF_LOADING_COMPLETED)
    num_boddies = Raw.b3GetStatusBodyIndices(status_handle, Ref{Cint}(0), Cint(0))
    
    boddies = repeat([Cint(-1)], num_boddies)
    boddies_ptr = pointer(boddies)
    if (num_boddies > 0)
        num_boddies = Raw.b3GetStatusBodyIndices(status_handle, boddies_ptr, num_boddies)
    end

    boddies
end