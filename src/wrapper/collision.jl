function get_contact_point_information(sm::Sim, body_a_id, link_a_id, body_b_id, link_b_id, distance)
    command_handle = Raw.b3InitClosestDistanceQuery(sm)
    Raw.b3SetClosestDistanceThreshold(command_handle, distance)
    Raw.b3SetClosestDistanceFilterBodyA(command_handle, body_a_id)
    Raw.b3SetClosestDistanceFilterBodyB(command_handle, body_b_id)

    Raw.b3SetClosestDistanceFilterLinkA(command_handle, link_a_id)
    Raw.b3SetClosestDistanceFilterLinkB(command_handle, link_b_id)

    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_CONTACT_POINT_INFORMATION_COMPLETED)

    contact_point_data = Ref{Raw.b3ContactInformation}()
    Raw.b3GetContactPointInformation(sm, contact_point_data)
    return contact_point_data[]
end

function get_contact_point_information(sm::Sim, body_a_id, body_b_id, distance)
    command_handle = Raw.b3InitClosestDistanceQuery(sm)
    Raw.b3SetClosestDistanceThreshold(command_handle, distance)
    Raw.b3SetClosestDistanceFilterBodyA(command_handle, body_a_id)
    Raw.b3SetClosestDistanceFilterBodyB(command_handle, body_b_id)

    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_CONTACT_POINT_INFORMATION_COMPLETED)

    contact_point_data = Ref{Raw.b3ContactInformation}()
    Raw.b3GetContactPointInformation(sm, contact_point_data)
    return contact_point_data[]
end

function set_collision_filter_pair(sm::Sim, body_a_id, link_a_id, body_b_id, link_b_id, enable_collision)
    command_handle = Raw.b3CollisionFilterCommandInit(sm)
	Raw.b3SetCollisionFilterPair(command_handle, body_a_id, body_b_id, link_a_id, link_b_id, enable_collision);
    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_CLIENT_COMMAND_COMPLETED);
end

function get_collision_shape_information(sm::Sim, body_id, link_id)
    command_handle = Raw.b3InitRequestCollisionShapeInformation(sm, body_id, link_id);
    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_COLLISION_SHAPE_INFO_COMPLETED)
    collision_shape_info = Ref{Raw.b3CollisionShapeInformation}()
    Raw.b3GetCollisionShapeInformation(sm, collision_shape_info)
    return collision_shape_info[]
end

function set_collision_flags(sm::Sim, body_id, link_id, collision_filter_group, collision_filter_mask)
    command_handle = Raw.b3CollisionFilterCommandInit(sm)
    Raw.b3SetCollisionFilterGroupMask(command_handle, body_id, link_id, collision_filter_group, collision_filter_mask)
    submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_CLIENT_COMMAND_COMPLETED)
end