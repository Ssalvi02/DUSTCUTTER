extends Node3D

@export var pickup_name = ""
@export var ammo_value = 0

@export var sprite:Texture = null
@export_enum("consumables", "weapons") var group : String

signal can_pickup(pickup)

var is_in_pickup_area = false

func _ready():
	$Sprite3D.texture = sprite
	add_to_group(group)
	pass

func _on_area_3d_area_entered(area):
	is_in_pickup_area = true
	#Texto para pegar armas / upgrades


func _on_area_3d_area_exited(area):
	is_in_pickup_area = false
	#Remover texto para pegar armas / upgrades

func _process(delta):
	if(is_in_pickup_area):
		can_pickup.emit(self)
	else:
		return
