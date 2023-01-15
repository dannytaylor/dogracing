# based on tutorial https://www.youtube.com/watch?v=a9BiDC0xT-4 by https://twitter.com/mreliptik_

extends RigidBody3D

@onready var camera_pivot = get_node('../SpringArmPivot')
@onready var camera_arm = camera_pivot.get_node('SpringArm3D')
@onready var camera = camera_arm.get_node('Camera3D')

@onready var rays = get_tree().get_nodes_in_group('rays')

var SPEED = 25000
var TORQUE = 3000
var LERP_VAL = 0.1
var MAX_HOVER = 500

func _unhandled_input(_event):		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _ready():
	pass

func _physics_process(delta):
	
	
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var collision_point = ray.get_collision_point()
			var dist = collision_point.distance_to(ray.global_transform.origin)	
			
			apply_force(Vector3.UP * (1/dist) * MAX_HOVER * delta, ray.global_transform.origin - global_transform.origin)
			
			
	if Input.is_action_pressed("w"):
		apply_central_force(global_transform.basis* Vector3.FORWARD * SPEED * delta)
	if Input.is_action_pressed("s"):
		apply_central_force(global_transform.basis* Vector3.FORWARD * -SPEED * delta)
	if Input.is_action_pressed("a"):
		apply_central_force(global_transform.basis* Vector3.LEFT * SPEED/4 * delta)
	if Input.is_action_pressed("d"):
		apply_central_force(global_transform.basis* Vector3.RIGHT * SPEED/4 * delta)
	if Input.is_action_pressed("q"):
		apply_torque(Vector3.UP * TORQUE * delta)
	if Input.is_action_pressed("e"):
		apply_torque(Vector3.UP * -TORQUE * delta)
		
	
	rotation.x = lerp(rotation.x,0.0,LERP_VAL)
	rotation.z = lerp(rotation.x,0.0,LERP_VAL)
		
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, rotation.y,LERP_VAL)

