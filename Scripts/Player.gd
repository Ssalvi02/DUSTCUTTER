extends CharacterBody3D

var bullet = load("res://Scenes/bullet.tscn")
var instance

var revolver = load("res://Scenes/Weapons/WeaponRevolver.tscn")

@onready var sprite3d = $Gun/GunBase/AnimatedSprite2D
@onready var raycastgun = $Camera3D/RayCast3D

@export_category("Attributes")
@export var move_speed = 5.0

@onready var gun = $Gun
@onready var ammo_bar = $Gun/AmmoCount/TextureProgressBar
@onready var ammo_text = $Gun/AmmoCount/Label


const MOUSE_SENS = 0.1

var can_shoot = true
var dead = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sprite3d.animation_finished.connect(shoot_anim_done)
	update_bullet_ui()
	
func _input(event):
	if(dead):
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
		$Camera3D.rotation_degrees.x -= event.relative.y * MOUSE_SENS
		
func _process(delta):
	if(Input.is_action_just_pressed("exit")):
		get_tree().quit()
	if(Input.is_action_just_pressed("restart")):
		sprite3d.speed_scale = gun.fire_rate
		
	if dead:
		return
		
	if(Input.is_action_just_pressed("shoot")):
		if gun.current_ammo > 0:
			shoot()
		else:
			reload()
	elif Input.is_action_just_pressed("reload") && gun.current_ammo < gun.max_ammo:
		reload()

func _physics_process(delta):
	if dead:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

func restart():
	get_tree().reload_current_scene()
	
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	gun.current_ammo -= 1
	sprite3d.play("shoot")
	update_bullet_ui()
	
	#INSTANCIA A BALA
	instance = bullet.instantiate()
	instance.position = raycastgun.global_position
	instance.transform.basis = raycastgun.global_transform.basis
	get_parent_node_3d().add_child(instance)
	
func reload():
	if gun.reserve_ammo <= 0:
		return
		
	can_shoot = false
	
	var ammo_missing = gun.max_ammo - gun.current_ammo
	
	if gun.reserve_ammo >= ammo_missing:
		gun.reserve_ammo -= ammo_missing
		gun.current_ammo = gun.max_ammo
	else:
		gun.current_ammo += gun.reserve_ammo
		gun.reserve_ammo = 0
	update_bullet_ui()
	
	sprite3d.play("reload")
	
	return

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func update_bullet_ui():
	ammo_text.text = "%s/%s" % [gun.current_ammo, gun.reserve_ammo]
	ammo_bar.value = gun.current_ammo





func _on_pickup_change_weapons():
	$Gun.queue_free()
	var i = revolver.instantiate()
	add_child(i)
