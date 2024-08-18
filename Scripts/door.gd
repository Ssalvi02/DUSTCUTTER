extends RigidBody3D

@onready var ray : RayCast3D = $RayCast3D
@onready var door_static : MeshInstance3D = $MeshInstance3D
var door_shards : Array


func _ready():
	door_shards = find_child("Shards").get_children() 

func knockback(a, kick_force, kick_raycast_pos):
	freeze = false
	apply_impulse(ray.target_position * kick_force)
	for i in door_shards:
		i.find_child("CollisionShape3D").disabled = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("enemies"):
		door_static.visible = false
		find_child("Shards").visible = true
		self.add_to_group("door_shards")
		for i in door_shards:
			i.add_to_group("door_shards")
			i.freeze = false
			i.linear_velocity = linear_velocity
			i.collision_layer = 1
			i.collision_mask = 1
		print(body)
		body.stun()
		await get_tree().create_timer(5).timeout
		queue_free()
