extends CharacterBody3D

#Guns
var revolver = load("res://Scenes/Weapons/WeaponRevolver.tscn")
var pistol = load("res://Scenes/Weapons/WeaponPistol.tscn")
var sshotgun = load("res://Scenes/Weapons/WeaponSuperShotgun.tscn")

#Guns Pickups
var revolver_p = load("res://Scenes/WeaponsPickups/PickupRevolver.tscn")
var pistol_p = load("res://Scenes/WeaponsPickups/PickupPistol.tscn")
var sshotgun_p = load("res://Scenes/WeaponsPickups/PickupShotgun.tscn")

signal add_ammo(ammo_amount) 

@onready var raycastgun = $Camera3D/RayCast3D
@onready var ui = $PlayerUI

@export_category("Attributes")
@export var move_speed = 5.0
@export var max_health = 6
@export var current_health = max_health

@onready var weapons = {
	"pistol": pistol,
	"revolver": revolver,
	"supershotgun": sshotgun
}

@onready var guns_pickups = {
	"pistol": pistol_p,
	"revolver": revolver_p,
	"supershotgun": sshotgun_p
}

var gun
var gun_p

@export var current_gun = ""

const MOUSE_SENS = 0.1
const JOY_SENS = 0.05

var can_shoot = true
var dead = false

var pickups

var pickup_throw 
var pickup_cool = 1
var can_pickup_again = true

func _ready():
	get_pickups()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if(dead):
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
		$Camera3D.rotation_degrees.x -= event.relative.y * MOUSE_SENS

func _process(delta):
	$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x, -90, 90)
	if(Input.is_action_just_pressed("exit")):
		get_tree().quit()
	if dead:
		return
	
	joystick_controller_camera()

func get_pickups():
	pickups = get_tree().get_nodes_in_group("pickup")
	
	for i in pickups:
		i.can_pickup.connect(_on_can_pickup)

func lose_heart():
	max_health -= 2
	ui.lose_heart()
	if current_health > max_health:
		current_health = max_health

func take_damage():
	current_health -= 1
	ui.take_damage()

func joystick_controller_camera():
	$Camera3D.rotate_x(Input.get_action_strength("look_up") * JOY_SENS)
	$Camera3D.rotate_x(Input.get_action_strength("look_down") * JOY_SENS * -1)
	rotate_y(Input.get_action_strength("look_left") * JOY_SENS)
	rotate_y(Input.get_action_strength("look_right") * JOY_SENS * -1)
	pass

func _physics_process(delta):
	if dead:
		return
	move()
	check_throw()
	move_and_slide()

func move():
	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

func restart():
	get_tree().reload_current_scene()

func instantiate_gun(gunName):
	current_gun = gunName
	gun = weapons.get(gunName).instantiate()
	add_child(gun)

func check_throw():
	if(Input.is_action_just_pressed("throw")):
		throw_gun()

func throw_gun():
	if gun != null:
		gun.queue_free()
		gun_p = guns_pickups.get(gun.g_name).instantiate()
		gun_p.position = position
		gun_p.can_pickup.connect(_on_can_pickup)
		can_pickup_again = false 
		get_tree().root.get_child(0).add_child(gun_p)
		await get_tree().create_timer(pickup_cool).timeout
		can_pickup_again = true
	else:
		return

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func _on_can_pickup(pickup):
	if (Input.is_action_just_pressed("throw") && can_pickup_again):
		if gun != null:
			gun.queue_free()
		pickup.queue_free()
		instantiate_gun(pickup.pickup_name)
