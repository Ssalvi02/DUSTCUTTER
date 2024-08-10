extends Control

var bullet_case = load("res://Assets/UI/Bullets/bullet_case.tscn")
var instance_case

var bullet_bg = load("res://Assets/UI/Bullets/bullet_bg.tscn")
var instance_bbg

@onready var bullets_texture = null
@onready var weapon = $".."
@onready var gc

@export var bullet_texture : Texture = null

var bullets_bg = null
var p_current_ammo : int 

# Called when the node enters the scene tree for the first time.
func _ready():
	gc = get_tree().root.get_child(0)
	#find current pickup ammo
	for i in gc.pickups:
		if weapon.g_name == i.pickup_name:
			p_current_ammo = i.ammo_value

	instantiate_bullet_bg()
	bullets_bg = $TextureRect/HBoxContainer.get_children()
	init_bullet_ui()

func bullet_ui_shoot():
	for i in range(p_current_ammo):
		var bullet_case_phys = bullets_bg[i].get_child(1)
		if i == weapon.current_ammo:
			bullet_case_phys.freeze = false
			bullet_case_phys.apply_impulse(Vector2.UP *200, bullet_case_phys.position)
			bullet_case_phys.get_child(2).emitting = true

func bullet_ui_show():
	for i in range(p_current_ammo):
		var bullet_case_phys = bullets_bg[i].get_child(1)
		bullet_case_phys.visible = true
		bullet_case_phys.freeze = true

func bullet_ui_renew():
	for i in range(weapon.current_ammo):
		bullets_bg[i].get_child(1).queue_free()
		var ibc = instantiate_bullet_case()
		bullets_bg[i].add_child(ibc)
		ibc.visible = true
		ibc.freeze = true
	bullet_ui_show()

func init_bullet_ui():
	for i in range(p_current_ammo):
		var ibc = instantiate_bullet_case()
		bullets_bg[i].add_child(ibc)
		ibc.visible = false
		ibc.freeze = true

func instantiate_bullet_bg():
	for i in range(weapon.max_ammo):
		instance_bbg = bullet_bg.instantiate()
		instance_bbg.get_child(0).texture = bullet_texture
		get_child(0).get_child(0).add_child(instance_bbg)

func instantiate_bullet_case():
		var bc = bullet_case.instantiate()
		bc.find_child("Sprite2D").texture = bullet_texture
		return bc
