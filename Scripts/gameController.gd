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

func check_gun_priority():
	for i in player.player_area_pickups:
		for j in player.player_area_pickups:
			if i.priority > j.priority:
				j.is_in_pickup_area = false

func recheck_pickup_area():
	for i in player.player_area_pickups:
		i.is_in_pickup_area = true
	check_gun_priority()
