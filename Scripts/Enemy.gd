extends CharacterBody3D

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D

enum et {
	CLOSE,
	SHOOTING,
	EXPLODING
}

@export var move_speed : int
@export var attack_range : int
@export var sprite_texture : SpriteFrames = null 
@export var enemy_type : et;
@export var stun_time : int = 3

@onready var player : CharacterBody3D = get_tree().root.get_child(0).find_child("Player")
@onready var gc 
@onready var nav = $NavigationAgent3D

var player_in_range = false

var dead :bool = false
var stunned : bool = false
var kicked : bool = false
var firs_col : bool = true

func _ready():
	gc = get_tree().root.get_child(0)
	sprite.sprite_frames = sprite_texture
	sprite.play("walk")
	set_physics_process(false)
	call_deferred("enemy_setup")

func enemy_setup():
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(delta):
	if stunned:
		if kicked && firs_col:
			kill()
			firs_col = false
		return

	if dead:
		$CollisionShape3D.disabled = true
		return
	
	if player == null:
		return
	
	match enemy_type:
		et.CLOSE:
			if !kicked:
				var current_loc = global_transform.origin
				var next_loc = nav.get_next_path_position()
				var new_vel = (next_loc - current_loc).normalized() * move_speed
				nav.set_velocity(new_vel)
		et.SHOOTING:
			pass
		et.EXPLODING:
			pass

func update_target_loc(target_loc):
	nav.set_target_position(target_loc)

func kill():
	$DetectBodies.monitoring = false
	nav.avoidance_enabled = false
	gc.kill_count += 1
	sprite.play("death")
	$CollisionShape3D.call_deferred("set_disabled", true)
	dead = true

func stun():
	if stunned:
		return
	#sprite.play(stunned)
	stunned = true
	await get_tree().create_timer(stun_time).timeout
	if $DetectBodies.get_overlapping_bodies().size() > 0:
		player.kill()
	stunned = false
	

func knockback(dir, force , kick_raycast_pos):
	kicked = true
	velocity = dir * force
	await get_tree().create_timer(0.3).timeout
	stun()
	kicked = false

func knockback_door():
	velocity = Vector3.FORWARD * 20
	await get_tree().create_timer(.5).timeout
	$CollisionShape3D.call_deferred("set_disabled", true)

func _on_detect_bodies_body_entered(body):
	if body.name == "Player" && !stunned or kicked:
		body.kill()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !dead && !stunned:
		velocity = velocity.move_toward(safe_velocity, 0.25)
		move_and_slide()
