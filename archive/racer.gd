# based on MIT license HoverCar demo from https://www.youtube.com/watch?v=PicKIVGVncsm, https://www.youtube.com/@dzonemanarmy6771

extends RigidBody3D

@onready var camera_pivot = get_node('../SpringArmPivot')
@onready var camera_arm = camera_pivot.get_node('../SpringArm3D')
@onready var camera = camera_pivot.get_node('../SpringArm3D/Camera')
@onready var ray = $Ray
@onready var hoverspring = $HoverSpring

var SPEED = 4000
var TORQUE = 800
var LERP_VAL = 0.1
var MAX_HOVER = 80
var HOVER_DIST = 2

func _unhandled_input(event):		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _ready():
	linear_damp = 1
	angular_damp = 5
	gravity_scale = 5

func _physics_process(delta):
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
		
		
	var dist = hoverspring.get_hit_length()
	constant_force.y = clamp(MAX_HOVER*HOVER_DIST/dist,0,MAX_HOVER)
	print(dist)
	
	rotation.x = lerp(rotation.x,0.0,LERP_VAL)
	rotation.z = lerp(rotation.x,0.0,LERP_VAL)
		
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, rotation.y,LERP_VAL)

