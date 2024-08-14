extends CharacterBody3D

signal add_ammo(ammo_amount) 
signal throw_weapon()

@onready var gc 
@onready var raycastgun = $Camera3D/RayCast3D
@onready var raycastkick = $Camera3D/RayCast3DK
@onready var ui = $PlayerUI
@onready var area = $PickupArea

@export_category("Attributes")
@export var move_speed : float = 5.0
@export var run_speed : float = 8.0
@export var max_health : int = 2
@export var current_health = max_health
@export var KICK_FORCE : int = 20
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var gun

@export var current_gun = ""

const MOUSE_SENS = 0.1
const JOY_SENS = 0.05

var can_shoot = true
var dead = false

var pickup_throw 
var pickup_cool = 1
var can_pickup_again = true

var running = false

var pickup_area_count :int = 0
var player_area_pickups : Array

func _ready():
	gc = get_tree().root.get_child(0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if(dead):
		return

	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
		$Camera3D.rotation_degrees.x -= event.relative.y * MOUSE_SENS

func _process(delta):
	$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x, -90, 90)

	if dead:
		return

	if !is_on_floor():
		velocity.y -= gravity * delta

	joystick_controller_camera()

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
	if Input.is_action_just_pressed("kick"):
		await get_tree().create_timer(0.1).timeout
		if raycastkick.is_colliding():
			var obj = raycastkick.get_collider()
			print(obj)
			if obj.has_method("knockback"):
				obj.knockback(-raycastkick.global_transform.basis.z, KICK_FORCE, raycastkick.get_collision_point())
	move()
	check_throw()
	move_and_slide()

func move():
	if Input.is_action_just_pressed("run"):
		running = !running
	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
			if running:
				velocity.x = direction.x * run_speed
				velocity.z = direction.z * run_speed
			else:
				velocity.x = direction.x * move_speed
				velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = 5
		pass

func instantiate_gun(gunName):
	current_gun = gunName
	gun = gc.weapons.get(gunName).instantiate()
	add_child(gun)

func check_throw():
	if(Input.is_action_just_pressed("throw")):
		throw_gun()

func throw_gun():
	if gun != null:
		throw_weapon.emit()
		can_shoot = true
		gc.recheck_pickup_area()
		gun.queue_free()
	else:
		return

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func _on_can_pickup(pickup):
	if (Input.is_action_just_pressed("throw")):
		if gun != null:
			gun.queue_free()
			return
		pickup_handler(pickup)


func pickup_handler(pickup):
	pickup.reparent(get_tree().root.get_child(0).get_child(0), false)
	pickup.visible = false
	pickup.freeze = true
	pickup.get_child(1).monitorable = false
	pickup.get_child(1).monitoring = false
	pickup.get_child(4).disabled = true
	instantiate_gun(pickup.pickup_name)
	pickup.connect_throw.emit()

func get_gun():
	return gun

func _on_pickup_area_area_entered(area):
	if area.get_parent().is_in_group("pickup"):
		player_area_pickups.append(area.get_parent())

func _on_pickup_area_area_exited(area):
	if area.get_parent().is_in_group("pickup"):
		player_area_pickups.erase(area.get_parent())
