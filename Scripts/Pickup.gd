extends Node3D

signal can_pickup(pickup)

var is_in_pickup_area = false

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
