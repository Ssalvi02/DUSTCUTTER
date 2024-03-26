extends CanvasLayer

var bullet = load("res://Scenes/Bullet.tscn")
var instance

@export_category("Gun Attributes")
@export var bullet_speed = 0
@export var max_ammo = 0
var current_ammo = max_ammo
@export var reserve_ammo = 0
@export var fire_rate:float = 0
@export var spread = false
@export var pierce = false

@onready var sprite = $GunBase/AnimatedSprite2D
@onready var ammo_bar = $AmmoCount/TextureProgressBar
@onready var ammo_text = $AmmoCount/Label
@onready var player = get_parent()

func _ready():
	$GunBase/AnimatedSprite2D.animation_finished.connect(get_parent().shoot_anim_done)
	update_bullet_ui()

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

func update_bullet_ui():
	ammo_text.text = "%s/%s" % [current_ammo, reserve_ammo]
	ammo_bar.value = current_ammo

func shoot():
	if !get_parent().can_shoot:
		return
	get_parent().can_shoot = false
	current_ammo -= 1
	update_bullet_ui()
	sprite.play("shoot")
	
	instantiate_bullet()

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
	update_bullet_ui()
	
	return
