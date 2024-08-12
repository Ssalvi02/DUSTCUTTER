extends Node3D

#Guns
var revolver = load("res://Scenes/Weapons/WeaponRevolver.tscn")
var pistol = load("res://Scenes/Weapons/WeaponPistol.tscn")
var sshotgun = load("res://Scenes/Weapons/WeaponSuperShotgun.tscn")

@onready var weapons = {
	"pistol": pistol,
	"revolver": revolver,
	"supershotgun": sshotgun
}

#Pickups
var pickups

@onready var player = $Player

func _ready():
	get_pickups()

func _process(delta):
	if(Input.is_action_just_pressed("exit")):
		get_tree().quit()

func get_pickups():
	pickups = get_tree().get_nodes_in_group("pickup")
	for i in pickups:
		i.can_pickup.connect(player._on_can_pickup)

func disable_priority_area():
	for i in pickups:
		match i.priority:
			0:
				i.is_in_pickup_area = false
				return
			1:
				i.is_in_pickup_area = false
				return
			2:
				i.is_in_pickup_area = false
				return
