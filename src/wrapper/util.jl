submit_client_command_and_wait(sm, command) = Raw.b3SubmitClientCommandAndWaitStatus(sm, command)

function submit_client_command_and_wait_status_checked(sm, command; checked_status)
    status_handle = submit_client_command_and_wait(sm, command)
    status = Raw.EnumSharedMemoryServerStatus(Raw.b3GetStatusType(status_handle))
    if checked_status != status
        error("expected $(checked_status), got $(status)")
    end
    return status_handle
end

function set_color(sm, color; body_id, link_id=-1, shape_id=-1)
    command_handle = Raw.b3InitUpdateVisualShape2(sm, body_id, link_id, shape_id);
    Safe.UpdateVisualShapeRGBAColor(command_handle, color)
    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Bullet.Raw.CMD_VISUAL_SHAPE_UPDATE_COMPLETED)
end
