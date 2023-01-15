# adapted from https://www.youtube.com/@DevLogLogan Third Person character tutorial

extends CharacterBody3D

@onready var spring_arm_pivot = get_node('../SpringArmPivot')
@onready var spring_arm = spring_arm_pivot.get_node('CameraSpringArm')
@onready var camera = spring_arm.get_node('Camera3D')

@onready var player_root = $PlayerRootCollision
@onready var left = $PlayerRootCollision/meshes/bottle/ketchup
@onready var right = $PlayerRootCollision/meshes/bottle/mustard
@onready var sa_leftdown = $PlayerRootCollision/meshes/springarms/leftdown
@onready var sa_rightdown = $PlayerRootCollision/meshes/springarms/rightdown
@onready var sa_leftfront = $PlayerRootCollision/meshes/springarms/leftfront
@onready var sa_rightfront = $PlayerRootCollision/meshes/springarms/rightfront

@onready var wires = $PlayerRootCollision/meshes/bottle/cab/wires
@onready var cab = $PlayerRootCollision/meshes/bottle/cab
@onready var spark = $PlayerRootCollision/meshes/sparks
@onready var spark_height = spark.position.y
@onready var spark_z = spark.position.z

@onready var lefttrail = $PlayerRootCollision/meshes/bottle/ketchup/lefttrail/cabtrail
@onready var righttrail = $PlayerRootCollision/meshes/bottle/mustard/righttrail/cabtrail
@onready var cabtrail = $PlayerRootCollision/meshes/cabtrail

@onready var engine = $engine_sfx

const SPEED = 100.0
const STRAFE_SPEED = 25.0
const JUMP_VELOCITY = 4.5
const LERP_VAL = 0.01
const FOV = 90
const SMOKE_MAX = 512
const ENGINE_DB = [3,-20]

var ARM_Y = 0
var ARM_Z = -4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ARM_Y = left.position.y
	ARM_Z = left.position.z
	
	

func _unhandled_input(_event):		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	#if event is InputEventMouseMotion:
	#	spring_arm_pivot.rotate_y(-event.relative.x * 0.003)
	#	spring_arm.rotate_x(-event.relative.y * 0.003)
	#	spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/8, PI/16)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	

	# print(transform.origin)
	# Handle Jump.
	#if Input.is_action_just_pressed("space") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
	
	# lerp towards direct back of player
	
	spring_arm_pivot.position = position
	spring_arm_pivot.rotation.y = lerp_angle(spring_arm_pivot.rotation.y, player_root.rotation.y, LERP_VAL*8)
	
	

	var input_dir = Input.get_vector("q", "e", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, player_root.rotation.y)
	
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED,LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED,LERP_VAL)
		direction = (transform.basis * Vector3(velocity.x, 0, velocity.y)).normalized()
		player_root.rotation.y = lerp_angle(player_root.rotation.y, atan2(-velocity.x,-velocity.z), LERP_VAL*16)
		# player_root.rotation.z = lerp_angle(0, input_dir.x*PI/2, LERP_VAL)

	else:
		velocity.x = lerp(velocity.x,0.0,LERP_VAL)
		velocity.z = lerp(velocity.z,0.0,LERP_VAL*4)
		
	
	# player_root.rotation.y = lerp_angle(player_root.rotation.y, atan2(velocity.x,velocity.z), LERP_VAL*2)
	
	# strafing
	#if Input.is_action_pressed("a"):
	#	velocity.z = lerp(velocity.z, -STRAFE_SPEED,LERP_VAL*32)
	#if Input.is_action_pressed("d"):
	#	velocity.z = lerp(velocity.z, STRAFE_SPEED,LERP_VAL*32)
	
	var speed_ratio = clamp(velocity.length()/SPEED,0.0,1.0)
	camera.fov = lerp(camera.fov, FOV + 30*speed_ratio,LERP_VAL*4)
	spring_arm.spring_length = lerp(spring_arm.spring_length, 5 + 3*speed_ratio,LERP_VAL*4)
	spring_arm_pivot.rotation.x = lerp(spring_arm_pivot.rotation.x,  deg_to_rad(-35 + 12.5*speed_ratio),LERP_VAL*4)
	
	#trail.scale_amount_max = speed_ratio
	#trail.scale_amount_min = speed_ratio/2
	
	left.position.y = lerp(left.position.y,ARM_Y+(2-sa_leftdown.get_hit_length()),LERP_VAL*2)
	right.position.y = lerp(right.position.y,ARM_Y+(2-sa_rightdown.get_hit_length()),LERP_VAL*2)
	
	left.position.z = lerp(left.position.z,ARM_Z+(4-sa_leftfront.get_hit_length()),LERP_VAL*2)
	right.position.z = lerp(right.position.z,ARM_Z+(4-sa_rightfront.get_hit_length()),LERP_VAL*2)
	
	spark.position.y = (left.position.y+right.position.y)/2 + spark_height - ARM_Y
	spark.position.z = (left.position.z+right.position.z)/2 + spark_z - ARM_Z
	wires.position.z = (left.position.z+right.position.z)/4 - ARM_Z
	cab.position.y = (left.position.y+right.position.y)/4 -  - ARM_Y
	
	lefttrail.mesh.material.albedo_color = Color(1,1,1,speed_ratio-0.2)
	righttrail.mesh.material.albedo_color = Color(1,1,1,speed_ratio-0.2)
	if speed_ratio < 0.4:
		righttrail.mesh.material.distance_fade_mode = 2
		lefttrail.mesh.material.distance_fade_mode = 2
	else:
		lefttrail.mesh.material.distance_fade_mode = 0
		righttrail.mesh.material.distance_fade_mode = 0
		var leftparent = lefttrail.get_parent()
		var rightparent = righttrail.get_parent()
		lefttrail.mesh.radius = 0.2*speed_ratio+0.1
		leftparent.scale.z = lerp(leftparent.scale.z,speed_ratio,LERP_VAL*16)
		righttrail.mesh.radius = 0.2*speed_ratio+0.1
		rightparent.scale.z = lerp(rightparent.scale.z,speed_ratio,LERP_VAL*16)
	cabtrail.scale.z = speed_ratio/2
	
	if speed_ratio < 0.1:
		engine.stop()
	else:
		if not engine.playing:
			engine.play()
		engine.volume_db = ENGINE_DB[0] + ENGINE_DB[1]*(1-speed_ratio)
		engine.pitch_scale = 1+speed_ratio/3
	
	

	move_and_slide()
