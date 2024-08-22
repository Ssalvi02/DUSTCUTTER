extends RigidBody3D

var SPEED : int = 20

@onready var ray : RayCast3D = $RayCast3D
@onready var player : CharacterBody3D = $"../Player"
@onready var gc 
@export var pickup_name : String = ""
@export var ammo_value : int = 0
@export var priority : int = 0

@export var sprite : Texture = null
@export var group : String = "weapons"

var cooldown : float = 1 

var throwing : bool = false
var throw_time : float = 0

#Signals and control
signal can_pickup(pickup)
signal connect_throw
signal disconnect_throw

var is_in_pickup_area = false

#Audio
@onready var sounds = $Audios
@export var throw_sound : AudioStreamMP3

var first_col : bool = true

func _ready():
	gc = get_tree().root.get_child(0)
	sounds.find_child("Throw").stream = throw_sound
	$Sprite3D.texture = sprite
	$Area3D.priority = priority 
	add_to_group(group)
	pass

func _process(delta):
	if(is_in_pickup_area):
		gc.check_gun_priority()
		can_pickup.emit(self)

	if throwing:
		throw_time += delta
		
		if ray.is_colliding():
			$Area3D.monitorable = true
			$Area3D.monitoring = true
			throwing = false

			if ray.get_collider().has_method("stun"):
				ray.get_collider().stun()

		if throw_time >= cooldown:
			throw_time = 0
			unstuck()
	else:
		first_col = true
		return

func knockback(dir, kick_force, kick_raycast_pos):
	apply_impulse(dir * kick_force, kick_raycast_pos)

func unstuck():
	$Area3D.monitorable = true
	$Area3D.monitoring = true
	throwing = false

func _on_area_3d_area_entered(area):
	if area.name == "PickupArea":
		player.ui.find_child("BottomText").find_child("PickupText").text = "Grab " + pickup_name
		player.ui.find_child("BottomText").find_child("PickupText").visible = true
		is_in_pickup_area = true
		#Texto para pegar armas 

func _on_area_3d_area_exited(area):
	if area.name == "PickupArea":
		player.ui.find_child("BottomText").find_child("PickupText").visible = false
		is_in_pickup_area = false
		#Remover texto para pegar armas 

func _on_player_throw_weapon():
	sounds.find_child("Throw").play()
	rootParent()
	freeze = false
	visible = true
	global_position = player.raycastgun.global_position
	transform.basis = player.raycastgun.global_transform.basis
	$CollisionShape3D.disabled = false
	apply_central_impulse(-self.global_transform.basis.z * SPEED)
	throwing = true
	player.throw_weapon.disconnect(_on_player_throw_weapon)
	player.get_gun().update_ammo_value.disconnect(_on_update_ammo_value)

func rootParent():
	self.reparent(get_tree().root.get_child(0), false)

func _on_connect_throw():
	player.throw_weapon.connect(_on_player_throw_weapon)
	player.get_gun().update_ammo_value.connect(_on_update_ammo_value)

func _on_update_ammo_value(new_value):
	ammo_value = new_value
