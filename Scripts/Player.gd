extends CharacterBody3D

var bullet = load("res://Scenes/bullet.tscn")
var instance

@onready var sprite3d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var raycastgun = $RayCast3D


const SPEED = 5.0
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
		$RayCast3D.rotation_degrees.x -= event.relative.y * MOUSE_SENS
		$Camera3D.rotation_degrees.x -= event.relative.y * MOUSE_SENS
		
func _process(delta):
	if(Input.is_action_just_pressed("exit")):
		get_tree().quit()
	if(Input.is_action_just_pressed("restart")):
		restart()
		
	if dead:
		return
		
	if(Input.is_action_just_pressed("shoot")):
		shoot()
		
func _physics_process(delta):
	if dead:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func restart():
	get_tree().reload_current_scene()
	
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	sprite3d.play("shoot")
	instance = bullet.instantiate()
	instance.position = raycastgun.global_position
	instance.transform.basis = raycastgun.global_transform.basis
	get_parent_node_3d().add_child(instance)
	


func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
