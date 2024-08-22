extends RigidBody3D

@onready var ray : RayCast3D = $RayCast3D
@onready var door_static : MeshInstance3D = $Door
@onready var audios : Array
var door_shards : Array

@export var ray_dir : Vector3 = Vector3(0,0,-1)

func _ready():
	audios = $Audios.get_children()
	ray.target_position = ray_dir
	door_shards = find_child("Shards").get_children() 

func knockback(a, kick_force, kick_raycast_pos):
	freeze = false
	audios[0].play()
	apply_impulse(ray.target_position * kick_force)

func _on_area_3d_body_entered(body):
	if body.is_in_group("enemies"):
		body.knockback_door()
		door_static.visible = false
		collision_layer = 4
		find_child("Shards").visible = true
		add_to_group("door_shards")
		audios[1].play()
		for i in door_shards:
			i.add_to_group("door_shards")
			i.freeze = false
			i.apply_central_impulse(ray.target_position * 10)
			#i.linear_velocity = linear_velocity
			i.collision_mask = 1
		body.kill()
		await get_tree().create_timer(5).timeout
		queue_free()
