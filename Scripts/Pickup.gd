extends RigidBody3D

var SPEED : int = 20
var first_col : bool = true 

@onready var ray : RayCast3D = $RayCast3D
@onready var player : CharacterBody3D = $"../Player"
@export var pickup_name = ""
@export var ammo_value = 0

@export var sprite : Texture = null
@export var group : String = "weapons"

var throwing : bool = false

signal can_pickup(pickup)
signal connect_throw
signal disconnect_throw

var is_in_pickup_area = false

func _ready():
	$Sprite3D.texture = sprite
	add_to_group(group)
	pass

func _process(delta):
	if(is_in_pickup_area):
		can_pickup.emit(self)

	if throwing:
		if ray.is_colliding():
			$Area3D.monitorable = true
			$Area3D.monitoring = true
			throwing = false
			
			if ray.get_collider().has_method("stun"):
				ray.get_collider().stun()
				
			if(ray.get_collider().is_in_group("enemies")):
				#bounce back
				if first_col == true :
					apply_central_impulse(self.global_transform.basis.z * SPEED)
					first_col = false
	else:
		return


func _on_area_3d_area_entered(area):
	is_in_pickup_area = true
	#Texto para pegar armas / upgrades

func _on_area_3d_area_exited(area):
	is_in_pickup_area = false
	#Remover texto para pegar armas / upgrades

func _on_player_throw_weapon():
	rootParent()
	lock_rotation = false
	freeze = false
	visible = true
	global_position = player.raycastgun.global_position
	transform.basis = player.raycastgun.global_transform.basis
	$CollisionShape3D.disabled = false
	apply_central_impulse(-self.global_transform.basis.z * SPEED)
	throwing = true
	player.throw_weapon.disconnect(_on_player_throw_weapon)

func rootParent():
	self.reparent(get_tree().root.get_child(0), false)

func _on_connect_throw():
	player.throw_weapon.connect(_on_player_throw_weapon)

