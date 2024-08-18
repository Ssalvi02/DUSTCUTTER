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
@onready var playerui = $Player.ui
@onready var playerui_ec = playerui.find_child("UpperText").find_child("EnemyCount")
@onready var playerui_t = playerui.find_child("UpperText").find_child("Timer")
@onready var level_timer = $Timer

var kill_count = 0
var total_time_in_ms : float = 0

func _ready():
	get_pickups()
	playerui_ec.text = "kill em all " + str(kill_count) + "/" + str(get_enemy_count())

func _process(delta):
	playerui_ec.text = "kill em all " + str(kill_count) + "/" + str(get_enemy_count())
	
	if(kill_count == get_enemy_count()):
		level_timer.stop()
		playerui.find_child("CenterText").find_child("LevelComplete").visible = true
	
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

func get_enemy_count():
	return find_child("Enemies").get_child_count()

func _on_timer_timeout() -> void:
	total_time_in_ms += 0.1
	var mins = int(total_time_in_ms) / 60
	var secs = int(total_time_in_ms) 
	var mili = int((total_time_in_ms - int(total_time_in_ms)) * 100)
	playerui_t.text = str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, secs]) + ":" + str("%0*d" % [2, mili]) 
