extends Node3D

signal change_weapons()

func _on_area_3d_area_entered(area):
	change_weapons.emit()
	#Texto para pegar armas / upgrades
	if Input.is_action_just_pressed("interact"):
		print("BBBBBBB")
