extends CharacterBody3D

var bullet = load("res://Scenes/bullet.tscn")
var instance

@onready var sprite3d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var raycastgun = $Camera3D/RayCast3D

@export_category("Attributes")
@export var move_speed = 5.0

@export_category("Gun Attributes")
@export var bullet_speed = 40.0
@export var max_ammo = 7
var current_ammo = max_ammo
@export var reserve_ammo = 14
@export var reload_time = 7
@export var fire_rate = 1


const MOUSE_SENS = 0.1

var can_shoot = true
var dead = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sprite3d.animation_finished.connect(shoot_anim_done)
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)
	
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
		sprite3d.speed_scale = fire_rate
		
	if dead:
		return
		
	if(Input.is_action_just_pressed("shoot")):
		if current_ammo > 0:
			shoot()
		else:
			reload()
	elif Input.is_action_just_pressed("reload") && current_ammo < max_ammo:
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
	current_ammo -= 1
	sprite3d.play("shoot")
	instance = bullet.instantiate()
	instance.position = raycastgun.global_position
	instance.transform.basis = raycastgun.global_transform.basis
	get_parent_node_3d().add_child(instance)
	
func reload():
	can_shoot = false
	
	var ammo_missing = max_ammo - current_ammo
	
	if reserve_ammo >= ammo_missing:
		reserve_ammo -= ammo_missing
		current_ammo = max_ammo
	else:
		current_ammo += reserve_ammo
		reserve_ammo = 0
	
	sprite3d.play("reload")
	return

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
