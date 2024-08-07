extends RigidBody3D

var SPEED : int = 20
var first_col : bool = true 

@onready var ray : RayCast3D = $RayCast3D
@onready var sprite : Sprite3D = $Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(-self.global_transform.basis.z * SPEED)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray.is_colliding():
		if ray.get_collider().has_method("stun"):
			ray.get_collider().stun()
			
		if(ray.get_collider().is_in_group("enemies")):
			#bounce back
			if first_col == true :
				apply_central_impulse(self.global_transform.basis.z * SPEED)
				first_col = false
			#queue_free()
