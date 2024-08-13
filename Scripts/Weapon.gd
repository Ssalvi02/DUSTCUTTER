extends CanvasLayer

var bullet = load("res://Scenes/Bullet.tscn")
var instance

@export_category("Gun Attributes")
@export var g_name : String = ""
@export var bullet_speed : float = 0
@export var max_ammo : int = 0
var current_ammo = 0
@export var fire_rate : float = 0
@export var spread : bool = false
@export var spread_count : int = 0 
@export var pierce : bool = false
@export var is_thrown : bool = false
@export_category("Gun UI/Sounds")
@export var texture : SpriteFrames = null
@export var cross_texture : Texture = null
@export var pickup_texture : Texture = null
@export var grab_sound : AudioStreamMP3

@onready var sprite = $GunBase/AnimatedSprite2D
@onready var player = get_parent()

@onready var ui = $AmmoCount
@onready var audios = $Audios
@onready var gc

signal update_ammo_value(new_value)

func _ready():
	audios.find_child("Grab").stream = grab_sound
	gc = get_tree().root.get_child(0)

	for i in gc.pickups:
		if g_name == i.pickup_name:
			current_ammo = i.ammo_value

	audios.find_child("Grab").play()
	sprite.sprite_frames = texture
	$Crosshair.texture = cross_texture
	ui = find_child("AmmoCount")
	$GunBase/AnimatedSprite2D.animation_finished.connect(get_parent().shoot_anim_done)
	ui.bullet_ui_show()

func _process(delta):
	if player.dead:
		return
	if(Input.is_action_just_pressed("shoot")):
		if current_ammo > 0:
			shoot()
		else:
			audios.get_child(1).play()

func shoot():
	if !get_parent().can_shoot:
		return
	get_parent().can_shoot = false
	current_ammo -= 1
	update_ammo_value.emit(current_ammo)
	ui.bullet_ui_shoot()
	sprite.play("shoot")
	audios.get_child(0).play()
	if(!spread):
		instantiate_bullet()
	else:
		instantiate_bullet_spread()

func instantiate_bullet_spread():
	var xaxis = Vector3(1,0,0)
	var yaxis = Vector3(0,1,0)
	for n in spread_count:
		var yrot_amount = deg_to_rad(randf_range(-10, 10))
		var xrot_amount = deg_to_rad(randf_range(-10, 10))
		instance = bullet.instantiate()
		instance.position = player.raycastgun.global_position
		instance.transform.basis = player.raycastgun.global_transform.basis.rotated(xaxis, xrot_amount)
		instance.transform.basis = instance.transform.basis.rotated(yaxis, yrot_amount)
		add_child(instance)

func instantiate_bullet():
	instance = bullet.instantiate()
	instance.position = player.raycastgun.global_position
	instance.transform.basis = player.raycastgun.global_transform.basis
	add_child(instance)
