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
	check_player_in_range()
	match enemy_type:
		et.CLOSE:
			if !kicked && player_in_range:
				var direction = Vector3()
				nav.target_position = player.global_position
				direction = (nav.get_next_path_position() - global_position).normalized()
				velocity = direction * move_speed
				move_and_slide()
		et.SHOOTING:
			pass
		et.EXPLODING:
			pass

func check_player_in_range():
	$PlayerRange.target_position = player.global_position-$PlayerRange.global_position
	if self.name == "Enemy2":
		print($PlayerRange.get_collider())
	if $PlayerRange.is_colliding() && $PlayerRange.get_collider().name == "Player":
		player_in_range = true

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
	if ($DetectBodies.monitoring == true &&
	$DetectBodies.get_overlapping_bodies().size() > 0):
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
