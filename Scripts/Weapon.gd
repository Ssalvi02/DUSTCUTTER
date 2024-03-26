extends CanvasLayer

@export_category("Gun Attributes")
@export var bullet_speed = 40.0
@export var max_ammo = 7
var current_ammo = max_ammo
@export var reserve_ammo = 14
@export var fire_rate:float = 1
@export var spread = false
@export var pierce = false

func _ready():
	var path = get_path()
	print(path)
	pass
