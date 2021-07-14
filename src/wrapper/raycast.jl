function raycast(sm::Sim, ray_from, ray_to)
    command_handle = Safe.CreateRaycastCommandInit(sm, ray_from, ray_to)
    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED)
    rci_ref = Ref{Raw.b3RaycastInformation}()
    Raw.b3GetRaycastInformation(sm, rci_ref)
    rci = rci_ref[]

    @assert rci.m_numRayHits == 1
    ray_hit = unsafe_load(rci.m_rayHits)
    return ray_hit
end

function raycast_batch(sm::Sim, rays_from::Array{Cdouble,2}, rays_to::Array{Cdouble,2}, )
  # must ensure memory layout matches Bullet's
    @assert size(rays_from, 1) == 3
    @assert size(rays_to, 1) == 3
    @assert size(rays_from, 2) == size(rays_to, 2)
    N = size(rays_from, 2)
    @assert N <= Raw.MAX_RAY_INTERSECTION_BATCH_SIZE

    command_handle = Raw.b3CreateRaycastBatchCommandInit(sm)
  # Raw.b3RaycastBatchSetNumThreads(command_handle, 1)

    Raw.b3RaycastBatchAddRays(sm, command_handle, rays_from, rays_to, N)

    status_handle = submit_client_command_and_wait_status_checked(sm, command_handle; checked_status=Raw.CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED)

    rci_ref = Ref{Raw.b3RaycastInformation}()
    Raw.b3GetRaycastInformation(sm, rci_ref)

    rci = rci_ref[]
    @assert rci.m_numRayHits == N
    rci
end