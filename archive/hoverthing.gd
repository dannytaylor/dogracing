# based on MIT license HoverCar demo from https://www.youtube.com/watch?v=PicKIVGVncsm, https://www.youtube.com/@dzonemanarmy6771

extends Node3D

@onready var ray = $HoverRayCast


@export var ForcePower = 20000.0
@export var Stiffness = 0.02
@export var Damping = 0.002
@export var HoverHeight = 70.0


var ForceToAdd = Vector3()
var Displacement = 0.0
var PrevDisplacement = 0.0
var Speed = 0.0


func _ready():
	ray.target_position.y = -HoverHeight
	#ray.add_exception(get_parent())

func _physics_process(Delta):
	if(ray.is_colliding()):
		if(!$HoverCollisionPoint.visible):
			$HoverCollisionPoint.visible = true
		PrevDisplacement = Displacement
		Displacement = (ray.target_position.length() - (global_transform * ray.get_collision_point()).length())
		Speed = (Displacement - PrevDisplacement) / Delta
		var SpringForce = ProjectSettings.get_setting("physics/3d/default_gravity") * get_parent().mass * Stiffness * Displacement
		var DampingForce = Damping * Speed
		ForceToAdd = Vector3.UP * clamp(SpringForce + DampingForce, 0, 50)
		$HoverCollisionPoint.global_transform.origin = ray.get_collision_point()
	else:
		if($HoverCollisionPoint.visible):
			$HoverCollisionPoint.visible = false
		ForceToAdd = Vector3.ZERO
	
	get_parent().apply_force((get_parent().global_transform.basis * (global_transform.origin - get_parent().global_transform.origin))*ForceToAdd * Delta * ForcePower)








