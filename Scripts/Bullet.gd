extends Node3D

@onready var decal = preload("res://Scenes/decal.tscn")

@onready var pierce : bool = get_parent().pierce
@export var pierce_limit : int = 2

@onready var SPEED : int = get_parent().bullet_speed

@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var ray : RayCast3D = $RayCast3D
@onready var particle : GPUParticles3D = $GPUParticles3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	if ray.is_colliding():
		generate_decal()
		if ray.get_collider().has_method("kill"):
			ray.get_collider().kill()
			
		if(!pierce or !ray.get_collider().is_in_group("enemies")):
			mesh.visible = false
			ray.enabled = false
			particle.emitting = true
			await get_tree().create_timer(5).timeout
			queue_free()
		elif(pierce and pierce_limit > 0 and
		ray.get_collider().is_in_group("enemies")):
			pierce_limit -= 1
			particle.emitting = true
			if(pierce_limit < 1):
				queue_free()

func generate_decal():
	var col_nor = ray.get_collision_normal()
	var col_point = ray.get_collision_point()
	var p = decal.instantiate()
	get_tree().root.get_child(0).add_child(p)
	p.global_transform.origin = col_point
	if col_nor != Vector3.DOWN:
		p.rotation_degrees.x = 90
	elif col_nor != Vector3.UP:
		p.look_at(col_point - col_nor, Vector3(0,1,0))

func _on_timer_timeout():
	queue_free()
