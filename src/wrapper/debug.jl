function set_debug_object_color(sm::Sim, body_id, link_id, color_rgb)
    #= 
      only visible in wireframe mode of Bullet debug visualizer (hit the W key) =#
    command_handle = Raw.b3InitDebugDrawingCommand(sm)
    Raw.b3SetDebugObjectColor(command_handle, body_id, link_id, color_rgb);
    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_USER_DEBUG_DRAW_COMPLETED);
end

function debug_draw_line(sm::Sim, from, to, color, line_width, life_time)
    command_handle = Safe.InitUserDebugDrawAddLine3D(sm, from, to, color, line_width, life_time)
    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_USER_DEBUG_DRAW_COMPLETED)
    debugItemUniqueId = Raw.b3GetDebugItemUniqueId(status_handle)
    return debugItemUniqueId
end