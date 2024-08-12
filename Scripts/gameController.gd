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

var player_area_pickups : Array

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
		i.player_area_pickup_enter.connect(_add_player_area_list)
		i.player_area_pickup_enter.connect(_remove_player_area_list)

func _add_player_area_list(pickup):
	player_area_pickups.append(pickup)

func _remove_player_area_list(pickup):
	player_area_pickups.erase(pickup)

func disable_priority_area():
	for i in pickups:
		if i.is_in_pickup_area == true:
			i.is_in_pickup_area == false
