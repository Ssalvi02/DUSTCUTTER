extends Control

var heartscene = load("res://Assets/UI/Health/heart_ui.tscn")
var instance_heart

@onready var player = get_parent()

func _ready():
	init_hearts() 

func _process(delta):
	pass

func init_hearts():
	for i in player.max_health/2:
		var heart = heartscene.instantiate() 
		get_child(0).add_child(heart)

func take_damage():
	var hearts = get_child(0).get_children()
	var i = player.current_health
	if i%2 == 0:
		hearts[i/2].get_child(0).frame = 2
		hearts[i/2].get_child(1).play("shake")
	else:
		hearts[i/2+0.5].get_child(0).frame = 1
		hearts[i/2+0.5].get_child(1).play("shake")

func lose_heart():
	var hearts = get_child(0).get_children()
	hearts.back().queue_free()
