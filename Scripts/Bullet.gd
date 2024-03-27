extends Node3D

@onready var pierce = get_parent().pierce
@export var pierce_limit = 2

@onready var SPEED = get_parent().bullet_speed

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particle = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	if ray.is_colliding():
		if ray.get_collider().has_method("kill"):
			ray.get_collider().kill()
			
		if(!pierce or !ray.get_collider().is_in_group("enemies")):
			mesh.visible = false
			ray.enabled = false
			particle.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
		elif(pierce and pierce_limit > 0 and
		ray.get_collider().is_in_group("enemies")):
			pierce_limit -= 1
			print(pierce_limit)
			particle.emitting = true
			if(pierce_limit < 1):
				queue_free()


func _on_timer_timeout():
	queue_free()
