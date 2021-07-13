b = Bullet

sm = b.connect(kind=:direct)

# Loaders
@test b.load_urdf(sm, joinpath(assets_dir, "planeMesh.urdf")) == 0
@test b.load_mjcf(sm, joinpath(assets_dir, "ant.xml")) == [1]  # TODO add ant.xml to build
@test b.load_mjcf(sm, joinpath(assets_dir, "double_ant.xml")) == [2, 3]

@test b.get_num_joints(sm, 1) == 20

# Make sure this doesn't error with the correct symbols
b.set_joint_motor_control(sm, :position, 1, 0, target_position=0.5, target_velocity=0.5)
b.set_joint_motor_control(sm, :velocity, 1, 3, target_velocity=0.5)
b.set_joint_motor_control(sm, :torque, 1, 2, max_torque=50.)
