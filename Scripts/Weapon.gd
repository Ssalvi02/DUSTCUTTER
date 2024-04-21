extends CanvasLayer

var bullet = load("res://Scenes/Bullet.tscn")
var instance

@export_category("Gun Attributes")
@export var bullet_speed : float = 0
@export var max_ammo : int = 0
var current_ammo = max_ammo
@export var reserve_ammo : int = 0
@export var fire_rate : float = 0
@export var spread : bool = false
@export var spread_count : int = 0 
@export var pierce : bool = false
@export var automatic :bool = false
@export_category("Gun UI/Texture")
@export var texture : SpriteFrames = null
@export var cross_texture : Texture = null


@onready var sprite = $GunBase/AnimatedSprite2D
@onready var player = get_parent()

@onready var ui = $AmmoCount

func _ready():
	sprite.sprite_frames = texture
	$Crosshair.texture = cross_texture
	ui = find_child("AmmoCount")
	player.connect("add_ammo", _add_ammo_pickup)
	$GunBase/AnimatedSprite2D.animation_finished.connect(get_parent().shoot_anim_done)
	ui.update_bullet_text()

func _process(delta):
	if player.dead:
		return
	if(Input.is_action_just_pressed("shoot")):
		if current_ammo > 0:
			shoot()
		else:
			reload()
	elif Input.is_action_just_pressed("reload") && current_ammo < max_ammo:
		reload()

func _add_ammo_pickup(amount):
	reserve_ammo += amount
	ui.update_bullet_text()

func shoot():
	if !get_parent().can_shoot:
		return
	get_parent().can_shoot = false
	current_ammo -= 1
	ui.bullet_ui_shoot()
	ui.update_bullet_text()
	sprite.play("shoot")
	if(!spread):
		instantiate_bullet()
	else:
		instantiate_bullet_spread()
		pass

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

func reload():
	if reserve_ammo <= 0:
		return
		
	get_parent().can_shoot = false
	
	var ammo_missing = max_ammo - current_ammo
	
	if reserve_ammo >= ammo_missing:
		reserve_ammo -= ammo_missing
		current_ammo = max_ammo
	else:
		current_ammo += reserve_ammo
		reserve_ammo = 0
	sprite.play("reload")
	ui.bullet_ui_renew()
	ui.update_bullet_text()
	
	return
